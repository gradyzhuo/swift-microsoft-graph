import Foundation

public actor GraphTokenProvider {
    private struct CachedToken {
        let accessToken: String
        let expiresAt: Date

        // 提前 60 秒視為過期，避免邊界競爭
        var isExpired: Bool { Date() >= expiresAt.addingTimeInterval(-60) }
    }

    private let credential: GraphCredential
    private var cachedToken: CachedToken?

    public init(credential: GraphCredential) {
        self.credential = credential
    }

    public func accessToken() async throws -> String {
        if let cached = cachedToken, !cached.isExpired {
            return cached.accessToken
        }
        let token = try await fetchToken()
        cachedToken = token
        return token.accessToken
    }

    private func fetchToken() async throws -> CachedToken {
        let url = URL(string: "https://login.microsoftonline.com/\(credential.tenantId)/oauth2/v2.0/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = [
            "grant_type=client_credentials",
            "client_id=\(credential.clientId)",
            "client_secret=\(credential.clientSecret)",
            "scope=https%3A%2F%2Fgraph.microsoft.com%2F.default",
        ].joined(separator: "&").data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let http = response as? HTTPURLResponse
            let body = String(data: data, encoding: .utf8) ?? ""
            throw GraphError.authenticationFailed(statusCode: http?.statusCode ?? 0, body: body)
        }

        let decoded = try JSONDecoder().decode(TokenResponse.self, from: data)
        return CachedToken(
            accessToken: decoded.access_token,
            expiresAt: Date().addingTimeInterval(TimeInterval(decoded.expires_in))
        )
    }
}

private struct TokenResponse: Decodable {
    let access_token: String
    let expires_in: Int
}
