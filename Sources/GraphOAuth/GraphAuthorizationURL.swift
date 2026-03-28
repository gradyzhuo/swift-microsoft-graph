import Foundation

public struct GraphAuthorizationURL: Sendable {

    /// Build a Microsoft identity platform authorization URL for the OAuth 2.0 authorization code + PKCE flow.
    public static func build(
        config: GraphOAuthConfig,
        scopes: [String],
        codeChallenge: String,
        codeChallengeMethod: String = "S256",
        state: String? = nil
    ) -> URL {
        var components = URLComponents(string: "https://login.microsoftonline.com/\(config.tenantId)/oauth2/v2.0/authorize")!
        var items: [URLQueryItem] = [
            .init(name: "client_id", value: config.clientId),
            .init(name: "response_type", value: "code"),
            .init(name: "redirect_uri", value: config.redirectURI),
            .init(name: "scope", value: scopes.joined(separator: " ")),
            .init(name: "code_challenge", value: codeChallenge),
            .init(name: "code_challenge_method", value: codeChallengeMethod),
        ]
        if let state {
            items.append(.init(name: "state", value: state))
        }
        components.queryItems = items
        return components.url!
    }
}
