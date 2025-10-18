---
description: Generate educational diagram from a URL source using Excalidraw
---

You are tasked with generating an educational diagram from online content using the Excalidraw MCP integration.

## Steps to follow:

1. Ask the user for the URL if not provided
2. Fetch and analyze the content from the URL using WebFetch
3. Extract key concepts and structure from the content
4. Determine the most appropriate diagram type based on content:
   - Documentation → Architecture or Concept Map
   - Tutorial/Guide → Flowchart or Process Flow
   - Historical content → Timeline
   - Conceptual article → Mind Map or Concept Map

5. Create the diagram using Excalidraw MCP tools:
   - Start with a clear structure
   - Use `batch_create_elements` for efficiency
   - Create hierarchies where appropriate
   - Add visual cues (colors, shapes) to enhance understanding
   - Ensure proper spacing and layout

6. Provide the user with:
   - Summary of what was diagrammed
   - Link to view at http://localhost:3000
   - Brief explanation of the diagram structure

## Tips for different content types:

**API Documentation**:
- Create architecture showing endpoints and data flow
- Use rectangles for services
- Use arrows for request/response flow

**Tutorial Content**:
- Create step-by-step flowchart
- Number the steps clearly
- Show decision points with diamonds

**Conceptual Articles**:
- Create mind map with central topic
- Branch out to sub-topics
- Use different colors for themes

This command enables agents to transform web content into visual educational materials!
