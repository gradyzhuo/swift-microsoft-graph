import Foundation

public struct GraphMailSender: Sendable {
    private let client: GraphClient
    private let senderEmail: String

    public init(client: GraphClient, senderEmail: String) {
        self.client = client
        self.senderEmail = senderEmail
    }

    public func send(_ message: GraphMailMessage) async throws {
        let request = SendMailRequest(from: message)
        try await client.post(path: "/v1.0/users/\(senderEmail)/sendMail", body: request)
    }
}

// MARK: - Encodable request models

private struct SendMailRequest: Encodable, Sendable {
    let message: Message
    let saveToSentItems: Bool = true

    init(from message: GraphMailMessage) {
        self.message = Message(from: message)
    }

    struct Message: Encodable, Sendable {
        let subject: String
        let body: Body
        let toRecipients: [RecipientWrapper]

        init(from message: GraphMailMessage) {
            self.subject = message.subject
            self.body = Body(contentType: "HTML", content: message.htmlBody)
            self.toRecipients = message.to.map { RecipientWrapper(emailAddress: .init($0)) }
        }

        struct Body: Encodable, Sendable {
            let contentType: String
            let content: String
        }

        struct RecipientWrapper: Encodable, Sendable {
            let emailAddress: EmailAddress

            struct EmailAddress: Encodable, Sendable {
                let name: String?
                let address: String

                init(_ recipient: GraphMailMessage.Recipient) {
                    self.name = recipient.name
                    self.address = recipient.address
                }
            }
        }
    }
}
