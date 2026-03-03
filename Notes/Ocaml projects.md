Foundational                                                                                                                                                                                                                                  
 - Key-Value Store - Build a simple in-memory KV store with a network protocol (TCP/HTTP), then add persistence
  - RPC Framework - Implement remote procedure calls with serialization, timeouts, and retries                                                                                                                                                  
  Consensus & Coordination                                                                                                                                                                                                                      
  - Raft Implementation - Leader election, log replication, and state machine replication
  - Paxos - Single-decree or multi-Paxos for distributed consensus
  - Distributed Lock Service - Like a simplified ZooKeeper or etcd lock
  - Vector Clocks - Implement causal ordering and conflict detection                                                                                                                                                                            
  Storage Systems                                                                                                                                                                                                                               
  - Distributed Hash Table (DHT) - Chord or Kademlia for peer-to-peer lookups
  - Log-Structured Storage - Append-only storage with compaction (like Kafka's segments)
  - Replicated State Machine - Combine consensus with a KV store for fault tolerance
  - CRDT Library - Conflict-free replicated data types (G-Counter, LWW-Register, OR-Set)                                                                                                                                                        
  Practical Systems                                                                                                                                                                                                                             
  - Task Queue - Distributed job scheduling with workers, retries, and dead-letter handling
  - Pub/Sub System - Message broker with topics, subscriptions, and delivery guarantees
  - Distributed Cache - Consistent hashing, replication, and cache invalidation
  - Service Discovery - Registry for microservices with health checks                                                                                                                                                                           
  Advanced                                                                                                                                                                                                                                      
  - Distributed Database - Sharding, replication, and transaction coordination (2PC/3PC) 
  - Gossip Protocol - Epidemic broadcast for cluster membership and failure detection
  - Distributed Tracing - Propagate trace context across services, collect spans