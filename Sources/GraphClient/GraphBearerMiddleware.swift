import OpenAPIRuntime
import HTTPTypes
import Foundation

/// Injects an `Authorization: Bearer <token>` header into every outgoing request.
public struct GraphBearerMiddleware: ClientMiddleware, Sendable {
    private let getToken: @Sendable () async throws -> String

    public init(getToken: @escaping @Sendable () async throws -> String) {
        self.getToken = getToken
    }

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        let token = try await getToken()
        request.headerFields[.authorization] = "Bearer \(token)"
        return try await next(request, body, baseURL)
    }
}
