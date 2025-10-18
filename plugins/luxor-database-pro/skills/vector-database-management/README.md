# Vector Database Management

A comprehensive guide to managing vector databases for semantic search, RAG systems, and similarity-based applications using Pinecone, Weaviate, and Chroma.

## Quick Start

### Installation

```bash
# Install Pinecone
pip install pinecone-client

# Install Weaviate
pip install weaviate-client

# Install Chroma
pip install chromadb

# Install OpenAI for embeddings
pip install openai

# Install optional dependencies
pip install sentence-transformers numpy pandas
```

### 5-Minute Setup

#### Pinecone

```python
from pinecone import Pinecone, ServerlessSpec
from openai import OpenAI

# Initialize clients
pc = Pinecone(api_key="YOUR_PINECONE_API_KEY")
openai_client = OpenAI(api_key="YOUR_OPENAI_API_KEY")

# Create index
index_name = "quickstart"
if index_name not in [idx.name for idx in pc.list_indexes()]:
    pc.create_index(
        name=index_name,
        dimension=1536,
        metric="cosine",
        spec=ServerlessSpec(cloud="aws", region="us-east-1")
    )

index = pc.Index(index_name)

# Generate embedding
def embed(text):
    response = openai_client.embeddings.create(
        input=text,
        model="text-embedding-3-small"
    )
    return response.data[0].embedding

# Upsert vectors
index.upsert(vectors=[
    {
        "id": "doc1",
        "values": embed("Pinecone is a vector database"),
        "metadata": {"title": "What is Pinecone?", "category": "intro"}
    },
    {
        "id": "doc2",
        "values": embed("Vector databases enable semantic search"),
        "metadata": {"title": "Semantic Search", "category": "concepts"}
    }
])

# Query
query_text = "Tell me about vector databases"
results = index.query(
    vector=embed(query_text),
    top_k=2,
    include_metadata=True
)

for match in results.matches:
    print(f"{match.metadata['title']}: {match.score:.4f}")
```

#### Weaviate

```python
import weaviate
from weaviate.classes.config import Configure

# Connect
client = weaviate.connect_to_local()

# Create collection
collection = client.collections.create(
    name="Documents",
    vectorizer_config=Configure.Vectorizer.text2vec_openai()
)

# Add data
collection.data.insert_many([
    {
        "title": "What is Weaviate?",
        "content": "Weaviate is a vector database",
        "category": "intro"
    },
    {
        "title": "Semantic Search",
        "content": "Vector databases enable semantic search",
        "category": "concepts"
    }
])

# Search
documents = client.collections.get("Documents")
response = documents.query.near_text(
    query="Tell me about vector databases",
    limit=2
)

for obj in response.objects:
    print(f"{obj.properties['title']}")
```

#### Chroma

```python
import chromadb

# Initialize
client = chromadb.PersistentClient(path="./chroma_db")
collection = client.get_or_create_collection(name="documents")

# Add data
collection.add(
    documents=[
        "Chroma is a vector database",
        "Vector databases enable semantic search"
    ],
    metadatas=[
        {"title": "What is Chroma?", "category": "intro"},
        {"title": "Semantic Search", "category": "concepts"}
    ],
    ids=["doc1", "doc2"]
)

# Query
results = collection.query(
    query_texts=["Tell me about vector databases"],
    n_results=2
)

for i, doc_id in enumerate(results['ids'][0]):
    print(f"{results['metadatas'][0][i]['title']}: {results['distances'][0][i]:.4f}")
```

## Vector Database Comparison

### Feature Matrix

| Feature | Pinecone | Weaviate | Chroma |
|---------|----------|----------|--------|
| **Deployment** | Fully managed cloud | Managed or self-hosted | Self-hosted or cloud |
| **Scale** | Billions of vectors | Millions-billions | Thousands-millions |
| **Indexing** | Proprietary (similar to HNSW) | HNSW | HNSW |
| **Similarity Metrics** | Cosine, Dot Product, Euclidean | Cosine, Dot Product, L2, Hamming, Manhattan | Cosine, L2, Inner Product |
| **Sparse Vectors** | Yes (hybrid search) | Yes (via modules) | Limited |
| **Metadata Filtering** | Advanced with operators | GraphQL-based | Simple key-value |
| **Namespaces** | Yes | Collections | Collections |
| **Multi-tenancy** | Namespaces | Collections | Collections |
| **Hybrid Search** | Dense + Sparse | Built-in BM25 | Limited |
| **API** | Python, Node.js, Go, Java | Python, TypeScript, Go, Java | Python, JavaScript |
| **Pricing Model** | Pay-per-use or pods | Usage-based or self-hosted | Free (self-hosted) |
| **Best For** | Production RAG, large scale | Knowledge graphs, complex schemas | Development, small-medium projects |

### Performance Comparison

```python
import time
import numpy as np

def benchmark_database(db_type: str, num_vectors: int = 10000, dimension: int = 1536):
    """Benchmark vector database operations."""

    # Generate test data
    vectors = np.random.rand(num_vectors, dimension).tolist()

    results = {
        "database": db_type,
        "num_vectors": num_vectors,
        "dimension": dimension
    }

    if db_type == "pinecone":
        # Upsert benchmark
        start = time.time()
        batch_size = 100
        for i in range(0, num_vectors, batch_size):
            batch = [
                {"id": f"vec{j}", "values": vectors[j]}
                for j in range(i, min(i + batch_size, num_vectors))
            ]
            index.upsert(vectors=batch)
        results["upsert_time"] = time.time() - start

        # Query benchmark
        query_vector = vectors[0]
        start = time.time()
        for _ in range(100):
            index.query(vector=query_vector, top_k=10)
        results["query_time_per_100"] = time.time() - start

    elif db_type == "weaviate":
        # Similar benchmarking for Weaviate
        pass

    elif db_type == "chroma":
        # Similar benchmarking for Chroma
        pass

    return results

# Typical results (approximate):
# Pinecone: Upsert ~1000 vectors/sec, Query ~50ms
# Weaviate: Upsert ~500 vectors/sec, Query ~30ms
# Chroma: Upsert ~2000 vectors/sec (local), Query ~10ms (small datasets)
```

### Cost Comparison

```python
def estimate_monthly_cost(
    num_vectors: int,
    dimension: int,
    queries_per_month: int,
    upserts_per_month: int
):
    """Estimate monthly costs for each database."""

    # Storage size calculation
    vector_size_bytes = dimension * 4  # float32
    metadata_size_bytes = 1024  # average
    total_size_gb = (num_vectors * (vector_size_bytes + metadata_size_bytes)) / (1024 ** 3)

    costs = {}

    # Pinecone Serverless (approximate pricing)
    pinecone_storage = total_size_gb * 0.095  # per GB/month
    pinecone_read = (queries_per_month / 1000) * 0.00625  # per 1000 read units
    pinecone_write = (upserts_per_month / 1000) * 0.0025  # per 1000 write units
    costs["pinecone_serverless"] = {
        "storage": pinecone_storage,
        "reads": pinecone_read,
        "writes": pinecone_write,
        "total": pinecone_storage + pinecone_read + pinecone_write
    }

    # Pinecone Pods (p1.x1)
    costs["pinecone_pods_p1x1"] = {
        "fixed_monthly": 70,  # approximate
        "total": 70
    }

    # Weaviate Cloud (approximate)
    weaviate_compute = 50  # base compute
    weaviate_storage = total_size_gb * 0.25  # per GB/month
    costs["weaviate_cloud"] = {
        "compute": weaviate_compute,
        "storage": weaviate_storage,
        "total": weaviate_compute + weaviate_storage
    }

    # Chroma (self-hosted)
    # Server costs vary by provider
    costs["chroma_self_hosted"] = {
        "infrastructure": "Variable (AWS EC2, GCP, etc.)",
        "software": 0,  # Open source
        "total": "Depends on infrastructure"
    }

    return costs

# Example: 1M vectors, 1536 dimensions, 100k queries/month, 10k upserts/month
costs = estimate_monthly_cost(
    num_vectors=1_000_000,
    dimension=1536,
    queries_per_month=100_000,
    upserts_per_month=10_000
)

print("Estimated Monthly Costs:")
for db, cost_breakdown in costs.items():
    if isinstance(cost_breakdown, dict) and "total" in cost_breakdown:
        print(f"{db}: ${cost_breakdown['total']:.2f}")
```

## Architecture Patterns

### Pattern 1: RAG (Retrieval Augmented Generation)

```python
from openai import OpenAI
from pinecone import Pinecone

class RAGSystem:
    """Retrieval Augmented Generation system using vector database."""

    def __init__(self, index_name: str):
        self.pc = Pinecone(api_key="PINECONE_API_KEY")
        self.index = self.pc.Index(index_name)
        self.openai = OpenAI(api_key="OPENAI_API_KEY")

    def embed(self, text: str) -> list[float]:
        """Generate embedding for text."""
        response = self.openai.embeddings.create(
            input=text,
            model="text-embedding-3-small"
        )
        return response.data[0].embedding

    def add_documents(self, documents: list[dict]):
        """Add documents to vector database."""
        vectors = []
        for doc in documents:
            vectors.append({
                "id": doc["id"],
                "values": self.embed(doc["content"]),
                "metadata": {
                    "title": doc["title"],
                    "content": doc["content"][:500],  # Store snippet
                    "source": doc.get("source", "")
                }
            })

        self.index.upsert(vectors=vectors)

    def retrieve(self, query: str, top_k: int = 5) -> list[dict]:
        """Retrieve relevant documents for query."""
        query_embedding = self.embed(query)
        results = self.index.query(
            vector=query_embedding,
            top_k=top_k,
            include_metadata=True
        )

        return [
            {
                "content": match.metadata["content"],
                "title": match.metadata["title"],
                "score": match.score
            }
            for match in results.matches
        ]

    def generate_answer(self, query: str, context_docs: list[dict]) -> str:
        """Generate answer using retrieved context."""
        context = "\n\n".join([
            f"Source: {doc['title']}\n{doc['content']}"
            for doc in context_docs
        ])

        prompt = f"""Answer the question based on the context below.

Context:
{context}

Question: {query}

Answer:"""

        response = self.openai.chat.completions.create(
            model="gpt-4",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.7
        )

        return response.choices[0].message.content

    def query(self, question: str) -> dict:
        """End-to-end RAG query."""
        # 1. Retrieve relevant documents
        docs = self.retrieve(question, top_k=5)

        # 2. Generate answer
        answer = self.generate_answer(question, docs)

        return {
            "question": question,
            "answer": answer,
            "sources": [{"title": doc["title"], "score": doc["score"]} for doc in docs]
        }

# Usage
rag = RAGSystem("knowledge-base")

# Add documents
rag.add_documents([
    {
        "id": "doc1",
        "title": "Vector Databases Overview",
        "content": "Vector databases store and search embeddings...",
        "source": "https://example.com/docs/vectors"
    }
])

# Query
result = rag.query("What are vector databases?")
print(f"Answer: {result['answer']}")
print(f"Sources: {result['sources']}")
```

### Pattern 2: Semantic Search

```python
class SemanticSearchEngine:
    """Production-grade semantic search engine."""

    def __init__(self, index_name: str):
        self.pc = Pinecone(api_key="PINECONE_API_KEY")
        self.index = self.pc.Index(index_name)
        self.openai = OpenAI(api_key="OPENAI_API_KEY")

    def index_documents(self, documents: list[dict], batch_size: int = 100):
        """Index documents with progress tracking."""
        total = len(documents)

        for i in range(0, total, batch_size):
            batch = documents[i:i + batch_size]
            vectors = []

            for doc in batch:
                embedding = self.embed(doc["text"])
                vectors.append({
                    "id": doc["id"],
                    "values": embedding,
                    "metadata": {
                        "title": doc["title"],
                        "category": doc.get("category", "general"),
                        "url": doc.get("url", ""),
                        "created_at": doc.get("created_at", "")
                    }
                })

            self.index.upsert(vectors=vectors)
            print(f"Indexed {min(i + batch_size, total)}/{total} documents")

    def search(
        self,
        query: str,
        filters: dict = None,
        top_k: int = 10
    ) -> list[dict]:
        """Search with optional filters."""
        query_embedding = self.embed(query)

        results = self.index.query(
            vector=query_embedding,
            top_k=top_k,
            filter=filters,
            include_metadata=True
        )

        return [
            {
                "id": match.id,
                "title": match.metadata["title"],
                "category": match.metadata["category"],
                "url": match.metadata["url"],
                "relevance_score": match.score
            }
            for match in results.matches
        ]

    def search_with_filters(
        self,
        query: str,
        category: str = None,
        date_from: str = None,
        top_k: int = 10
    ) -> list[dict]:
        """Search with convenience filter parameters."""
        filters = {}

        if category:
            filters["category"] = {"$eq": category}

        if date_from:
            filters["created_at"] = {"$gte": date_from}

        return self.search(query, filters=filters if filters else None, top_k=top_k)

    def embed(self, text: str) -> list[float]:
        """Generate embedding."""
        response = self.openai.embeddings.create(
            input=text,
            model="text-embedding-3-small"
        )
        return response.data[0].embedding

# Usage
search_engine = SemanticSearchEngine("semantic-search")

# Search
results = search_engine.search_with_filters(
    query="machine learning tutorials",
    category="education",
    date_from="2024-01-01",
    top_k=10
)

for result in results:
    print(f"{result['title']} - Score: {result['relevance_score']:.4f}")
```

### Pattern 3: Recommendation System

```python
class VectorRecommendationSystem:
    """Content-based recommendation using vector similarity."""

    def __init__(self, index_name: str):
        self.pc = Pinecone(api_key="PINECONE_API_KEY")
        self.index = self.pc.Index(index_name)

    def recommend_by_item(
        self,
        item_id: str,
        top_k: int = 10,
        filters: dict = None
    ) -> list[dict]:
        """Recommend similar items based on a given item."""
        results = self.index.query(
            id=item_id,  # Query by existing vector
            top_k=top_k + 1,  # +1 to account for self
            filter=filters,
            include_metadata=True
        )

        # Skip first result (self)
        recommendations = [
            {
                "id": match.id,
                "title": match.metadata.get("title", ""),
                "similarity_score": match.score
            }
            for match in results.matches[1:]
        ]

        return recommendations

    def recommend_by_user_history(
        self,
        user_id: str,
        interaction_history: list[str],
        top_k: int = 10
    ) -> list[dict]:
        """Recommend based on user's interaction history."""
        # Fetch user's interacted items
        vectors = []
        for item_id in interaction_history[-10:]:  # Last 10 items
            try:
                item = self.index.fetch(ids=[item_id])
                if item_id in item.vectors:
                    vectors.append(item.vectors[item_id].values)
            except:
                continue

        if not vectors:
            return []

        # Average embeddings
        avg_vector = [sum(col) / len(vectors) for col in zip(*vectors)]

        # Query with averaged vector
        results = self.index.query(
            vector=avg_vector,
            top_k=top_k * 2,  # Get more candidates
            filter={"item_id": {"$nin": interaction_history}},  # Exclude seen
            include_metadata=True
        )

        return [
            {
                "id": match.id,
                "title": match.metadata.get("title", ""),
                "recommendation_score": match.score
            }
            for match in results.matches[:top_k]
        ]

# Usage
recommender = VectorRecommendationSystem("recommendations")

# Item-based recommendations
similar_items = recommender.recommend_by_item("item-123", top_k=5)

# User-based recommendations
user_history = ["item-1", "item-5", "item-12"]
recommendations = recommender.recommend_by_user_history("user-456", user_history, top_k=10)
```

## Common Use Cases

### 1. Document Search & Q&A

Perfect for searching through large document collections, FAQs, and knowledge bases.

```python
# Index documentation
docs = [
    {"id": "doc1", "title": "Getting Started", "content": "..."},
    {"id": "doc2", "title": "API Reference", "content": "..."},
    {"id": "doc3", "title": "Best Practices", "content": "..."}
]

for doc in docs:
    embedding = generate_embedding(doc["content"])
    index.upsert(vectors=[{
        "id": doc["id"],
        "values": embedding,
        "metadata": {"title": doc["title"], "type": "documentation"}
    }])

# Search
results = index.query(
    vector=generate_embedding("How do I get started?"),
    top_k=3,
    include_metadata=True
)
```

### 2. E-commerce Product Discovery

Semantic product search enabling natural language queries.

```python
# Index products
products = [
    {
        "id": "prod1",
        "name": "Wireless Bluetooth Headphones",
        "description": "Over-ear headphones with noise cancellation",
        "category": "electronics",
        "price": 199.99
    }
]

for product in products:
    text = f"{product['name']} {product['description']}"
    embedding = generate_embedding(text)
    index.upsert(vectors=[{
        "id": product["id"],
        "values": embedding,
        "metadata": {
            "name": product["name"],
            "category": product["category"],
            "price": product["price"]
        }
    }])

# Search with natural language
results = index.query(
    vector=generate_embedding("noise canceling headphones for music"),
    top_k=10,
    filter={"price": {"$lte": 250}},
    include_metadata=True
)
```

### 3. Content Moderation

Identify similar content for duplicate detection and policy enforcement.

```python
# Index flagged content
flagged_content = [
    {"id": "flag1", "text": "Inappropriate content example 1", "category": "spam"},
    {"id": "flag2", "text": "Inappropriate content example 2", "category": "harassment"}
]

# Check new content against flagged content
def check_content(new_content: str, threshold: float = 0.85):
    """Check if content is similar to flagged content."""
    embedding = generate_embedding(new_content)
    results = index.query(
        vector=embedding,
        top_k=1,
        namespace="moderation",
        include_metadata=True
    )

    if results.matches and results.matches[0].score > threshold:
        return {
            "flagged": True,
            "reason": results.matches[0].metadata["category"],
            "similarity": results.matches[0].score
        }

    return {"flagged": False}
```

### 4. Chatbot Intent Matching

Match user queries to predefined intents for conversational AI.

```python
# Index intents
intents = [
    {"id": "int1", "text": "What are your business hours?", "intent": "hours"},
    {"id": "int2", "text": "How can I track my order?", "intent": "order_tracking"},
    {"id": "int3", "text": "I want to return a product", "intent": "returns"}
]

# Match user query to intent
def match_intent(user_query: str) -> str:
    """Match user query to closest intent."""
    embedding = generate_embedding(user_query)
    results = index.query(
        vector=embedding,
        top_k=1,
        namespace="intents",
        include_metadata=True
    )

    if results.matches:
        return results.matches[0].metadata["intent"]
    return "unknown"

# Usage
user_query = "When do you open?"
intent = match_intent(user_query)  # Returns "hours"
```

### 5. Multi-modal Search (Text + Images)

Search across different data types using unified vector space.

```python
# Requires multi-modal embeddings (e.g., CLIP)
from sentence_transformers import SentenceTransformer

model = SentenceTransformer('clip-ViT-B-32')

# Index images
image_embedding = model.encode(Image.open("product.jpg"))
index.upsert(vectors=[{
    "id": "img1",
    "values": image_embedding.tolist(),
    "metadata": {"type": "image", "product_id": "prod1"}
}])

# Search with text
text_embedding = model.encode("red sneakers")
results = index.query(
    vector=text_embedding.tolist(),
    top_k=10,
    filter={"type": "image"},
    include_metadata=True
)
```

## Troubleshooting

### Common Issues

**Issue: Slow query performance**
- Reduce `top_k` value
- Use metadata filters to reduce search space
- Enable selective metadata indexing
- Consider using pods instead of serverless for high QPS

**Issue: Poor search results**
- Verify embedding model matches use case
- Check if embeddings are normalized (for cosine similarity)
- Ensure metadata is accurate and up-to-date
- Try different similarity metrics (cosine vs dot product)

**Issue: High costs**
- Use selective metadata indexing
- Reduce embedding dimensions (smaller models)
- Implement query caching
- Clean up unused vectors regularly
- Choose appropriate deployment type (serverless vs pods)

**Issue: Index creation fails**
- Check API key permissions
- Verify region availability
- Ensure dimension matches embedding model
- Check quota limits

## Next Steps

1. Review the [SKILL.md](./SKILL.md) for comprehensive technical details
2. Explore the [EXAMPLES.md](./EXAMPLES.md) for 18+ production-ready examples
3. Join the community:
   - Pinecone: https://community.pinecone.io
   - Weaviate: https://forum.weaviate.io
   - Chroma: https://discord.gg/MMeYNTmh3x

## Resources

- [Pinecone Documentation](https://docs.pinecone.io)
- [Weaviate Documentation](https://weaviate.io/developers/weaviate)
- [Chroma Documentation](https://docs.trychroma.com)
- [OpenAI Embeddings Guide](https://platform.openai.com/docs/guides/embeddings)
- [Sentence Transformers](https://www.sbert.net)

## License

MIT License - See LICENSE file for details
