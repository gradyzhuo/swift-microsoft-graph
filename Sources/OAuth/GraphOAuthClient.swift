import Foundation

public struct GraphOAuthClient: Sendable {
    private static let graphBaseURL = "https://graph.microsoft.com"
    private let config: GraphOAuthConfig

    public init(config: GraphOAuthConfig) {
        self.config = config
    }

    /// Exchange an authorization code + PKCE verifier for MS tokens (confidential client).
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
        let url = URL(string: "\(Self.graphBaseURL)/v1.0/me")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let http = response as? HTTPURLResponse
            let body = String(data: data, encoding: .utf8) ?? ""
            throw GraphError.requestFailed(statusCode: http?.statusCode ?? 0, body: body)
        }
        return try JSONDecoder().decode(GraphUserProfile.self, from: data)
    }
}
