public protocol GraphUserTarget: Sendable {
    var apiVersion: GraphAPIVersion { get }
}

extension GraphUserTarget where Self == V1GraphUsersTarget {
    public static var v1: V1GraphUsersTarget { .init() }
}

extension GraphUserTarget where Self == BetaGraphUsersTarget {
    public static var beta: BetaGraphUsersTarget { .init() }
}
