import Foundation
import GraphAuth

public enum GraphAPIVersion: String, Sendable {
    case v1_0 = "v1.0"
    case beta = "beta"

    public static let latest: GraphAPIVersion = .v1_0
}

/// Shared credential container. Each API module creates its own OpenAPI `Client`
/// using the bearer middleware produced by `makeBearerMiddleware()`.
public struct GraphClient: Sendable {
    private let tokenProvider: GraphTokenProvider

    public init(credential: GraphCredential) {
        self.tokenProvider = GraphTokenProvider(credential: credential)
    }

    /// Returns a middleware that injects the app-credential Bearer token.
    public func makeBearerMiddleware() -> GraphBearerMiddleware {
        GraphBearerMiddleware { try await tokenProvider.accessToken() }
    }
}
