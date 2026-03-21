// v1.0 user response model
public struct GraphUser: Sendable, Decodable {
    public let id: String
    public let displayName: String?
    public let mail: String?
    public let userPrincipalName: String
    public let givenName: String?
    public let surname: String?
    public let jobTitle: String?
    public let businessPhones: [String]
    public let mobilePhone: String?
    public let officeLocation: String?
    public let preferredLanguage: String?
}
