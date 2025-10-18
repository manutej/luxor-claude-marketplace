# Rust Systems Programming

> Build high-performance, memory-safe systems software with Rust's ownership model, zero-cost abstractions, and fearless concurrency.

## Overview

Rust is a systems programming language that guarantees memory safety and thread safety at compile time, without requiring a garbage collector. It provides the performance of C/C++ with modern language features, making it ideal for systems software, embedded development, web services, and command-line tools.

## The Rust Guarantee

Rust provides three fundamental guarantees:

### 1. Memory Safety Without Garbage Collection

Rust prevents common memory bugs at compile time:
- **No null pointer dereferences**: Use `Option<T>` instead of null
- **No dangling pointers**: References are always valid
- **No buffer overflows**: Bounds checking on arrays
- **No use-after-free**: Ownership system prevents accessing freed memory
- **No data races**: Thread safety enforced by the type system

### 2. Zero-Cost Abstractions

High-level features compile to efficient machine code:
- Iterators optimize to simple loops
- Generic functions are monomorphized (specialized per type)
- Pattern matching compiles to efficient jump tables
- Trait objects use virtual dispatch only when needed
- No runtime overhead for safety guarantees

### 3. Fearless Concurrency

The type system prevents data races:
- `Send` trait: Types safe to transfer between threads
- `Sync` trait: Types safe to share between threads
- Compile-time enforcement prevents race conditions
- Lock APIs prevent deadlocks at type level
- Message passing with channels for safe communication

## The Ownership Model

Rust's ownership system is the foundation of its guarantees:

```rust
// Each value has exactly one owner
let s1 = String::from("hello");

// Ownership can be transferred (moved)
let s2 = s1;  // s1 is no longer valid

// Values can be borrowed immutably (any number of borrows)
let s3 = String::from("world");
let len = calculate_length(&s3);

// Or borrowed mutably (exactly one mutable borrow)
let mut s4 = String::from("foo");
change(&mut s4);

// When the owner goes out of scope, the value is dropped
```

**Ownership Rules:**
1. Each value in Rust has exactly one owner
2. When the owner goes out of scope, the value is dropped
3. Values can be borrowed via references (`&T` or `&mut T`)
4. You can have either one mutable reference OR any number of immutable references
5. References must always be valid

## Borrowing: The Key to Flexibility

Borrowing allows you to use values without taking ownership:

### Immutable Borrowing

```rust
fn calculate_length(s: &String) -> usize {
    s.len()  // Can read, cannot modify
}

let s = String::from("hello");
let len = calculate_length(&s);
println!("{} has length {}", s, len);  // s still valid
```

### Mutable Borrowing

```rust
fn append_world(s: &mut String) {
    s.push_str(" world");
}

let mut s = String::from("hello");
append_world(&mut s);
println!("{}", s);  // "hello world"
```

### Borrowing Rules Prevent Errors

```rust
let mut data = vec![1, 2, 3];
let first = &data[0];       // Immutable borrow
// data.push(4);            // ERROR: Cannot mutate while borrowed
println!("{}", first);      // Borrow ends here
data.push(4);               // Now OK
```

## Core Types and Patterns

### Smart Pointers

```rust
// Box: Heap allocation, single owner
let boxed = Box::new(5);

// Rc: Reference counted, single-threaded sharing
use std::rc::Rc;
let shared = Rc::new(5);
let cloned = Rc::clone(&shared);

// Arc: Atomic reference counted, thread-safe sharing
use std::sync::Arc;
let shared_thread_safe = Arc::new(5);

// RefCell: Interior mutability with runtime checks
use std::cell::RefCell;
let mutable = RefCell::new(5);
*mutable.borrow_mut() += 1;

// Mutex: Thread-safe interior mutability
use std::sync::Mutex;
let counter = Mutex::new(0);
*counter.lock().unwrap() += 1;
```

### Error Handling

Rust uses types for error handling, not exceptions:

```rust
// Result for recoverable errors
fn divide(a: i32, b: i32) -> Result<i32, String> {
    if b == 0 {
        Err("Division by zero".to_string())
    } else {
        Ok(a / b)
    }
}

// Option for optional values
fn find_user(id: u64) -> Option<User> {
    database.get(id)
}

// ? operator for error propagation
fn read_config(path: &str) -> Result<Config, Error> {
    let contents = std::fs::read_to_string(path)?;
    let config = parse_config(&contents)?;
    Ok(config)
}
```

## Concurrency Patterns

### Threads and Message Passing

```rust
use std::thread;
use std::sync::mpsc;

let (tx, rx) = mpsc::channel();

thread::spawn(move || {
    let data = expensive_computation();
    tx.send(data).unwrap();
});

let result = rx.recv().unwrap();
println!("Got result: {}", result);
```

### Shared State with Mutex

```rust
use std::sync::{Arc, Mutex};
use std::thread;

let counter = Arc::new(Mutex::new(0));
let mut handles = vec![];

for _ in 0..10 {
    let counter = Arc::clone(&counter);
    let handle = thread::spawn(move || {
        let mut num = counter.lock().unwrap();
        *num += 1;
    });
    handles.push(handle);
}

for handle in handles {
    handle.join().unwrap();
}

println!("Result: {}", *counter.lock().unwrap());
```

## Async Programming

Rust's async/await enables efficient I/O without blocking threads:

```rust
use tokio;

#[tokio::main]
async fn main() {
    let result = fetch_data().await;
    println!("Data: {:?}", result);
}

async fn fetch_data() -> Result<String, Error> {
    let response = reqwest::get("https://api.example.com/data").await?;
    let text = response.text().await?;
    Ok(text)
}

// Concurrent async operations
async fn fetch_multiple() -> Result<Vec<String>, Error> {
    let (data1, data2, data3) = tokio::join!(
        fetch_url("https://example.com/1"),
        fetch_url("https://example.com/2"),
        fetch_url("https://example.com/3"),
    );

    Ok(vec![data1?, data2?, data3?])
}
```

## When to Use Rust

### Excellent For:

**Systems Programming**
- Operating systems and kernels
- Device drivers
- Embedded systems
- File systems and databases

**High-Performance Applications**
- Game engines
- Browser engines (Firefox uses Rust)
- Video/audio processing
- Real-time systems

**Network Services**
- Web servers and proxies
- Load balancers
- Network protocols
- API gateways

**Command-Line Tools**
- Fast, reliable CLI applications
- Cross-platform utilities
- Build tools and compilers

**WebAssembly**
- Near-native performance in browsers
- Portable binary format
- Safe sandboxed execution

**Cryptography and Security**
- Memory-safe crypto implementations
- Security-critical components
- Blockchain and distributed systems

### Consider Alternatives For:

**Rapid Prototyping**: Python, JavaScript for faster iteration
**Data Science**: Python's ecosystem is more mature
**Mobile Apps**: Swift (iOS) or Kotlin (Android) for platform-specific features
**Enterprise Applications**: Java or C# if you need existing enterprise ecosystems

## Quick Start Guide

### Installation

```bash
# Install Rust via rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Update Rust
rustup update

# Check version
rustc --version
cargo --version
```

### Create a New Project

```bash
# Binary (application)
cargo new my_app
cd my_app

# Library
cargo new --lib my_lib
```

### Project Structure

```
my_app/
├── Cargo.toml      # Dependencies and metadata
├── Cargo.lock      # Dependency lock file
└── src/
    └── main.rs     # Entry point
```

### Build and Run

```bash
# Build in debug mode
cargo build

# Build in release mode (optimized)
cargo build --release

# Run the application
cargo run

# Run tests
cargo test

# Check code without building
cargo check

# Format code
cargo fmt

# Lint code
cargo clippy
```

### Adding Dependencies

Edit `Cargo.toml`:

```toml
[dependencies]
serde = { version = "1.0", features = ["derive"] }
tokio = { version = "1", features = ["full"] }
reqwest = { version = "0.11", features = ["json"] }
```

Then run:

```bash
cargo build  # Downloads and compiles dependencies
```

## Common Patterns

### The Builder Pattern

```rust
struct Server {
    host: String,
    port: u16,
    workers: usize,
}

impl Server {
    fn builder() -> ServerBuilder {
        ServerBuilder::default()
    }
}

#[derive(Default)]
struct ServerBuilder {
    host: Option<String>,
    port: Option<u16>,
    workers: Option<usize>,
}

impl ServerBuilder {
    fn host(mut self, host: impl Into<String>) -> Self {
        self.host = Some(host.into());
        self
    }

    fn port(mut self, port: u16) -> Self {
        self.port = Some(port);
        self
    }

    fn workers(mut self, workers: usize) -> Self {
        self.workers = Some(workers);
        self
    }

    fn build(self) -> Server {
        Server {
            host: self.host.unwrap_or_else(|| "127.0.0.1".to_string()),
            port: self.port.unwrap_or(8080),
            workers: self.workers.unwrap_or(4),
        }
    }
}

// Usage
let server = Server::builder()
    .host("0.0.0.0")
    .port(3000)
    .workers(8)
    .build();
```

### The Newtype Pattern

```rust
struct UserId(u64);
struct PostId(u64);

fn get_user(id: UserId) -> User { /* ... */ }

// Type safety: can't mix up IDs
// let user = get_user(PostId(42));  // Compile error!
```

### RAII (Resource Acquisition Is Initialization)

```rust
struct FileHandle {
    file: std::fs::File,
}

impl FileHandle {
    fn open(path: &str) -> std::io::Result<Self> {
        Ok(FileHandle {
            file: std::fs::File::create(path)?,
        })
    }
}

impl Drop for FileHandle {
    fn drop(&mut self) {
        println!("File automatically closed");
        // File is closed when FileHandle goes out of scope
    }
}
```

## Performance Tips

1. **Use References**: Avoid unnecessary clones by borrowing
2. **Iterators Over Loops**: Iterators often optimize better
3. **Avoid Allocations**: Use `&str` instead of `String` when possible
4. **Profile First**: Use `cargo-flamegraph` or `perf` to find bottlenecks
5. **Enable LTO**: Set `lto = true` in release profile
6. **Use `cargo-bloat`**: Find large dependencies
7. **Benchmark**: Use `criterion` for reliable benchmarks

## Testing

```rust
// Unit tests in the same file
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_addition() {
        assert_eq!(2 + 2, 4);
    }

    #[test]
    #[should_panic(expected = "divide by zero")]
    fn test_panic() {
        divide(10, 0);
    }

    #[tokio::test]
    async fn test_async() {
        let result = async_function().await;
        assert!(result.is_ok());
    }
}

// Integration tests in tests/
// tests/integration_test.rs
use my_crate;

#[test]
fn test_public_api() {
    assert_eq!(my_crate::add(2, 2), 4);
}

// Benchmarks in benches/
// benches/my_benchmark.rs
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn fibonacci_benchmark(c: &mut Criterion) {
    c.bench_function("fib 20", |b| {
        b.iter(|| fibonacci(black_box(20)))
    });
}

criterion_group!(benches, fibonacci_benchmark);
criterion_main!(benches);
```

## Documentation

```rust
/// Calculates the sum of two numbers.
///
/// # Examples
///
/// ```
/// let result = my_crate::add(2, 2);
/// assert_eq!(result, 4);
/// ```
///
/// # Panics
///
/// Panics if the result overflows.
///
/// # Errors
///
/// Returns `Err` if...
///
/// # Safety
///
/// Caller must ensure...
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

Generate documentation:

```bash
cargo doc --open
```

## Community Resources

### Official Resources
- **The Rust Book**: https://doc.rust-lang.org/book/
- **Rust by Example**: https://doc.rust-lang.org/rust-by-example/
- **Standard Library Docs**: https://doc.rust-lang.org/std/
- **Cargo Book**: https://doc.rust-lang.org/cargo/

### Advanced Resources
- **The Rustonomicon**: Unsafe Rust guide
- **Async Book**: Async programming in depth
- **Performance Book**: Optimization techniques
- **Embedded Book**: Embedded systems with Rust

### Community
- **Rust Users Forum**: https://users.rust-lang.org/
- **Rust Subreddit**: r/rust
- **Discord**: Official Rust Discord server
- **This Week in Rust**: Weekly newsletter

### Tools
- **rustfmt**: Code formatter
- **clippy**: Lint tool
- **rust-analyzer**: IDE language server
- **cargo-edit**: Manage dependencies from CLI
- **cargo-watch**: Auto-rebuild on file changes

## Common Errors and Solutions

### Borrow Checker Errors

**"cannot borrow as mutable because it is also borrowed as immutable"**
→ Ensure borrows don't overlap in scope

**"cannot move out of borrowed content"**
→ Use `.clone()`, take a reference, or use `Rc<T>`

**"borrowed value does not live long enough"**
→ Add lifetime annotations or restructure code

### Compilation Errors

**"trait X is not implemented for Y"**
→ Derive or implement the trait, or use a different type

**"type annotations needed"**
→ Add explicit type annotations or help the compiler infer

**"recursive type has infinite size"**
→ Use `Box<T>` to create indirection

## Next Steps

1. **Complete The Rust Book**: https://doc.rust-lang.org/book/
2. **Build Projects**: Start with small CLI tools
3. **Read Other's Code**: Explore popular crates on crates.io
4. **Join the Community**: Ask questions, help others
5. **Contribute**: Fix bugs, improve documentation

---

**Get Started**: `cargo new my_project && cd my_project && cargo run`

**Learn More**: Explore SKILL.md and EXAMPLES.md for comprehensive patterns and production examples.
