import Foundation

public enum GraphAPIVersion: String, Sendable {
    case v1_0 = "v1.0"
    case beta = "beta"
}

public struct GraphClient: Sendable {
    private static let baseURL = "https://graph.microsoft.com"

    private let tokenProvider: GraphTokenProvider

    public init(credential: GraphCredential) {
        self.tokenProvider = GraphTokenProvider(credential: credential)
    }

    func post(path: String, body: some Encodable & Sendable) async throws {
        let token = try await tokenProvider.accessToken()

        var request = URLRequest(url: URL(string: "\(Self.baseURL)\(path)")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let http = response as? HTTPURLResponse
            let body = String(data: data, encoding: .utf8) ?? ""
            throw GraphError.requestFailed(statusCode: http?.statusCode ?? 0, body: body)
        }
    }

    func get<T: Decodable & Sendable>(path: String) async throws -> T {
        let token = try await tokenProvider.accessToken()
        let url = URL(string: "\(Self.baseURL)\(path)")!
        return try await get(url: url, token: token)
    }

    // nextLink 是完整 URL，不走 baseURL 組合
    func get<T: Decodable & Sendable>(url: URL) async throws -> T {
        let token = try await tokenProvider.accessToken()
        return try await get(url: url, token: token)
    }

    private func get<T: Decodable & Sendable>(url: URL, token: String) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let http = response as? HTTPURLResponse
            let body = String(data: data, encoding: .utf8) ?? ""
            throw GraphError.requestFailed(statusCode: http?.statusCode ?? 0, body: body)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
