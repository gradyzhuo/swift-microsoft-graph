# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```bash
# Build
swift build

# Run all tests
swift test

# Run a single test
swift test --filter GraphMailSenderTests

# Build in release mode
swift build -c release
```

## Project Overview

A Swift package (`MicrosoftGraph`) providing a client for the Microsoft Graph API. It targets macOS 14+, requires Swift 6.2, and has zero external dependencies — all HTTP is done via `URLSession`.

## Architecture

### Module Layout

```
Sources/
├── Auth/    — OAuth2 token acquisition and caching
├── Client/  — Core HTTP client and shared error types
├── Mail/    — Send email via Graph API
└── Users/   — List/query users from directory
```

### Auth Layer

- `GraphCredential` — value type holding `tenantId`, `clientId`, `clientSecret`
- `GraphTokenProvider` — `actor` that fetches and caches OAuth2 bearer tokens using the Azure client-credentials flow; tokens are considered expired 60 seconds early to avoid boundary-condition failures

### Core Client

- `GraphClient` — `Sendable` struct; wraps `URLSession` with automatic Bearer-token injection
- `GraphAPIVersion` — `.v1` / `.beta` enum used throughout
- `GraphError` — `.authenticationFailed(statusCode, body)` / `.requestFailed(statusCode, body)`

### Protocol-Based API Versioning (Users module)

The Users module uses a protocol + generic client to select the API version at compile time:

```swift
// GraphUserTarget protocol — implemented by V1GraphUsersTarget and BetaGraphUsersTarget
let client = GraphClient(credential: cred)
let users: [GraphUser]     = try await client.users(version: .v1).allUsers()
let beta:  [GraphBetaUser] = try await client.users(version: .beta).allUsers()
```

`GraphUserClient<Target: GraphUserTarget>` uses conditional extensions (`where Target == V1…`) to return different model types depending on the version.

### Pagination

`GraphClient` and `GraphUserClient` handle OData `@odata.nextLink` pagination internally via `fetchAll<T>()` — callers receive a complete array without manual paging.

### Tests

Tests use Swift's native `Testing` framework (`@Suite`, `#expect`), not XCTest. Integration tests require real M365 credentials; they can be supplied via environment variables (`tenantId`, `clientId`, `clientSecret`).
