---
name: langchain-orchestration
description: Comprehensive guide for building production-grade LLM applications using LangChain's chains, agents, memory systems, RAG patterns, and advanced orchestration
version: 1.0.0
category: AI/ML
tags:
  - langchain
  - llm
  - chains
  - agents
  - rag
  - memory
  - retrieval
  - orchestration
  - streaming
  - callbacks
  - python
prerequisites:
  - Python 3.8+
  - langchain>=0.1.0
  - langchain-core>=0.1.0
  - langchain-community>=0.0.20
  - OpenAI API key or other LLM provider credentials
  - Vector store setup (FAISS, Chroma, Pinecone, etc.)
---

# LangChain Orchestration Skill

Complete guide for building production-grade LLM applications with LangChain, covering chains, agents, memory, RAG patterns, and advanced orchestration techniques.

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [Chains](#chains)
3. [Agents](#agents)
4. [Memory Systems](#memory-systems)
5. [RAG Patterns](#rag-patterns)
6. [LLM Integrations](#llm-integrations)
7. [Callbacks & Monitoring](#callbacks--monitoring)
8. [Retrieval Strategies](#retrieval-strategies)
9. [Streaming](#streaming)
10. [Error Handling](#error-handling)
11. [Production Best Practices](#production-best-practices)

## Core Concepts

### LangChain Expression Language (LCEL)

LCEL is the declarative way to compose chains in LangChain, enabling streaming, async, and parallel execution.

```python
from langchain_core.runnables import RunnablePassthrough
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_openai import ChatOpenAI

# Basic LCEL chain
prompt = ChatPromptTemplate.from_template("Tell me about {topic}")
llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)
output_parser = StrOutputParser()

chain = prompt | llm | output_parser
result = chain.invoke({"topic": "quantum computing"})
```

### Runnable Interface

Every component in LangChain implements the Runnable interface with standard methods:

```python
from langchain_core.runnables import RunnablePassthrough

# Key methods: invoke, stream, batch, ainvoke, astream, abatch
chain = prompt | llm | output_parser

# Synchronous invoke
result = chain.invoke({"topic": "AI"})

# Streaming
for chunk in chain.stream({"topic": "AI"}):
    print(chunk, end="", flush=True)

# Batch processing
results = chain.batch([{"topic": "AI"}, {"topic": "ML"}])

# Async variants
result = await chain.ainvoke({"topic": "AI"})
```

### RunnablePassthrough

Pass inputs directly through or apply transformations:

```python
from langchain_core.runnables import RunnablePassthrough

# Pass through unchanged
chain = RunnablePassthrough() | llm | output_parser

# With transformation
def add_context(x):
    return {"text": x["input"], "context": "important"}

chain = RunnablePassthrough.assign(processed=add_context) | llm
```

## Chains

### Sequential Chains

Process data through multiple steps sequentially.

```python
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(temperature=0)

# Step 1: Generate ideas
idea_prompt = ChatPromptTemplate.from_template(
    "Generate 3 creative ideas for: {topic}"
)
idea_chain = idea_prompt | llm | StrOutputParser()

# Step 2: Evaluate ideas
eval_prompt = ChatPromptTemplate.from_template(
    "Evaluate these ideas and pick the best one:\n{ideas}"
)
eval_chain = eval_prompt | llm | StrOutputParser()

# Combine into sequential chain
sequential_chain = (
    {"ideas": idea_chain}
    | RunnablePassthrough.assign(evaluation=eval_chain)
)

result = sequential_chain.invoke({"topic": "mobile app"})
```

### Map-Reduce Chains

Process multiple inputs in parallel and combine results.

```python
from langchain_core.runnables import RunnableParallel
from langchain_core.prompts import ChatPromptTemplate

# Define parallel processing
summary_prompt = ChatPromptTemplate.from_template(
    "Summarize this text in one sentence: {text}"
)
keywords_prompt = ChatPromptTemplate.from_template(
    "Extract 3 keywords from: {text}"
)
sentiment_prompt = ChatPromptTemplate.from_template(
    "Analyze sentiment (positive/negative/neutral): {text}"
)

# Map: Process in parallel
map_chain = RunnableParallel(
    summary=summary_prompt | llm | StrOutputParser(),
    keywords=keywords_prompt | llm | StrOutputParser(),
    sentiment=sentiment_prompt | llm | StrOutputParser()
)

# Reduce: Combine results
reduce_prompt = ChatPromptTemplate.from_template(
    """Combine the analysis:
    Summary: {summary}
    Keywords: {keywords}
    Sentiment: {sentiment}

    Provide a comprehensive report:"""
)

map_reduce_chain = map_chain | reduce_prompt | llm | StrOutputParser()

result = map_reduce_chain.invoke({
    "text": "LangChain is an amazing framework for building LLM applications."
})
```

### Router Chains

Route inputs to different chains based on conditions.

```python
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

# Define specialized chains
technical_prompt = ChatPromptTemplate.from_template(
    "Provide a technical explanation of: {query}"
)
simple_prompt = ChatPromptTemplate.from_template(
    "Explain in simple terms: {query}"
)

technical_chain = technical_prompt | llm | StrOutputParser()
simple_chain = simple_prompt | llm | StrOutputParser()

# Router function
def route_query(input_dict):
    query = input_dict["query"]
    complexity = input_dict.get("complexity", "simple")

    if complexity == "technical":
        return technical_chain
    return simple_chain

# Create router chain
from langchain_core.runnables import RunnableLambda

router_chain = RunnableLambda(route_query)

# Use the router
result = router_chain.invoke({
    "query": "quantum entanglement",
    "complexity": "technical"
})
```

### Conditional Chains

Execute chains based on conditions.

```python
from langchain_core.runnables import RunnableBranch

# Define condition-based routing
classification_prompt = ChatPromptTemplate.from_template(
    "Classify this as 'question', 'statement', or 'command': {text}"
)

question_handler = ChatPromptTemplate.from_template(
    "Answer this question: {text}"
) | llm | StrOutputParser()

statement_handler = ChatPromptTemplate.from_template(
    "Acknowledge this statement: {text}"
) | llm | StrOutputParser()

command_handler = ChatPromptTemplate.from_template(
    "Execute this command: {text}"
) | llm | StrOutputParser()

# Create conditional branch
branch = RunnableBranch(
    (lambda x: "question" in x["type"].lower(), question_handler),
    (lambda x: "statement" in x["type"].lower(), statement_handler),
    command_handler  # default
)

# Full chain with classification
full_chain = (
    {"text": RunnablePassthrough(), "type": classification_prompt | llm | StrOutputParser()}
    | branch
)
```

### LLMChain (Legacy)

Traditional chain format still supported:

```python
from langchain.chains import LLMChain
from langchain_core.prompts import PromptTemplate

prompt = PromptTemplate(
    input_variables=["product"],
    template="What is a good name for a company that makes {product}?"
)

chain = LLMChain(llm=llm, prompt=prompt)
result = chain.run(product="eco-friendly water bottles")
```

### Stuff Documents Chain

Combine documents into a single context:

```python
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.documents import Document

prompt = ChatPromptTemplate.from_template(
    """Answer based on the following context:

<context>
{context}
</context>

Question: {input}"""
)

document_chain = create_stuff_documents_chain(llm, prompt)

docs = [
    Document(page_content="LangChain supports multiple LLM providers."),
    Document(page_content="Chains can be composed using LCEL.")
]

result = document_chain.invoke({
    "input": "What does LangChain support?",
    "context": docs
})
```

## Agents

### ReAct Agents

Reasoning and Acting agents that use tools iteratively.

```python
from langchain.agents import create_react_agent, AgentExecutor
from langchain_core.tools import Tool
from langchain import hub

# Define tools
def search_tool(query: str) -> str:
    """Search for information"""
    return f"Search results for: {query}"

def calculator_tool(expression: str) -> str:
    """Calculate mathematical expressions"""
    try:
        return str(eval(expression))
    except:
        return "Invalid expression"

tools = [
    Tool(
        name="Search",
        func=search_tool,
        description="Useful for searching information"
    ),
    Tool(
        name="Calculator",
        func=calculator_tool,
        description="Useful for math calculations"
    )
]

# Create ReAct agent
prompt = hub.pull("hwchase17/react")
agent = create_react_agent(llm, tools, prompt)
agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    verbose=True,
    max_iterations=5
)

result = agent_executor.invoke({
    "input": "What is 25 * 4, and then search for that number's significance"
})
```

### LangGraph ReAct Agent

Modern approach using LangGraph for better control:

```python
from langgraph.prebuilt import create_react_agent
from langchain_core.tools import tool
from langgraph.checkpoint.memory import MemorySaver

@tool
def retrieve(query: str) -> str:
    """Retrieve relevant information from the knowledge base"""
    # Your retrieval logic here
    return f"Retrieved information for: {query}"

@tool
def analyze(text: str) -> str:
    """Analyze text and provide insights"""
    return f"Analysis of: {text}"

# Create agent with memory
memory = MemorySaver()
agent_executor = create_react_agent(
    llm,
    [retrieve, analyze],
    checkpointer=memory
)

# Use with configuration
config = {"configurable": {"thread_id": "abc123"}}
for chunk in agent_executor.stream(
    {"messages": [("user", "Find information about LangChain")]},
    config=config
):
    print(chunk)
```

### Conversational ReAct Agent

Agent with built-in conversation memory:

```python
from langchain.agents import create_conversational_retrieval_agent
from langchain_core.tools import Tool

tools = [
    Tool(
        name="Knowledge Base",
        func=lambda q: f"KB result: {q}",
        description="Search the knowledge base"
    )
]

conversational_agent = create_conversational_retrieval_agent(
    llm,
    tools,
    verbose=True
)

# Maintains conversation context
result1 = conversational_agent.invoke({
    "input": "What is LangChain?"
})
result2 = conversational_agent.invoke({
    "input": "Tell me more about its features"
})
```

### Zero-Shot React Agent

Agent that works without examples:

```python
from langchain.agents import AgentType, initialize_agent, load_tools

# Load pre-built tools
tools = load_tools(["serpapi", "llm-math"], llm=llm)

agent = initialize_agent(
    tools,
    llm,
    agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION,
    verbose=True,
    max_iterations=3
)

result = agent.run(
    "What is the population of Tokyo and what is that number divided by 2?"
)
```

### Structured Chat Agent

Agent that uses structured input/output:

```python
from langchain.agents import create_structured_chat_agent

# Define tools with structured schemas
from pydantic import BaseModel, Field

class SearchInput(BaseModel):
    query: str = Field(description="The search query")
    max_results: int = Field(default=5, description="Maximum results")

@tool(args_schema=SearchInput)
def structured_search(query: str, max_results: int = 5) -> str:
    """Search with structured parameters"""
    return f"Found {max_results} results for: {query}"

tools = [structured_search]

prompt = hub.pull("hwchase17/structured-chat-agent")
agent = create_structured_chat_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)
```

### Tool Calling Agent

Modern agent using native tool calling:

```python
from langchain_core.tools import tool

@tool
def multiply(a: int, b: int) -> int:
    """Multiply two numbers"""
    return a * b

@tool
def search_database(query: str, limit: int = 10) -> str:
    """Search the database"""
    return f"Found {limit} results for {query}"

# Bind tools to LLM
llm_with_tools = llm.bind_tools([multiply, search_database])

# Create simple tool chain
from operator import itemgetter

tool_chain = llm_with_tools | (lambda x: x.tool_calls[0]["args"]) | multiply
result = tool_chain.invoke("What's four times 23")
```

## Memory Systems

### ConversationBufferMemory

Store complete conversation history:

```python
from langchain.memory import ConversationBufferMemory
from langchain.chains import LLMChain

memory = ConversationBufferMemory(
    memory_key="chat_history",
    return_messages=True
)

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant."),
    ("placeholder", "{chat_history}"),
    ("human", "{input}")
])

chain = LLMChain(llm=llm, prompt=prompt, memory=memory)

# Conversation is automatically stored
response1 = chain.run(input="Hi, I'm Alice")
response2 = chain.run(input="What's my name?")  # Will remember Alice
```

### ConversationBufferWindowMemory

Keep only recent K interactions:

```python
from langchain.memory import ConversationBufferWindowMemory

memory = ConversationBufferWindowMemory(
    k=5,  # Keep last 5 interactions
    memory_key="chat_history",
    return_messages=True
)

chain = LLMChain(llm=llm, prompt=prompt, memory=memory)
```

### ConversationSummaryMemory

Summarize conversation history:

```python
from langchain.memory import ConversationSummaryMemory

memory = ConversationSummaryMemory(
    llm=llm,
    memory_key="chat_history",
    return_messages=True
)

chain = LLMChain(llm=llm, prompt=prompt, memory=memory)

# Long conversations are automatically summarized
for i in range(20):
    chain.run(input=f"Tell me fact {i} about AI")
```

### ConversationSummaryBufferMemory

Hybrid approach: recent messages + summary:

```python
from langchain.memory import ConversationSummaryBufferMemory

memory = ConversationSummaryBufferMemory(
    llm=llm,
    max_token_limit=100,  # When to trigger summarization
    memory_key="chat_history",
    return_messages=True
)
```

### Vector Store Memory

Semantic search over conversation history:

```python
from langchain.memory import VectorStoreRetrieverMemory
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings()
vectorstore = FAISS.from_texts([], embeddings)

memory = VectorStoreRetrieverMemory(
    retriever=vectorstore.as_retriever(search_kwargs={"k": 5})
)

# Save context
memory.save_context(
    {"input": "My favorite color is blue"},
    {"output": "That's great!"}
)

# Retrieve relevant context
relevant = memory.load_memory_variables({"input": "What's my favorite color?"})
```

### Recall Memories (LangGraph)

Structured memory with save and search:

```python
from langchain_core.vectorstores import InMemoryVectorStore
from langchain_openai import OpenAIEmbeddings
from langchain_core.tools import tool

recall_vector_store = InMemoryVectorStore(OpenAIEmbeddings())

@tool
def save_recall_memory(memory: str) -> str:
    """Save important information to long-term memory"""
    recall_vector_store.add_texts([memory])
    return f"Saved memory: {memory}"

@tool
def search_recall_memories(query: str) -> str:
    """Search long-term memories"""
    docs = recall_vector_store.similarity_search(query, k=3)
    return "\n".join([doc.page_content for doc in docs])

# Use with agent
from langgraph.prebuilt import create_react_agent

agent = create_react_agent(
    llm,
    [save_recall_memory, search_recall_memories]
)
```

### Custom Memory with LangGraph State

Define custom state for memory:

```python
from typing import List
from langgraph.graph import MessagesState, StateGraph, START, END

class State(MessagesState):
    recall_memories: List[str]

def load_memories(state: State):
    """Load relevant memories before agent processes input"""
    messages = state["messages"]
    last_message = messages[-1].content if messages else ""

    # Search for relevant memories
    docs = recall_vector_store.similarity_search(last_message, k=3)
    memories = [doc.page_content for doc in docs]

    return {"recall_memories": memories}

# Add to graph
builder = StateGraph(State)
builder.add_node(load_memories)
builder.add_edge(START, "load_memories")
```

## RAG Patterns

### Basic RAG Chain

Fundamental retrieval-augmented generation:

```python
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough

# Setup vector store
embeddings = OpenAIEmbeddings()
vectorstore = FAISS.from_texts(
    [
        "LangChain supports multiple LLM providers including OpenAI, Anthropic, and more.",
        "Chains can be composed using LangChain Expression Language (LCEL).",
        "Agents can use tools to interact with external systems."
    ],
    embedding=embeddings
)

retriever = vectorstore.as_retriever(search_kwargs={"k": 3})

# RAG prompt
template = """Answer the question based only on the following context:

{context}

Question: {question}
"""
prompt = ChatPromptTemplate.from_template(template)

def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

# Build RAG chain
rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)

result = rag_chain.invoke("What does LangChain support?")
```

### RAG with Retrieval Chain

Using built-in retrieval chain constructor:

```python
from langchain.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain

prompt = ChatPromptTemplate.from_template(
    """Answer based on the context:

<context>
{context}
</context>

Question: {input}"""
)

document_chain = create_stuff_documents_chain(llm, prompt)
retrieval_chain = create_retrieval_chain(retriever, document_chain)

response = retrieval_chain.invoke({
    "input": "What is LCEL?"
})
# Returns: {"input": "...", "context": [...], "answer": "..."}
```

### RAG with Chat History

Conversational RAG with context:

```python
from langchain.chains import create_history_aware_retriever
from langchain_core.prompts import MessagesPlaceholder

contextualize_prompt = ChatPromptTemplate.from_messages([
    ("system", "Given a chat history and the latest user question, "
               "formulate a standalone question which can be understood "
               "without the chat history."),
    MessagesPlaceholder("chat_history"),
    ("human", "{input}")
])

history_aware_retriever = create_history_aware_retriever(
    llm,
    retriever,
    contextualize_prompt
)

# Use in RAG chain
qa_chain = create_retrieval_chain(
    history_aware_retriever,
    document_chain
)

# First question
result1 = qa_chain.invoke({
    "input": "What is LangChain?",
    "chat_history": []
})

# Follow-up with context
result2 = qa_chain.invoke({
    "input": "What are its main features?",
    "chat_history": [
        ("human", "What is LangChain?"),
        ("ai", result1["answer"])
    ]
})
```

### Multi-Query RAG

Generate multiple search queries for better retrieval:

```python
from langchain.retrievers.multi_query import MultiQueryRetriever

multi_query_retriever = MultiQueryRetriever.from_llm(
    retriever=vectorstore.as_retriever(),
    llm=llm
)

# Automatically generates multiple query variations
rag_chain = (
    {"context": multi_query_retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)
```

### RAG with Reranking

Improve relevance with reranking:

```python
from langchain.retrievers import ContextualCompressionRetriever
from langchain.retrievers.document_compressors import FlashrankRerank

# Setup reranker
compressor = FlashrankRerank()
compression_retriever = ContextualCompressionRetriever(
    base_compressor=compressor,
    base_retriever=retriever
)

# Use in RAG chain
rag_chain = (
    {"context": compression_retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)
```

### Parent Document Retrieval

Retrieve larger parent documents for full context:

```python
from langchain.retrievers import ParentDocumentRetriever
from langchain.storage import InMemoryStore
from langchain_text_splitters import RecursiveCharacterTextSplitter

# Storage for parent documents
store = InMemoryStore()

# Splitters
child_splitter = RecursiveCharacterTextSplitter(chunk_size=400)
parent_splitter = RecursiveCharacterTextSplitter(chunk_size=2000)

parent_retriever = ParentDocumentRetriever(
    vectorstore=vectorstore,
    docstore=store,
    child_splitter=child_splitter,
    parent_splitter=parent_splitter,
)

# Add documents
parent_retriever.add_documents(documents)
```

### Self-Query Retrieval

Natural language to structured queries:

```python
from langchain.retrievers.self_query.base import SelfQueryRetriever
from langchain.chains.query_constructor.base import AttributeInfo

metadata_field_info = [
    AttributeInfo(
        name="source",
        description="The document source",
        type="string",
    ),
    AttributeInfo(
        name="page",
        description="The page number",
        type="integer",
    ),
]

document_content_description = "Technical documentation"

self_query_retriever = SelfQueryRetriever.from_llm(
    llm,
    vectorstore,
    document_content_description,
    metadata_field_info,
)
```

## LLM Integrations

### OpenAI Integration

```python
from langchain_openai import ChatOpenAI, OpenAI

# Chat model
chat_model = ChatOpenAI(
    model="gpt-4o-mini",
    temperature=0.7,
    max_tokens=500,
    api_key="your-api-key"
)

# Completion model
completion_model = OpenAI(
    model="gpt-3.5-turbo-instruct",
    temperature=0.9
)
```

### Anthropic Claude Integration

```python
from langchain_anthropic import ChatAnthropic

claude = ChatAnthropic(
    model="claude-3-5-sonnet-20241022",
    temperature=0,
    max_tokens=1024,
    api_key="your-api-key"
)
```

### HuggingFace Integration

```python
from langchain_huggingface import HuggingFaceEndpoint

llm = HuggingFaceEndpoint(
    repo_id="meta-llama/Llama-2-7b-chat-hf",
    huggingfacehub_api_token="your-token",
    task="text-generation",
    temperature=0.7
)
```

### Google Vertex AI Integration

```python
from langchain_google_vertexai import ChatVertexAI, VertexAI

# Chat model
chat_model = ChatVertexAI(
    model_name="chat-bison",
    temperature=0
)

# Completion model
completion_model = VertexAI(
    model_name="gemini-1.0-pro-002"
)
```

### Ollama Local Models

```python
from langchain_community.llms import Ollama

llm = Ollama(
    model="llama2",
    temperature=0.8
)
```

### Binding Tools to LLMs

```python
from langchain_core.tools import tool

@tool
def multiply(a: int, b: int) -> int:
    """Multiply two numbers together"""
    return a * b

# Bind tools to model
llm_with_tools = llm.bind_tools([multiply])

# Model will return tool calls
response = llm_with_tools.invoke("What is 3 times 4?")
print(response.tool_calls)
```

## Callbacks & Monitoring

### Standard Callbacks

Track chain execution:

```python
from langchain_core.callbacks import StdOutCallbackHandler
from langchain.callbacks import get_openai_callback

# Standard output callback
callbacks = [StdOutCallbackHandler()]

chain = prompt | llm | StrOutputParser()
result = chain.invoke(
    {"topic": "AI"},
    config={"callbacks": callbacks}
)

# OpenAI cost tracking
with get_openai_callback() as cb:
    result = chain.invoke({"topic": "AI"})
    print(f"Total Tokens: {cb.total_tokens}")
    print(f"Total Cost: ${cb.total_cost}")
```

### Custom Callbacks

Create custom callback handlers:

```python
from langchain_core.callbacks import BaseCallbackHandler
from typing import Any, Dict

class MyCustomCallback(BaseCallbackHandler):
    def on_llm_start(self, serialized: Dict[str, Any], prompts: list[str], **kwargs):
        print(f"LLM started with prompts: {prompts}")

    def on_llm_end(self, response, **kwargs):
        print(f"LLM finished with response: {response}")

    def on_chain_start(self, serialized: Dict[str, Any], inputs: Dict[str, Any], **kwargs):
        print(f"Chain started with inputs: {inputs}")

    def on_chain_end(self, outputs: Dict[str, Any], **kwargs):
        print(f"Chain ended with outputs: {outputs}")

    def on_tool_start(self, serialized: Dict[str, Any], input_str: str, **kwargs):
        print(f"Tool started with input: {input_str}")

    def on_tool_end(self, output: str, **kwargs):
        print(f"Tool ended with output: {output}")

# Use custom callback
custom_callback = MyCustomCallback()
result = chain.invoke(
    {"topic": "AI"},
    config={"callbacks": [custom_callback]}
)
```

### Argilla Callback

Track and log to Argilla:

```python
from langchain_community.callbacks import ArgillaCallbackHandler

argilla_callback = ArgillaCallbackHandler(
    dataset_name="langchain-dataset",
    api_url="http://localhost:6900",
    api_key="your-api-key"
)

callbacks = [argilla_callback]

agent = initialize_agent(
    tools,
    llm,
    agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION,
    callbacks=callbacks
)

agent.run("Who was the first president of the United States?")
```

### UpTrain Callback

RAG evaluation and monitoring:

```python
from langchain_community.callbacks import UpTrainCallbackHandler

uptrain_callback = UpTrainCallbackHandler(
    key_type="uptrain",
    api_key="your-api-key"
)

config = {"callbacks": [uptrain_callback]}

# Automatically evaluates context relevance, factual accuracy, completeness
result = rag_chain.invoke("What is LangChain?", config=config)
```

### LangSmith Integration

Production monitoring and debugging:

```python
import os

# Set environment variables
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = "your-langsmith-key"
os.environ["LANGCHAIN_PROJECT"] = "my-project"

# All chains automatically traced
result = chain.invoke({"topic": "AI"})
# View traces at smith.langchain.com
```

## Retrieval Strategies

### Vector Store Retrievers

Basic similarity search:

```python
from langchain_community.vectorstores import FAISS, Chroma, Pinecone

# FAISS
faiss_retriever = vectorstore.as_retriever(
    search_type="similarity",
    search_kwargs={"k": 5}
)

# Maximum Marginal Relevance (MMR)
mmr_retriever = vectorstore.as_retriever(
    search_type="mmr",
    search_kwargs={"k": 5, "fetch_k": 20, "lambda_mult": 0.5}
)

# Similarity with threshold
threshold_retriever = vectorstore.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={"score_threshold": 0.8, "k": 5}
)
```

### Ensemble Retriever

Combine multiple retrievers:

```python
from langchain.retrievers import EnsembleRetriever
from langchain_community.retrievers import BM25Retriever

# BM25 for keyword search
bm25_retriever = BM25Retriever.from_texts(texts)
bm25_retriever.k = 5

# Combine with vector search
ensemble_retriever = EnsembleRetriever(
    retrievers=[bm25_retriever, faiss_retriever],
    weights=[0.5, 0.5]
)

docs = ensemble_retriever.get_relevant_documents("LangChain features")
```

### Time-Weighted Retriever

Prioritize recent documents:

```python
from langchain.retrievers import TimeWeightedVectorStoreRetriever

retriever = TimeWeightedVectorStoreRetriever(
    vectorstore=vectorstore,
    decay_rate=0.01,  # Decay factor for older docs
    k=5
)
```

### Multi-Vector Retriever

Multiple vectors per document:

```python
from langchain.retrievers.multi_vector import MultiVectorRetriever
from langchain.storage import InMemoryByteStore

store = InMemoryByteStore()

retriever = MultiVectorRetriever(
    vectorstore=vectorstore,
    byte_store=store,
    id_key="doc_id"
)

# Add documents with multiple representations
retriever.add_documents(documents)
```

## Streaming

### Stream Chain Output

Stream tokens as they're generated:

```python
from langchain_core.output_parsers import StrOutputParser

chain = prompt | llm | StrOutputParser()

# Stream method
for chunk in chain.stream({"topic": "AI"}):
    print(chunk, end="", flush=True)
```

### Stream with Callbacks

Handle streaming events:

```python
from langchain_core.callbacks import StreamingStdOutCallbackHandler

streaming_llm = ChatOpenAI(
    streaming=True,
    callbacks=[StreamingStdOutCallbackHandler()]
)

chain = prompt | streaming_llm | StrOutputParser()
result = chain.invoke({"topic": "AI"})  # Streams to stdout
```

### Async Streaming

Stream asynchronously:

```python
async def stream_async():
    async for chunk in chain.astream({"topic": "AI"}):
        print(chunk, end="", flush=True)

# Run async
import asyncio
asyncio.run(stream_async())
```

### Stream Agent Responses

Stream agent execution:

```python
from langgraph.prebuilt import create_react_agent

agent = create_react_agent(llm, tools)

for chunk in agent.stream(
    {"messages": [("user", "Search for LangChain information")]},
    stream_mode="values"
):
    chunk["messages"][-1].pretty_print()
```

### Streaming RAG

Stream RAG responses:

```python
retrieval_chain = (
    {
        "context": retriever.with_config(run_name="Docs"),
        "question": RunnablePassthrough(),
    }
    | prompt
    | llm
    | StrOutputParser()
)

# Stream the response
for chunk in retrieval_chain.stream("What is LangChain?"):
    print(chunk, end="", flush=True)
```

## Error Handling

### Retry Logic

Automatic retries on failure:

```python
from langchain_core.runnables import RunnableRetry

# Add retry to chain
chain_with_retry = (prompt | llm | StrOutputParser()).with_retry(
    stop_after_attempt=3,
    wait_exponential_jitter=True
)

result = chain_with_retry.invoke({"topic": "AI"})
```

### Fallback Chains

Use fallback on errors:

```python
from langchain_core.runnables import RunnableWithFallbacks

primary_llm = ChatOpenAI(model="gpt-4")
fallback_llm = ChatOpenAI(model="gpt-3.5-turbo")

chain_with_fallback = (prompt | primary_llm).with_fallbacks(
    [prompt | fallback_llm]
)

result = chain_with_fallback.invoke({"topic": "AI"})
```

### Try-Except Patterns

Manual error handling:

```python
from langchain_core.exceptions import OutputParserException

try:
    result = chain.invoke({"topic": "AI"})
except OutputParserException as e:
    print(f"Parsing failed: {e}")
    result = chain.invoke({"topic": "AI"})  # Retry
except Exception as e:
    print(f"Chain execution failed: {e}")
    result = None
```

### Timeout Handling

Set execution timeouts:

```python
from langchain_core.runnables import RunnableConfig

config = RunnableConfig(timeout=10.0)  # 10 seconds

try:
    result = chain.invoke({"topic": "AI"}, config=config)
except TimeoutError:
    print("Chain execution timed out")
```

### Validation

Validate inputs and outputs:

```python
from pydantic import BaseModel, Field, validator

class QueryInput(BaseModel):
    topic: str = Field(..., min_length=1, max_length=100)

    @validator("topic")
    def topic_must_be_valid(cls, v):
        if not v.strip():
            raise ValueError("Topic cannot be empty")
        return v.strip()

# Use with chain
def validate_and_invoke(topic: str):
    try:
        validated = QueryInput(topic=topic)
        return chain.invoke({"topic": validated.topic})
    except ValueError as e:
        return f"Validation error: {e}"
```

## Production Best Practices

### Environment Configuration

Manage secrets securely:

```python
import os
from dotenv import load_dotenv

load_dotenv()

# Use environment variables
llm = ChatOpenAI(
    api_key=os.getenv("OPENAI_API_KEY"),
    model=os.getenv("MODEL_NAME", "gpt-4o-mini")
)

# Vector store configuration
VECTOR_STORE_TYPE = os.getenv("VECTOR_STORE", "faiss")
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "text-embedding-3-small")
```

### Caching

Cache LLM responses:

```python
from langchain.cache import InMemoryCache, SQLiteCache
from langchain.globals import set_llm_cache

# In-memory cache
set_llm_cache(InMemoryCache())

# Persistent cache
set_llm_cache(SQLiteCache(database_path=".langchain.db"))

# Responses are cached automatically
result1 = llm.invoke("What is AI?")  # Calls API
result2 = llm.invoke("What is AI?")  # Uses cache
```

### Rate Limiting

Control API usage:

```python
from langchain_core.rate_limiters import InMemoryRateLimiter

rate_limiter = InMemoryRateLimiter(
    requests_per_second=1,
    check_every_n_seconds=0.1,
    max_bucket_size=10
)

llm = ChatOpenAI(rate_limiter=rate_limiter)
```

### Batch Processing

Process multiple inputs efficiently:

```python
# Batch invoke
inputs = [{"topic": f"Topic {i}"} for i in range(10)]
results = chain.batch(inputs, config={"max_concurrency": 5})

# Async batch
async def batch_process():
    results = await chain.abatch(inputs)
    return results
```

### Monitoring and Logging

Production monitoring:

```python
import logging
from langchain_core.callbacks import BaseCallbackHandler

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ProductionCallback(BaseCallbackHandler):
    def on_chain_start(self, serialized, inputs, **kwargs):
        logger.info(f"Chain started: {serialized.get('name', 'unknown')}")

    def on_chain_end(self, outputs, **kwargs):
        logger.info(f"Chain completed successfully")

    def on_chain_error(self, error, **kwargs):
        logger.error(f"Chain error: {error}")

# Use in production
production_callback = ProductionCallback()
config = {"callbacks": [production_callback]}
```

### Testing Chains

Unit test your chains:

```python
import pytest
from langchain_core.messages import HumanMessage, AIMessage

def test_basic_chain():
    chain = prompt | llm | StrOutputParser()
    result = chain.invoke({"topic": "testing"})
    assert isinstance(result, str)
    assert len(result) > 0

def test_rag_chain():
    result = rag_chain.invoke("What is LangChain?")
    assert "LangChain" in result
    assert len(result) > 50

@pytest.mark.asyncio
async def test_async_chain():
    result = await chain.ainvoke({"topic": "async"})
    assert isinstance(result, str)
```

### Performance Optimization

Optimize chain execution:

```python
# Use appropriate chunk sizes for text splitting
from langchain_text_splitters import RecursiveCharacterTextSplitter

splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200,
    length_function=len
)

# Limit retrieval results
retriever = vectorstore.as_retriever(search_kwargs={"k": 3})

# Use smaller, faster models where appropriate
fast_llm = ChatOpenAI(model="gpt-4o-mini")

# Enable streaming for better UX
streaming_chain = prompt | fast_llm.with_streaming() | StrOutputParser()
```

### Documentation

Document your chains:

```python
from langchain_core.runnables import RunnableConfig

class DocumentedChain:
    """
    Production RAG chain for technical documentation.

    Features:
    - Multi-query retrieval for better coverage
    - Reranking for improved relevance
    - Streaming support
    - Error handling with fallbacks

    Usage:
        chain = DocumentedChain()
        result = chain.invoke("Your question here")
    """

    def __init__(self):
        self.llm = ChatOpenAI(model="gpt-4o-mini")
        self.retriever = self._setup_retriever()
        self.chain = self._build_chain()

    def _setup_retriever(self):
        # Setup logic
        pass

    def _build_chain(self):
        # Chain construction
        pass

    def invoke(self, query: str, config: RunnableConfig = None):
        """Execute the chain with error handling"""
        try:
            return self.chain.invoke(query, config=config)
        except Exception as e:
            logger.error(f"Chain execution failed: {e}")
            raise
```

---

## Summary

This skill covers comprehensive LangChain orchestration patterns:

- **Chains**: Sequential, map-reduce, router, conditional chains
- **Agents**: ReAct, conversational, zero-shot, structured agents
- **Memory**: Buffer, window, summary, vector store memory
- **RAG**: Basic, multi-query, reranking, parent document retrieval
- **LLM Integration**: OpenAI, Anthropic, HuggingFace, Vertex AI, Ollama
- **Callbacks**: Standard, custom, Argilla, UpTrain, LangSmith
- **Retrieval**: Vector store, ensemble, time-weighted, multi-vector
- **Streaming**: Chain, agent, async streaming
- **Error Handling**: Retry, fallback, timeout, validation
- **Production**: Configuration, caching, rate limiting, monitoring, testing

For more examples and patterns, see EXAMPLES.md.
