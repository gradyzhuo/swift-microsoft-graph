public struct GraphUserProfile: Decodable, Sendable {
    public let id: String
    public let displayName: String?
    public let mail: String?
    public let userPrincipalName: String

    /// The best available email: prefers `mail`, falls back to `userPrincipalName`.
    public var email: String { mail ?? userPrincipalName }
}
