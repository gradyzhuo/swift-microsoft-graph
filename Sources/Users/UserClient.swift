import Foundation

public struct UserClient<Target: UsersTarget>: Sendable {
    private let client: GraphClient
    public let target: Target

    init(client: GraphClient, target: Target) {
        self.client = client
        self.target = target
    }
}

// MARK: - v1.0

extension UserClient where Target == V1UsersTarget {
    public func allUsers() async throws -> [User] {
        let select = "id,displayName,mail,userPrincipalName,givenName,surname,jobTitle,businessPhones,mobilePhone,officeLocation,preferredLanguage"
        return try await fetchAll(path: "/users?$select=\(select)", version: target.apiVersion)
    }
}

// MARK: - beta

extension UserClient where Target == BetaUsersTarget {
    public func allUsers() async throws -> [User.Beta] {
        return try await fetchAll(path: "/users", version: target.apiVersion)
    }
}

// MARK: - Pagination helper

private extension UserClient {
    func fetchAll<T: Decodable & Sendable>(path: String, version: GraphAPIVersion) async throws -> [T] {
        var results: [T] = []

        let firstPage: PagedResponse<T> = try await client.get(path: "/\(version.rawValue)\(path)")
        results.append(contentsOf: firstPage.value)

        var nextLink = firstPage.nextLink.flatMap { URL(string: $0) }
        while let url = nextLink {
            let page: PagedResponse<T> = try await client.get(url: url)
            results.append(contentsOf: page.value)
            nextLink = page.nextLink.flatMap { URL(string: $0) }
        }

        return results
    }
}

// MARK: - Paged response wrapper

private struct PagedResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let value: [T]
    let nextLink: String?

    enum CodingKeys: String, CodingKey {
        case value
        case nextLink = "@odata.nextLink"
    }
}
