import GraphClient

public protocol UsersTarget: Sendable {
    var apiVersion: GraphAPIVersion { get }
}

extension UsersTarget where Self == V1UsersTarget {
    public static var v1: V1UsersTarget { .init() }
}

extension UsersTarget where Self == BetaUsersTarget {
    public static var beta: BetaUsersTarget { .init() }
}
