import Foundation
import OpenAPIAsyncHTTPClient

public actor GraphTokenProvider {
    private struct CachedToken {
        let accessToken: String
        let expiresAt: Date

        // 提前 60 秒視為過期，避免邊界競爭
        var isExpired: Bool { Date() >= expiresAt.addingTimeInterval(-60) }
    }

    private let credential: GraphCredential
    private var cachedToken: CachedToken?
    private let apiClient: Client

    public init(credential: GraphCredential) {
        self.credential = credential
        self.apiClient = Client(
            serverURL: URL(string: "https://login.microsoftonline.com")!,
            transport: AsyncHTTPClientTransport()
        )
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
        let response = try await apiClient.acquireToken(
            path: .init(tenantId: credential.tenantId),
            body: .urlEncodedForm(.init(
                grant_type: "client_credentials",
                client_id: credential.clientId,
                client_secret: credential.clientSecret,
                scope: "https://graph.microsoft.com/.default"
            ))
        )
        switch response {
        case .ok(let ok):
            switch ok.body {
            case .json(let token):
                return CachedToken(
                    accessToken: token.access_token,
                    expiresAt: Date().addingTimeInterval(TimeInterval(token.expires_in))
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
}
