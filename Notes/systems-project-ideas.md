# High-Performance Systems Project Ideas

Benchmarkable systems programming projects that demonstrate real engineering skill.

## Database/Storage Systems

| Project                      | Description                                            | Benchmark Against     |
| ---------------------------- | ------------------------------------------------------ | --------------------- |
| **LSM-tree key-value store** | Like LevelDB/RocksDB - write-optimized with compaction | LevelDB, BadgerDB     |
| **Time-series database**     | Optimized for append-heavy metrics data                | InfluxDB, TimescaleDB |
| **Embedded database**        | Single-file DB like SQLite                             | SQLite, BoltDB        |
| **Distributed cache**        | Consistent hashing, replication                        | Memcached cluster     |

## Networking/Proxies

| Project | Description | Benchmark Against |
|---------|-------------|-------------------|
| **L4/L7 load balancer** | TCP/HTTP proxy with health checks | HAProxy, Nginx |
| **HTTP/2 or HTTP/3 server** | From scratch with HPACK/QPACK | Nginx, Caddy |
| **Message queue** | Persistent pub/sub with consumer groups | Redis Streams, Kafka |
| **Rate limiter service** | Distributed token bucket/sliding window | Redis-based limiters |

## Compute/Runtime

| Project | Description | Benchmark Against |
|---------|-------------|-------------------|
| **JSON parser** | SIMD-optimized, streaming | simdjson, sonic |
| **Regex engine** | NFA/DFA with JIT compilation | RE2, PCRE2 |
| **Schema validator** | JSON Schema / Protobuf validator | ajv, protoc |
| **Compression codec** | LZ4/Snappy compatible | lz4, zstd |

## Top 3 Recommendations

### 1. LSM-tree Key-Value Store

Teaches you:
- Write-ahead logs (WAL)
- SSTables and memtables
- Bloom filters
- Compaction strategies (leveled, tiered)
- Range queries and iterators

Metrics: read/write throughput, latency percentiles, space amplification, write amplification

### 2. Message Queue with Persistence

Features to implement:
- Append-only log storage
- Consumer groups with offsets
- Message replay from offset
- Acknowledgments and redelivery
- Partitioning for parallelism

Metrics: messages/sec, end-to-end latency, durability guarantees

### 3. HTTP Reverse Proxy

Features to implement:
- Connection pooling to backends
- Load balancing algorithms (round-robin, least-conn, consistent hash)
- Health checks and circuit breakers
- Request/response streaming
- TLS termination

Metrics: requests/sec, latency (p50/p99), concurrent connections

## Benchmarking Tools

| Tool | Use Case |
|------|----------|
| `memtier_benchmark` | Redis/Memcached protocols |
| `wrk` / `hey` | HTTP load testing |
| `fio` | Storage I/O benchmarking |
| `go test -bench` | Microbenchmarks |
| `pprof` | CPU/memory profiling |

## Resources

- [Database Internals](https://www.databass.dev/) - Alex Petrov
- [Designing Data-Intensive Applications](https://dataintensive.net/) - Martin Kleppmann
- [Systems Performance](https://www.brendangregg.com/systems-performance-2nd-edition-book.html) - Brendan Gregg
