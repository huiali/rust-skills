---
name: rust-macro
description: |
  Macro and procedural metaprogramming expert covering macro_rules!, derive macros,
  proc-macros, compile-time computation, and code generation patterns.
triggers:
  - macro
  - derive
  - proc-macro
  - macro_rules
  - metaprogramming
  - code generation
  - compile-time
---

# Macro and Procedural Metaprogramming Expert

## Core Question

**How do you reduce code duplication? When to use macros vs generics?**

Macros are compile-time code generation, generics are runtime polymorphism.

---

## Macros vs Generics

| Dimension | Macros | Generics |
|-----------|--------|----------|
| Flexibility | Code transformation | Type abstraction |
| Compile cost | Incremental-friendly | Monomorphization overhead |
| Error messages | Can be cryptic | Clear |
| Debugging | Debug expanded code | Direct debugging |
| Use case | Reduce boilerplate | Generic algorithms |

---

## Solution Patterns

### Pattern 1: Declarative Macro (macro_rules!)

```rust
// Basic structure
macro_rules! my_vec {
    // Empty case
    () => {
        Vec::new()
    };
    // List of elements
    ($($elem:expr),* $(,)?) => {{
        let mut v = Vec::new();
        $(
            v.push($elem);
        )*
        v
    }};
    // Repeated element
    ($elem:expr; $n:expr) => {
        vec![$elem; $n]
    };
}

// Usage
let v1 = my_vec![];
let v2 = my_vec![1, 2, 3];
let v3 = my_vec![0; 10];
```

### Pattern 2: Derive Macro

```rust
// In a separate proc-macro crate
use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, DeriveInput};

#[proc_macro_derive(Builder)]
pub fn derive_builder(input: TokenStream) -> TokenStream {
    let input = parse_macro_input!(input as DeriveInput);
    let name = &input.ident;
    let builder_name = format!("{}Builder", name);
    let builder_ident = syn::Ident::new(&builder_name, name.span());

    let fields = match &input.data {
        syn::Data::Struct(data) => &data.fields,
        _ => panic!("Builder only works on structs"),
    };

    let field_names: Vec<_> = fields.iter()
        .filter_map(|f| f.ident.as_ref())
        .collect();

    let field_types: Vec<_> = fields.iter()
        .map(|f| &f.ty)
        .collect();

    let expanded = quote! {
        pub struct #builder_ident {
            #(#field_names: Option<#field_types>),*
        }

        impl #builder_ident {
            pub fn new() -> Self {
                Self {
                    #(#field_names: None),*
                }
            }

            #(
                pub fn #field_names(mut self, value: #field_types) -> Self {
                    self.#field_names = Some(value);
                    self
                }
            )*

            pub fn build(self) -> Result<#name, String> {
                Ok(#name {
                    #(
                        #field_names: self.#field_names
                            .ok_or_else(|| format!("Field {} not set", stringify!(#field_names)))?
                    ),*
                })
            }
        }

        impl #name {
            pub fn builder() -> #builder_ident {
                #builder_ident::new()
            }
        }
    };

    expanded.into()
}
```

### Pattern 3: Function-like Proc Macro

```rust
#[proc_macro]
pub fn sql(input: TokenStream) -> TokenStream {
    let sql_string = input.to_string();

    // Parse and validate SQL at compile time
    validate_sql(&sql_string);

    // Generate code
    quote! {
        QueryBuilder::raw(#sql_string)
    }.into()
}

// Usage:
let query = sql!("SELECT * FROM users WHERE id = ?");
```

### Pattern 4: Attribute Macro

```rust
#[proc_macro_attribute]
pub fn cached(_attr: TokenStream, item: TokenStream) -> TokenStream {
    let input = parse_macro_input!(item as ItemFn);
    let fn_name = &input.sig.ident;
    let fn_body = &input.block;

    let expanded = quote! {
        fn #fn_name() -> Result {
            use std::sync::OnceLock;
            static CACHE: OnceLock<Result> = OnceLock::new();

            CACHE.get_or_init(|| {
                #fn_body
            }).clone()
        }
    };

    expanded.into()
}

// Usage:
#[cached]
fn expensive_computation() -> String {
    // ...
}
```

---

## Repetition Patterns

| Syntax | Meaning |
|--------|---------|
| `$()` | Match zero or more |
| `$($x),*` | Comma-separated |
| `$($x),+` | At least one |
| `$x:ty` | Type matcher |
| `$x:expr` | Expression matcher |
| `$x:pat` | Pattern matcher |
| `$x:ident` | Identifier matcher |
| `$x:path` | Path matcher |
| `$x:tt` | Token tree matcher |

```rust
// Example: multiple matchers
macro_rules! create_struct {
    ($name:ident { $($field:ident: $type:ty),* }) => {
        struct $name {
            $($field: $type),*
        }
    };
}

create_struct!(User {
    id: u64,
    name: String,
    email: String
});
```

---

## Workflow

### Step 1: Consider Alternatives

```
Need to reduce duplication?
  → Can generics solve it? Prefer generics
  → Need syntax transformation? Use macros
  → Need to inspect types? Derive macro
  → Need attribute? Attribute macro
```

### Step 2: Choose Macro Type

```
Declarative (macro_rules!)?
  ✅ Simple pattern matching
  ✅ Quick to write
  ❌ Limited power

Procedural (proc-macro)?
  ✅ Full AST access
  ✅ Complex transformations
  ❌ Separate crate needed
  ❌ Longer compile times
```

### Step 3: Debug Expansion

```bash
# Expand macros
cargo expand

# Expand specific function
cargo expand my_module::my_function

# Expand tests
cargo expand --test test_name
```

### Step 4: Test Thoroughly

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_macro_expansion() {
        // Test generated code
        let result = my_macro!(input);
        assert_eq!(result, expected);
    }
}
```

---

## Common Crates

| Crate | Purpose |
|-------|---------|
| **syn** | Parse Rust syntax |
| **quote** | Generate Rust code |
| **proc-macro2** | Token manipulation |
| **derive-more** | Common derive macros |
| **darling** | Parse macro attributes |

---

## Best Practices

| Practice | Reason |
|----------|--------|
| Try generics first | Safer, easier to debug |
| Keep macros simple | Complex macros hard to maintain |
| Document macros | Users need to understand expansion |
| Test expansion | Ensure correctness |
| Use cargo expand | Visualize macro output |

---

## Review Checklist

When reviewing macro code:

- [ ] Could this be solved with generics instead?
- [ ] Macro expansion documented with examples
- [ ] Error messages are helpful
- [ ] Edge cases tested
- [ ] Hygiene respected (no accidental captures)
- [ ] Used cargo expand to verify output
- [ ] Compile-time overhead acceptable
- [ ] No unnecessary proc-macro dependency

---

## Verification Commands

```bash
# Expand macros
cargo expand

# Expand specific module
cargo expand path::to::module

# Check proc-macro crate
cargo check -p my-proc-macro

# Test expansion
cargo test --all-features
```

---

## Common Pitfalls

### 1. Hygiene Violations

**Symptom**: Unexpected variable captures

```rust
// ❌ Bad: name clash risk
macro_rules! bad_macro {
    ($x:expr) => {{
        let result = $x;  // 'result' might clash
        result
    }};
}

// ✅ Good: use unique names
macro_rules! good_macro {
    ($x:expr) => {{
        let __macro_result = $x;
        __macro_result
    }};
}
```

### 2. Complex Error Messages

**Symptom**: Users don't understand macro errors

```rust
// ✅ Good: helpful error messages
macro_rules! require_trait {
    ($t:ty) => {
        const _: fn() = || {
            fn assert_impl<T: MyTrait>() {}
            assert_impl::<$t>();
        };
    };
}
```

### 3. Proc Macro Compile Time

**Symptom**: Slow incremental builds

```rust
// ❌ Avoid: heavy proc macros for simple tasks
#[derive(HeavyProcMacro)]
struct Simple {
    field: String,
}

// ✅ Better: manual impl or simpler derive
impl Simple {
    // Manual implementation
}
```

---

## Related Skills

- **rust-coding** - Naming macro conventions
- **rust-performance** - Macro compile-time cost
- **rust-type-driven** - When generics suffice
- **rust-error** - Error handling in macros
- **rust-testing** - Testing macro expansion

---

## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
