public struct GraphCredential: Sendable {
    public let tenantId: String
    public let clientId: String
    public let clientSecret: String

    public init(tenantId: String, clientId: String, clientSecret: String) {
        self.tenantId = tenantId
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
}
