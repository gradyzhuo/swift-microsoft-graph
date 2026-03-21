public enum GraphError: Error, Sendable {
    case authenticationFailed(statusCode: Int, body: String)
    case requestFailed(statusCode: Int, body: String)
}
