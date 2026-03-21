extension GraphClient {
    public func users<Target: GraphUserTarget>(version: Target) -> GraphUserClient<Target> {
        GraphUserClient(client: self, target: version)
    }
}
