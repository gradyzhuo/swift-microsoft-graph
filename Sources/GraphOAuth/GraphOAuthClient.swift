import Foundation
import GraphAuth
import GraphClient
import OpenAPIURLSession

public struct GraphOAuthClient: Sendable {
    private let config: GraphOAuthConfig

    public init(config: GraphOAuthConfig) {
        self.config = config
    }

    /// Exchange an authorization code + PKCE verifier for MS tokens (confidential client).
    /// Uses URLSession directly — this calls Azure AD (login.microsoftonline.com),
    /// which is outside the Microsoft Graph OpenAPI spec.
    public func exchangeCodeForToken(
        code: String,
        codeVerifier: String,
        scopes: [String]
    ) async throws -> GraphOAuthTokenResponse {
        let url = URL(string: "https://login.microsoftonline.com/\(config.tenantId)/oauth2/v2.0/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = [
            "grant_type=authorization_code",
            "client_id=\(config.clientId)",
            "client_secret=\(config.clientSecret)",
            "code=\(code)",
            "redirect_uri=\(config.redirectURI)",
            "code_verifier=\(codeVerifier)",
            "scope=\(scopes.joined(separator: " "))",
        ].joined(separator: "&").data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let http = response as? HTTPURLResponse
            let body = String(data: data, encoding: .utf8) ?? ""
            throw GraphError.authenticationFailed(statusCode: http?.statusCode ?? 0, body: body)
        }
        return try JSONDecoder().decode(GraphOAuthTokenResponse.self, from: data)
    }

    /// Fetch the signed-in user's profile from Microsoft Graph using a delegated access token.
    public func me(accessToken: String) async throws -> GraphUserProfile {
        let middleware = GraphBearerMiddleware { accessToken }
        let apiClient = Client(
            serverURL: URL(string: "https://graph.microsoft.com")!,
            transport: URLSessionTransport(),
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
