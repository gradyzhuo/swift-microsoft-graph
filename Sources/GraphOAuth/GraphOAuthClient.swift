import Foundation
import GraphAuth
import GraphClient
import OpenAPIAsyncHTTPClient

public struct GraphOAuthClient: Sendable {
    private let config: GraphOAuthConfig
    // Shared transport — one HTTPClient/thread-pool for all calls
    private let transport: AsyncHTTPClientTransport
    // Shared client for Azure AD (no per-call middleware needed)
    private let azureClient: Client

    public init(config: GraphOAuthConfig) {
        self.config = config
        self.transport = AsyncHTTPClientTransport()
        self.azureClient = Client(
            serverURL: URL(string: "https://login.microsoftonline.com")!,
            transport: transport
        )
    }

    /// Exchange an authorization code + PKCE verifier for MS tokens (confidential client).
    /// Uses the generated client pointed at https://login.microsoftonline.com —
    /// the Azure AD token endpoint is outside the Microsoft Graph OpenAPI spec.
    public func exchangeCodeForToken(
        code: String,
        codeVerifier: String,
        scopes: [String],
        redirectURI: String? = nil
    ) async throws -> GraphOAuthTokenResponse {
        let response = try await azureClient.exchangeCodeForToken(
            path: .init(tenantId: config.tenantId),
            body: .urlEncodedForm(.init(
                grant_type: "authorization_code",
                client_id: config.clientId,
                client_secret: config.clientSecret,
                code: code,
                redirect_uri: redirectURI ?? config.redirectURI,
                code_verifier: codeVerifier,
                scope: scopes.joined(separator: " ")
            ))
        )
        switch response {
        case .ok(let ok):
            switch ok.body {
            case .json(let t):
                return GraphOAuthTokenResponse(
                    accessToken: t.access_token,
                    tokenType: t.token_type ?? "Bearer",
                    expiresIn: t.expires_in,
                    scope: t.scope ?? "",
                    refreshToken: t.refresh_token
                )
            }
        case .clientError(let statusCode, let err):
            let body: String
            if case .json(let e) = err.body {
                body = e.error_description ?? e.error ?? ""
            } else {
                body = ""
            }
            throw GraphError.authenticationFailed(statusCode: statusCode, body: body)
        case .undocumented(let statusCode, _):
            throw GraphError.authenticationFailed(statusCode: statusCode, body: "")
        }
    }

    /// Fetch the signed-in user's profile from Microsoft Graph using a delegated access token.
    public func me(accessToken: String) async throws -> GraphUserProfile {
        let middleware = GraphBearerMiddleware { accessToken }
        let apiClient = Client(
            serverURL: URL(string: "https://graph.microsoft.com")!,
            transport: transport,
            middlewares: [middleware]
        )
        let response = try await apiClient.me_period_user_period_GetUser()
        switch response {
        case .successful(_, let ok):
            switch ok.body {
            case .json(let profile):
                return try GraphUserProfile(schema: profile)
            }
        case .clientError(let statusCode, _), .serverError(let statusCode, _),
             .undocumented(let statusCode, _):
            throw GraphError.requestFailed(statusCode: statusCode, body: "")
        }
    }
}

private let iso8601Encoder: JSONEncoder = {
    let e = JSONEncoder()
    e.dateEncodingStrategy = .iso8601
    return e
}()

private extension GraphUserProfile {
    init(schema: Components.Schemas.microsoft_period_graph_period_user) throws {
        let data = try iso8601Encoder.encode(schema)
        self = try JSONDecoder().decode(GraphUserProfile.self, from: data)
    }
}
