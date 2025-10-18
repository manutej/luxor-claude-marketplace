# LangChain Orchestration

Production-grade guide for building LLM applications with LangChain's chains, agents, memory systems, and RAG patterns.

## Quick Start

```python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

# Basic chain
llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)
prompt = ChatPromptTemplate.from_template("Tell me about {topic}")
chain = prompt | llm | StrOutputParser()

result = chain.invoke({"topic": "LangChain"})
print(result)
```

## Installation

```bash
# Core packages
pip install langchain langchain-core langchain-community

# LLM providers
pip install langchain-openai langchain-anthropic langchain-huggingface

# Vector stores
pip install faiss-cpu chromadb pinecone-client

# Additional utilities
pip install langgraph langsmith python-dotenv
```

## Architecture Overview

LangChain orchestration consists of five main components:

### 1. Chains

Compose multiple operations into pipelines using LCEL (LangChain Expression Language).

```python
# Sequential processing
chain = prompt | llm | output_parser

# Parallel processing
from langchain_core.runnables import RunnableParallel

parallel_chain = RunnableParallel(
    summary=summary_chain,
    keywords=keywords_chain,
    sentiment=sentiment_chain
)
```

**Key patterns:**
- Sequential chains: Process data step-by-step
- Map-reduce chains: Parallel processing with aggregation
- Router chains: Dynamic routing based on input
- Conditional chains: Branch execution based on conditions

### 2. Agents

Autonomous systems that use tools and reasoning to accomplish tasks.

```python
from langgraph.prebuilt import create_react_agent

agent = create_react_agent(llm, tools=[search_tool, calculator_tool])

result = agent.invoke({
    "messages": [("user", "What is 25 * 4?")]
})
```

**Agent types:**
- ReAct agents: Reasoning + Acting with iterative tool use
- Conversational agents: Context-aware dialogue systems
- Zero-shot agents: Work without examples
- Structured agents: Use defined input/output schemas

### 3. Memory Systems

Maintain conversation context and user preferences.

```python
from langchain.memory import ConversationBufferMemory

memory = ConversationBufferMemory(
    memory_key="chat_history",
    return_messages=True
)

# Automatically stores and retrieves context
chain = LLMChain(llm=llm, prompt=prompt, memory=memory)
```

**Memory types:**
- Buffer memory: Store complete history
- Window memory: Keep last K interactions
- Summary memory: Summarize long conversations
- Vector memory: Semantic search over history

### 4. RAG (Retrieval-Augmented Generation)

Enhance LLM responses with external knowledge.

```python
from langchain.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain

# Setup retriever from vector store
retriever = vectorstore.as_retriever()

# Build RAG chain
document_chain = create_stuff_documents_chain(llm, prompt)
rag_chain = create_retrieval_chain(retriever, document_chain)

result = rag_chain.invoke({"input": "Your question"})
```

**RAG patterns:**
- Basic RAG: Simple retrieval + generation
- Multi-query RAG: Multiple search queries
- RAG with reranking: Improve relevance
- Conversational RAG: Context-aware retrieval

### 5. Streaming

Real-time token generation for better UX.

```python
for chunk in chain.stream({"topic": "AI"}):
    print(chunk, end="", flush=True)
```

## Common Use Cases

### 1. Question Answering System

Build a QA system over your documents:

```python
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings

# Load and embed documents
embeddings = OpenAIEmbeddings()
vectorstore = FAISS.from_documents(documents, embeddings)

# Create QA chain
from langchain.chains import RetrievalQA

qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=vectorstore.as_retriever()
)

answer = qa_chain.run("What is the main topic of the documents?")
```

### 2. Conversational AI

Create a chatbot with memory:

```python
from langchain.memory import ConversationBufferWindowMemory

memory = ConversationBufferWindowMemory(k=5, return_messages=True)

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant."),
    ("placeholder", "{chat_history}"),
    ("human", "{input}")
])

chain = LLMChain(llm=llm, prompt=prompt, memory=memory)

# Maintains conversation context
response1 = chain.run("Hi, I'm Alice")
response2 = chain.run("What's my name?")  # Remembers Alice
```

### 3. Research Assistant

Agent that can search and analyze information:

```python
from langchain.agents import create_react_agent, AgentExecutor
from langchain_core.tools import Tool

def search_web(query: str) -> str:
    # Your search implementation
    return f"Results for: {query}"

def analyze_data(data: str) -> str:
    # Your analysis implementation
    return f"Analysis of: {data}"

tools = [
    Tool(name="Search", func=search_web, description="Search the web"),
    Tool(name="Analyze", func=analyze_data, description="Analyze data")
]

agent = create_react_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

result = agent_executor.invoke({
    "input": "Research LangChain and analyze its key features"
})
```

### 4. Document Summarization

Summarize long documents efficiently:

```python
from langchain.chains.summarize import load_summarize_chain

# Map-reduce summarization
chain = load_summarize_chain(
    llm,
    chain_type="map_reduce",
    verbose=True
)

summary = chain.run(documents)
```

### 5. Data Extraction

Extract structured information:

```python
from langchain.output_parsers import PydanticOutputParser
from pydantic import BaseModel, Field

class Person(BaseModel):
    name: str = Field(description="Person's name")
    age: int = Field(description="Person's age")
    occupation: str = Field(description="Person's occupation")

parser = PydanticOutputParser(pydantic_object=Person)

prompt = ChatPromptTemplate.from_template(
    """Extract person information:
    {format_instructions}

    Text: {text}"""
).partial(format_instructions=parser.get_format_instructions())

chain = prompt | llm | parser
result = chain.invoke({"text": "John Doe is a 30-year-old engineer"})
# Returns Person object
```

## Learning Path

### Beginner (Week 1-2)

1. **Basic Chains**
   - Understand LCEL syntax
   - Build simple prompt | llm | parser chains
   - Practice with sequential operations

2. **Prompts & Outputs**
   - Create effective prompt templates
   - Use output parsers
   - Handle structured outputs

3. **Simple RAG**
   - Setup vector stores
   - Build basic retrieval chains
   - Test with small document sets

### Intermediate (Week 3-4)

1. **Advanced Chains**
   - Implement map-reduce patterns
   - Build router chains
   - Use conditional logic

2. **Memory Systems**
   - Add conversation memory
   - Implement different memory types
   - Manage context windows

3. **Agent Basics**
   - Create simple ReAct agents
   - Define custom tools
   - Handle agent errors

### Advanced (Week 5-6)

1. **Complex RAG**
   - Multi-query retrieval
   - Reranking strategies
   - Parent document retrieval
   - Conversational RAG

2. **Production Agents**
   - LangGraph integration
   - Structured memory
   - Tool calling patterns
   - Agent orchestration

3. **Monitoring & Optimization**
   - Implement callbacks
   - Setup LangSmith tracing
   - Optimize performance
   - Handle errors gracefully

### Expert (Week 7+)

1. **Custom Components**
   - Build custom retrievers
   - Create specialized chains
   - Implement custom memory

2. **Production Deployment**
   - Caching strategies
   - Rate limiting
   - Batch processing
   - Testing frameworks

3. **Advanced Patterns**
   - Multi-agent systems
   - Complex orchestration
   - Hybrid retrieval
   - Custom evaluation

## Configuration Best Practices

### Environment Setup

```python
# .env file
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
LANGCHAIN_TRACING_V2=true
LANGCHAIN_API_KEY=ls__...
LANGCHAIN_PROJECT=my-project

# Vector store
VECTOR_STORE_TYPE=faiss
EMBEDDING_MODEL=text-embedding-3-small

# Model configuration
DEFAULT_MODEL=gpt-4o-mini
DEFAULT_TEMPERATURE=0.7
MAX_TOKENS=500
```

### Loading Configuration

```python
import os
from dotenv import load_dotenv

load_dotenv()

# Initialize with environment variables
llm = ChatOpenAI(
    api_key=os.getenv("OPENAI_API_KEY"),
    model=os.getenv("DEFAULT_MODEL", "gpt-4o-mini"),
    temperature=float(os.getenv("DEFAULT_TEMPERATURE", "0.7")),
    max_tokens=int(os.getenv("MAX_TOKENS", "500"))
)
```

## Error Handling Patterns

### Retry with Exponential Backoff

```python
chain_with_retry = chain.with_retry(
    stop_after_attempt=3,
    wait_exponential_jitter=True
)
```

### Fallback Chains

```python
primary_chain = prompt | expensive_llm
fallback_chain = prompt | cheap_llm

chain_with_fallback = primary_chain.with_fallbacks([fallback_chain])
```

### Timeout Protection

```python
from langchain_core.runnables import RunnableConfig

config = RunnableConfig(timeout=10.0)
result = chain.invoke({"topic": "AI"}, config=config)
```

## Performance Tips

1. **Use smaller models for simple tasks**
   - gpt-4o-mini for basic tasks
   - gpt-4 for complex reasoning

2. **Implement caching**
   - Cache LLM responses
   - Cache embeddings
   - Cache retrieval results

3. **Batch operations**
   - Use chain.batch() for multiple inputs
   - Set max_concurrency appropriately

4. **Optimize retrieval**
   - Limit k parameter
   - Use appropriate chunk sizes
   - Implement reranking

5. **Stream when possible**
   - Better user experience
   - Lower perceived latency
   - Easier to cancel

## Testing Your Chains

```python
import pytest

def test_basic_chain():
    chain = prompt | llm | StrOutputParser()
    result = chain.invoke({"topic": "testing"})
    assert isinstance(result, str)
    assert len(result) > 0

def test_rag_chain():
    result = rag_chain.invoke("What is LangChain?")
    assert "LangChain" in result.lower()

@pytest.mark.asyncio
async def test_async_chain():
    result = await chain.ainvoke({"topic": "async"})
    assert isinstance(result, str)
```

## Monitoring in Production

### LangSmith Integration

```python
import os

os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = "your-key"
os.environ["LANGCHAIN_PROJECT"] = "production"

# All chains automatically traced
result = chain.invoke({"topic": "AI"})
```

### Custom Callbacks

```python
from langchain_core.callbacks import BaseCallbackHandler

class MetricsCallback(BaseCallbackHandler):
    def __init__(self):
        self.metrics = {
            "llm_calls": 0,
            "total_tokens": 0,
            "errors": 0
        }

    def on_llm_start(self, serialized, prompts, **kwargs):
        self.metrics["llm_calls"] += 1

    def on_llm_end(self, response, **kwargs):
        # Track token usage
        pass

    def on_chain_error(self, error, **kwargs):
        self.metrics["errors"] += 1
```

## Resources

### Official Documentation
- [LangChain Docs](https://python.langchain.com/)
- [LangGraph](https://langchain-ai.github.io/langgraph/)
- [LangSmith](https://docs.smith.langchain.com/)

### Community
- [GitHub Discussions](https://github.com/langchain-ai/langchain/discussions)
- [Discord Community](https://discord.gg/langchain)

### Examples
- See EXAMPLES.md for 18+ production-ready patterns
- Check SKILL.md for comprehensive API reference

## File Structure

```
langchain-orchestration/
├── SKILL.md          # Comprehensive guide with 60+ examples
├── README.md         # Quick start and learning path
└── EXAMPLES.md       # 18+ production-ready examples
```

## Contributing

This skill is designed to be comprehensive and production-ready. For improvements or additions:

1. Ensure examples are tested and working
2. Follow the existing structure and style
3. Include both basic and advanced use cases
4. Add production best practices

## License

This skill documentation is provided as-is for educational and production use.

---

**Next Steps:**
1. Review SKILL.md for comprehensive API coverage
2. Explore EXAMPLES.md for production patterns
3. Start with Basic Chains in the Learning Path
4. Build your first RAG application
5. Deploy with monitoring and error handling

Happy orchestrating!
