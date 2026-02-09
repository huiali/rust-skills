---
name: rust-type-driven
description: 'Type-driven design expert covering newtype pattern, type state, PhantomData,
  marker traits,

  builder pattern, compile-time validation, sealed traits, and zero-sized types (ZST).

  '
metadata:
  triggers:
  - type-driven
  - newtype
  - type state
  - PhantomData
  - marker trait
  - builder pattern
  - compile-time validation
  - sealed trait
  - ZST
  - zero-sized type
---

# Type-Driven Design Expert

## Core Question

**How can you make the compiler catch more errors at compile time?**

Good type design means fewer runtime errors.

---

## Solution Patterns

### Pattern 1: Newtype Pattern

```rust
// ❌ Primitive types can be confused
fn process_user(id: u64) { ... }
fn process_order(id: u64) { ... }

// Easy to mix up:
process_order(user_id);  // Compiles but wrong!

// ✅ Type-safe newtypes
struct UserId(u64);
struct OrderId(u64);

fn process_user(id: UserId) { ... }
fn process_order(id: OrderId) { ... }

// Compiler prevents:
// process_order(user_id);  // Compile error!
```

**When to use:**
- Domain-specific identifiers
- Values with different semantics but same representation
- Adding type-level validation

### Pattern 2: Type State Pattern

```rust
// Encode states in types
struct Disconnected;
struct Connecting;
struct Connected;

struct Connection<State = Disconnected> {
    socket: TcpSocket,
    _state: PhantomData<State>,
}

impl Connection<Disconnected> {
    pub fn new() -> Self {
        Connection {
            socket: TcpSocket::new(),
            _state: PhantomData,
        }
    }

    pub fn connect(self) -> Connection<Connecting> {
        // Start connection...
        Connection {
            socket: self.socket,
            _state: PhantomData,
        }
    }
}

impl Connection<Connecting> {
    pub fn finish(self) -> Result<Connection<Connected>, Error> {
        // Complete connection...
        Ok(Connection {
            socket: self.socket,
            _state: PhantomData,
        })
    }
}

impl Connection<Connected> {
    pub fn send(&mut self, data: &[u8]) -> Result<(), Error> {
        // Only Connected state can send
        self.socket.write(data)
    }
}

// Type state prevents invalid operations:
let conn = Connection::new();
// conn.send(data);  // Compile error! Not connected yet
let conn = conn.connect();
let mut conn = conn.finish()?;
conn.send(data)?;  // OK!
```

### Pattern 3: PhantomData for Ownership

```rust
use std::marker::PhantomData;

// PhantomData marks ownership and variance
struct MyIterator<'a, T> {
    ptr: *const T,
    end: *const T,
    _marker: PhantomData<&'a T>,  // Tells compiler: we borrow T
}

// Without PhantomData, compiler doesn't know about the 'a lifetime
```

### Pattern 4: Builder Pattern with Type State

```rust
// Type-safe builder that enforces required fields
struct HostSet;
struct HostUnset;
struct PortSet;
struct PortUnset;

struct ConfigBuilder<H, P> {
    host: Option<String>,
    port: Option<u16>,
    _host: PhantomData<H>,
    _port: PhantomData<P>,
}

impl ConfigBuilder<HostUnset, PortUnset> {
    pub fn new() -> Self {
        ConfigBuilder {
            host: None,
            port: None,
            _host: PhantomData,
            _port: PhantomData,
        }
    }
}

impl<P> ConfigBuilder<HostUnset, P> {
    pub fn host(self, host: impl Into<String>) -> ConfigBuilder<HostSet, P> {
        ConfigBuilder {
            host: Some(host.into()),
            port: self.port,
            _host: PhantomData,
            _port: PhantomData,
        }
    }
}

impl<H> ConfigBuilder<H, PortUnset> {
    pub fn port(self, port: u16) -> ConfigBuilder<H, PortSet> {
        ConfigBuilder {
            host: self.host,
            port: Some(port),
            _host: PhantomData,
            _port: PhantomData,
        }
    }
}

// Only works when both required fields are set
impl ConfigBuilder<HostSet, PortSet> {
    pub fn build(self) -> Config {
        Config {
            host: self.host.unwrap(),
            port: self.port.unwrap(),
        }
    }
}

// Usage:
let config = ConfigBuilder::new()
    .host("localhost")
    .port(8080)
    .build();  // OK

// Won't compile without required fields:
// ConfigBuilder::new().build();  // Error!
```

---

## Making Invalid States Unrepresentable

```rust
// ❌ Easy to create invalid state
struct User {
    name: String,
    email: Option<String>,  // Might be empty
    age: u32,
}

// ✅ Email cannot be invalid
struct User {
    name: String,
    email: Email,  // Type guarantees validity
    age: u32,
}

struct Email(String);

impl Email {
    pub fn new(s: impl Into<String>) -> Result<Self, EmailError> {
        let s = s.into();
        if s.contains('@') && s.len() > 3 {
            Ok(Email(s))
        } else {
            Err(EmailError::Invalid)
        }
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}
```

---

## Marker Traits

```rust
// Use marker traits to signal capabilities
trait Sendable: Send + 'static {}

// Sealed trait pattern (prevent external implementation)
mod sealed {
    pub trait Sealed {}
}

pub trait MyTrait: sealed::Sealed {
    fn method(&self);
}

// Only types we define can implement MyTrait
struct MyType;
impl sealed::Sealed for MyType {}
impl MyTrait for MyType {
    fn method(&self) { ... }
}
```

---

## Zero-Sized Types (ZST)

```rust
// Use ZST for compile-time markers (no runtime cost)
struct DebugOnly;
struct Always;

struct Logger<Mode = Always> {
    _marker: PhantomData<Mode>,
}

impl Logger<DebugOnly> {
    pub fn log(&self, msg: &str) {
        #[cfg(debug_assertions)]
        println!("[DEBUG] {}", msg);
    }
}

impl Logger<Always> {
    pub fn log(&self, msg: &str) {
        println!("[LOG] {}", msg);
    }
}

// ZST has zero runtime cost:
assert_eq!(std::mem::size_of::<Logger<DebugOnly>>(), 0);
```

---

## Workflow

### Step 1: Identify Domain Invariants

```
What can go wrong?
  → IDs mixed up? Use newtype
  → Invalid state transitions? Use type state
  → Optional fields always present? Remove Option
  → Values need validation? Validate in constructor
```

### Step 2: Choose Type Pattern

```
Need to:
  → Prevent ID confusion? Newtype pattern
  → Encode state machine? Type state pattern
  → Enforce required fields? Builder with type state
  → Mark variance/ownership? PhantomData
  → Zero-cost abstraction? ZST
```

### Step 3: Validate at Construction

```rust
// ✅ Validation at construction
impl Email {
    pub fn new(s: &str) -> Result<Self, Error> {
        validate(s)?;  // Validate once
        Ok(Email(s.to_string()))
    }
}

// Now Email is always valid
fn send_email(to: Email) {
    // No need to re-validate
}
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| `is_valid` flag | Runtime checking | Use type states |
| Many `Option`s | Nullable everywhere | Redesign types |
| Primitive types everywhere | Type confusion | Newtype pattern |
| Runtime validation | Late error discovery | Constructor validation |
| Boolean parameters | Unclear meaning | Use enum or builder |

---

## Validation Timing

| Validation Type | Best Time | Example |
|-----------------|-----------|---------|
| Range validation | Construction | `Email::new()` returns `Result` |
| State transitions | Type boundaries | `Connection<Connected>` |
| Reference validity | Lifetimes | `&'a T` |
| Thread safety | `Send + Sync` | Compiler checks |

---

## Review Checklist

When reviewing type design:

- [ ] Invalid states are unrepresentable
- [ ] Newtypes used for domain concepts
- [ ] Validation happens at construction
- [ ] Type states prevent invalid operations
- [ ] No boolean blindness (use enums)
- [ ] PhantomData correctly marks ownership
- [ ] Builder enforces required fields
- [ ] Marker traits document capabilities
- [ ] ZSTs used for zero-cost abstractions

---

## Verification Commands

```bash
# Check type sizes
cargo build --release
nm target/release/myapp | grep MyType

# Ensure ZST optimization
objdump -d target/release/myapp | grep -A 10 my_function

# Test type-level guarantees
cargo test --lib
```

---

## Common Pitfalls

### 1. Boolean Blindness

**Symptom**: Unclear what true/false means

```rust
// ❌ Bad: what does true mean?
fn connect(hostname: &str, secure: bool) { ... }

// ✅ Good: explicit type
enum ConnectionMode {
    Secure,
    Insecure,
}

fn connect(hostname: &str, mode: ConnectionMode) { ... }
```

### 2. Optional Fields That Shouldn't Be

**Symptom**: Lots of `Option` everywhere

```rust
// ❌ Bad: user email should always exist
struct User {
    name: String,
    email: Option<String>,
}

// ✅ Good: validate at construction
struct User {
    name: String,
    email: Email,  // Always valid
}
```

### 3. Missing Newtype

**Symptom**: Mixing up IDs

```rust
// ❌ Bad: easy to confuse
fn transfer_money(from: u64, to: u64, amount: u64) { ... }

// transfer_money(amount, to, from);  // Oops!

// ✅ Good: type safety
fn transfer_money(from: AccountId, to: AccountId, amount: Money) { ... }
```

---

## Related Skills

- **rust-ownership** - Lifetime and borrowing fundamentals
- **rust-trait** - Advanced trait patterns
- **rust-pattern** - Design pattern implementations
- **rust-zero-cost** - Zero-cost abstractions
- **rust-linear-type** - Linear types and session types

---

## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
