import Foundation
import GraphAuth
import GraphClient
import OpenAPIAsyncHTTPClient

public struct GraphMailSender: Sendable {
    private let apiClient: Client
    private let senderEmail: String

    public init(client: GraphClient, senderEmail: String) {
        self.apiClient = Client(
            serverURL: URL(string: "https://graph.microsoft.com")!,
            transport: AsyncHTTPClientTransport(),
            middlewares: [client.makeBearerMiddleware()]
        )
        self.senderEmail = senderEmail
    }

    public func send(_ message: GraphMailMessage) async throws {
        let payload = Operations.users_period_user_period_sendMail.Input.Body.jsonPayload(
            Message: .init(
                subject: message.subject,
                body: .init(content: message.htmlBody, contentType: .html),
                toRecipients: message.to.map {
                    .init(emailAddress: .init(address: $0.address, name: $0.name))
                }
            ),
            SaveToSentItems: true
        )
        let response = try await apiClient.users_period_user_period_sendMail(
            path: .init(user_hyphen_id: senderEmail),
            body: .json(payload)
        )
        switch response {
        case .undocumented(let statusCode, _) where (200..<300).contains(statusCode):
            // Graph sendMail returns 202 Accepted on success (per Microsoft's
            // documentation), but the bundled OpenAPI spec only declares 204,
            // so 202 surfaces as .undocumented. Treat any 2xx as success —
            // otherwise every real successful send is misreported as a failure
            // and callers retry with duplicate mail.
            return
        case .noContent:
            return
        case .clientError(let statusCode, _), .serverError(let statusCode, _),
             .undocumented(let statusCode, _):
            throw GraphError.requestFailed(statusCode: statusCode, body: "")
        }
    }
}
