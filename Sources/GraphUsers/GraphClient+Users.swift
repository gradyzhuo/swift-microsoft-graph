import GraphClient

extension GraphClient {
    public func users<Target: UsersTarget>(version: Target) -> UserClient<Target> {
        UserClient(client: self, target: version)
    }
}
