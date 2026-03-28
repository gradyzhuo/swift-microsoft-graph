public struct GraphOAuthConfig: Sendable {
    public let tenantId: String
    public let clientId: String
    public let clientSecret: String
    public let redirectURI: String

    public init(tenantId: String, clientId: String, clientSecret: String, redirectURI: String) {
        self.tenantId = tenantId
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectURI = redirectURI
    }
}
