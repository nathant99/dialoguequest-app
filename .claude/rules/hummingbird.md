---
paths:
  - "**/Server/**/*.swift"
  - "**/Sources/Server/**/*.swift"
---

# Hummingbird 2 Patterns

Conventions for Hummingbird 2 servers (ForgeSync, future `forgeplay`, and any per-app servers). Learned in the multi-tenant spike (2026-05-18). All version-stamped against Hummingbird 2.14 + hummingbird-websocket 2.x + ForgeKit 0.84.

## Routing

1. **Path parameters match a whole segment** — `router.get("/tenant-:tenantID/health")` does **NOT** match `/tenant-a/health` because `:tenantID` must occupy an entire segment, not a fragment after a literal prefix. For tenant URL shapes like `/tenant-<id>/...`, register each tenant via `router.group("/tenant-<id>")` in a loop instead of using a path parameter.
2. **`Router.group(...)` is the idiomatic prefix grouping** — subtree of routes sharing a literal prefix. Use it for per-tenant route mounting and for `/v1/...` API versioning.
3. **Routes need a literal terminal path** — `router.get("/health")`, not `router.get("")`. Empty paths on groups can be ambiguous; always supply a path.

## Request Context

4. **Use `context.logger` to mutate request logger metadata** — the `coreContext.logger` storage is `@usableFromInline`/internal and not directly settable. The public seam is `RequestContext.logger` (from a protocol extension): `context.logger[metadataKey: "tenant"] = .string(id)`. Reading is the same.
5. **One context, multiple capabilities** — a custom `RequestContext` can conform to both `RequestContext` and `WebSocketRequestContext` simultaneously by adding `let webSocket: WebSocketHandlerReference<Self>`. This lets one router host HTTP and WebSocket routes with a single middleware chain.
6. **Mutate context via `var context = context`** — `RequestContext` is passed by value into middleware. Copy locally, mutate, then forward to `next(request, context)`.
7. **`ApplicationRequestContextSource` needs a real Channel** — unit-testing middleware that constructs its own context is awkward because `ApplicationRequestContextSource.init(channel:logger:)` wants a NIO `Channel`. Test middleware via the router using `app.test(.router) { client in ... }` instead — the router framework constructs the context for you.

## Middleware

8. **`RouterMiddleware` requires a concrete `Context` typealias** — `struct Middleware<Context: RequestContext>: RouterMiddleware where Context == MyContext` raises "same-type requirement makes generic parameter non-generic". Drop the generic and use `typealias Context = MyContext` inside the struct.
9. **`add(middleware:)` order matters** — middlewares run top-down on the way in and bottom-up on the way out (Hummingbird wraps them in declaration order). Put `LogRequestsMiddleware` AFTER tenant-resolving middleware so the request log line inherits the tenant tag.
10. **Tag the request logger as early as possible** — once `context.logger[metadataKey: "tenant"]` is set, Hummingbird's built-in request log line plus every handler log line inherits the tag. Centralizing this in one middleware is cheaper and more reliable than per-handler logging.

## Response Encoding

11. **`String` route handlers return `text/plain`, NOT JSON** — a handler `-> String` writes the bytes as-is. If you want JSON-quoted output, wrap the value in a `Codable` struct conforming to `ResponseEncodable`. Tests should assert raw body string, not JSON-encoded.
12. **Custom DTOs conform to `ResponseEncodable`** — `extension MyDTO: ResponseEncodable {}` is enough when the DTO is `Codable`. The default response encoder is JSON.
13. **`HTTPResponseError` for handler errors** — conform error types to `HTTPResponseError` (Hummingbird) and Hummingbird's responder pipeline maps them to HTTP responses cleanly. Define `status` and `response(from:context:)` (or use the default response generator).

## WebSocket

14. **One router can host HTTP + WS routes** when the context conforms to `WebSocketRequestContext`. Wire it with `server: .http1WebSocketUpgrade(webSocketRouter: router)` — the same router fills both responder slots.
15. **`.ws(path:onUpgrade:)`** is the route DSL: `router.ws("/ws") { inbound, outbound, context in ... }`. The handler closure receives `(WebSocketInboundMessages, WebSocketOutboundWriter, WebSocketRouterContext<Context>)`.
16. **`context.requestContext.tenantID`** inside the WS handler — the WS handler sees a `WebSocketRouterContext<TenantRequestContext>` wrapper; the original `TenantRequestContext` is at `.requestContext`. Never trust client-supplied tenant identifiers inside WS messages — derive from the resolved context.
17. **Per-connection cleanup with `defer { Task { await ... } }`** — WebSocket handlers are async functions; cleanup goes in a `defer` block, but if the cleanup is async, dispatch via `Task {}`. Don't use unstructured `Task` for hot-path work — only for fire-and-forget cleanup.

## Application Lifecycle

18. **`Application(router:server:configuration:logger:)`** — pass an explicit logger for consistent labeling across processes. Don't rely on the default label.
19. **Use `runService()` from an `AsyncParsableCommand.run`** — `try await app.runService()` blocks until graceful shutdown. Combine with `ArgumentParser` for CLI flags (hostname, port, tenant list).
20. **`ServiceLifecycle` is implicit** in `runService()` — Hummingbird handles SIGTERM/SIGINT, drains connections, and shuts down cleanly. Don't manually wrap with a `ServiceGroup` unless you need to compose multiple services.

## Testing

21. **`.router` framework for fast unit-style tests** — `app.test(.router) { client in ... }` skips network I/O. Best for HTTP route logic, middleware behavior, response shape assertions.
22. **`.live` framework for WebSocket tests** — `app.test(.live) { client in try await client.ws("/path") { inbound, outbound, ctx in ... } }` requires a live server on a free port. `HummingbirdWSTesting` provides the `client.ws(...)` extension.
23. **HummingbirdTesting client.execute pattern** — pass a `testCallback: (TestResponse) async throws -> Return` to make assertions inside the callback closure. Return any value you need to thread out (e.g., extracted IDs from JSON bodies).
24. **Body decode in tests** — `JSONDecoder().decode(MyDTO.self, from: response.body)` works directly on `ByteBuffer` because `ByteBuffer` is `DataProtocol`-compatible.

## ForgeKit Server Actor Integration

25. **`RoomRegistry<Room>`** (`ForgeServerActors`) — actor; all access is `await`. Construct fresh per tenant/per logical scope. No shared state between instances.
26. **`WebSocketRateLimiter`** (`ForgeServerActors`) — actor; sliding-window limiter. Default 60 req/60s but spike configures 5/1s for fast saturation in tests. Reset via `reset(clientID)` on disconnect.
27. **`ForgeRoom` protocol** — minimum requirement is `nonisolated var code: String { get }`. Implement with any value or reference type that's `Sendable`.

## Anti-Patterns

- **Don't use `:param` in a literal-prefix segment** — see rule 1.
- **Don't access `coreContext.logger` directly** — see rule 4.
- **Don't construct test contexts manually** — see rule 7.
- **Don't trust client-supplied tenant identifiers** — see rule 16. Always derive tenant from the URL prefix (middleware-resolved) or from JWT claims (server-validated).
- **Don't `fatalError` in tenant-supplied handlers** — `fatalError` kills the whole process. Use `throw` with `HTTPResponseError` instead. This is the load-bearing property that lets one Hummingbird process host many tenants.
<!-- END LABSMITH-SYNCED CONTENT -->
