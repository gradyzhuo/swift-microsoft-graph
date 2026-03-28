public struct GraphMailMessage: Sendable {
    public struct Recipient: Sendable {
        public let name: String?
        public let address: String

        public init(name: String? = nil, address: String) {
            self.name = name
            self.address = address
        }
    }

    public let subject: String
    public let htmlBody: String
    public let textBody: String?
    public let to: [Recipient]

    public init(subject: String, htmlBody: String, textBody: String? = nil, to: [Recipient]) {
        self.subject = subject
        self.htmlBody = htmlBody
        self.textBody = textBody
        self.to = to
    }
}
