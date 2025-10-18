---
description: Generate educational diagram from a source file using Excalidraw
---

You are tasked with generating an educational diagram from source material using the Excalidraw MCP integration.

## Steps to follow:

1. Ask the user for the file path if not provided
2. Read the source file content
3. Analyze the content structure and determine the best diagram type:
   - **Flowchart**: For processes, workflows, or sequential steps
   - **Mind Map**: For hierarchical concepts or brainstorming
   - **Architecture**: For system designs or component structures
   - **Timeline**: For chronological events or historical data
   - **Concept Map**: For relationships between ideas

4. Use the Excalidraw MCP tools to create the diagram:
   - Use `batch_create_elements` for complex diagrams with multiple elements
   - Create appropriate shapes (rectangles, ellipses, diamonds for decisions)
   - Add connecting arrows or lines to show relationships
   - Use colors to distinguish different types or categories
   - Add clear text labels

5. Ensure the diagram is:
   - Clear and easy to understand
   - Well-organized with proper spacing
   - Visually appealing with appropriate colors
   - Complete with all necessary connections

6. Inform the user that the diagram is available at http://localhost:3000

## Example usage:

User provides a markdown file about "Software Development Lifecycle"
- Extract main concepts: Planning, Development, Testing, Deployment, Maintenance
- Create a flowchart showing the progression
- Add decision points where appropriate
- Use color coding for different phases
- Add arrows showing the flow and feedback loops

Remember to make educational diagrams that enhance understanding of the content!
