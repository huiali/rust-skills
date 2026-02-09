---
name: rust-observability
description: Rust observability skill for logging, tracing, metrics, OpenTelemetry, structured events, and production diagnostics. Use when instrumenting Rust services with tracing spans, correlation IDs, Prometheus metrics, alerting signals, or debugging latency/error hotspots.
---

# Rust Observability Skill

Use this skill to make Rust systems diagnosable in production.

## Workflow

1. Define signals: logs, traces, metrics, and service-level objectives.
2. Instrument critical paths first: request entry, DB calls, external RPC, queue boundaries.
3. Add correlation context (request ID, tenant, user-safe identifiers).
4. Export telemetry to your backend (Prometheus/OTLP/etc.).
5. Validate dashboards and alert thresholds against failure modes.

## Instrumentation Patterns

### Tracing

- Use `tracing` spans around I/O and business-critical operations.
- Attach semantic fields (`status`, `latency_ms`, `db.statement.name`).
- Propagate trace context across async/task boundaries.

### Logging

- Prefer structured logs over free-form strings.
- Separate user-safe context from sensitive data.
- Keep log levels intentional (`error`, `warn`, `info`, `debug`, `trace`).

### Metrics

- Track RED signals: rate, errors, duration.
- Add saturation metrics for pools, queues, and executors.
- Keep metric cardinality bounded.

## Suggested crates

- `tracing`, `tracing-subscriber`
- `metrics` or `prometheus`
- `opentelemetry`, `tracing-opentelemetry`

## Guardrails

- Do not log secrets or tokens.
- Do not use high-cardinality labels (e.g., raw user IDs) in metrics.
- Do not instrument everything first; instrument bottlenecks first.
