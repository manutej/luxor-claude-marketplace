# LangChain Orchestration Examples

Production-ready examples covering chains, agents, memory, RAG patterns, and advanced orchestration.

## Table of Contents

1. [Chain Examples](#chain-examples)
2. [Agent Examples](#agent-examples)
3. [Memory Examples](#memory-examples)
4. [RAG Examples](#rag-examples)
5. [Advanced Patterns](#advanced-patterns)

## Chain Examples

### 1. Sequential Analysis Chain

**Use Case:** Multi-step content analysis pipeline

**Description:** Process text through sequential steps: summarization, keyword extraction, and sentiment analysis.

```python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough

llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)

# Step 1: Summarize
summarize_prompt = ChatPromptTemplate.from_template(
    "Summarize this text in 2-3 sentences:\n\n{text}"
)
summarize_chain = summarize_prompt | llm | StrOutputParser()

# Step 2: Extract keywords
keywords_prompt = ChatPromptTemplate.from_template(
    "Extract 5 key topics from this summary:\n\n{summary}"
)
keywords_chain = keywords_prompt | llm | StrOutputParser()

# Step 3: Analyze sentiment
sentiment_prompt = ChatPromptTemplate.from_template(
    "Analyze the sentiment (positive/negative/neutral) and explain:\n\n{summary}"
)
sentiment_chain = sentiment_prompt | llm | StrOutputParser()

# Combine into sequential chain
sequential_chain = (
    {"summary": {"text": RunnablePassthrough()} | summarize_chain}
    | RunnablePassthrough.assign(
        keywords=lambda x: keywords_chain.invoke({"summary": x["summary"]}),
        sentiment=lambda x: sentiment_chain.invoke({"summary": x["summary"]})
    )
)

# Execute
text = """
LangChain is a powerful framework for building LLM applications.
It provides comprehensive tools for chains, agents, and memory systems.
The community is active and the documentation is excellent.
"""

result = sequential_chain.invoke(text)
print(f"Summary: {result['summary']}\n")
print(f"Keywords: {result['keywords']}\n")
print(f"Sentiment: {result['sentiment']}")
```

**Explanation:** This chain demonstrates sequential processing where each step depends on the previous one. The first step summarizes the input, then parallel steps extract keywords and analyze sentiment from that summary.

---

### 2. Map-Reduce Document Processing

**Use Case:** Analyze multiple documents in parallel and combine results

**Description:** Process multiple documents simultaneously and aggregate findings.

```python
from langchain_core.runnables import RunnableParallel
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

llm = ChatOpenAI(temperature=0)

# Map phase: Process each document
doc_analysis_prompt = ChatPromptTemplate.from_template(
    """Analyze this document and extract:
    1. Main topic
    2. Key points (3 max)
    3. Conclusion

    Document: {document}

    Provide a structured analysis:"""
)

analysis_chain = doc_analysis_prompt | llm | StrOutputParser()

# Reduce phase: Combine all analyses
combine_prompt = ChatPromptTemplate.from_template(
    """Combine these document analyses into a comprehensive report:

    {analyses}

    Provide:
    1. Overall themes
    2. Common patterns
    3. Unique insights
    4. Final recommendations
    """
)

combine_chain = combine_prompt | llm | StrOutputParser()

# Full map-reduce implementation
def map_reduce_documents(documents):
    # Map: Analyze each document in parallel
    map_chains = {
        f"doc_{i}": (lambda doc: {"document": doc}) | analysis_chain
        for i in range(len(documents))
    }

    parallel_map = RunnableParallel(**map_chains)

    # Execute map phase
    analyses = parallel_map.invoke({
        f"doc_{i}": doc for i, doc in enumerate(documents)
    })

    # Reduce: Combine results
    combined_analyses = "\n\n---\n\n".join(analyses.values())
    final_report = combine_chain.invoke({"analyses": combined_analyses})

    return final_report

# Example usage
documents = [
    "LangChain provides tools for building LLM applications...",
    "Vector databases enable semantic search capabilities...",
    "RAG patterns combine retrieval with generation..."
]

report = map_reduce_documents(documents)
print(report)
```

**Explanation:** Map-reduce pattern processes multiple inputs in parallel (map phase) then combines results (reduce phase). This is efficient for analyzing multiple documents or data sources simultaneously.

---

### 3. Dynamic Router Chain

**Use Case:** Route queries to specialized handlers

**Description:** Classify input and route to appropriate processing chain.

```python
from langchain_core.runnables import RunnableBranch, RunnableLambda

# Define specialized chains
technical_prompt = ChatPromptTemplate.from_template(
    """Provide a detailed technical explanation with code examples:

    Topic: {query}

    Include:
    - Technical details
    - Code examples
    - Best practices
    """
)

beginner_prompt = ChatPromptTemplate.from_template(
    """Explain in simple, beginner-friendly terms:

    Topic: {query}

    Use:
    - Simple language
    - Analogies
    - Step-by-step breakdown
    """
)

business_prompt = ChatPromptTemplate.from_template(
    """Provide a business-focused explanation:

    Topic: {query}

    Focus on:
    - Business value
    - ROI considerations
    - Use cases
    """
)

technical_chain = technical_prompt | llm | StrOutputParser()
beginner_chain = beginner_prompt | llm | StrOutputParser()
business_chain = business_prompt | llm | StrOutputParser()

# Classifier chain
classifier_prompt = ChatPromptTemplate.from_template(
    """Classify this query as 'technical', 'beginner', or 'business':

    Query: {query}

    Respond with only one word: technical, beginner, or business"""
)

classifier = classifier_prompt | llm | StrOutputParser()

# Router implementation
def route_query(input_dict):
    query = input_dict["query"]
    classification = classifier.invoke({"query": query}).strip().lower()

    print(f"Routing to: {classification}")

    if "technical" in classification:
        return technical_chain.invoke({"query": query})
    elif "beginner" in classification:
        return beginner_chain.invoke({"query": query})
    else:
        return business_chain.invoke({"query": query})

router_chain = RunnableLambda(route_query)

# Test different query types
queries = [
    "Explain async/await in Python with implementation details",
    "What is machine learning?",
    "How can AI improve our company's efficiency?"
]

for query in queries:
    print(f"\nQuery: {query}")
    result = router_chain.invoke({"query": query})
    print(f"Response: {result[:200]}...")
```

**Explanation:** Router chains dynamically select the appropriate processing path based on input classification. This enables specialized handling for different types of queries.

---

### 4. Conditional Branching Chain

**Use Case:** Execute different logic based on conditions

**Description:** Branch execution based on input characteristics.

```python
from langchain_core.runnables import RunnableBranch

# Define handlers for different input types
def handle_question(input_dict):
    prompt = ChatPromptTemplate.from_template(
        "Provide a comprehensive answer to: {text}"
    )
    chain = prompt | llm | StrOutputParser()
    return chain.invoke(input_dict)

def handle_statement(input_dict):
    prompt = ChatPromptTemplate.from_template(
        "Acknowledge and expand on this statement: {text}"
    )
    chain = prompt | llm | StrOutputParser()
    return chain.invoke(input_dict)

def handle_command(input_dict):
    prompt = ChatPromptTemplate.from_template(
        "Explain how to execute this command: {text}"
    )
    chain = prompt | llm | StrOutputParser()
    return chain.invoke(input_dict)

# Classifier
def classify_input(text):
    if "?" in text:
        return "question"
    elif any(word in text.lower() for word in ["create", "build", "make", "generate"]):
        return "command"
    return "statement"

# Create conditional branch
branch = RunnableBranch(
    (lambda x: classify_input(x["text"]) == "question", RunnableLambda(handle_question)),
    (lambda x: classify_input(x["text"]) == "command", RunnableLambda(handle_command)),
    RunnableLambda(handle_statement)  # default
)

# Test inputs
inputs = [
    {"text": "What is the capital of France?"},
    {"text": "Create a Python function for sorting"},
    {"text": "LangChain is an amazing framework"}
]

for inp in inputs:
    print(f"\nInput: {inp['text']}")
    result = branch.invoke(inp)
    print(f"Result: {result[:150]}...")
```

**Explanation:** Conditional branching allows different processing paths based on input characteristics. This is useful for handling various input types with specialized logic.

---

## Agent Examples

### 5. ReAct Agent with Custom Tools

**Use Case:** Research assistant with search and calculation tools

**Description:** Agent that reasons about tool usage and acts accordingly.

```python
from langchain.agents import create_react_agent, AgentExecutor
from langchain_core.tools import Tool
from langchain import hub
import json

# Define custom tools
def search_knowledge_base(query: str) -> str:
    """Search internal knowledge base"""
    # Simulate knowledge base search
    knowledge = {
        "langchain": "LangChain is a framework for developing LLM applications",
        "rag": "RAG stands for Retrieval Augmented Generation",
        "agents": "Agents use tools and reasoning to accomplish tasks"
    }

    query_lower = query.lower()
    for key, value in knowledge.items():
        if key in query_lower:
            return value

    return f"No information found for: {query}"

def calculate(expression: str) -> str:
    """Perform mathematical calculations"""
    try:
        # Safe evaluation (in production, use a proper math parser)
        result = eval(expression, {"__builtins__": {}}, {})
        return f"Result: {result}"
    except Exception as e:
        return f"Calculation error: {str(e)}"

def analyze_data(data_json: str) -> str:
    """Analyze structured data"""
    try:
        data = json.loads(data_json)
        if isinstance(data, list):
            return f"List analysis: {len(data)} items, avg={sum(data)/len(data):.2f}"
        elif isinstance(data, dict):
            return f"Dict analysis: {len(data)} keys: {list(data.keys())}"
        return f"Type: {type(data).__name__}"
    except Exception as e:
        return f"Analysis error: {str(e)}"

# Create tools
tools = [
    Tool(
        name="Knowledge_Base_Search",
        func=search_knowledge_base,
        description="Search the internal knowledge base for information about LangChain concepts"
    ),
    Tool(
        name="Calculator",
        func=calculate,
        description="Perform mathematical calculations. Input should be a valid Python expression like '2 + 2' or '10 * 5'"
    ),
    Tool(
        name="Data_Analyzer",
        func=analyze_data,
        description="Analyze structured data in JSON format. Input should be valid JSON."
    )
]

# Create ReAct agent
llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)
prompt = hub.pull("hwchase17/react")

agent = create_react_agent(llm, tools, prompt)
agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    verbose=True,
    max_iterations=5,
    handle_parsing_errors=True
)

# Test queries
queries = [
    "What is RAG and calculate 15 * 8",
    "Analyze this data: [10, 20, 30, 40, 50]",
    "Search for information about agents and calculate 100 / 4"
]

for query in queries:
    print(f"\n{'='*60}")
    print(f"Query: {query}")
    print(f"{'='*60}")
    result = agent_executor.invoke({"input": query})
    print(f"\nFinal Answer: {result['output']}")
```

**Explanation:** ReAct agents combine reasoning and acting. They think about which tool to use, execute it, observe the result, and continue until the task is complete. This example shows custom tools for search, calculation, and data analysis.

---

### 6. LangGraph Agent with Memory

**Use Case:** Conversational agent with persistent memory

**Description:** Modern agent using LangGraph with conversation history.

```python
from langgraph.prebuilt import create_react_agent
from langgraph.checkpoint.memory import MemorySaver
from langchain_core.tools import tool

# Define tools
@tool
def get_weather(location: str) -> str:
    """Get weather information for a location"""
    # Simulate weather API
    weather_data = {
        "new york": "Sunny, 72°F",
        "london": "Rainy, 15°C",
        "tokyo": "Cloudy, 20°C"
    }
    return weather_data.get(location.lower(), "Weather data not available")

@tool
def save_preference(preference: str) -> str:
    """Save user preference to memory"""
    return f"Saved preference: {preference}"

@tool
def get_news(topic: str) -> str:
    """Get latest news about a topic"""
    return f"Latest news about {topic}: [Simulated news content]"

# Create agent with memory
memory = MemorySaver()
llm = ChatOpenAI(model="gpt-4o-mini")

agent_executor = create_react_agent(
    llm,
    tools=[get_weather, save_preference, get_news],
    checkpointer=memory
)

# Conversation with memory
config = {"configurable": {"thread_id": "user_123"}}

# First interaction
print("Interaction 1:")
for chunk in agent_executor.stream(
    {"messages": [("user", "What's the weather in New York?")]},
    config=config,
    stream_mode="values"
):
    chunk["messages"][-1].pretty_print()

# Second interaction (remembers context)
print("\n\nInteraction 2:")
for chunk in agent_executor.stream(
    {"messages": [("user", "Save my preference: I prefer metric units")]},
    config=config,
    stream_mode="values"
):
    chunk["messages"][-1].pretty_print()

# Third interaction (uses memory)
print("\n\nInteraction 3:")
for chunk in agent_executor.stream(
    {"messages": [("user", "Get news about AI")]},
    config=config,
    stream_mode="values"
):
    chunk["messages"][-1].pretty_print()
```

**Explanation:** LangGraph agents provide better control over execution flow and built-in memory management. The checkpointer maintains conversation state across interactions, enabling context-aware responses.

---

### 7. Multi-Step Research Agent

**Use Case:** Complex research tasks requiring multiple tool calls

**Description:** Agent that breaks down complex queries into steps.

```python
from langchain_core.tools import tool
from langchain.agents import AgentExecutor, create_react_agent

@tool
def web_search(query: str) -> str:
    """Search the web for information"""
    # Simulate web search
    results = {
        "langchain pricing": "LangChain is open source and free to use",
        "python version": "Current Python version is 3.11",
        "ai trends": "Top AI trends: LLMs, RAG, Agents, Multimodal AI"
    }

    for key in results:
        if key in query.lower():
            return results[key]
    return f"Search results for: {query}"

@tool
def summarize_text(text: str) -> str:
    """Summarize long text into key points"""
    # Simulate summarization
    words = text.split()
    if len(words) > 20:
        return " ".join(words[:20]) + "... [summarized]"
    return text

@tool
def compare_items(items: str) -> str:
    """Compare multiple items and provide analysis"""
    return f"Comparison analysis of: {items}"

# Create research agent
tools = [web_search, summarize_text, compare_items]
llm = ChatOpenAI(model="gpt-4", temperature=0)
prompt = hub.pull("hwchase17/react")

agent = create_react_agent(llm, tools, prompt)
agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    verbose=True,
    max_iterations=10
)

# Complex research query
research_query = """
Research the current state of AI agents, find information about LangChain,
summarize the key findings, and compare different approaches to building agents.
"""

result = agent_executor.invoke({"input": research_query})
print(f"\n\nResearch Complete!")
print(f"Final Report: {result['output']}")
```

**Explanation:** This agent demonstrates multi-step reasoning for complex tasks. It searches for information, processes results, and combines findings to answer complex queries.

---

## Memory Examples

### 8. Conversation Buffer Memory

**Use Case:** Chatbot with complete conversation history

**Description:** Store and retrieve full conversation context.

```python
from langchain.memory import ConversationBufferMemory
from langchain.chains import LLMChain
from langchain_core.prompts import ChatPromptTemplate

# Setup memory
memory = ConversationBufferMemory(
    memory_key="chat_history",
    return_messages=True
)

# Create conversational prompt
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful AI assistant with memory of our conversation."),
    ("placeholder", "{chat_history}"),
    ("human", "{input}")
])

# Create chain with memory
llm = ChatOpenAI(model="gpt-4o-mini")
conversation = LLMChain(
    llm=llm,
    prompt=prompt,
    memory=memory,
    verbose=True
)

# Simulate conversation
conversations = [
    "Hi, my name is Alice and I'm interested in learning Python",
    "What programming concepts should I start with?",
    "Can you remind me what my name is?",
    "What was I interested in learning?"
]

for user_input in conversations:
    print(f"\nUser: {user_input}")
    response = conversation.run(input=user_input)
    print(f"Assistant: {response}")

# Inspect memory
print("\n\nConversation History:")
print(memory.load_memory_variables({}))
```

**Explanation:** ConversationBufferMemory stores the complete conversation history, enabling the model to reference previous interactions. This is ideal for short to medium conversations where full context is important.

---

### 9. Conversation Summary Memory

**Use Case:** Long conversations with automatic summarization

**Description:** Summarize conversation history to manage token limits.

```python
from langchain.memory import ConversationSummaryMemory

# Create summary memory
llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)
memory = ConversationSummaryMemory(
    llm=llm,
    memory_key="chat_history",
    return_messages=True
)

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant. Use the conversation summary below:"),
    ("placeholder", "{chat_history}"),
    ("human", "{input}")
])

conversation = LLMChain(llm=llm, prompt=prompt, memory=memory)

# Simulate long conversation
topics = [
    "Tell me about machine learning",
    "How does deep learning differ from traditional ML?",
    "What are neural networks?",
    "Explain backpropagation",
    "What is gradient descent?",
    "Tell me about overfitting",
    "How do you prevent overfitting?",
    "What is regularization?",
    "Explain dropout technique",
    "What have we discussed so far?"  # Should use summary
]

for topic in topics:
    print(f"\nUser: {topic}")
    response = conversation.run(input=topic)
    print(f"Assistant: {response[:150]}...")

# View summary
print("\n\nConversation Summary:")
print(memory.load_memory_variables({}))
```

**Explanation:** ConversationSummaryMemory automatically summarizes conversation history when it gets too long. This maintains context while managing token limits for extended conversations.

---

### 10. Vector Store Memory

**Use Case:** Semantic search over conversation history

**Description:** Store conversations in vector database for semantic retrieval.

```python
from langchain.memory import VectorStoreRetrieverMemory
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings
from langchain_core.prompts import PromptTemplate

# Initialize vector store
embeddings = OpenAIEmbeddings()
vectorstore = FAISS.from_texts(
    ["Initial memory"],  # Start with placeholder
    embeddings,
    metadatas=[{"timestamp": "initial"}]
)

# Create vector memory
memory = VectorStoreRetrieverMemory(
    retriever=vectorstore.as_retriever(search_kwargs={"k": 3}),
    memory_key="history"
)

# Save various facts
facts = [
    ("My name is Bob", "Nice to meet you Bob!"),
    ("I work as a data scientist", "That's interesting!"),
    ("I'm learning LangChain", "Great choice!"),
    ("My favorite color is blue", "Blue is a nice color!"),
    ("I have two cats named Whiskers and Mittens", "Cute names!")
]

for user_msg, ai_msg in facts:
    memory.save_context(
        {"input": user_msg},
        {"output": ai_msg}
    )

# Retrieve relevant memories
queries = [
    "What's my profession?",
    "Do I have any pets?",
    "What color do I like?"
]

for query in queries:
    print(f"\nQuery: {query}")
    relevant_memories = memory.load_memory_variables({"input": query})
    print(f"Relevant memories: {relevant_memories['history']}")
```

**Explanation:** Vector store memory enables semantic search over conversation history. It retrieves relevant past interactions based on similarity, not just recent context.

---

### 11. Custom Recall Memory with LangGraph

**Use Case:** Structured long-term memory for agents

**Description:** Save and recall specific memories using vector search.

```python
from langchain_core.vectorstores import InMemoryVectorStore
from langchain_openai import OpenAIEmbeddings
from langchain_core.tools import tool
from langgraph.prebuilt import create_react_agent

# Initialize recall memory
recall_vector_store = InMemoryVectorStore(OpenAIEmbeddings())

@tool
def save_recall_memory(memory: str) -> str:
    """Save important information to long-term memory for future recall"""
    recall_vector_store.add_texts([memory])
    return f"Saved to memory: {memory}"

@tool
def search_recall_memories(query: str) -> str:
    """Search long-term memories for relevant information"""
    docs = recall_vector_store.similarity_search(query, k=3)
    if not docs:
        return "No relevant memories found"
    memories = "\n".join([f"- {doc.page_content}" for doc in docs])
    return f"Relevant memories:\n{memories}"

@tool
def get_current_time() -> str:
    """Get the current time"""
    from datetime import datetime
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# Create agent with recall tools
llm = ChatOpenAI(model="gpt-4o-mini")
agent = create_react_agent(llm, [save_recall_memory, search_recall_memories, get_current_time])

# Test conversation with memory
config = {"configurable": {"thread_id": "memory_test"}}

# Save memories
print("Saving memories...")
agent.invoke(
    {"messages": [("user", "Remember that my birthday is on July 15th")]},
    config=config
)

agent.invoke(
    {"messages": [("user", "Save this: I prefer vegetarian food")]},
    config=config
)

agent.invoke(
    {"messages": [("user", "Remember my favorite programming language is Python")]},
    config=config
)

# Recall memories
print("\n\nRecalling memories...")
result = agent.invoke(
    {"messages": [("user", "What do you know about my preferences?")]},
    config=config
)

print(result)
```

**Explanation:** Custom recall memory provides structured long-term storage. Agents can explicitly save important information and search for it later using semantic similarity.

---

## RAG Examples

### 12. Basic RAG Chain

**Use Case:** Question answering over documents

**Description:** Retrieve relevant documents and generate answers.

```python
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings, ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from langchain_core.documents import Document

# Create sample documents
documents = [
    Document(page_content="LangChain is a framework for developing applications powered by language models."),
    Document(page_content="Chains allow you to combine multiple components together to create a single, coherent application."),
    Document(page_content="Agents use language models to choose a sequence of actions to take."),
    Document(page_content="Memory systems allow you to persist state between calls of a chain/agent."),
    Document(page_content="RAG (Retrieval Augmented Generation) combines retrieval with generation for better answers."),
]

# Setup vector store
embeddings = OpenAIEmbeddings()
vectorstore = FAISS.from_documents(documents, embeddings)
retriever = vectorstore.as_retriever(search_kwargs={"k": 3})

# Create RAG prompt
prompt = ChatPromptTemplate.from_template("""
Answer the question based only on the following context:

Context:
{context}

Question: {question}

Provide a clear and concise answer:
""")

# Helper function
def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

# Build RAG chain
llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)

rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)

# Test questions
questions = [
    "What is LangChain?",
    "How do agents work?",
    "What is RAG?",
    "Explain memory systems"
]

for question in questions:
    print(f"\nQuestion: {question}")
    answer = rag_chain.invoke(question)
    print(f"Answer: {answer}")
```

**Explanation:** Basic RAG retrieves relevant documents from a vector store and uses them as context for the LLM to generate accurate answers. This grounds responses in your data.

---

### 13. Conversational RAG

**Use Case:** Multi-turn Q&A with conversation history

**Description:** RAG that maintains conversation context for follow-up questions.

```python
from langchain.chains import create_history_aware_retriever, create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import MessagesPlaceholder

# Setup (reuse vectorstore from previous example)
llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)

# Contextualize question prompt
contextualize_prompt = ChatPromptTemplate.from_messages([
    ("system", "Given a chat history and the latest user question "
               "which might reference context in the chat history, "
               "formulate a standalone question which can be understood "
               "without the chat history. Do NOT answer the question, "
               "just reformulate it if needed and otherwise return it as is."),
    MessagesPlaceholder("chat_history"),
    ("human", "{input}")
])

# Create history-aware retriever
history_aware_retriever = create_history_aware_retriever(
    llm,
    retriever,
    contextualize_prompt
)

# QA prompt
qa_prompt = ChatPromptTemplate.from_messages([
    ("system", "Answer the question based on the following context:\n\n{context}"),
    MessagesPlaceholder("chat_history"),
    ("human", "{input}")
])

# Create document chain
document_chain = create_stuff_documents_chain(llm, qa_prompt)

# Create full conversational RAG chain
conversational_rag_chain = create_retrieval_chain(
    history_aware_retriever,
    document_chain
)

# Simulate conversation
chat_history = []

questions = [
    "What is LangChain?",
    "What are its main components?",  # Follow-up
    "Tell me more about agents",  # Another follow-up
]

for question in questions:
    print(f"\nUser: {question}")

    result = conversational_rag_chain.invoke({
        "input": question,
        "chat_history": chat_history
    })

    print(f"Assistant: {result['answer']}")

    # Update chat history
    chat_history.extend([
        ("human", question),
        ("ai", result['answer'])
    ])

print("\n\nFinal chat history length:", len(chat_history))
```

**Explanation:** Conversational RAG reformulates follow-up questions using conversation history, enabling natural multi-turn conversations while maintaining retrieval accuracy.

---

### 14. Multi-Query RAG

**Use Case:** Improve retrieval coverage with multiple query variants

**Description:** Generate multiple search queries for comprehensive retrieval.

```python
from langchain.retrievers.multi_query import MultiQueryRetriever

# Create multi-query retriever
llm = ChatOpenAI(temperature=0)

multi_query_retriever = MultiQueryRetriever.from_llm(
    retriever=vectorstore.as_retriever(),
    llm=llm
)

# Setup RAG chain with multi-query retriever
prompt = ChatPromptTemplate.from_template("""
Answer based on the context below. Be comprehensive.

Context:
{context}

Question: {question}

Answer:
""")

def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

multi_query_rag = (
    {"context": multi_query_retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)

# Test with ambiguous queries
queries = [
    "How can I build applications?",  # Could match chains, agents, etc.
    "Tell me about memory",
    "What features are available?"
]

for query in queries:
    print(f"\n{'='*60}")
    print(f"Query: {query}")
    print(f"{'='*60}")

    answer = multi_query_rag.invoke(query)
    print(f"Answer: {answer}")
```

**Explanation:** Multi-query RAG automatically generates multiple variations of the user's question, retrieves documents for each, and combines them. This improves coverage and handles ambiguous queries better.

---

### 15. RAG with Reranking

**Use Case:** Improve retrieval relevance with reranking

**Description:** Retrieve more documents initially, then rerank for relevance.

```python
from langchain.retrievers import ContextualCompressionRetriever
from langchain_community.document_compressors import FlashrankRerank

# Create base retriever (retrieve more docs initially)
base_retriever = vectorstore.as_retriever(search_kwargs={"k": 10})

# Setup reranker
compressor = FlashrankRerank(top_n=3)  # Rerank and keep top 3

# Create compression retriever
compression_retriever = ContextualCompressionRetriever(
    base_compressor=compressor,
    base_retriever=base_retriever
)

# RAG chain with reranking
rerank_rag_chain = (
    {"context": compression_retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)

# Compare with and without reranking
test_query = "How do I build intelligent applications?"

print("Without reranking:")
basic_docs = base_retriever.get_relevant_documents(test_query)
print(f"Retrieved {len(basic_docs)} documents")
for i, doc in enumerate(basic_docs[:3], 1):
    print(f"{i}. {doc.page_content[:100]}...")

print("\n\nWith reranking:")
reranked_docs = compression_retriever.get_relevant_documents(test_query)
print(f"Reranked to {len(reranked_docs)} documents")
for i, doc in enumerate(reranked_docs, 1):
    print(f"{i}. {doc.page_content[:100]}...")

print("\n\nFinal answer with reranking:")
answer = rerank_rag_chain.invoke(test_query)
print(answer)
```

**Explanation:** Reranking retrieves more documents initially then uses a specialized model to reorder them by relevance. This two-stage approach improves answer quality.

---

### 16. RAG with Source Citations

**Use Case:** Provide answers with source attribution

**Description:** Track and cite source documents in responses.

```python
from langchain_core.documents import Document

# Create documents with metadata
docs_with_metadata = [
    Document(
        page_content="LangChain is a framework for developing applications powered by language models.",
        metadata={"source": "LangChain Documentation", "page": 1}
    ),
    Document(
        page_content="Chains combine multiple components together to create coherent applications.",
        metadata={"source": "LangChain Guide", "page": 15}
    ),
    Document(
        page_content="Agents use LLMs to choose sequences of actions to take.",
        metadata={"source": "Agent Tutorial", "page": 3}
    ),
]

# Create vector store with metadata
embeddings = OpenAIEmbeddings()
vectorstore_with_metadata = FAISS.from_documents(docs_with_metadata, embeddings)
retriever_with_metadata = vectorstore_with_metadata.as_retriever(search_kwargs={"k": 2})

# Citation prompt
citation_prompt = ChatPromptTemplate.from_template("""
Answer the question based on the context below. After your answer, cite the sources used.

Context:
{context}

Question: {question}

Answer (include citations in format [Source, Page]):
""")

# Helper to format docs with metadata
def format_docs_with_citations(docs):
    formatted = []
    for doc in docs:
        content = doc.page_content
        source = doc.metadata.get("source", "Unknown")
        page = doc.metadata.get("page", "N/A")
        formatted.append(f"{content}\n[Source: {source}, Page: {page}]")
    return "\n\n".join(formatted)

# RAG chain with citations
citation_rag = (
    {"context": retriever_with_metadata | format_docs_with_citations, "question": RunnablePassthrough()}
    | citation_prompt
    | llm
    | StrOutputParser()
)

# Test
question = "What is LangChain and how do chains work?"
answer_with_citations = citation_rag.invoke(question)

print(f"Question: {question}")
print(f"\nAnswer with citations:\n{answer_with_citations}")
```

**Explanation:** Including metadata with documents enables source attribution. This builds trust and allows users to verify information sources.

---

## Advanced Patterns

### 17. Hybrid Agent-RAG System

**Use Case:** Agent with RAG capabilities and other tools

**Description:** Combine agent reasoning with RAG retrieval and tools.

```python
from langchain_core.tools import tool
from langgraph.prebuilt import create_react_agent

# RAG tool
@tool
def search_knowledge_base(query: str) -> str:
    """Search the knowledge base for relevant information"""
    # Reuse retriever from previous examples
    docs = retriever.get_relevant_documents(query)
    return format_docs(docs)

@tool
def calculate(expression: str) -> str:
    """Calculate mathematical expressions"""
    try:
        result = eval(expression, {"__builtins__": {}}, {})
        return f"Result: {result}"
    except Exception as e:
        return f"Error: {str(e)}"

@tool
def generate_summary(text: str) -> str:
    """Generate a summary of the provided text"""
    summary_prompt = ChatPromptTemplate.from_template(
        "Summarize this text concisely:\n\n{text}"
    )
    summary_chain = summary_prompt | llm | StrOutputParser()
    return summary_chain.invoke({"text": text})

# Create hybrid agent
hybrid_agent = create_react_agent(
    llm,
    tools=[search_knowledge_base, calculate, generate_summary]
)

# Test complex queries that require multiple capabilities
complex_queries = [
    "Search the knowledge base for information about agents and summarize it",
    "Find information about chains and calculate how many components were mentioned",
    "What is RAG? Then summarize your findings in one sentence"
]

for query in complex_queries:
    print(f"\n{'='*60}")
    print(f"Query: {query}")
    print(f"{'='*60}")

    for chunk in hybrid_agent.stream(
        {"messages": [("user", query)]},
        stream_mode="values"
    ):
        chunk["messages"][-1].pretty_print()
```

**Explanation:** Hybrid systems combine RAG retrieval with agent reasoning and tools. Agents decide when to retrieve information versus using other capabilities.

---

### 18. Streaming RAG with Callbacks

**Use Case:** Real-time RAG responses with progress tracking

**Description:** Stream responses and track execution stages.

```python
from langchain_core.callbacks import BaseCallbackHandler
from typing import Any, Dict

class StreamingRAGCallback(BaseCallbackHandler):
    """Custom callback for tracking RAG execution"""

    def __init__(self):
        self.retrieval_count = 0
        self.generation_started = False

    def on_retriever_start(self, serialized: Dict[str, Any], query: str, **kwargs):
        print(f"\n[Retrieval] Searching for: {query}")
        self.retrieval_count += 1

    def on_retriever_end(self, documents, **kwargs):
        print(f"[Retrieval] Found {len(documents)} documents")

    def on_llm_start(self, serialized: Dict[str, Any], prompts: list, **kwargs):
        if not self.generation_started:
            print("[Generation] Starting response generation...")
            self.generation_started = True

    def on_llm_new_token(self, token: str, **kwargs):
        print(token, end="", flush=True)

    def on_chain_end(self, outputs: Dict[str, Any], **kwargs):
        print(f"\n\n[Complete] Total retrievals: {self.retrieval_count}")

# Setup streaming LLM
streaming_llm = ChatOpenAI(
    model="gpt-4o-mini",
    streaming=True,
    temperature=0
)

# Create streaming RAG chain
streaming_rag = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | streaming_llm
    | StrOutputParser()
)

# Execute with callback
callback = StreamingRAGCallback()

print("Question: What is LangChain?")
result = streaming_rag.invoke(
    "What is LangChain?",
    config={"callbacks": [callback]}
)
```

**Explanation:** Streaming with callbacks provides real-time feedback on RAG execution. Users see retrieval progress and response generation as it happens.

---

### 19. Multi-Index RAG

**Use Case:** Search across multiple knowledge bases

**Description:** Route queries to appropriate vector stores.

```python
from langchain_community.vectorstores import FAISS
from langchain_core.documents import Document

# Create multiple specialized vector stores
technical_docs = [
    Document(page_content="Python uses dynamic typing and garbage collection."),
    Document(page_content="Async/await enables concurrent programming in Python."),
]

business_docs = [
    Document(page_content="ROI measures the profitability of investments."),
    Document(page_content="Agile methodology emphasizes iterative development."),
]

product_docs = [
    Document(page_content="Our API supports REST and GraphQL."),
    Document(page_content="Enterprise plan includes 24/7 support."),
]

# Create separate vector stores
embeddings = OpenAIEmbeddings()
technical_store = FAISS.from_documents(technical_docs, embeddings)
business_store = FAISS.from_documents(business_docs, embeddings)
product_store = FAISS.from_documents(product_docs, embeddings)

# Router function
def route_query(query: str) -> FAISS:
    """Route query to appropriate vector store"""
    query_lower = query.lower()

    if any(word in query_lower for word in ["python", "code", "programming", "technical"]):
        print("[Router] -> Technical docs")
        return technical_store
    elif any(word in query_lower for word in ["business", "roi", "profit", "agile"]):
        print("[Router] -> Business docs")
        return business_store
    else:
        print("[Router] -> Product docs")
        return product_store

# Multi-index RAG
def multi_index_rag(query: str) -> str:
    # Route to appropriate store
    vectorstore = route_query(query)
    retriever = vectorstore.as_retriever()

    # Build RAG chain
    chain = (
        {"context": retriever | format_docs, "question": RunnablePassthrough()}
        | prompt
        | llm
        | StrOutputParser()
    )

    return chain.invoke(query)

# Test routing
queries = [
    "How does Python handle memory?",
    "What is ROI?",
    "What support options are available?"
]

for query in queries:
    print(f"\n{'='*60}")
    print(f"Query: {query}")
    answer = multi_index_rag(query)
    print(f"Answer: {answer}")
```

**Explanation:** Multi-index RAG routes queries to specialized knowledge bases. This improves relevance by searching domain-specific collections.

---

### 20. Evaluation Pipeline

**Use Case:** Automated RAG evaluation and quality metrics

**Description:** Measure RAG performance with automated evaluation.

```python
from langchain.evaluation import load_evaluator
from typing import List, Dict

# Evaluation metrics
def evaluate_rag_response(
    question: str,
    answer: str,
    contexts: List[str],
    ground_truth: str = None
) -> Dict[str, float]:
    """Evaluate RAG response quality"""

    results = {}

    # 1. Context relevance
    relevance_evaluator = load_evaluator("criteria", criteria="relevance")
    relevance_score = relevance_evaluator.evaluate_strings(
        prediction=answer,
        input=question,
        reference="\n".join(contexts)
    )
    results["context_relevance"] = relevance_score

    # 2. Answer completeness
    if ground_truth:
        accuracy_evaluator = load_evaluator("labeled_criteria", criteria="correctness")
        accuracy = accuracy_evaluator.evaluate_strings(
            prediction=answer,
            input=question,
            reference=ground_truth
        )
        results["accuracy"] = accuracy

    # 3. Response length appropriateness
    word_count = len(answer.split())
    results["word_count"] = word_count
    results["conciseness_score"] = 1.0 if 50 <= word_count <= 200 else 0.5

    return results

# Test cases with ground truth
test_cases = [
    {
        "question": "What is LangChain?",
        "ground_truth": "LangChain is a framework for developing applications powered by language models"
    },
    {
        "question": "How do agents work?",
        "ground_truth": "Agents use language models to choose sequences of actions to take"
    }
]

# Evaluate RAG system
print("Evaluating RAG System...\n")

for i, test in enumerate(test_cases, 1):
    print(f"Test Case {i}:")
    print(f"Question: {test['question']}")

    # Get RAG response
    answer = rag_chain.invoke(test["question"])
    print(f"Answer: {answer[:100]}...")

    # Get retrieved contexts
    docs = retriever.get_relevant_documents(test["question"])
    contexts = [doc.page_content for doc in docs]

    # Evaluate
    scores = evaluate_rag_response(
        question=test["question"],
        answer=answer,
        contexts=contexts,
        ground_truth=test["ground_truth"]
    )

    print(f"Evaluation Scores: {scores}\n")
    print(f"{'='*60}\n")
```

**Explanation:** Automated evaluation measures RAG quality using metrics like context relevance, answer accuracy, and conciseness. This enables systematic optimization.

---

## Summary

This examples collection demonstrates:

**Chains (4 examples):**
- Sequential processing with dependencies
- Parallel map-reduce patterns
- Dynamic routing and classification
- Conditional branching

**Agents (3 examples):**
- ReAct agents with custom tools
- LangGraph agents with memory
- Multi-step research workflows

**Memory (4 examples):**
- Complete conversation history
- Automatic summarization
- Semantic memory search
- Custom recall systems

**RAG (5 examples):**
- Basic retrieval-augmented generation
- Conversational RAG with history
- Multi-query retrieval
- Reranking for relevance
- Source citations

**Advanced Patterns (4 examples):**
- Hybrid agent-RAG systems
- Streaming with callbacks
- Multi-index routing
- Automated evaluation

Each example includes:
- Clear use case description
- Complete, runnable code
- Detailed explanation
- Production considerations

For comprehensive API reference, see SKILL.md.
For architecture and learning path, see README.md.
