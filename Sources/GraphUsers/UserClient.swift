import Foundation
import GraphAuth
import GraphClient
import OpenAPIAsyncHTTPClient

public struct UserClient<Target: UsersTarget>: Sendable {
    private let apiClient: Client
    public let target: Target

    init(client: GraphClient, target: Target) {
        self.apiClient = Client(
            serverURL: URL(string: "https://graph.microsoft.com")!,
            transport: AsyncHTTPClientTransport(),
            middlewares: [client.makeBearerMiddleware()]
        )
        self.target = target
    }
}

// MARK: - v1.0

extension UserClient where Target == V1UsersTarget {
    public func allUsers() async throws -> [User] {
        let select = ["id", "displayName", "mail", "userPrincipalName", "givenName",
                      "surname", "jobTitle", "businessPhones", "mobilePhone",
                      "officeLocation", "preferredLanguage"]
        var results: [User] = []
        var skiptoken: String? = nil
        repeat {
            let response = try await apiClient.users_period_user_period_ListUser(
                query: .init(_dollar_select: select, _dollar_skiptoken: skiptoken)
            )
            guard case .successful(_, let ok) = response,
                  case .json(let page) = ok.body else {
                throw GraphError.requestFailed(statusCode: 0, body: "unexpected response")
            }
            results += try (page.value ?? []).map { try User(schema: $0) }
            skiptoken = extractSkiptoken(from: page._commat_odata_period_nextLink)
        } while skiptoken != nil
        return results
    }
}

// MARK: - beta

extension UserClient where Target == BetaUsersTarget {
    public func allUsers() async throws -> [User.Beta] {
        var results: [User.Beta] = []
        var skiptoken: String? = nil
        repeat {
            let response = try await apiClient.users_period_user_period_ListUserBeta(
                query: .init(_dollar_skiptoken: skiptoken)
            )
            guard case .successful(_, let ok) = response,
                  case .json(let page) = ok.body else {
                throw GraphError.requestFailed(statusCode: 0, body: "unexpected response")
            }
            results += try (page.value ?? []).map { try User.Beta(schema: $0) }
            skiptoken = extractSkiptoken(from: page._commat_odata_period_nextLink)
        } while skiptoken != nil
        return results
    }
}

// MARK: - Pagination helper

private func extractSkiptoken(from nextLink: String?) -> String? {
    guard
        let nextLink,
        let url = URL(string: nextLink),
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
        let item = components.queryItems?.first(where: { $0.name == "$skiptoken" })
    else { return nil }
    return item.value
}

// MARK: - Model mapping (JSON round-trip keeps field names in sync with the spec)

private let iso8601Encoder: JSONEncoder = {
    let e = JSONEncoder()
    e.dateEncodingStrategy = .iso8601
    return e
}()

private let iso8601Decoder: JSONDecoder = {
    let d = JSONDecoder()
    d.dateDecodingStrategy = .iso8601
    return d
}()

private extension User {
    init(schema: Components.Schemas.microsoft_period_graph_period_user) throws {
        let data = try iso8601Encoder.encode(schema)
        self = try iso8601Decoder.decode(User.self, from: data)
    }
}

private extension User.Beta {
    init(schema: Components.Schemas.microsoft_period_graph_period_betaUser) throws {
        let data = try iso8601Encoder.encode(schema)
        self = try iso8601Decoder.decode(User.Beta.self, from: data)
    }
}
