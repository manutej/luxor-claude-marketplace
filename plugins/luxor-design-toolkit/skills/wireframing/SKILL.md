---
name: wireframing
description: Low/high fidelity wireframes, user flows, information architecture, prototyping techniques, and design iteration processes
category: design
tags: [wireframing, ux, prototyping, user-flows, information-architecture, sketching]
version: 1.0.0
---

# Wireframing Skill

## Table of Contents
1. [When to Use This Skill](#when-to-use-this-skill)
2. [Core Concepts](#core-concepts)
3. [Wireframe Types](#wireframe-types)
4. [Information Architecture](#information-architecture)
5. [User Flows](#user-flows)
6. [Wireframe Elements](#wireframe-elements)
7. [Annotation and Specification](#annotation-and-specification)
8. [Tools and Technologies](#tools-and-technologies)
9. [Iteration Process](#iteration-process)
10. [Best Practices](#best-practices)
11. [Wireframing Examples](#wireframing-examples)

## When to Use This Skill

Wireframing is essential during various phases of product development and design:

### Early Product Discovery
- **Requirements gathering**: Visualize stakeholder ideas and requirements
- **Concept exploration**: Quickly test multiple design directions
- **Feasibility assessment**: Identify technical constraints early
- **Scope definition**: Define feature sets and functionality boundaries

### Design Process
- **Information architecture**: Structure content and navigation hierarchies
- **Layout exploration**: Test different arrangements of UI elements
- **User flow mapping**: Visualize user journeys through the product
- **Interaction design**: Define how users interact with interface elements

### Collaboration and Communication
- **Stakeholder alignment**: Get buy-in before detailed design work
- **Developer handoff**: Communicate functionality and structure
- **User testing**: Validate concepts without expensive high-fidelity work
- **Design documentation**: Create reference materials for the team

### Iteration and Refinement
- **Design critique sessions**: Focus feedback on structure not aesthetics
- **Rapid prototyping**: Test ideas quickly with minimal investment
- **A/B testing concepts**: Compare different approaches efficiently
- **Design system foundation**: Establish patterns before visual design

## Core Concepts

### Low Fidelity vs High Fidelity

**Low Fidelity Wireframes**

Characteristics:
- Basic shapes and placeholders (boxes, lines, simple text)
- Grayscale or monochromatic color schemes
- Minimal detail and visual polish
- Focus on structure and layout
- Quick to create and modify
- Often hand-drawn or using basic digital tools

When to use:
- Early conceptual phases
- Rapid iteration and exploration
- Stakeholder workshops and brainstorming
- When you need quick feedback on structure
- Budget or time constraints

Advantages:
- Fast creation and iteration
- Low investment reduces attachment to ideas
- Encourages focus on functionality
- Accessible to non-designers
- Reduces cognitive load during review

**High Fidelity Wireframes**

Characteristics:
- Detailed UI elements and components
- Refined spacing and alignment
- Actual or representative content
- Interactive elements clearly defined
- May include real images and copy
- Closer to final design

When to use:
- After concept validation
- Developer handoff preparation
- Detailed user testing
- When precise specifications are needed
- Stakeholder presentations requiring polish

Advantages:
- Clear communication of intent
- Better for usability testing
- Serves as development reference
- Identifies edge cases and details
- Reduces ambiguity in implementation

### The Wireframing Spectrum

```
Sketches → Low-Fi → Mid-Fi → High-Fi → Mockups → Prototypes
  ↓          ↓        ↓         ↓         ↓          ↓
Paper    Boxes &  Details   Refined   Visual    Interactive
notes    labels   added     content   design    behavior
```

### Fidelity Dimensions

Wireframes can vary in fidelity across multiple dimensions:

1. **Visual Fidelity**: Level of visual detail and polish
2. **Content Fidelity**: Real vs placeholder content
3. **Functional Fidelity**: Interactive vs static
4. **Layout Fidelity**: Precise vs approximate spacing

## Wireframe Types

### 1. Paper Sketches

**Description**: Hand-drawn wireframes on paper or whiteboards

**Use Cases**:
- Brainstorming sessions
- Quick ideation
- Early concept exploration
- Collaborative workshops
- Personal thinking process

**Tools**:
- Pen and paper
- Whiteboards
- Sticky notes
- Dot grid notebooks
- Stencils and templates

**Techniques**:
- Quick sketching with basic shapes
- Crazy 8's method (8 ideas in 8 minutes)
- Thumbnail sketches for multiple concepts
- Annotation with arrows and notes
- Photograph for digital archiving

**Advantages**:
- Zero learning curve
- No tool barriers
- Encourages creativity
- Natural for collaboration
- Portable and accessible

**Limitations**:
- Not easily shared remotely
- Difficult to iterate digitally
- Lacks precision
- Hard to maintain version control
- Not suitable for developer handoff

### 2. Low-Fidelity Digital Wireframes

**Description**: Simple digital wireframes using basic shapes and minimal styling

**Visual Characteristics**:
- Boxes, lines, and simple geometric shapes
- Grayscale color palette
- Placeholder text (Lorem ipsum or FPO)
- Generic icons (squares with X's for images)
- Minimal hierarchy through size and weight

**Content**:
- "Hero Image" or gray boxes for visuals
- Lorem ipsum or repeated text
- Generic labels and headings
- Simplified navigation structures

**Common Elements**:
- Header placeholders
- Navigation bars (simple lines/boxes)
- Content blocks (rectangles)
- Button placeholders (outlined boxes)
- Form fields (lines or simple inputs)
- Footer areas

**Best For**:
- Exploring multiple layout options
- Testing information hierarchy
- Getting quick stakeholder feedback
- Validating user flows
- Design team discussions

### 3. Mid-Fidelity Wireframes

**Description**: More refined wireframes with moderate detail

**Visual Characteristics**:
- Actual UI component representations
- Refined spacing and alignment
- Typography hierarchy (different weights/sizes)
- Some real content mixed with placeholders
- Basic iconography
- Grid-based layouts

**Content**:
- Mix of real and placeholder text
- Actual headings and key copy
- Representative content length
- Realistic form labels
- Actual navigation items

**Interactive Elements**:
- Clear button states
- Form field types defined
- Dropdown indicators
- Link styling
- Active states indicated

**Best For**:
- User testing structure and flow
- Detailed stakeholder reviews
- Information architecture validation
- Content strategy alignment
- Pre-development planning

### 4. High-Fidelity Wireframes

**Description**: Detailed, polished wireframes that closely represent final design

**Visual Characteristics**:
- Precise spacing and measurements
- Refined typography system
- Real or high-quality placeholder content
- Detailed component states
- Accessibility considerations
- Responsive breakpoints shown

**Content**:
- Actual copy or near-final content
- Real images or high-quality stock photos
- Accurate data representations
- Proper content hierarchy
- Character count considerations

**Annotations**:
- Interaction specifications
- State descriptions
- Conditional logic
- Error handling
- Loading states
- Edge cases documented

**Best For**:
- Developer handoff
- Detailed usability testing
- Stakeholder sign-off
- Design system documentation
- Accessibility review

### 5. Interactive Prototypes

**Description**: Clickable wireframes that simulate user interactions

**Capabilities**:
- Page navigation
- Form interactions
- Modal and overlay behaviors
- Animations and transitions
- Conditional logic
- User input handling

**Fidelity Levels**:
- Low-fi interactive: Basic click-through
- Mid-fi interactive: Some conditional flows
- High-fi interactive: Complex behaviors and micro-interactions

**Use Cases**:
- Usability testing
- Stakeholder demonstrations
- User flow validation
- Interaction pattern testing
- Presentation to executives

**Tools**:
- Figma prototyping
- Axure RP
- Proto.io
- InVision
- Adobe XD

## Information Architecture

### Sitemaps

**Purpose**: Visual representation of website/app structure and hierarchy

**Components**:
- Pages/screens represented as nodes
- Hierarchical relationships
- Navigation pathways
- Content groupings
- User access levels

**Types of Sitemaps**:

1. **Hierarchical Sitemap**:
```
Home
├── Products
│   ├── Category A
│   │   ├── Product 1
│   │   └── Product 2
│   └── Category B
│       ├── Product 3
│       └── Product 4
├── About
│   ├── Team
│   └── History
└── Contact
```

2. **Sequential Sitemap**: Linear flows (e.g., onboarding, checkout)
3. **Matrix Sitemap**: Multiple paths to the same destination
4. **Organic Sitemap**: User-generated or dynamic content structures

**Best Practices**:
- Use consistent notation and symbols
- Indicate page templates vs unique pages
- Show navigation types (global, utility, contextual)
- Document user permissions and access
- Include off-site links and integrations
- Version and date your sitemaps

### Content Hierarchy

**Definition**: Organization of content by importance and relationships

**Principles**:

1. **Visual Hierarchy**:
- Size: Larger elements draw more attention
- Weight: Bold text creates emphasis
- Color: Contrast highlights importance
- Position: Top and left get noticed first
- White space: Breathing room adds prominence

2. **Information Hierarchy**:
- Primary information: Main user goal
- Secondary information: Supporting details
- Tertiary information: Optional or contextual
- Metadata: System-level information

**F-Pattern and Z-Pattern**:
- **F-Pattern**: Common reading pattern for text-heavy content
  - Users scan horizontally across top
  - Second horizontal scan lower down
  - Vertical scan down left side

- **Z-Pattern**: For less text-heavy, more visual content
  - Top left to top right
  - Diagonal to bottom left
  - Bottom left to bottom right

**Creating Clear Hierarchy**:
- Establish clear content types (H1, H2, H3, body, captions)
- Use consistent spacing scales
- Group related information
- Apply the principle of proximity
- Limit hierarchy levels (typically 3-4 max)
- Test hierarchy by squinting (blur test)

### Card Sorting

**Purpose**: Understand user mental models for content organization

**Types**:

1. **Open Card Sorting**:
- Participants create their own categories
- Useful for discovering natural groupings
- Best for new products or redesigns

2. **Closed Card Sorting**:
- Participants sort into predefined categories
- Validates existing structure
- Tests category labels

3. **Hybrid Card Sorting**:
- Predefined categories with option to create new ones
- Balances structure with discovery

**Process**:
1. Identify content items to be sorted
2. Create cards (physical or digital)
3. Recruit representative users
4. Conduct sorting sessions
5. Analyze results for patterns
6. Iterate on information architecture

**Tools**:
- OptimalSort
- UserZoom
- Miro (virtual card sorting)
- Physical index cards

## User Flows

### Task Flows

**Definition**: Step-by-step paths users take to complete specific tasks

**Components**:
- Entry point
- Decision points
- Actions/steps
- System responses
- Success criteria
- Error states

**Flow Diagram Elements**:
- **Rectangles**: Screens or pages
- **Diamonds**: Decision points
- **Ovals**: Entry/exit points
- **Arrows**: Flow direction
- **Annotations**: Additional context

**Example Task Flow Structure**:
```
[Start] → [Login Page] → {Valid Credentials?}
                              ↓ Yes          ↓ No
                         [Dashboard]    [Error Message]
                              ↓               ↓
                         [Success]      [Retry Login]
```

**Creating Effective Task Flows**:
1. Define the user goal clearly
2. Map all possible paths (happy path and edge cases)
3. Identify decision points
4. Document system responses
5. Include error handling
6. Note any assumptions
7. Test with actual user scenarios

### User Journeys

**Definition**: Holistic view of user experience across touchpoints over time

**Difference from Task Flows**:
- Broader scope (multiple tasks/sessions)
- Includes emotional journey
- Considers all touchpoints
- Maps user thoughts and feelings
- Identifies pain points and opportunities

**Journey Map Components**:
1. **Persona**: Who is the user?
2. **Scenario**: What are they trying to accomplish?
3. **Phases**: Major stages of the journey
4. **Actions**: What the user does
5. **Touchpoints**: Where interactions occur
6. **Thoughts**: User mental model
7. **Emotions**: User feelings (often visualized as a graph)
8. **Pain Points**: Frustrations and obstacles
9. **Opportunities**: Areas for improvement

**Example Journey Phases** (E-commerce):
1. Awareness: Discover product need
2. Research: Compare options
3. Purchase: Complete transaction
4. Delivery: Receive product
5. Usage: Experience product
6. Support: Get help if needed
7. Loyalty: Repeat purchase or recommend

### Flowcharts

**Purpose**: Visualize logic, processes, and system behavior

**Standard Flowchart Symbols**:
- **Terminator** (oval): Start/End
- **Process** (rectangle): Action or step
- **Decision** (diamond): Yes/No question
- **Input/Output** (parallelogram): Data entry or display
- **Connector** (circle): Link to another part of flow
- **Document** (wavy bottom rectangle): Document or report

**Types of Flowcharts for UX**:

1. **User Flowchart**: User's path through interface
2. **System Flowchart**: Backend logic and processes
3. **Swimlane Flowchart**: Multiple actors or systems
4. **State Diagram**: Object states and transitions

**Best Practices**:
- Use standard symbols consistently
- Flow top-to-bottom, left-to-right
- Minimize crossing lines
- Label all decision branches clearly
- Keep flows on one page when possible
- Use connectors for complex flows
- Include a legend if needed

### Wireflows

**Definition**: Combination of wireframes and user flows

**Format**:
- Actual wireframe screens connected by arrows
- Shows both interface design and flow logic
- Annotations on transitions and interactions

**When to Use**:
- Complex interaction patterns
- Multi-step processes
- Conditional navigation
- Developer handoff for flows
- Documenting interactive prototypes

**Creating Wireflows**:
1. Create key wireframes for each step
2. Arrange in logical sequence
3. Connect with arrows showing transitions
4. Annotate triggers and conditions
5. Include alternative paths
6. Note error states and edge cases

## Wireframe Elements

### Layout Components

**Grid Systems**:
- 12-column grid (most common for responsive)
- 8-column grid (simpler layouts)
- 16-column grid (complex, detailed layouts)
- Baseline grid (vertical rhythm)

**Container Types**:
- Fixed width containers
- Fluid containers (full width)
- Constrained containers (max-width)

**Spacing Systems**:
- 4px or 8px base unit
- Consistent padding and margins
- Vertical rhythm for readability

### Navigation Elements

**Primary Navigation**:
- Top horizontal navigation bar
- Hamburger/mobile menu
- Mega menus
- Sidebar navigation
- Tab navigation

**Secondary Navigation**:
- Breadcrumbs
- Pagination
- Filters and sorting
- In-page navigation (anchor links)
- Related links

**Utility Navigation**:
- User account menu
- Cart/shopping bag
- Search
- Language/region selector
- Settings and preferences

### Content Elements

**Typography Placeholders**:
- Headlines (H1, H2, H3, etc.)
- Body text (paragraphs)
- Lists (bulleted, numbered)
- Captions and labels
- Links and CTAs

**Media Placeholders**:
- Images (box with X or diagonal lines)
- Video players (box with play icon)
- Icons (simple shapes or actual icons)
- Maps (box labeled "MAP")
- Charts and graphs

**Form Elements**:
- Text inputs
- Text areas
- Checkboxes
- Radio buttons
- Dropdowns/select menus
- Date pickers
- File uploads
- Submit buttons

### Interactive Elements

**Buttons**:
- Primary buttons (filled)
- Secondary buttons (outlined)
- Tertiary buttons (text only)
- Icon buttons
- Button groups
- Toggle buttons

**Links**:
- Inline text links
- Standalone links
- Navigation links
- Footer links

**Toggles and Switches**:
- On/off toggles
- Checkbox toggles
- Segmented controls

**Cards**:
- Content cards
- Product cards
- Profile cards
- Interactive cards

### Feedback Elements

**Status Indicators**:
- Loading spinners
- Progress bars
- Success messages
- Error messages
- Warning messages
- Informational messages

**Modals and Overlays**:
- Modal dialogs
- Lightboxes
- Tooltips
- Popovers
- Drawers/side panels

## Annotation and Specification

### Types of Annotations

**1. Functional Annotations**:
- What happens when user clicks/taps
- Form validation rules
- Dynamic content updates
- Conditional logic

Example:
```
[Button: "Add to Cart"]
→ On click: Add item to cart
→ Update cart count in header
→ Show success message
→ Animate button (scale feedback)
```

**2. Content Annotations**:
- Character limits
- Content sources
- Placeholder vs final content
- Content rules and logic

Example:
```
[Product Title]
→ Max 60 characters
→ Source: Product database, title field
→ Truncate with ellipsis if exceeds limit
```

**3. Behavioral Annotations**:
- Hover states
- Active states
- Disabled states
- Loading states
- Error states

**4. Technical Annotations**:
- API endpoints
- Data requirements
- Performance considerations
- Third-party integrations

**5. Accessibility Annotations**:
- Alt text requirements
- ARIA labels
- Focus order
- Keyboard interactions
- Screen reader behavior

### Annotation Methods

**Numbered Callouts**:
```
Wireframe with numbered markers:
1. Logo links to homepage
2. Search expands on click
3. Cart shows item count
4. User menu drops down on hover
```

**Inline Notes**:
- Annotations directly on or near elements
- Use leader lines for clarity
- Color-code by annotation type

**Separate Specification Document**:
- Detailed specifications separate from wireframes
- Reference wireframes by screen name/number
- Include user stories and acceptance criteria

**Interactive Annotations** (in prototyping tools):
- Hover to reveal notes
- Click to expand details
- Linked specification docs

### Writing Clear Annotations

**Best Practices**:
1. Be specific and unambiguous
2. Use consistent terminology
3. Focus on behavior, not implementation
4. Include edge cases
5. Reference design patterns or examples
6. Specify what, not how (unless critical)

**Poor Annotation**:
"Button does something when clicked"

**Good Annotation**:
"On click: Submit form data. If validation passes, navigate to confirmation page. If validation fails, display inline error messages next to invalid fields and scroll to first error."

### Specifications for Developers

**What to Include**:

1. **Layout Specifications**:
- Spacing values (padding, margins)
- Grid columns and gutters
- Breakpoint behaviors
- Alignment rules

2. **Component Specifications**:
- States (default, hover, active, disabled, error)
- Size variations
- Content rules
- Accessibility requirements

3. **Interaction Specifications**:
- User triggers (click, tap, hover, swipe)
- System responses
- Animation timing and easing
- Transition behaviors

4. **Data Specifications**:
- Required vs optional data
- Data formats
- Default values
- Validation rules

5. **Conditional Logic**:
- If/then scenarios
- User permission levels
- Feature flags
- Personalization rules

## Tools and Technologies

### Paper and Physical Tools

**Pen and Paper**:
- **Best for**: Quick ideation, brainstorming
- **Pros**: Immediate, tactile, accessible
- **Cons**: Hard to share remotely, limited iteration

**Whiteboards**:
- **Best for**: Collaborative sessions, workshops
- **Pros**: Easy to erase and modify, great for groups
- **Cons**: Not portable, requires photography for archiving

**Sticky Notes**:
- **Best for**: Card sorting, affinity mapping, flow creation
- **Pros**: Flexible, tactile, easy to reorganize
- **Cons**: Temporary, requires physical space

**Wireframe Notebooks and Templates**:
- Dot grid notebooks
- Pre-printed device templates
- UI stencils
- **Pros**: Structured, professional-looking
- **Cons**: Limited flexibility

### Low-Fidelity Digital Tools

**Balsamiq**:
- **Description**: Sketch-style wireframing tool
- **Best for**: Low-fi wireframes, rapid prototyping
- **Key features**:
  - Intentionally "sketchy" aesthetic
  - Large component library
  - Quick to create mockups
  - Built-in UI components
- **Pricing**: Subscription-based
- **Learning curve**: Low

**Whimsical**:
- **Description**: Lightweight diagramming and wireframing
- **Best for**: Flowcharts, wireframes, mind maps
- **Key features**:
  - Fast performance
  - Clean, minimal interface
  - Real-time collaboration
  - Integrated flowcharts and wireframes
- **Pricing**: Freemium
- **Learning curve**: Very low

**Miro**:
- **Description**: Digital whiteboard platform
- **Best for**: Workshops, brainstorming, collaborative wireframing
- **Key features**:
  - Infinite canvas
  - Wireframe templates
  - Real-time collaboration
  - Integration with other tools
- **Pricing**: Freemium
- **Learning curve**: Low

### Professional Wireframing Tools

**Figma**:
- **Description**: Collaborative interface design tool
- **Best for**: All fidelity levels, design systems, prototyping
- **Key features**:
  - Browser-based, cross-platform
  - Real-time collaboration
  - Component libraries
  - Advanced prototyping
  - Design systems support
  - Developer handoff
  - Version history
- **Pricing**: Freemium (free for individual use)
- **Learning curve**: Medium
- **Wireframing approach**:
  - Use Auto Layout for responsive designs
  - Create component libraries
  - Leverage community wireframe kits
  - Use variants for component states

**Sketch**:
- **Description**: Vector-based design tool (macOS only)
- **Best for**: High-fidelity wireframes, UI design
- **Key features**:
  - Symbols and libraries
  - Plugin ecosystem
  - Prototyping capabilities
  - Developer handoff
- **Pricing**: Subscription
- **Learning curve**: Medium
- **Limitations**: macOS only, limited collaboration

**Adobe XD**:
- **Description**: UI/UX design and prototyping tool
- **Best for**: High-fidelity wireframes, interactive prototypes
- **Key features**:
  - Components and states
  - Advanced prototyping
  - Auto-animate
  - Voice prototyping
  - Design systems
- **Pricing**: Included with Creative Cloud
- **Learning curve**: Medium

**Axure RP**:
- **Description**: Professional prototyping and specification tool
- **Best for**: Complex interactions, detailed specifications
- **Key features**:
  - Advanced conditional logic
  - Dynamic content
  - Variables and expressions
  - Detailed documentation generation
  - Team collaboration
- **Pricing**: License-based (expensive)
- **Learning curve**: High
- **Best for**: Enterprise, complex applications

### Specialized Tools

**OmniGraffle** (macOS/iOS):
- **Best for**: Diagrams, sitemaps, user flows
- **Strengths**: Powerful diagramming, beautiful output
- **Limitations**: macOS/iOS only

**Lucidchart**:
- **Best for**: Flowcharts, sitemaps, system diagrams
- **Strengths**: Collaboration, integrations
- **Use case**: Information architecture documentation

**FlowMapp**:
- **Best for**: Sitemaps and user flows
- **Strengths**: Purpose-built for IA work
- **Features**: Visual sitemaps, user flow creation

**Overflow**:
- **Best for**: User flow diagrams from designs
- **Strengths**: Imports from design tools, creates beautiful flows
- **Use case**: Documentation and presentation

### Code-Based Wireframing

**HTML/CSS Wireframes**:
- **When to use**: When wireframes should be functional
- **Pros**: Truly responsive, testable, can become production code
- **Cons**: Slower, requires coding skills

**Frameworks for Wireframing**:
- **Tailwind CSS**: Utility-first CSS framework
- **Bootstrap**: Component library
- **Material UI**: Google's design system
- **Semantic UI**: Human-friendly HTML

**Example Tools**:
- CodePen: Quick prototyping
- JSFiddle: Interactive coding
- StackBlitz: Full development environment

### Choosing the Right Tool

**Decision Factors**:

1. **Project Fidelity Needs**:
- Low-fi: Balsamiq, Whimsical, paper
- Mid-fi: Figma, Sketch, Adobe XD
- High-fi: Figma, Sketch, Adobe XD, Axure

2. **Collaboration Requirements**:
- Solo: Any tool
- Small team: Figma, Miro, Whimsical
- Large team: Figma, Adobe XD, Axure

3. **Budget**:
- Free: Figma (free tier), Miro (free tier), paper
- Moderate: Whimsical, Balsamiq
- Enterprise: Axure, Sketch

4. **Platform**:
- Cross-platform: Figma, Adobe XD, web-based tools
- macOS only: Sketch, OmniGraffle

5. **Learning Curve**:
- Easy: Balsamiq, Whimsical, paper
- Moderate: Figma, Adobe XD
- Advanced: Axure, code-based

## Iteration Process

### Design Iteration Cycle

**1. Create Initial Wireframes**:
- Start with low-fidelity sketches
- Focus on core user flows
- Explore multiple concepts
- Don't get attached to first ideas

**2. Internal Review**:
- Share with design team
- Get feedback on structure and flow
- Identify assumptions and gaps
- Refine based on team input

**3. Stakeholder Review**:
- Present to product owners, business stakeholders
- Validate against business requirements
- Confirm scope and priorities
- Document decisions and rationale

**4. User Testing**:
- Test with representative users
- Observe behavior, not just opinions
- Identify pain points and confusion
- Validate assumptions

**5. Analysis and Synthesis**:
- Review feedback and data
- Identify patterns and themes
- Prioritize changes
- Create action items

**6. Refinement**:
- Incorporate validated changes
- Increase fidelity if appropriate
- Add detail where needed
- Prepare for next round

**7. Repeat**:
- Multiple iterations are normal
- Each cycle should answer specific questions
- Know when to move forward

### Feedback Loops

**Types of Feedback**:

1. **Design Critique**:
- Regular sessions with design team
- Focus on specific aspects
- Structured feedback format
- Document decisions

2. **Stakeholder Feedback**:
- Business alignment check
- Technical feasibility review
- Resource and timeline impact
- Strategic fit

3. **User Feedback**:
- Usability testing
- Surveys and interviews
- Analytics and behavior data
- A/B testing results

**Feedback Best Practices**:
- Set clear objectives for each review
- Ask specific questions
- Focus on user needs, not personal preferences
- Document all feedback and decisions
- Close the loop (show how feedback was addressed)

### Usability Testing with Wireframes

**When to Test**:
- After initial concept validation
- Before high-fidelity design work
- When exploring new patterns
- To validate major changes

**Testing Methods**:

1. **Moderated Usability Testing**:
- One-on-one sessions
- Think-aloud protocol
- Task-based scenarios
- Observer takes notes

2. **Unmoderated Testing**:
- Remote, asynchronous
- Users complete tasks independently
- Screen recording
- Survey responses

3. **Guerrilla Testing**:
- Quick, informal testing
- Coffee shop or public space
- Brief sessions (5-10 minutes)
- Low-fi appropriate

**What to Test**:
- Can users complete key tasks?
- Do users understand the information hierarchy?
- Is the navigation intuitive?
- Are interactions clear?
- Does the flow match user mental models?
- Are there points of confusion or friction?

**Testing Wireframes vs High-Fi**:
- Wireframes: Test structure and flow
- High-fidelity: Test visual hierarchy and details
- Both: Test usability and user understanding

### Progressive Refinement

**Low-Fi to High-Fi Journey**:

**Stage 1: Sketches** (Hours):
- Multiple rough concepts
- Explore different approaches
- Get quick team alignment
- Identify obvious issues

**Stage 2: Low-Fi Wireframes** (Days):
- Digitize best concepts
- Create basic user flows
- Test core structure
- Stakeholder review

**Stage 3: Mid-Fi Wireframes** (Days-Weeks):
- Add detail and refinement
- Include actual content where possible
- Create component consistency
- User testing

**Stage 4: High-Fi Wireframes** (Weeks):
- Precise specifications
- All states documented
- Edge cases addressed
- Developer-ready

**Stage 5: Interactive Prototype** (Weeks):
- Functional interactions
- Animation and transitions
- Advanced user testing
- Stakeholder demos

**When to Increase Fidelity**:
- Core structure is validated
- Major changes are unlikely
- Specific details need testing
- Developer handoff is approaching
- Stakeholder sign-off is needed

**When to Stay Low-Fi**:
- Still exploring options
- Major questions unanswered
- Early in process
- Limited time/budget
- Testing basic concepts

## Best Practices

### Clarity and Communication

**1. Use Consistent Visual Language**:
- Same placeholder styles throughout
- Consistent annotation format
- Standard symbols and notation
- Uniform component representation

**2. Establish Clear Hierarchy**:
- Size indicates importance
- Spacing creates relationships
- Weight adds emphasis
- Position guides attention

**3. Label Everything**:
- Page/screen names
- Section headings
- Interactive elements
- Navigation items
- Form fields

**4. Provide Context**:
- Show where in the flow users are
- Include breadcrumbs or progress indicators
- Reference related screens
- Note user state or context

**5. Document Assumptions**:
- Note what's assumed about user knowledge
- Document technical assumptions
- Clarify content assumptions
- Specify user permissions or roles

### Focus on Structure Over Style

**1. Resist Visual Design Temptation**:
- Don't choose final colors yet
- Avoid specific typography decisions
- Don't add unnecessary decoration
- Focus on layout and function

**2. Use Grayscale**:
- Keeps focus on structure
- Prevents premature style decisions
- Reduces stakeholder distraction
- Makes hierarchy testing easier

**3. Consistent Element Styling**:
- All buttons look the same
- All form fields consistent
- All headings uniform
- Variations only when functionally different

**4. Separate Content from Container**:
- Use placeholders appropriately
- Don't let content drive layout
- Consider various content scenarios
- Plan for edge cases (long/short content)

### Collaboration and Handoff

**1. Involve Stakeholders Early**:
- Share low-fi concepts quickly
- Get alignment before detail work
- Regular check-ins
- Document decisions

**2. Work with Developers**:
- Understand technical constraints
- Ask about feasibility
- Provide clear specifications
- Be available for questions

**3. Version Control**:
- Date all wireframes
- Track major changes
- Maintain changelog
- Archive old versions

**4. Create a Design System**:
- Reusable components
- Consistent patterns
- Shared libraries
- Documentation

**5. Handoff Checklist**:
- All screens documented
- Interactions specified
- States defined
- Edge cases addressed
- Assets prepared
- Specifications clear

### Accessibility Considerations

**1. Consider Screen Readers**:
- Logical heading hierarchy
- Meaningful link text
- Form label associations
- Alt text requirements noted

**2. Keyboard Navigation**:
- Focus order makes sense
- All interactive elements accessible
- Keyboard shortcuts documented
- Skip links for long pages

**3. Color and Contrast**:
- Don't rely on color alone
- Note where contrast is critical
- Consider colorblind users
- Plan for high contrast modes

**4. Touch Targets**:
- Minimum 44x44px for mobile
- Adequate spacing between targets
- Consider thumb zones
- Plan for various input methods

**5. Content Accessibility**:
- Clear language
- Logical structure
- Alternatives for complex content
- Captions for media

### Common Pitfalls to Avoid

**1. Too Much Detail Too Soon**:
- Risk: Wasted effort on wrong direction
- Solution: Stay low-fi until validated

**2. Designing in a Vacuum**:
- Risk: Misaligned with user needs or business goals
- Solution: Regular feedback and testing

**3. Ignoring Edge Cases**:
- Risk: Incomplete specifications, development surprises
- Solution: Think through error states, empty states, loading, etc.

**4. Inconsistent Patterns**:
- Risk: Confusing users, inefficient development
- Solution: Establish and follow patterns

**5. Missing Mobile/Responsive Considerations**:
- Risk: Designs don't work on all devices
- Solution: Design for multiple breakpoints

**6. Inadequate Annotation**:
- Risk: Misunderstood requirements, rework
- Solution: Clear, comprehensive specifications

**7. Skipping User Testing**:
- Risk: Building the wrong thing
- Solution: Test early and often

**8. Not Considering Content**:
- Risk: Designs break with real content
- Solution: Use realistic content, plan for variations

## Wireframing Examples

### Example 1: E-Commerce Product Listing Page

**Purpose**: Display multiple products with filtering and sorting

**Low-Fidelity Approach**:
```
[Header]
+------------------------------------------+
| Logo    Search        Cart  Account      |
+------------------------------------------+

[Breadcrumbs]
Home > Category > Subcategory

[Main Content Area]
+------------+  +------------------------+
| Filters    |  | [Sort: Dropdown]       |
|            |  | [Grid View] [List View]|
| Category   |  |                        |
| [ ] Option |  | +----+  +----+  +----+ |
| [ ] Option |  | |Img |  |Img |  |Img | |
|            |  | |    |  |    |  |    | |
| Price      |  | |Name|  |Name|  |Name| |
| [Slider]   |  | |$XXX|  |$XXX|  |$XXX| |
|            |  | +----+  +----+  +----+ |
| Brand      |  |                        |
| [ ] Option |  | +----+  +----+  +----+ |
| [ ] Option |  | |Img |  |Img |  |Img | |
|            |  | +----+  +----+  +----+ |
| [Apply]    |  |                        |
+------------+  | [Load More]            |
                +------------------------+
```

**Annotations**:
1. Filter sidebar: Collapsible on mobile
2. Product grid: 3 columns desktop, 2 tablet, 1 mobile
3. Sort dropdown: Options include price, rating, newest
4. Each product card links to product detail page
5. "Load More" uses infinite scroll on mobile

**High-Fidelity Considerations**:
- Product image aspect ratio: 1:1
- Price formatting with currency
- Sale price treatment
- Quick view functionality
- Wishlist/favorite icons
- Out of stock indication
- Rating stars display

### Example 2: User Registration Flow

**Flow Overview**:
```
[Landing Page] → [Sign Up Form] → [Email Verification] → [Profile Setup] → [Dashboard]
                       ↓
                  [Login Instead]
```

**Sign Up Form Wireframe**:
```
+------------------------------------------+
|              Create Account              |
+------------------------------------------+
|                                          |
| Full Name                                |
| [________________________]               |
|                                          |
| Email Address                            |
| [________________________]               |
|                                          |
| Password                                 |
| [________________________]  [👁]         |
| • Must be 8+ characters                  |
| • Include number and special character   |
|                                          |
| [ ] I agree to Terms and Privacy Policy  |
|                                          |
| [     Create Account      ]              |
|                                          |
| Already have an account? [Log In]        |
|                                          |
| -------- Or sign up with --------        |
|                                          |
| [Google]  [Apple]  [Facebook]            |
+------------------------------------------+
```

**Annotations**:
1. Email field: Validate format on blur
2. Password field: Toggle visibility with eye icon
3. Password strength indicator: Update as user types
4. Terms checkbox: Required, link to full terms
5. Social signup: OAuth flow, create account with minimal info
6. Error handling: Inline validation, show errors above field

**States to Consider**:
- Empty state (initial)
- Filled state (valid)
- Error state (invalid email, weak password)
- Loading state (submitting)
- Success state (account created)

### Example 3: Dashboard with Data Visualization

**Purpose**: Display key metrics and performance data

**Layout Structure**:
```
+----------------------------------------------------+
| Logo  Dashboard  Reports  Settings    [Profile▼]  |
+----------------------------------------------------+
| Welcome back, [User Name]         [Date Range ▼]  |
|                                                    |
| +---------------+  +---------------+  +---------+  |
| | Total Sales   |  | Orders        |  | Growth  |  |
| | $XXX,XXX      |  | XXX           |  | +XX%    |  |
| | +XX% vs LM    |  | +XX% vs LM    |  | ↑       |  |
| +---------------+  +---------------+  +---------+  |
|                                                    |
| +------------------------------------------------+ |
| | Revenue Over Time                 [Month▼]    | |
| | [Line Chart]                                   | |
| |                                                | |
| |                                                | |
| +------------------------------------------------+ |
|                                                    |
| +-----------------------+  +---------------------+ |
| | Top Products          |  | Recent Orders       | |
| | 1. Product A    $XXX  |  | #1234  [Status]     | |
| | 2. Product B    $XXX  |  | #1235  [Status]     | |
| | 3. Product C    $XXX  |  | #1236  [Status]     | |
| | [View All]            |  | [View All]          | |
| +-----------------------+  +---------------------+ |
+----------------------------------------------------+
```

**Interactive Elements**:
1. Date range picker: Updates all data
2. Metric cards: Click to drill down
3. Chart: Hover for data points, click for details
4. Tables: Sortable columns, click row for details

**Responsive Behavior**:
- Desktop: 3-column metric cards, side-by-side tables
- Tablet: 2-column metrics, stacked tables
- Mobile: 1-column, vertical stack, simplified chart

### Example 4: Mobile App Onboarding

**Screen Flow**:
```
[Splash] → [Welcome] → [Feature 1] → [Feature 2] → [Feature 3] → [Sign Up/Login]
              ↓
           [Skip]
```

**Welcome Screen**:
```
+-------------------+
|                   |
|   [Illustration]  |
|                   |
|  Welcome to App   |
|                   |
|  Discover amazing |
|  features that    |
|  make life easier |
|                   |
| ● ○ ○ ○           |
|                   |
| [     Next     ]  |
|                   |
| [Skip]            |
+-------------------+
```

**Annotations**:
1. Swipe gestures: Left/right to navigate
2. Progress dots: Indicate current screen (4 total)
3. Next button: Advance to next screen
4. Skip link: Jump directly to sign up/login
5. Auto-advance: Option to auto-play with timer

**Design Considerations**:
- Simple, focused messaging
- One concept per screen
- Visual > text
- Easy exit option
- Remember user (don't show again)

### Example 5: Search Results Page

**Layout**:
```
+--------------------------------------------------+
| Logo  [Search: "keyword"            ] [Search]   |
+--------------------------------------------------+
| About X,XXX results (0.XX seconds)               |
|                                                  |
| Filters: [All] [Images] [Videos] [News] [More▼] |
|                                                  |
| +---------+                                      |
| | [Image] |  Result Title - Linked               |
| +---------+  www.example.com › path              |
|              Brief description of the content    |
|              showing search term highlighted...  |
|              Additional context line.            |
|                                                  |
| +---------+                                      |
| | [Image] |  Result Title - Linked               |
| +---------+  www.example.com › path              |
|              Brief description...                |
|                                                  |
| [People also ask]                                |
| ▼ Question related to search?                    |
| ▼ Another question?                              |
|                                                  |
| ... more results ...                             |
|                                                  |
| [Previous] [1] [2] [3] [4] [5] [Next]           |
+--------------------------------------------------+
```

**Annotations**:
1. Search box: Maintains query, suggest refinements
2. Filters: Change result type, update page
3. Result images: Preview image when available
4. Breadcrumb URL: Show page hierarchy
5. Description: Keyword highlighting
6. "People also ask": Expandable FAQ accordion
7. Pagination: Standard page navigation

### Example 6: Blog Article Page

**Structure**:
```
+--------------------------------------------------+
| Logo  Home  Articles  About  Contact   [Search] |
+--------------------------------------------------+
|                                                  |
| Home > Category > Article Title                  |
|                                                  |
|              Article Title Here                  |
|          A compelling subtitle or summary        |
|                                                  |
|    By [Author Name] | [Date] | X min read       |
|                                                  |
|           [Featured Image - Full Width]          |
|                                                  |
| +--------------------------------------------+   |
| | Article content begins here. Lorem ipsum  |   |
| | dolor sit amet, consectetur adipiscing    |   |
| | elit. Paragraphs of main content...       |   |
| |                                           |   |
| | ## Subheading                             |   |
| |                                           |   |
| | More content with proper hierarchy and    |   |
| | formatting. Lists, quotes, images, etc.   |   |
| |                                           |   |
| | [Inline Image with Caption]               |   |
| |                                           |   |
| +--------------------------------------------+   |
|                                                  |
| Tags: [Design] [UX] [Wireframing]               |
|                                                  |
| Share: [Twitter] [Facebook] [LinkedIn]           |
|                                                  |
| +--------------------------------------------+   |
| | About the Author                          |   |
| | [Avatar] Name                             |   |
| |          Brief bio and social links       |   |
| +--------------------------------------------+   |
|                                                  |
| Related Articles                                 |
| +-------+  +-------+  +-------+                  |
| |[Image]|  |[Image]|  |[Image]|                  |
| |Title  |  |Title  |  |Title  |                  |
| +-------+  +-------+  +-------+                  |
+--------------------------------------------------+
```

**Responsive Considerations**:
- Desktop: Max-width container (680-720px) for readability
- Mobile: Full-width with padding, stacked layout
- Images: Responsive, maintain aspect ratio
- Related articles: 3 columns → 1 column

### Example 7: Settings/Preferences Page

**Tab-Based Layout**:
```
+--------------------------------------------------+
| [Account] [Privacy] [Notifications] [Billing]    |
+--------------------------------------------------+
|                                                  |
| Account Settings                                 |
|                                                  |
| Profile Photo                                    |
| [  Avatar  ]  [Change Photo] [Remove]            |
|                                                  |
| Display Name                                     |
| [_____________________________]                  |
|                                                  |
| Email Address                                    |
| user@example.com                [Verified ✓]     |
| [Change Email]                                   |
|                                                  |
| Password                                         |
| ••••••••                                         |
| [Change Password]                                |
|                                                  |
| Two-Factor Authentication                        |
| [ Enabled ]                                      |
| Add an extra layer of security                   |
| [Manage 2FA]                                     |
|                                                  |
| Timezone                                         |
| [America/New_York               ▼]              |
|                                                  |
| Language                                         |
| [English                        ▼]              |
|                                                  |
| Danger Zone                                      |
| [Delete Account]  This action cannot be undone   |
|                                                  |
| [Cancel]  [Save Changes]                         |
+--------------------------------------------------+
```

**Annotations**:
1. Tabs: Load different setting sections
2. Change actions: Modal or inline edit
3. 2FA toggle: Confirmation required
4. Save button: Enabled only when changes made
5. Danger zone: Confirmation modal with password
6. Autosave option: Consider for better UX

### Example 8: Calendar/Scheduling Interface

**Monthly View**:
```
+--------------------------------------------------+
| [<] October 2024 [>]           [Today] [+ Event] |
+--------------------------------------------------+
| Sun | Mon | Tue | Wed | Thu | Fri | Sat |        |
+--------------------------------------------------+
|     |     | 1   | 2   | 3   | 4   | 5   |        |
|     |     |     |     |     |     |     |        |
+--------------------------------------------------+
| 6   | 7   | 8   | 9   | 10  | 11  | 12  |        |
|     | ●   |     | ●●  |     |     |     |        |
+--------------------------------------------------+
| 13  | 14  | 15  | 16  | 17  | 18  | 19  |        |
|     |     | ●   |     | ●   | ●●● |     |        |
+--------------------------------------------------+
| 20  | 21  | 22  | 23  | 24  | 25  | 26  |        |
|     | ●   |     |     |     | ●   |     |        |
+--------------------------------------------------+
| 27  | 28  | 29  | 30  | 31  |     |     |        |
|     |     |     | ●●  |     |     |     |        |
+--------------------------------------------------+
|                                                  |
| Upcoming Events                                  |
| Oct 9, 9:00 AM - Team Meeting                    |
| Oct 15, 2:00 PM - Client Call                    |
| Oct 17, 10:00 AM - Design Review                 |
| [View All]                                       |
+--------------------------------------------------+
```

**Alternative Views**:
- Week view: Hourly grid with event blocks
- Day view: Detailed timeline with conflicts shown
- Agenda view: List of all events

**Interactions**:
1. Click date: See day detail or create event
2. Dots: Indicate events (color-coded by type)
3. Drag events: Reschedule
4. Click event: View/edit details
5. Month navigation: Previous/next, or date picker

### Example 9: Social Media Feed

**Feed Structure**:
```
+--------------------------------------------------+
| [Home] [Discover] [Messages] [Profile] [@user]  |
+--------------------------------------------------+
| What's on your mind?                             |
| [____________________________] [Photo] [Post]    |
+--------------------------------------------------+
|                                                  |
| +----------------------------------------------+ |
| | [Avatar] User Name                    [•••] | |
| |          @username · 2h ago                  | |
| |                                              | |
| | Post content here. This could be text,       | |
| | images, links, or other media. #hashtag      | |
| |                                              | |
| | [Preview Image if link/media]                | |
| |                                              | |
| | [💬 12] [🔄 5] [❤️ 24] [🔖] [📤]            | |
| +----------------------------------------------+ |
|                                                  |
| +----------------------------------------------+ |
| | [Avatar] Another User               [•••]    | |
| |          @user2 · 5h ago                     | |
| |                                              | |
| | Another post with different content...       | |
| |                                              | |
| | [💬 3] [🔄 1] [❤️ 8] [🔖] [📤]              | |
| +----------------------------------------------+ |
|                                                  |
| [Load More Posts]                                |
+--------------------------------------------------+
```

**Post Interactions**:
1. Avatar/name: Link to user profile
2. Three-dot menu: Report, mute, block, etc.
3. Reply icon: Open comment thread
4. Repost icon: Share to own feed
5. Like icon: Toggle like state
6. Bookmark: Save for later
7. Share: Share externally

**Features**:
- Infinite scroll or "Load More"
- Pull-to-refresh on mobile
- Real-time updates for new posts
- Engagement counts update live

### Example 10: Video Player Interface

**Player Wireframe**:
```
+--------------------------------------------------+
|                                                  |
|                [Video Content]                   |
|                                                  |
|               [Play/Pause Overlay]               |
|                                                  |
+--------------------------------------------------+
| [▶/⏸] [⏮] [⏭]  ——●————————————————  [🔊] [⚙] [⛶]|
|  0:45                            12:34           |
+--------------------------------------------------+
|                                                  |
| Video Title Goes Here                            |
| 1.2M views · 2 days ago                          |
|                                                  |
| [Avatar] Channel Name           [Subscribe]      |
|          125K subscribers                        |
|                                                  |
| [👍 12K] [👎] [Share] [Download] [Save] [•••]   |
|                                                  |
| [Show Description ▼]                             |
+--------------------------------------------------+
```

**Player Controls**:
1. Play/Pause: Toggle playback
2. Skip buttons: 10 seconds back/forward
3. Progress bar: Scrub to any point, show buffer
4. Volume: Slider control, mute toggle
5. Settings: Quality, speed, captions
6. Fullscreen: Toggle fullscreen mode

**Additional Features**:
- Auto-hide controls after inactivity
- Keyboard shortcuts
- Picture-in-picture mode
- Captions/subtitles toggle
- Playlist navigation

### Example 11: Checkout Flow

**Multi-Step Process**:
```
Step 1: Cart → Step 2: Shipping → Step 3: Payment → Step 4: Review → Confirmation
```

**Payment Step Wireframe**:
```
+--------------------------------------------------+
| [Logo]                                    [Help] |
+--------------------------------------------------+
| [✓] Cart  [✓] Shipping  [●] Payment  [ ] Review |
+--------------------------------------------------+
|                                                  |
| Payment Method                                   |
| (•) Credit Card                                  |
| ( ) PayPal                                       |
| ( ) Apple Pay                                    |
|                                                  |
| Card Number                                      |
| [____-____-____-____]              [VISA]        |
|                                                  |
| Expiry Date         CVV                          |
| [MM/YY]             [___]  [?]                   |
|                                                  |
| Cardholder Name                                  |
| [_____________________________]                  |
|                                                  |
| Billing Address                                  |
| [ ] Same as shipping address                     |
|                                                  |
| [Apply Promo Code ▼]                             |
|                                                  |
| +--------------------------------------------+   |
| | Order Summary                              |   |
| | Subtotal:                      $XX.XX      |   |
| | Shipping:                      $X.XX       |   |
| | Tax:                           $X.XX       |   |
| | ----------------------------------------   |   |
| | Total:                         $XX.XX      |   |
| +--------------------------------------------+   |
|                                                  |
| [< Back to Shipping]    [Continue to Review >]  |
+--------------------------------------------------+
```

**Security & Trust Elements**:
- SSL badge/lock icon
- Accepted payment methods shown
- Security text/guarantees
- Save payment info option (if logged in)

### Example 12: FAQ/Help Center

**Layout**:
```
+--------------------------------------------------+
| Logo  Products  Resources  Support   [Sign In]  |
+--------------------------------------------------+
|                                                  |
|            How can we help you?                  |
|     [Search for help topics...    ] [Search]     |
|                                                  |
| Popular Topics                                   |
| +-------------+  +-------------+  +-------------+|
| | [Icon]      |  | [Icon]      |  | [Icon]      ||
| | Getting     |  | Billing &   |  | Technical   ||
| | Started     |  | Account     |  | Support     ||
| +-------------+  +-------------+  +-------------+|
|                                                  |
| Frequently Asked Questions                       |
|                                                  |
| [▼] How do I reset my password?                  |
|     To reset your password, click on...          |
|                                                  |
| [>] How do I update my billing information?      |
|                                                  |
| [>] What payment methods do you accept?          |
|                                                  |
| [>] How do I cancel my subscription?             |
|                                                  |
| [>] How do I contact customer support?           |
|                                                  |
| [Browse All Articles]                            |
|                                                  |
| Still need help?                                 |
| [Contact Support]  or  [Community Forum]         |
+--------------------------------------------------+
```

**Interactive Elements**:
1. Search: Auto-suggest relevant articles
2. Category cards: Link to filtered view
3. FAQ accordion: Expand/collapse answers
4. Related articles: Show after viewing FAQ
5. Helpful voting: "Was this helpful? Yes/No"

### Example 13: Data Table with Actions

**Complex Table Interface**:
```
+--------------------------------------------------+
| [+ New Item]           [Search: _____] [Filter▼]|
+--------------------------------------------------+
| [ ] | Name       | Status  | Date     | Actions  |
+--------------------------------------------------+
| [✓] | Item Alpha | Active  | 01/15/24 | [•••]   |
| [ ] | Item Beta  | Pending | 01/16/24 | [•••]   |
| [✓] | Item Gamma | Active  | 01/17/24 | [•••]   |
| [ ] | Item Delta | Inactive| 01/18/24 | [•••]   |
| [ ] | Item Echo  | Active  | 01/19/24 | [•••]   |
+--------------------------------------------------+
| Bulk Actions: [Delete] [Export] [Change Status]  |
|                                                  |
| Showing 5 of 127 items    [< 1 2 3 4 5 >]       |
+--------------------------------------------------+
```

**Annotations**:
1. Checkboxes: Multi-select for bulk actions
2. Column headers: Clickable to sort
3. Status: Color-coded badges
4. Actions menu: Edit, duplicate, delete, view details
5. Search: Filter table in real-time
6. Filters: Dropdown with multiple criteria
7. Pagination: Standard page controls

**Responsive Strategy**:
- Desktop: Full table view
- Tablet: Horizontal scroll or hide less critical columns
- Mobile: Card-based view with key information

### Example 14: Modal Dialog

**Confirmation Modal**:
```
         +------------------------------+
         |                            [X]|
         |   Delete Item?                |
         |                               |
         | Are you sure you want to      |
         | delete "Item Name"? This      |
         | action cannot be undone.      |
         |                               |
         | [Cancel]  [Delete]            |
         +------------------------------+
```

**Form Modal**:
```
         +------------------------------+
         |  Add New Item              [X]|
         +------------------------------+
         |                               |
         | Item Name                     |
         | [_______________________]     |
         |                               |
         | Category                      |
         | [Select category       ▼]     |
         |                               |
         | Description                   |
         | [_______________________]     |
         | [_______________________]     |
         | [_______________________]     |
         |                               |
         | [ ] Mark as featured          |
         |                               |
         | [Cancel]  [Add Item]          |
         +------------------------------+
```

**Modal Best Practices**:
- Overlay/backdrop to focus attention
- Clear close options (X button, Cancel, click outside)
- Logical action button placement
- Keyboard support (ESC to close, Tab navigation)
- Focus trap (keep focus within modal)
- Avoid modals within modals

### Example 15: Mobile Navigation Patterns

**Hamburger Menu**:
```
+-------------------+
| [☰] Logo    [🔍]  |
+-------------------+
|                   |
| Main Content      |
|                   |
+-------------------+

[Menu Open State]
+-------------------+
| [✕] Menu          |
+-------------------+
| Home              |
| Products          |
| About             |
| Contact           |
| Account           |
+-------------------+
```

**Tab Bar Navigation** (Bottom):
```
+-------------------+
|                   |
| Content Area      |
|                   |
+-------------------+
| [🏠]  [🔍]  [+]   |
| Home  Search  Add |
|                   |
| [♥]  [👤]         |
| Saved Profile     |
+-------------------+
```

**Tab Bar Best Practices**:
- 3-5 primary destinations
- Icons + labels for clarity
- Active state clearly indicated
- Don't hide primary actions
- Fixed position at bottom

## Conclusion

Wireframing is a critical skill in the UX design process. It enables rapid exploration of ideas, validates concepts with minimal investment, facilitates clear communication among stakeholders, and provides a solid foundation for visual design and development.

Key takeaways:
- Match fidelity to your stage in the design process
- Focus on structure and functionality before aesthetics
- Iterate based on feedback and testing
- Use the right tools for your needs and team
- Document interactions and specifications clearly
- Consider accessibility from the start
- Involve stakeholders and users throughout

By mastering wireframing techniques and following best practices, you'll create more effective designs, reduce costly revisions, and deliver better user experiences.
