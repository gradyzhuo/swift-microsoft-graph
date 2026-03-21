# swift-microsoft-graph

A lightweight Swift package for interacting with the [Microsoft Graph API](https://learn.microsoft.com/en-us/graph/overview). Zero external dependencies — built entirely on `URLSession` and Swift concurrency.

## Requirements

- Swift 6.2+
- macOS 14+

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/gradyzhuo/swift-microsoft-graph", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "MicrosoftGraph", package: "swift-microsoft-graph")
        ]
    )
]
```

## Authentication

All APIs require an Azure AD app registration with the **client credentials** (app-only) flow.

```swift
import MicrosoftGraph

let credential = GraphCredential(
    tenantId: "your-tenant-id",
    clientId: "your-client-id",
    clientSecret: "your-client-secret"
)

let client = GraphClient(credential: credential)
```

## Usage

### Send Email

Requires the `Mail.Send` application permission in Azure AD.

```swift
let sender = GraphMailSender(client: client, senderEmail: "sender@contoso.com")

let message = GraphMailMessage(
    subject: "Hello from Swift",
    htmlBody: "<p>Hello, world!</p>",
    to: [
        .init(name: "Jane Doe", address: "jane@contoso.com")
    ]
)

try await sender.send(message)
```

### List Users (v1.0)

Requires the `User.Read.All` application permission.

```swift
let users: [GraphUser] = try await client.users(version: .v1).allUsers()

for user in users {
    print(user.displayName ?? "", user.mail ?? "")
}
```

### List Users (Beta)

```swift
let users: [GraphBetaUser] = try await client.users(version: .beta).allUsers()
```

The beta response includes 98+ fields such as on-premises AD sync data, license assignments, provisioned plans, and extended identity attributes.

Pagination is handled automatically — both `allUsers()` variants return the complete result set regardless of directory size.

## License

MIT — see [LICENSE](LICENSE).
