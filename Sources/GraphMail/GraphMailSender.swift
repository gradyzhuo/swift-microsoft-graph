import Foundation
import GraphAuth
import GraphClient
import OpenAPIURLSession

public struct GraphMailSender: Sendable {
    private let apiClient: Client
    private let senderEmail: String

    public init(client: GraphClient, senderEmail: String) {
        self.apiClient = Client(
            serverURL: URL(string: "https://graph.microsoft.com")!,
            transport: URLSessionTransport(),
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
        case .noContent:
            return
        case .clientError(let statusCode, _), .serverError(let statusCode, _),
             .undocumented(let statusCode, _):
            throw GraphError.requestFailed(statusCode: statusCode, body: "")
        }
    }
}
