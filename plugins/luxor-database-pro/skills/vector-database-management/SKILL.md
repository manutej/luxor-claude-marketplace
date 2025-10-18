---
name: vector-database-management
description: Comprehensive guide for managing vector databases including Pinecone, Weaviate, and Chroma for semantic search, RAG systems, and similarity-based applications
version: 1.0.0
category: data-engineering
tags: [vector-database, embeddings, semantic-search, rag, pinecone, weaviate, chroma, similarity-search, machine-learning, ai]
prerequisites:
  - Python 3.8+
  - Basic understanding of embeddings and vector representations
  - Familiarity with REST APIs
  - Knowledge of similarity metrics (cosine, euclidean, dot product)
---

# Vector Database Management

## Table of Contents

1. [Introduction](#introduction)
2. [Vector Embeddings Fundamentals](#vector-embeddings-fundamentals)
3. [Database Setup & Configuration](#database-setup--configuration)
4. [Index Operations](#index-operations)
5. [Vector Operations](#vector-operations)
6. [Similarity Search](#similarity-search)
7. [Metadata Filtering](#metadata-filtering)
8. [Hybrid Search](#hybrid-search)
9. [Namespace & Collection Management](#namespace--collection-management)
10. [Performance & Scaling](#performance--scaling)
11. [Production Best Practices](#production-best-practices)
12. [Cost Optimization](#cost-optimization)

## Introduction

Vector databases are specialized systems designed to store, index, and query high-dimensional vector embeddings efficiently. They power modern AI applications including semantic search, recommendation systems, RAG (Retrieval Augmented Generation), and similarity-based matching.

### Key Concepts

- **Vector Embeddings**: Numerical representations of data (text, images, audio) in high-dimensional space
- **Similarity Search**: Finding vectors that are "close" to a query vector using distance metrics
- **Metadata Filtering**: Combining vector similarity with structured data filtering
- **Indexing**: Optimization structures (HNSW, IVF, etc.) for fast approximate nearest neighbor search

### Database Comparison

| Feature | Pinecone | Weaviate | Chroma |
|---------|----------|----------|--------|
| Deployment | Fully managed | Managed or self-hosted | Self-hosted or cloud |
| Index Types | Serverless, Pods | HNSW | HNSW |
| Metadata Filtering | Advanced | GraphQL-based | Simple |
| Hybrid Search | Sparse-Dense | Built-in | Limited |
| Scale | Massive | Large | Small-Medium |
| Best For | Production RAG | Knowledge graphs | Local development |

## Vector Embeddings Fundamentals

### Understanding Vector Representations

Vector embeddings transform unstructured data into numerical arrays that capture semantic meaning:

```python
# Text to embeddings using OpenAI
from openai import OpenAI

client = OpenAI(api_key="YOUR_API_KEY")

def generate_embedding(text: str, model: str = "text-embedding-3-small") -> list[float]:
    """Generate embeddings from text using OpenAI."""
    response = client.embeddings.create(
        input=text,
        model=model
    )
    return response.data[0].embedding

# Example usage
text = "Vector databases enable semantic search capabilities"
embedding = generate_embedding(text)
print(f"Embedding dimension: {len(embedding)}")  # 1536 dimensions
print(f"First 5 values: {embedding[:5]}")
```

### Popular Embedding Models

```python
# 1. OpenAI Embeddings (Production-grade)
from openai import OpenAI

def openai_embeddings(texts: list[str]) -> list[list[float]]:
    """Batch generate OpenAI embeddings."""
    client = OpenAI(api_key="YOUR_API_KEY")
    response = client.embeddings.create(
        input=texts,
        model="text-embedding-3-large"  # 3072 dimensions
    )
    return [item.embedding for item in response.data]

# 2. Sentence Transformers (Open-source)
from sentence_transformers import SentenceTransformer

def sentence_transformer_embeddings(texts: list[str]) -> list[list[float]]:
    """Generate embeddings using Sentence Transformers."""
    model = SentenceTransformer('all-MiniLM-L6-v2')  # 384 dimensions
    embeddings = model.encode(texts)
    return embeddings.tolist()

# 3. Cohere Embeddings
import cohere

def cohere_embeddings(texts: list[str]) -> list[list[float]]:
    """Generate embeddings using Cohere."""
    co = cohere.Client("YOUR_API_KEY")
    response = co.embed(
        texts=texts,
        model="embed-english-v3.0",
        input_type="search_document"
    )
    return response.embeddings
```

### Embedding Dimensions & Trade-offs

```python
# Different embedding models for different use cases
EMBEDDING_CONFIGS = {
    "openai-small": {
        "model": "text-embedding-3-small",
        "dimensions": 1536,
        "cost_per_1m": 0.02,
        "use_case": "General purpose, cost-effective"
    },
    "openai-large": {
        "model": "text-embedding-3-large",
        "dimensions": 3072,
        "cost_per_1m": 0.13,
        "use_case": "High accuracy requirements"
    },
    "sentence-transformers": {
        "model": "all-MiniLM-L6-v2",
        "dimensions": 384,
        "cost_per_1m": 0.00,  # Open-source
        "use_case": "Local development, privacy-sensitive"
    },
    "cohere-multilingual": {
        "model": "embed-multilingual-v3.0",
        "dimensions": 1024,
        "cost_per_1m": 0.10,
        "use_case": "Multi-language applications"
    }
}
```

## Database Setup & Configuration

### Pinecone Setup

```python
# Install Pinecone SDK
# pip install pinecone-client

from pinecone import Pinecone, ServerlessSpec

# Initialize Pinecone client
pc = Pinecone(api_key="YOUR_API_KEY")

# List existing indexes
indexes = pc.list_indexes()
print(f"Existing indexes: {[idx.name for idx in indexes]}")

# Create serverless index (recommended for production)
index_name = "production-search"

if index_name not in [idx.name for idx in pc.list_indexes()]:
    pc.create_index(
        name=index_name,
        dimension=1536,  # Match your embedding model
        metric="cosine",  # cosine, dotproduct, or euclidean
        spec=ServerlessSpec(
            cloud="aws",
            region="us-east-1"
        ),
        deletion_protection="enabled",  # Prevent accidental deletion
        tags={
            "environment": "production",
            "team": "ml",
            "project": "semantic-search"
        }
    )
    print(f"Created index: {index_name}")

# Connect to index
index = pc.Index(index_name)

# Get index stats
stats = index.describe_index_stats()
print(f"Index stats: {stats}")
```

### Selective Metadata Indexing (Pinecone)

```python
# Configure which metadata fields to index for filtering
# This optimizes memory usage and query performance

from pinecone import Pinecone, ServerlessSpec

pc = Pinecone(api_key="YOUR_API_KEY")

# Create index with metadata configuration
pc.create_index(
    name="optimized-index",
    dimension=1536,
    metric="cosine",
    spec=ServerlessSpec(
        cloud="aws",
        region="us-east-1",
        schema={
            "fields": {
                # Index these fields for filtering
                "document_id": {"filterable": True},
                "category": {"filterable": True},
                "created_at": {"filterable": True},
                "tags": {"filterable": True},
                # Store but don't index (saves memory)
                "document_title": {"filterable": False},
                "document_url": {"filterable": False},
                "full_content": {"filterable": False}
            }
        }
    )
)

# This configuration allows you to:
# 1. Filter by document_id, category, created_at, tags
# 2. Retrieve document_title, document_url, full_content in results
# 3. Save memory by not indexing non-filterable fields
```

### Weaviate Setup

```python
# Install Weaviate client
# pip install weaviate-client

import weaviate
from weaviate.classes.config import Configure, Property, DataType

# Connect to Weaviate
client = weaviate.connect_to_local()

# Or connect to Weaviate Cloud
# client = weaviate.connect_to_wcs(
#     cluster_url="YOUR_WCS_URL",
#     auth_credentials=weaviate.auth.AuthApiKey("YOUR_API_KEY")
# )

# Create collection (schema)
try:
    collection = client.collections.create(
        name="Documents",
        vectorizer_config=Configure.Vectorizer.text2vec_openai(
            model="text-embedding-3-small"
        ),
        properties=[
            Property(name="title", data_type=DataType.TEXT),
            Property(name="content", data_type=DataType.TEXT),
            Property(name="category", data_type=DataType.TEXT),
            Property(name="created_at", data_type=DataType.DATE),
            Property(name="tags", data_type=DataType.TEXT_ARRAY)
        ]
    )
    print(f"Created collection: Documents")
except Exception as e:
    print(f"Collection exists or error: {e}")

# Get collection
documents = client.collections.get("Documents")

# Check collection info
print(documents.config.get())
```

### Chroma Setup

```python
# Install Chroma
# pip install chromadb

import chromadb
from chromadb.config import Settings

# Initialize Chroma client (persistent)
client = chromadb.PersistentClient(path="./chroma_db")

# Or use ephemeral (in-memory)
# client = chromadb.EphemeralClient()

# Create or get collection
collection = client.get_or_create_collection(
    name="documents",
    metadata={
        "description": "Document collection for semantic search",
        "hnsw:space": "cosine"  # cosine, l2, or ip (inner product)
    }
)

# List all collections
collections = client.list_collections()
print(f"Available collections: {[c.name for c in collections]}")

# Get collection info
print(f"Collection count: {collection.count()}")
```

## Index Operations

### Creating Indexes with Different Configurations

```python
from pinecone import Pinecone, ServerlessSpec, PodSpec

pc = Pinecone(api_key="YOUR_API_KEY")

# 1. Serverless index (auto-scaling, pay-per-use)
pc.create_index(
    name="serverless-index",
    dimension=1536,
    metric="cosine",
    spec=ServerlessSpec(
        cloud="aws",
        region="us-east-1"
    )
)

# 2. Pod-based index (dedicated resources)
pc.create_index(
    name="pod-index",
    dimension=1536,
    metric="dotproduct",
    spec=PodSpec(
        environment="us-east-1-aws",
        pod_type="p1.x1",  # Performance tier
        pods=2,  # Number of pods
        replicas=2,  # Replicas for high availability
        shards=1
    )
)

# 3. Sparse index (for BM25-like search)
pc.create_index(
    name="sparse-index",
    dimension=None,  # Sparse vectors don't have fixed dimension
    metric="dotproduct",
    spec=ServerlessSpec(
        cloud="aws",
        region="us-east-1"
    )
)
```

### Index Management Operations

```python
from pinecone import Pinecone

pc = Pinecone(api_key="YOUR_API_KEY")

# List all indexes
indexes = pc.list_indexes()
for idx in indexes:
    print(f"Name: {idx.name}, Status: {idx.status.state}, Host: {idx.host}")

# Describe specific index
index_info = pc.describe_index("production-search")
print(f"Dimension: {index_info.dimension}")
print(f"Metric: {index_info.metric}")
print(f"Status: {index_info.status}")

# Connect to index
index = pc.Index("production-search")

# Get index statistics
stats = index.describe_index_stats()
print(f"Total vectors: {stats.total_vector_count}")
print(f"Namespaces: {stats.namespaces}")
print(f"Index fullness: {stats.index_fullness}")

# Delete index (be careful!)
# pc.delete_index("test-index")
```

### Configuring Index for Optimal Performance

```python
# Configuration for different use cases

# 1. High-throughput search (many queries/second)
pc.create_index(
    name="high-throughput",
    dimension=1536,
    metric="cosine",
    spec=PodSpec(
        environment="us-east-1-aws",
        pod_type="p2.x1",  # Higher performance tier
        pods=4,
        replicas=3  # More replicas = higher query throughput
    )
)

# 2. Large-scale storage (billions of vectors)
pc.create_index(
    name="large-scale",
    dimension=1536,
    metric="cosine",
    spec=PodSpec(
        environment="us-east-1-aws",
        pod_type="s1.x1",  # Storage-optimized
        pods=8,
        shards=4  # More shards = more storage capacity
    )
)

# 3. Cost-optimized development
pc.create_index(
    name="dev-environment",
    dimension=1536,
    metric="cosine",
    spec=ServerlessSpec(
        cloud="aws",
        region="us-east-1"
    )  # Serverless = pay only for what you use
)
```

## Vector Operations

### Upserting Vectors (Pinecone)

```python
from pinecone import Pinecone
import uuid

pc = Pinecone(api_key="YOUR_API_KEY")
index = pc.Index("production-search")

# 1. Single vector upsert
vector_id = str(uuid.uuid4())
index.upsert(
    vectors=[
        {
            "id": vector_id,
            "values": [0.1, 0.2, 0.3, ...],  # 1536 dimensions
            "metadata": {
                "title": "Introduction to Vector Databases",
                "category": "education",
                "author": "John Doe",
                "created_at": "2024-01-15",
                "tags": ["ml", "ai", "databases"]
            }
        }
    ],
    namespace="documents"
)

# 2. Batch upsert (efficient for large datasets)
batch_size = 100
vectors = []

for i, (doc_id, embedding, metadata) in enumerate(documents):
    vectors.append({
        "id": doc_id,
        "values": embedding,
        "metadata": metadata
    })

    # Upsert in batches
    if len(vectors) >= batch_size or i == len(documents) - 1:
        index.upsert(vectors=vectors, namespace="documents")
        print(f"Upserted batch of {len(vectors)} vectors")
        vectors = []

# 3. Upsert with async for better performance
from pinecone import Pinecone
import asyncio

async def upsert_vectors_async(vectors_batch):
    """Async upsert for parallel processing."""
    index.upsert(vectors=vectors_batch, namespace="documents", async_req=True)

# Parallel upsert
tasks = []
for batch in batches:
    tasks.append(upsert_vectors_async(batch))
await asyncio.gather(*tasks)
```

### Sparse Vector Operations (Pinecone)

```python
# Sparse vectors are useful for keyword-based search (like BM25)
# Combined with dense vectors for hybrid search

from pinecone import Pinecone

pc = Pinecone(api_key="YOUR_API_KEY")
index = pc.Index("hybrid-search-index")

# Upsert vector with both dense and sparse components
index.upsert(
    vectors=[
        {
            "id": "doc1",
            "values": [0.1, 0.2, ..., 0.5],  # Dense vector
            "sparse_values": {
                "indices": [10, 45, 123, 234, 678],  # Token IDs
                "values": [0.8, 0.6, 0.9, 0.7, 0.5]  # TF-IDF weights
            },
            "metadata": {"title": "Hybrid Search Document"}
        }
    ],
    namespace="hybrid"
)

# Query with hybrid search
results = index.query(
    vector=[0.1, 0.2, ..., 0.5],  # Dense query vector
    sparse_vector={
        "indices": [10, 45, 123],
        "values": [0.8, 0.7, 0.9]
    },
    top_k=10,
    namespace="hybrid",
    include_metadata=True
)
```

### Vector Operations (Weaviate)

```python
import weaviate
from weaviate.classes.query import MetadataQuery

client = weaviate.connect_to_local()
documents = client.collections.get("Documents")

# 1. Insert single object
doc_uuid = documents.data.insert(
    properties={
        "title": "Vector Database Guide",
        "content": "A comprehensive guide to vector databases...",
        "category": "tutorial",
        "created_at": "2024-01-15T10:00:00Z",
        "tags": ["database", "ml", "ai"]
    }
)
print(f"Inserted: {doc_uuid}")

# 2. Batch insert
with documents.batch.dynamic() as batch:
    for doc in document_list:
        batch.add_object(
            properties={
                "title": doc["title"],
                "content": doc["content"],
                "category": doc["category"],
                "created_at": doc["created_at"],
                "tags": doc["tags"]
            }
        )

# 3. Insert with custom vector
documents.data.insert(
    properties={"title": "Custom Vector Doc", "content": "..."},
    vector=[0.1, 0.2, 0.3, ...]  # Your pre-computed vector
)

# 4. Update object
documents.data.update(
    uuid=doc_uuid,
    properties={"title": "Updated Title"}
)

# 5. Delete object
documents.data.delete_by_id(uuid=doc_uuid)
```

### Vector Operations (Chroma)

```python
import chromadb

client = chromadb.PersistentClient(path="./chroma_db")
collection = client.get_collection("documents")

# 1. Add documents with auto-embedding
collection.add(
    documents=[
        "This is document 1",
        "This is document 2",
        "This is document 3"
    ],
    metadatas=[
        {"category": "tech", "author": "Alice"},
        {"category": "science", "author": "Bob"},
        {"category": "tech", "author": "Charlie"}
    ],
    ids=["doc1", "doc2", "doc3"]
)

# 2. Add with custom embeddings
collection.add(
    embeddings=[
        [0.1, 0.2, 0.3, ...],
        [0.4, 0.5, 0.6, ...]
    ],
    metadatas=[
        {"title": "Doc 1"},
        {"title": "Doc 2"}
    ],
    ids=["custom1", "custom2"]
)

# 3. Update documents
collection.update(
    ids=["doc1"],
    documents=["Updated document content"],
    metadatas=[{"category": "tech", "updated": True}]
)

# 4. Delete documents
collection.delete(ids=["doc1", "doc2"])

# 5. Get documents by IDs
results = collection.get(
    ids=["doc1", "doc2"],
    include=["documents", "metadatas", "embeddings"]
)
```

## Similarity Search

### Basic Similarity Search (Pinecone)

```python
from pinecone import Pinecone
from openai import OpenAI

# Initialize clients
pc = Pinecone(api_key="PINECONE_API_KEY")
openai_client = OpenAI(api_key="OPENAI_API_KEY")

index = pc.Index("production-search")

# 1. Generate query embedding
query_text = "What are the benefits of vector databases?"
response = openai_client.embeddings.create(
    input=query_text,
    model="text-embedding-3-small"
)
query_embedding = response.data[0].embedding

# 2. Search for similar vectors
results = index.query(
    vector=query_embedding,
    top_k=10,
    namespace="documents",
    include_values=False,
    include_metadata=True
)

# 3. Process results
print(f"Found {len(results.matches)} results")
for match in results.matches:
    print(f"ID: {match.id}")
    print(f"Score: {match.score:.4f}")
    print(f"Title: {match.metadata.get('title')}")
    print(f"Category: {match.metadata.get('category')}")
    print("---")
```

### Search by ID (Query by Example)

```python
# Search using an existing vector as query
results = index.query(
    id="existing-doc-id",  # Use this document as the query
    top_k=10,
    namespace="documents",
    include_metadata=True
)

# Useful for "find similar items" features
print(f"Documents similar to {results.matches[0].metadata.get('title')}:")
for match in results.matches[1:]:  # Skip first (self)
    print(f"- {match.metadata.get('title')} (score: {match.score:.4f})")
```

### Multi-vector Search (Pinecone)

```python
# Search multiple query vectors in one request
query_embeddings = [
    [0.1, 0.2, ...],  # Query 1
    [0.3, 0.4, ...],  # Query 2
    [0.5, 0.6, ...]   # Query 3
]

results = index.query(
    queries=query_embeddings,
    top_k=5,
    namespace="documents",
    include_metadata=True
)

# Process results for each query
for i, query_results in enumerate(results):
    print(f"\nResults for query {i+1}:")
    for match in query_results.matches:
        print(f"- {match.metadata.get('title')} (score: {match.score:.4f})")
```

### Similarity Search (Weaviate)

```python
import weaviate
from weaviate.classes.query import MetadataQuery

client = weaviate.connect_to_local()
documents = client.collections.get("Documents")

# 1. Near text search (semantic)
response = documents.query.near_text(
    query="vector database performance optimization",
    limit=10,
    return_metadata=MetadataQuery(distance=True, certainty=True)
)

for obj in response.objects:
    print(f"Title: {obj.properties['title']}")
    print(f"Distance: {obj.metadata.distance:.4f}")
    print(f"Certainty: {obj.metadata.certainty:.4f}")
    print("---")

# 2. Near vector search (with custom embedding)
response = documents.query.near_vector(
    near_vector=[0.1, 0.2, 0.3, ...],
    limit=10
)

# 3. Near object search (find similar to existing object)
response = documents.query.near_object(
    near_object="uuid-of-reference-object",
    limit=10
)
```

### Similarity Search (Chroma)

```python
import chromadb

client = chromadb.PersistentClient(path="./chroma_db")
collection = client.get_collection("documents")

# 1. Query with text (auto-embedding)
results = collection.query(
    query_texts=["What is machine learning?"],
    n_results=10,
    include=["documents", "metadatas", "distances"]
)

print(f"Found {len(results['ids'][0])} results")
for i, doc_id in enumerate(results['ids'][0]):
    print(f"ID: {doc_id}")
    print(f"Distance: {results['distances'][0][i]:.4f}")
    print(f"Document: {results['documents'][0][i][:100]}...")
    print(f"Metadata: {results['metadatas'][0][i]}")
    print("---")

# 2. Query with custom embedding
results = collection.query(
    query_embeddings=[[0.1, 0.2, 0.3, ...]],
    n_results=10
)
```

## Metadata Filtering

### Pinecone Metadata Filters

```python
from pinecone import Pinecone

pc = Pinecone(api_key="YOUR_API_KEY")
index = pc.Index("production-search")

# 1. Equality filter
results = index.query(
    vector=query_embedding,
    top_k=10,
    filter={"category": {"$eq": "education"}},
    include_metadata=True
)

# 2. Inequality filter
results = index.query(
    vector=query_embedding,
    top_k=10,
    filter={"year": {"$ne": 2023}},
    include_metadata=True
)

# 3. Range filters
results = index.query(
    vector=query_embedding,
    top_k=10,
    filter={
        "$and": [
            {"year": {"$gte": 2020}},
            {"year": {"$lte": 2024}}
        ]
    },
    include_metadata=True
)

# 4. In/Not-in filters
results = index.query(
    vector=query_embedding,
    top_k=10,
    filter={
        "category": {"$in": ["education", "tutorial", "guide"]}
    },
    include_metadata=True
)

# 5. Existence check
results = index.query(
    vector=query_embedding,
    top_k=10,
    filter={"author": {"$exists": True}},
    include_metadata=True
)

# 6. Complex AND/OR queries
results = index.query(
    vector=query_embedding,
    top_k=10,
    filter={
        "$and": [
            {"category": {"$eq": "education"}},
            {
                "$or": [
                    {"year": {"$eq": 2024}},
                    {"featured": {"$eq": True}}
                ]
            },
            {"tags": {"$in": ["ml", "ai"]}}
        ]
    },
    include_metadata=True
)

# 7. Greater than/Less than
results = index.query(
    vector=query_embedding,
    top_k=10,
    filter={
        "view_count": {"$gt": 1000},
        "rating": {"$gte": 4.5}
    },
    include_metadata=True
)
```

### Production Metadata Filter Patterns

```python
# Pattern 1: Time-based filtering (recent content)
from datetime import datetime, timedelta

def search_recent_documents(query_text: str, days: int = 30):
    """Search only documents from last N days."""
    cutoff_date = (datetime.now() - timedelta(days=days)).isoformat()

    results = index.query(
        vector=generate_embedding(query_text),
        top_k=10,
        filter={
            "created_at": {"$gte": cutoff_date}
        },
        include_metadata=True
    )
    return results

# Pattern 2: User permission filtering
def search_with_permissions(query_text: str, user_id: str, user_roles: list):
    """Search only documents user has access to."""
    results = index.query(
        vector=generate_embedding(query_text),
        top_k=10,
        filter={
            "$or": [
                {"owner_id": {"$eq": user_id}},
                {"shared_with": {"$in": [user_id]}},
                {"public": {"$eq": True}},
                {"required_roles": {"$in": user_roles}}
            ]
        },
        include_metadata=True
    )
    return results

# Pattern 3: Multi-tenant filtering
def search_tenant_documents(query_text: str, tenant_id: str, category: str = None):
    """Search within a specific tenant's data."""
    filter_dict = {"tenant_id": {"$eq": tenant_id}}

    if category:
        filter_dict["category"] = {"$eq": category}

    results = index.query(
        vector=generate_embedding(query_text),
        top_k=10,
        filter=filter_dict,
        include_metadata=True
    )
    return results

# Pattern 4: Faceted search
def faceted_search(query_text: str, facets: dict):
    """Search with multiple facet filters."""
    filter_conditions = []

    for field, values in facets.items():
        if isinstance(values, list):
            filter_conditions.append({field: {"$in": values}})
        else:
            filter_conditions.append({field: {"$eq": values}})

    results = index.query(
        vector=generate_embedding(query_text),
        top_k=10,
        filter={"$and": filter_conditions} if filter_conditions else {},
        include_metadata=True
    )
    return results

# Usage
results = faceted_search(
    "machine learning tutorials",
    facets={
        "category": ["education", "tutorial"],
        "difficulty": "beginner",
        "language": ["english", "spanish"]
    }
)
```

### Weaviate Metadata Filtering

```python
import weaviate
from weaviate.classes.query import Filter

client = weaviate.connect_to_local()
documents = client.collections.get("Documents")

# 1. Simple equality filter
response = documents.query.near_text(
    query="vector databases",
    limit=10,
    filters=Filter.by_property("category").equal("education")
)

# 2. Greater than filter
response = documents.query.near_text(
    query="machine learning",
    limit=10,
    filters=Filter.by_property("year").greater_than(2020)
)

# 3. Contains any filter
response = documents.query.near_text(
    query="AI tutorials",
    limit=10,
    filters=Filter.by_property("tags").contains_any(["ml", "ai", "deep-learning"])
)

# 4. Complex AND/OR filters
response = documents.query.near_text(
    query="database optimization",
    limit=10,
    filters=(
        Filter.by_property("category").equal("tutorial") &
        (Filter.by_property("difficulty").equal("beginner") |
         Filter.by_property("featured").equal(True))
    )
)
```

### Chroma Metadata Filtering

```python
import chromadb

client = chromadb.PersistentClient(path="./chroma_db")
collection = client.get_collection("documents")

# 1. Simple equality filter
results = collection.query(
    query_texts=["vector databases"],
    n_results=10,
    where={"category": "education"}
)

# 2. AND conditions
results = collection.query(
    query_texts=["machine learning"],
    n_results=10,
    where={
        "$and": [
            {"category": "education"},
            {"difficulty": "beginner"}
        ]
    }
)

# 3. OR conditions
results = collection.query(
    query_texts=["AI tutorials"],
    n_results=10,
    where={
        "$or": [
            {"category": "education"},
            {"category": "tutorial"}
        ]
    }
)

# 4. Greater than/Less than
results = collection.query(
    query_texts=["recent content"],
    n_results=10,
    where={"year": {"$gte": 2023}}
)

# 5. In operator
results = collection.query(
    query_texts=["programming guides"],
    n_results=10,
    where={"language": {"$in": ["python", "javascript", "go"]}}
)
```

## Hybrid Search

### Pinecone Hybrid Search (Dense + Sparse)

```python
from pinecone import Pinecone
from typing import Dict, List
import re
from collections import Counter

pc = Pinecone(api_key="YOUR_API_KEY")
index = pc.Index("hybrid-search-index")

def create_sparse_vector(text: str, top_k: int = 100) -> Dict:
    """Create sparse vector using simple TF approach."""
    # Tokenize
    tokens = re.findall(r'\w+', text.lower())

    # Calculate term frequencies
    tf = Counter(tokens)

    # Create vocabulary mapping
    vocab = {word: hash(word) % 10000 for word in set(tokens)}

    # Get top-k terms
    top_terms = tf.most_common(top_k)

    # Create sparse vector
    indices = [vocab[term] for term, _ in top_terms]
    values = [float(freq) / len(tokens) for _, freq in top_terms]

    return {
        "indices": indices,
        "values": values
    }

def hybrid_search(query_text: str, top_k: int = 10, alpha: float = 0.5):
    """
    Perform hybrid search combining dense and sparse vectors.
    alpha: weight for dense search (0.0 = sparse only, 1.0 = dense only)
    """
    # Generate dense vector
    dense_vector = generate_embedding(query_text)

    # Generate sparse vector
    sparse_vector = create_sparse_vector(query_text)

    # Hybrid query
    results = index.query(
        vector=dense_vector,
        sparse_vector=sparse_vector,
        top_k=top_k,
        include_metadata=True
    )

    return results

# Example usage
results = hybrid_search("machine learning vector databases", top_k=10)
for match in results.matches:
    print(f"{match.metadata['title']}: {match.score:.4f}")
```

### Weaviate Hybrid Search

```python
import weaviate

client = weaviate.connect_to_local()
documents = client.collections.get("Documents")

# Hybrid search (combines dense vector + BM25 keyword search)
response = documents.query.hybrid(
    query="vector database performance",
    limit=10,
    alpha=0.5,  # 0 = pure keyword, 1 = pure vector, 0.5 = balanced
    fusion_type="rankedFusion"  # or "relativeScore"
)

for obj in response.objects:
    print(f"Title: {obj.properties['title']}")
    print(f"Score: {obj.metadata.score}")
    print("---")

# Hybrid search with filters
response = documents.query.hybrid(
    query="machine learning tutorials",
    limit=10,
    alpha=0.7,  # Favor semantic search
    filters=Filter.by_property("category").equal("education")
)

# Hybrid search with custom vector
response = documents.query.hybrid(
    query="custom query",
    vector=[0.1, 0.2, 0.3, ...],  # Your pre-computed vector
    limit=10,
    alpha=0.5
)
```

### BM25 + Vector Hybrid (Custom Implementation)

```python
from rank_bm25 import BM25Okapi
import numpy as np

class HybridSearchEngine:
    """Custom hybrid search combining BM25 and vector search."""

    def __init__(self, index, documents: List[Dict]):
        self.index = index
        self.documents = documents

        # Build BM25 index
        tokenized_docs = [doc['content'].lower().split() for doc in documents]
        self.bm25 = BM25Okapi(tokenized_docs)
        self.doc_ids = [doc['id'] for doc in documents]

    def search(self, query: str, top_k: int = 10, alpha: float = 0.5):
        """
        Hybrid search with custom score fusion.
        alpha: weight for vector search (1-alpha for BM25)
        """
        # 1. Vector search
        query_embedding = generate_embedding(query)
        vector_results = self.index.query(
            vector=query_embedding,
            top_k=top_k * 2,  # Get more candidates
            include_metadata=True
        )

        # 2. BM25 search
        tokenized_query = query.lower().split()
        bm25_scores = self.bm25.get_scores(tokenized_query)

        # 3. Normalize scores
        vector_scores = {
            m.id: m.score for m in vector_results.matches
        }
        max_vec_score = max(vector_scores.values()) if vector_scores else 1.0

        max_bm25_score = max(bm25_scores) if max(bm25_scores) > 0 else 1.0

        # 4. Combine scores
        hybrid_scores = {}
        all_ids = set(vector_scores.keys()) | set(self.doc_ids)

        for doc_id in all_ids:
            vec_score = vector_scores.get(doc_id, 0) / max_vec_score
            idx = self.doc_ids.index(doc_id) if doc_id in self.doc_ids else -1
            bm25_score = bm25_scores[idx] / max_bm25_score if idx >= 0 else 0

            hybrid_scores[doc_id] = (alpha * vec_score) + ((1 - alpha) * bm25_score)

        # 5. Rank and return top-k
        ranked = sorted(hybrid_scores.items(), key=lambda x: x[1], reverse=True)
        return ranked[:top_k]

# Usage
engine = HybridSearchEngine(index, documents)
results = engine.search("machine learning databases", top_k=10, alpha=0.7)
```

## Namespace & Collection Management

### Pinecone Namespaces

```python
from pinecone import Pinecone

pc = Pinecone(api_key="YOUR_API_KEY")
index = pc.Index("production-search")

# 1. Upsert to specific namespace
index.upsert(
    vectors=[
        {"id": "doc1", "values": [...], "metadata": {...}}
    ],
    namespace="production"
)

# 2. Query specific namespace
results = index.query(
    vector=[...],
    top_k=10,
    namespace="production",
    include_metadata=True
)

# 3. Get namespace statistics
stats = index.describe_index_stats()
for namespace, info in stats.namespaces.items():
    print(f"Namespace: {namespace}")
    print(f"  Vector count: {info.vector_count}")

# 4. Delete all vectors in namespace
index.delete(delete_all=True, namespace="test")

# 5. Multi-namespace architecture
NAMESPACES = {
    "production": "Live user-facing data",
    "staging": "Testing before production",
    "development": "Development and experiments",
    "archive": "Historical data"
}

def upsert_with_environment(vectors, environment="production"):
    """Upsert to appropriate namespace."""
    namespace = environment if environment in NAMESPACES else "development"
    index.upsert(vectors=vectors, namespace=namespace)

def search_across_namespaces(query_vector, namespaces=["production", "archive"]):
    """Search multiple namespaces and combine results."""
    all_results = []

    for ns in namespaces:
        results = index.query(
            vector=query_vector,
            top_k=10,
            namespace=ns,
            include_metadata=True
        )
        for match in results.matches:
            match.metadata["source_namespace"] = ns
            all_results.append(match)

    # Sort by score
    all_results.sort(key=lambda x: x.score, reverse=True)
    return all_results[:10]
```

### Weaviate Collections

```python
import weaviate
from weaviate.classes.config import Configure

client = weaviate.connect_to_local()

# 1. Create multiple collections
collections_config = [
    {
        "name": "Products",
        "properties": ["name", "description", "category", "price"]
    },
    {
        "name": "Users",
        "properties": ["username", "bio", "interests"]
    },
    {
        "name": "Reviews",
        "properties": ["content", "rating", "product_id", "user_id"]
    }
]

for config in collections_config:
    try:
        client.collections.create(
            name=config["name"],
            vectorizer_config=Configure.Vectorizer.text2vec_openai()
        )
    except Exception as e:
        print(f"Collection {config['name']} exists: {e}")

# 2. Cross-collection references
client.collections.create(
    name="Orders",
    references=[
        weaviate.classes.config.ReferenceProperty(
            name="hasProduct",
            target_collection="Products"
        ),
        weaviate.classes.config.ReferenceProperty(
            name="byUser",
            target_collection="Users"
        )
    ]
)

# 3. Multi-collection search
def search_all_collections(query: str):
    """Search across multiple collections."""
    results = {}

    for collection_name in ["Products", "Users", "Reviews"]:
        collection = client.collections.get(collection_name)
        response = collection.query.near_text(
            query=query,
            limit=5
        )
        results[collection_name] = response.objects

    return results

# 4. Delete collection
client.collections.delete("TestCollection")
```

### Chroma Collections

```python
import chromadb

client = chromadb.PersistentClient(path="./chroma_db")

# 1. Create multiple collections
collections = {
    "documents": {
        "metadata": {"description": "Document embeddings"},
        "embedding_function": None  # Use default
    },
    "images": {
        "metadata": {"description": "Image embeddings"},
        "embedding_function": None
    },
    "code": {
        "metadata": {"description": "Code snippets"},
        "embedding_function": None
    }
}

for name, config in collections.items():
    collection = client.get_or_create_collection(
        name=name,
        metadata=config["metadata"]
    )

# 2. List all collections
all_collections = client.list_collections()
for coll in all_collections:
    print(f"Collection: {coll.name}")
    print(f"  Count: {coll.count()}")
    print(f"  Metadata: {coll.metadata}")

# 3. Collection-specific operations
docs_collection = client.get_collection("documents")
docs_collection.add(
    documents=["Document text..."],
    metadatas=[{"type": "article"}],
    ids=["doc1"]
)

# 4. Delete collection
client.delete_collection("test_collection")

# 5. Multi-collection search
def search_all_collections(query: str, n_results: int = 5):
    """Search across all collections."""
    results = {}

    for collection in client.list_collections():
        try:
            collection_results = collection.query(
                query_texts=[query],
                n_results=n_results
            )
            results[collection.name] = collection_results
        except Exception as e:
            print(f"Error searching {collection.name}: {e}")

    return results
```

## Performance & Scaling

### Batch Operations Best Practices

```python
from pinecone import Pinecone
from typing import List, Dict
import asyncio
from concurrent.futures import ThreadPoolExecutor
import time

pc = Pinecone(api_key="YOUR_API_KEY")
index = pc.Index("production-search")

# 1. Optimal batch size
OPTIMAL_BATCH_SIZE = 100  # Pinecone recommendation

def batch_upsert(vectors: List[Dict], batch_size: int = OPTIMAL_BATCH_SIZE):
    """Efficiently upsert vectors in batches."""
    total_batches = (len(vectors) + batch_size - 1) // batch_size

    for i in range(0, len(vectors), batch_size):
        batch = vectors[i:i + batch_size]
        index.upsert(vectors=batch, namespace="documents")

        if (i // batch_size + 1) % 10 == 0:
            print(f"Processed {i // batch_size + 1}/{total_batches} batches")

# 2. Parallel batch upsert
def parallel_batch_upsert(vectors: List[Dict], num_workers: int = 4):
    """Parallel upsert using thread pool."""
    batch_size = 100
    batches = [
        vectors[i:i + batch_size]
        for i in range(0, len(vectors), batch_size)
    ]

    def upsert_batch(batch):
        try:
            index.upsert(vectors=batch, namespace="documents")
            return len(batch)
        except Exception as e:
            print(f"Error upserting batch: {e}")
            return 0

    with ThreadPoolExecutor(max_workers=num_workers) as executor:
        results = list(executor.map(upsert_batch, batches))

    print(f"Successfully upserted {sum(results)} vectors")

# 3. Rate limiting for API calls
class RateLimiter:
    """Simple rate limiter for API calls."""

    def __init__(self, max_calls: int, time_window: float):
        self.max_calls = max_calls
        self.time_window = time_window
        self.calls = []

    def wait_if_needed(self):
        """Wait if rate limit would be exceeded."""
        now = time.time()
        # Remove old calls outside time window
        self.calls = [call_time for call_time in self.calls
                      if now - call_time < self.time_window]

        if len(self.calls) >= self.max_calls:
            sleep_time = self.time_window - (now - self.calls[0])
            if sleep_time > 0:
                time.sleep(sleep_time)
                self.calls = []

        self.calls.append(now)

# Usage
rate_limiter = RateLimiter(max_calls=100, time_window=60)  # 100 calls/minute

for batch in batches:
    rate_limiter.wait_if_needed()
    index.upsert(vectors=batch)

# 4. Bulk delete optimization
def bulk_delete_by_filter(filter_dict: Dict, namespace: str = "documents"):
    """Delete vectors matching filter (more efficient than individual deletes)."""
    # First, get IDs matching filter
    results = index.query(
        vector=[0] * 1536,  # Dummy vector
        top_k=10000,  # Max allowed
        filter=filter_dict,
        namespace=namespace,
        include_values=False
    )

    ids_to_delete = [match.id for match in results.matches]

    # Delete in batches
    batch_size = 1000
    for i in range(0, len(ids_to_delete), batch_size):
        batch = ids_to_delete[i:i + batch_size]
        index.delete(ids=batch, namespace=namespace)
        print(f"Deleted {len(batch)} vectors")
```

### Query Optimization

```python
# 1. Minimize data transfer
results = index.query(
    vector=query_vector,
    top_k=10,
    include_values=False,  # Don't return vectors if not needed
    include_metadata=False,  # Don't return metadata if not needed
    namespace="documents"
)

# 2. Use appropriate top_k
# Smaller top_k = faster queries
results_small = index.query(vector=query_vector, top_k=10)  # Fast
results_large = index.query(vector=query_vector, top_k=1000)  # Slower

# 3. Filter before vector search when possible
# Good: Reduces search space
results = index.query(
    vector=query_vector,
    top_k=10,
    filter={"category": "education"},  # Reduces candidates
    namespace="documents"
)

# 4. Batch queries when possible
# More efficient than individual queries
queries = [embedding1, embedding2, embedding3]
results = index.query(
    queries=queries,
    top_k=10,
    namespace="documents"
)

# 5. Cache frequent queries
from functools import lru_cache
import hashlib
import json

def vector_hash(vector: List[float]) -> str:
    """Create hash of vector for caching."""
    return hashlib.md5(json.dumps(vector).encode()).hexdigest()

class CachedIndex:
    """Wrapper with query caching."""

    def __init__(self, index, cache_size: int = 1000):
        self.index = index
        self.cache = {}
        self.cache_size = cache_size

    def query(self, vector: List[float], top_k: int = 10, **kwargs):
        """Query with caching."""
        cache_key = f"{vector_hash(vector)}_{top_k}_{json.dumps(kwargs)}"

        if cache_key in self.cache:
            return self.cache[cache_key]

        results = self.index.query(vector=vector, top_k=top_k, **kwargs)

        if len(self.cache) >= self.cache_size:
            # Remove oldest entry
            self.cache.pop(next(iter(self.cache)))

        self.cache[cache_key] = results
        return results

# Usage
cached_index = CachedIndex(index)
results = cached_index.query(query_vector, top_k=10)  # Cached on subsequent calls
```

### Scaling Strategies

```python
# 1. Index sizing for scale
def calculate_index_requirements(
    num_vectors: int,
    dimension: int,
    metadata_size_per_vector: int = 1024  # bytes
) -> Dict:
    """Calculate storage and cost for index."""
    # Approximate calculations
    vector_size = dimension * 4  # 4 bytes per float32
    total_vector_storage = num_vectors * vector_size
    total_metadata_storage = num_vectors * metadata_size_per_vector
    total_storage = total_vector_storage + total_metadata_storage

    # Pinecone pricing (approximate)
    storage_cost_per_gb_month = 0.095  # Serverless pricing
    total_gb = total_storage / (1024 ** 3)
    monthly_storage_cost = total_gb * storage_cost_per_gb_month

    return {
        "num_vectors": num_vectors,
        "total_storage_gb": round(total_gb, 2),
        "monthly_storage_cost_usd": round(monthly_storage_cost, 2),
        "recommended_pod_type": "s1.x1" if num_vectors > 10_000_000 else "p1.x1"
    }

# Example
reqs = calculate_index_requirements(
    num_vectors=10_000_000,
    dimension=1536
)
print(f"10M vectors storage: {reqs['total_storage_gb']} GB")
print(f"Monthly cost: ${reqs['monthly_storage_cost_usd']}")

# 2. Sharding strategy for massive scale
def create_sharded_indexes(
    base_name: str,
    num_shards: int,
    dimension: int,
    metric: str = "cosine"
):
    """Create multiple indexes for horizontal scaling."""
    indexes = []

    for shard_id in range(num_shards):
        index_name = f"{base_name}-shard-{shard_id}"

        pc.create_index(
            name=index_name,
            dimension=dimension,
            metric=metric,
            spec=ServerlessSpec(cloud="aws", region="us-east-1")
        )

        indexes.append(index_name)

    return indexes

def route_to_shard(vector_id: str, num_shards: int) -> int:
    """Determine which shard a vector belongs to."""
    return hash(vector_id) % num_shards

def query_sharded_indexes(query_vector: List[float], indexes: List, top_k: int = 10):
    """Query all shards and merge results."""
    all_results = []

    for index_name in indexes:
        idx = pc.Index(index_name)
        results = idx.query(
            vector=query_vector,
            top_k=top_k,
            include_metadata=True
        )
        all_results.extend(results.matches)

    # Sort by score and return top_k
    all_results.sort(key=lambda x: x.score, reverse=True)
    return all_results[:top_k]
```

## Production Best Practices

### Error Handling & Retries

```python
import time
from typing import Optional, Callable
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class PineconeRetryHandler:
    """Robust error handling for Pinecone operations."""

    def __init__(self, max_retries: int = 3, base_delay: float = 1.0):
        self.max_retries = max_retries
        self.base_delay = base_delay

    def retry_with_backoff(
        self,
        operation: Callable,
        *args,
        **kwargs
    ) -> Optional[any]:
        """Retry operation with exponential backoff."""
        for attempt in range(self.max_retries):
            try:
                return operation(*args, **kwargs)
            except Exception as e:
                if attempt == self.max_retries - 1:
                    logger.error(f"Operation failed after {self.max_retries} attempts: {e}")
                    raise

                delay = self.base_delay * (2 ** attempt)
                logger.warning(f"Attempt {attempt + 1} failed: {e}. Retrying in {delay}s...")
                time.sleep(delay)

        return None

# Usage
retry_handler = PineconeRetryHandler(max_retries=3)

# Upsert with retry
def safe_upsert(vectors, namespace="documents"):
    return retry_handler.retry_with_backoff(
        index.upsert,
        vectors=vectors,
        namespace=namespace
    )

# Query with retry
def safe_query(vector, top_k=10, **kwargs):
    return retry_handler.retry_with_backoff(
        index.query,
        vector=vector,
        top_k=top_k,
        **kwargs
    )

# Example
try:
    results = safe_query(query_vector, top_k=10, include_metadata=True)
except Exception as e:
    logger.error(f"Query failed permanently: {e}")
```

### Monitoring & Observability

```python
import time
from dataclasses import dataclass
from typing import Dict, List
from datetime import datetime

@dataclass
class QueryMetrics:
    """Track query performance metrics."""
    query_time: float
    result_count: int
    top_score: float
    timestamp: datetime
    namespace: str
    filter_used: bool

class VectorDBMonitor:
    """Monitor vector database operations."""

    def __init__(self):
        self.metrics: List[QueryMetrics] = []

    def track_query(
        self,
        query_func: Callable,
        *args,
        **kwargs
    ):
        """Track query execution and metrics."""
        start_time = time.time()
        results = query_func(*args, **kwargs)
        elapsed = time.time() - start_time

        metrics = QueryMetrics(
            query_time=elapsed,
            result_count=len(results.matches),
            top_score=results.matches[0].score if results.matches else 0.0,
            timestamp=datetime.now(),
            namespace=kwargs.get('namespace', 'default'),
            filter_used='filter' in kwargs
        )

        self.metrics.append(metrics)

        # Alert on slow queries
        if elapsed > 1.0:  # 1 second threshold
            logger.warning(f"Slow query detected: {elapsed:.2f}s")

        return results

    def get_stats(self) -> Dict:
        """Get aggregate statistics."""
        if not self.metrics:
            return {}

        query_times = [m.query_time for m in self.metrics]

        return {
            "total_queries": len(self.metrics),
            "avg_query_time": sum(query_times) / len(query_times),
            "p95_query_time": sorted(query_times)[int(len(query_times) * 0.95)],
            "p99_query_time": sorted(query_times)[int(len(query_times) * 0.99)],
            "avg_results": sum(m.result_count for m in self.metrics) / len(self.metrics),
            "filtered_queries_pct": sum(1 for m in self.metrics if m.filter_used) / len(self.metrics) * 100
        }

# Usage
monitor = VectorDBMonitor()

# Wrap queries
results = monitor.track_query(
    index.query,
    vector=query_vector,
    top_k=10,
    namespace="documents",
    filter={"category": "education"}
)

# Get statistics
stats = monitor.get_stats()
print(f"Average query time: {stats['avg_query_time']:.3f}s")
print(f"P95 query time: {stats['p95_query_time']:.3f}s")
```

### Data Validation

```python
from typing import List, Dict
import numpy as np

class VectorValidator:
    """Validate vectors and metadata before operations."""

    def __init__(self, expected_dimension: int):
        self.expected_dimension = expected_dimension

    def validate_vector(self, vector: List[float]) -> tuple[bool, str]:
        """Validate vector format and content."""
        # Check type
        if not isinstance(vector, (list, np.ndarray)):
            return False, "Vector must be list or numpy array"

        # Check dimension
        if len(vector) != self.expected_dimension:
            return False, f"Expected {self.expected_dimension} dimensions, got {len(vector)}"

        # Check for NaN or Inf
        if any(not np.isfinite(v) for v in vector):
            return False, "Vector contains NaN or Inf values"

        # Check for zero vector
        if all(v == 0 for v in vector):
            return False, "Zero vector not allowed"

        return True, "Valid"

    def validate_metadata(self, metadata: Dict) -> tuple[bool, str]:
        """Validate metadata format."""
        # Check type
        if not isinstance(metadata, dict):
            return False, "Metadata must be dictionary"

        # Check metadata size (Pinecone limit: 40KB)
        metadata_str = str(metadata)
        if len(metadata_str.encode('utf-8')) > 40_000:
            return False, "Metadata exceeds 40KB limit"

        # Check for required fields (customize as needed)
        required_fields = ["title", "category"]
        for field in required_fields:
            if field not in metadata:
                return False, f"Missing required field: {field}"

        return True, "Valid"

    def validate_batch(
        self,
        vectors: List[Dict]
    ) -> tuple[List[Dict], List[str]]:
        """Validate batch of vectors, return valid ones and errors."""
        valid_vectors = []
        errors = []

        for i, item in enumerate(vectors):
            # Validate vector
            is_valid, error = self.validate_vector(item.get('values', []))
            if not is_valid:
                errors.append(f"Vector {i} ({item.get('id', 'unknown')}): {error}")
                continue

            # Validate metadata
            if 'metadata' in item:
                is_valid, error = self.validate_metadata(item['metadata'])
                if not is_valid:
                    errors.append(f"Metadata {i} ({item.get('id', 'unknown')}): {error}")
                    continue

            valid_vectors.append(item)

        return valid_vectors, errors

# Usage
validator = VectorValidator(expected_dimension=1536)

# Validate single vector
is_valid, error = validator.validate_vector(embedding)
if not is_valid:
    print(f"Invalid vector: {error}")

# Validate batch
valid_vectors, errors = validator.validate_batch(vectors_to_upsert)
if errors:
    for error in errors:
        logger.error(error)

# Upsert only valid vectors
if valid_vectors:
    index.upsert(vectors=valid_vectors)
```

### Backup & Disaster Recovery

```python
import json
import gzip
from datetime import datetime
from pathlib import Path

class VectorDBBackup:
    """Backup and restore vector database data."""

    def __init__(self, index, backup_dir: str = "./backups"):
        self.index = index
        self.backup_dir = Path(backup_dir)
        self.backup_dir.mkdir(exist_ok=True)

    def backup_namespace(
        self,
        namespace: str = "documents",
        compress: bool = True
    ) -> str:
        """Backup all vectors in a namespace."""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"backup_{namespace}_{timestamp}.json"

        if compress:
            filename += ".gz"

        filepath = self.backup_dir / filename

        # Fetch all vectors (in batches)
        all_vectors = []
        batch_size = 100

        # Get all IDs first (would need to be tracked separately)
        # This is a simplified example
        stats = self.index.describe_index_stats()

        # For actual implementation, you'd need to track IDs
        # or use fetch with known IDs

        # Save to file
        data = {
            "namespace": namespace,
            "timestamp": timestamp,
            "vector_count": len(all_vectors),
            "vectors": all_vectors
        }

        if compress:
            with gzip.open(filepath, 'wt', encoding='utf-8') as f:
                json.dump(data, f)
        else:
            with open(filepath, 'w') as f:
                json.dump(data, f, indent=2)

        logger.info(f"Backed up {len(all_vectors)} vectors to {filepath}")
        return str(filepath)

    def restore_from_backup(
        self,
        backup_file: str,
        target_namespace: str = None
    ):
        """Restore vectors from backup file."""
        filepath = Path(backup_file)

        # Load backup
        if filepath.suffix == '.gz':
            with gzip.open(filepath, 'rt', encoding='utf-8') as f:
                data = json.load(f)
        else:
            with open(filepath, 'r') as f:
                data = json.load(f)

        namespace = target_namespace or data['namespace']
        vectors = data['vectors']

        # Restore in batches
        batch_size = 100
        for i in range(0, len(vectors), batch_size):
            batch = vectors[i:i + batch_size]
            self.index.upsert(vectors=batch, namespace=namespace)
            logger.info(f"Restored {len(batch)} vectors")

        logger.info(f"Restored {len(vectors)} vectors to namespace '{namespace}'")

# Usage
backup_manager = VectorDBBackup(index)

# Backup
backup_file = backup_manager.backup_namespace("production")

# Restore
backup_manager.restore_from_backup(backup_file, target_namespace="production-restored")
```

## Cost Optimization

### Storage Optimization

```python
# 1. Reduce metadata size
# Bad: Storing full content in metadata
bad_metadata = {
    "title": "Long document title",
    "full_content": "...<entire document>...",  # Wastes space
    "description": "...<long description>...",
    "extra_field_1": "...",
    "extra_field_2": "..."
}

# Good: Store only necessary metadata
good_metadata = {
    "title": "Long document title",
    "doc_id": "doc-123",  # Reference to external store
    "category": "education",
    "created_at": "2024-01-15"
}

# 2. Use selective metadata indexing
# Only index fields you'll filter on
pc.create_index(
    name="optimized-index",
    dimension=1536,
    metric="cosine",
    spec=ServerlessSpec(
        cloud="aws",
        region="us-east-1",
        schema={
            "fields": {
                "category": {"filterable": True},  # Need to filter
                "created_at": {"filterable": True},  # Need to filter
                "title": {"filterable": False},  # Just for display
                "description": {"filterable": False}  # Just for display
            }
        }
    )
)

# 3. Regular cleanup of unused vectors
def cleanup_old_vectors(days_old: int = 90):
    """Delete vectors older than specified days."""
    from datetime import datetime, timedelta

    cutoff_date = (datetime.now() - timedelta(days=days_old)).isoformat()

    # Delete by filter
    index.delete(
        filter={"created_at": {"$lt": cutoff_date}},
        namespace="documents"
    )

# 4. Compress dimensions for smaller models
# text-embedding-3-small: 1536 dimensions
# all-MiniLM-L6-v2: 384 dimensions (75% storage reduction)

# Trade-off: slightly lower accuracy for significant cost savings
```

### Query Cost Optimization

```python
# 1. Batch queries instead of individual
# Bad: Multiple individual queries
for query in queries:
    results = index.query(vector=query, top_k=10)  # N API calls

# Good: Single batch query
results = index.query(
    queries=query_vectors,  # 1 API call
    top_k=10
)

# 2. Use appropriate top_k
# Larger top_k = more expensive
results = index.query(
    vector=query_vector,
    top_k=10,  # Usually sufficient
    # top_k=1000  # Much more expensive
)

# 3. Minimize data transfer
results = index.query(
    vector=query_vector,
    top_k=10,
    include_values=False,  # Save bandwidth
    include_metadata=False  # Save bandwidth if not needed
)

# 4. Use caching for repeated queries
from functools import lru_cache

@lru_cache(maxsize=1000)
def cached_search(query_text: str, top_k: int = 10):
    """Cache search results for identical queries."""
    embedding = generate_embedding(query_text)
    results = index.query(
        vector=embedding,
        top_k=top_k,
        include_metadata=True
    )
    return results

# 5. Choose serverless vs pods appropriately
# Serverless: Low/variable traffic (pay per query)
# Pods: High consistent traffic (fixed cost)

def choose_deployment_type(
    queries_per_month: int,
    avg_response_time_requirement: float = 100  # ms
) -> str:
    """Recommend deployment type based on usage."""
    # Rough cost calculations (update with current pricing)
    serverless_cost_per_query = 0.0001  # Example
    pod_cost_per_month = 70  # p1.x1 pod

    serverless_monthly_cost = queries_per_month * serverless_cost_per_query

    if serverless_monthly_cost < pod_cost_per_month:
        return "serverless"
    else:
        return "pods"
```

### Cost Monitoring

```python
import json
from datetime import datetime, timedelta
from collections import defaultdict

class CostMonitor:
    """Monitor and estimate vector database costs."""

    def __init__(self):
        self.operations = defaultdict(int)
        self.pricing = {
            "serverless_write_units": 0.0000025,  # per write unit
            "serverless_read_units": 0.00000625,  # per read unit
            "serverless_storage_gb": 0.095,  # per GB per month
            "p1_x1_pod": 0.096,  # per hour
            "p2_x1_pod": 0.240,  # per hour
        }

    def track_operation(self, operation_type: str, units: int = 1):
        """Track database operations."""
        self.operations[operation_type] += units

    def estimate_monthly_cost(
        self,
        deployment_type: str,
        storage_gb: float = 0,
        pod_type: str = None
    ) -> Dict:
        """Estimate monthly costs."""
        costs = {}

        if deployment_type == "serverless":
            # Storage cost
            storage_cost = storage_gb * self.pricing["serverless_storage_gb"]

            # Operation costs
            write_cost = (
                self.operations["upsert"] *
                self.pricing["serverless_write_units"]
            )
            read_cost = (
                self.operations["query"] *
                self.pricing["serverless_read_units"]
            )

            costs = {
                "storage": storage_cost,
                "writes": write_cost,
                "reads": read_cost,
                "total": storage_cost + write_cost + read_cost
            }

        elif deployment_type == "pods":
            # Fixed pod cost
            hours_per_month = 730
            pod_cost = self.pricing.get(f"{pod_type}_pod", 0) * hours_per_month

            costs = {
                "pod": pod_cost,
                "total": pod_cost
            }

        return costs

    def get_cost_report(self) -> str:
        """Generate cost report."""
        report = f"\n{'=' * 50}\n"
        report += "VECTOR DATABASE COST REPORT\n"
        report += f"{'=' * 50}\n\n"
        report += "Operations Summary:\n"

        for operation, count in self.operations.items():
            report += f"  {operation}: {count:,}\n"

        report += f"\n{'=' * 50}\n"
        return report

# Usage
cost_monitor = CostMonitor()

# Track operations
def monitored_upsert(vectors, **kwargs):
    cost_monitor.track_operation("upsert", len(vectors))
    return index.upsert(vectors=vectors, **kwargs)

def monitored_query(vector, **kwargs):
    cost_monitor.track_operation("query", 1)
    return index.query(vector=vector, **kwargs)

# Get cost estimate
monthly_cost = cost_monitor.estimate_monthly_cost(
    deployment_type="serverless",
    storage_gb=10.5
)

print(f"Estimated monthly cost: ${monthly_cost['total']:.2f}")
print(cost_monitor.get_cost_report())
```

---

## Summary

This comprehensive guide covers all aspects of vector database management across Pinecone, Weaviate, and Chroma. Key takeaways:

1. **Choose the right database**: Pinecone for production scale, Weaviate for knowledge graphs, Chroma for local development
2. **Optimize embeddings**: Balance dimension size with accuracy and cost
3. **Use metadata filtering**: Combine vector similarity with structured filtering for powerful search
4. **Implement hybrid search**: Combine dense and sparse vectors for best results
5. **Scale efficiently**: Use batching, caching, and appropriate index configurations
6. **Monitor and optimize costs**: Track usage and choose the right deployment type

For more information:
- Pinecone Documentation: https://docs.pinecone.io
- Weaviate Documentation: https://weaviate.io/developers/weaviate
- Chroma Documentation: https://docs.trychroma.com
