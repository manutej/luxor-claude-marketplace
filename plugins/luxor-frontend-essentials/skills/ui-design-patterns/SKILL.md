---
name: ui-design-patterns
description: Common interface patterns, navigation patterns, form patterns, data display patterns, feedback patterns, and accessibility considerations
category: design
tags: [ui, patterns, components, navigation, forms, accessibility, interaction-design]
version: 1.0.0
---

# UI Design Patterns

A comprehensive guide to common user interface design patterns, component patterns, interaction patterns, and accessibility best practices for building modern web and mobile applications.

## When to Use This Skill

Use this skill when you need to:

- **Design User Interfaces**: Create intuitive and user-friendly interface designs
- **Implement UI Components**: Build reusable interface components following established patterns
- **Solve UX Problems**: Address common user experience challenges with proven solutions
- **Ensure Accessibility**: Make interfaces accessible to all users including those with disabilities
- **Build Design Systems**: Create consistent component libraries and design systems
- **Review Interfaces**: Evaluate existing interfaces for usability and best practices
- **Prototype Interactions**: Design and implement interactive UI behaviors
- **Optimize Navigation**: Structure information architecture and navigation flows
- **Handle Form Design**: Create effective forms with proper validation and feedback
- **Display Data**: Present complex data in clear, scannable formats
- **Provide Feedback**: Communicate system state and user actions effectively
- **Responsive Design**: Adapt interfaces for different screen sizes and devices

## Core Concepts

### UI Patterns

UI patterns are reusable solutions to common design problems. They provide:

- **Consistency**: Users recognize familiar patterns across applications
- **Efficiency**: Proven solutions save design and development time
- **Usability**: Patterns are tested and refined through widespread use
- **Communication**: Shared vocabulary for designers and developers
- **Accessibility**: Established patterns often include accessibility considerations

### Design Systems

A design system is a collection of reusable components, patterns, and guidelines:

- **Component Library**: Reusable UI building blocks
- **Design Tokens**: Variables for colors, spacing, typography
- **Usage Guidelines**: When and how to use each component
- **Accessibility Standards**: WCAG compliance requirements
- **Code Examples**: Implementation references
- **Documentation**: Comprehensive guides and principles

### Atomic Design Methodology

Breaking interfaces into atomic units:

- **Atoms**: Basic building blocks (buttons, inputs, labels)
- **Molecules**: Simple combinations of atoms (search field with button)
- **Organisms**: Complex components (headers, forms, cards)
- **Templates**: Page-level layouts
- **Pages**: Specific instances with real content

## Navigation Patterns

### 1. Tabs Pattern

Organize content into multiple panels shown one at a time.

**When to Use**:
- Related content categories at the same hierarchy level
- Limited number of sections (3-7 tabs ideal)
- User needs to switch between views frequently
- Screen space is limited

**Anatomy**:
```
[Tab 1] [Tab 2] [Tab 3]
─────────────────────────
Content for active tab
```

**Best Practices**:
- Highlight active tab clearly
- Keep tab labels short and descriptive
- Maintain state when switching tabs
- Use icons + text for clarity
- Ensure keyboard navigation works
- Consider mobile alternatives (dropdown, segmented control)

**Accessibility**:
- Use ARIA `role="tablist"`, `role="tab"`, `role="tabpanel"`
- Implement arrow key navigation
- Set `aria-selected` and `aria-controls`
- Ensure tab panels are focusable

**Example HTML**:
```html
<div role="tablist" aria-label="Content sections">
  <button role="tab" aria-selected="true" aria-controls="panel-1" id="tab-1">
    Overview
  </button>
  <button role="tab" aria-selected="false" aria-controls="panel-2" id="tab-2">
    Details
  </button>
  <button role="tab" aria-selected="false" aria-controls="panel-3" id="tab-3">
    Settings
  </button>
</div>

<div role="tabpanel" id="panel-1" aria-labelledby="tab-1">
  Overview content...
</div>
```

### 2. Accordion Pattern

Vertically stacked sections with expand/collapse functionality.

**When to Use**:
- Long pages with distinct sections
- Progressive disclosure of information
- FAQ sections
- Settings panels
- Limited screen space

**Types**:
- **Single Expand**: Only one panel open at a time
- **Multi Expand**: Multiple panels can be open simultaneously
- **Nested**: Accordions within accordions

**Best Practices**:
- Use clear, descriptive headers
- Provide visual indicators (chevron, +/-)
- Consider default state (collapsed vs first open)
- Animate transitions smoothly (200-300ms)
- Maintain content when collapsed
- Allow keyboard control

**Accessibility**:
- Use `<button>` for headers
- Set `aria-expanded` attribute
- Use `aria-controls` to link header and panel
- Ensure keyboard navigation (Enter, Space, Arrow keys)
- Provide proper heading hierarchy

**Example Structure**:
```html
<div class="accordion">
  <h3>
    <button aria-expanded="false" aria-controls="section-1">
      Section Title
      <span class="icon" aria-hidden="true">▼</span>
    </button>
  </h3>
  <div id="section-1" hidden>
    <p>Section content...</p>
  </div>
</div>
```

### 3. Breadcrumbs Pattern

Show user's location in site hierarchy.

**When to Use**:
- Deep site hierarchies (3+ levels)
- E-commerce category navigation
- Documentation sites
- Multi-step processes

**Best Practices**:
- Show current location clearly
- Make previous levels clickable
- Use appropriate separators (>, /, →)
- Keep labels concise
- Consider mobile truncation
- Place at top of page

**Accessibility**:
- Use `<nav>` with `aria-label="Breadcrumb"`
- Mark current page with `aria-current="page"`
- Provide sufficient color contrast
- Ensure keyboard navigation

**Example**:
```html
<nav aria-label="Breadcrumb">
  <ol>
    <li><a href="/">Home</a></li>
    <li><a href="/products">Products</a></li>
    <li><a href="/products/electronics">Electronics</a></li>
    <li aria-current="page">Laptops</li>
  </ol>
</nav>
```

### 4. Pagination Pattern

Navigate through large sets of content split across pages.

**Types**:
- **Numbered**: Show page numbers (1, 2, 3...)
- **Load More**: Button to load additional content
- **Infinite Scroll**: Automatically load as user scrolls
- **Prev/Next**: Simple navigation between pages

**When to Use**:
- Search results
- Product listings
- Blog archives
- Data tables

**Best Practices**:
- Show current page clearly
- Provide Previous/Next controls
- Include First/Last page links
- Show total page count or results
- Use ellipsis for skipped pages (1 ... 5 6 7 ... 20)
- Maintain scroll position appropriately
- Consider load time and performance

**Accessibility**:
- Use `<nav>` with `aria-label="Pagination"`
- Mark current page with `aria-current="page"`
- Disable non-functional links properly
- Provide text alternatives for icon-only controls

### 5. Menu Patterns

#### Dropdown Menu
Reveals additional options on click or hover.

**Best Practices**:
- Prefer click over hover for mobile compatibility
- Add small delay before closing on hover
- Indicate submenu with arrow icon
- Keep menu depths shallow (2-3 levels max)
- Position intelligently to avoid viewport overflow

#### Mega Menu
Large dropdown showing multiple columns and categories.

**When to Use**:
- E-commerce sites with many categories
- Sites with complex information architecture
- When standard dropdown feels cramped

**Best Practices**:
- Use grid layout for organization
- Include visual elements (icons, images)
- Group related items
- Provide clear visual hierarchy
- Close on outside click or Esc key

#### Hamburger Menu
Collapsible menu for mobile navigation.

**Best Practices**:
- Use recognizable icon (three horizontal lines)
- Provide label for clarity ("Menu")
- Animate opening/closing
- Disable body scroll when open
- Include close button in menu
- Consider alternatives for better discoverability

**Accessibility**:
- Use proper ARIA roles and states
- Support keyboard navigation
- Announce menu state to screen readers
- Ensure focus management

## Form Patterns

### 1. Input Validation Pattern

Provide feedback on user input correctness.

**Validation Types**:
- **Required Fields**: Must be completed
- **Format Validation**: Email, phone, URL patterns
- **Length Validation**: Min/max characters
- **Range Validation**: Numeric ranges
- **Custom Rules**: Business logic validation

**Timing**:
- **On Submit**: Traditional approach, all errors at once
- **On Blur**: Validate when leaving field
- **On Change**: Real-time validation as typing
- **Hybrid**: Combine approaches for best UX

**Best Practices**:
- Mark required fields clearly (asterisk, "required" label)
- Provide inline error messages near fields
- Use clear, helpful error messages
- Show success states when appropriate
- Group related errors
- Disable submit until form is valid (optional)
- Preserve user input when showing errors
- Support browser autofill

**Error Message Guidelines**:
- Be specific about the problem
- Explain how to fix it
- Use friendly, non-technical language
- Avoid blame ("You entered..." → "Email format invalid")

**Visual Indicators**:
- Red border/background for errors
- Green for success/valid
- Icons to reinforce state
- Sufficient color contrast

**Accessibility**:
- Use `aria-invalid="true"` for invalid fields
- Link errors with `aria-describedby`
- Announce errors to screen readers
- Ensure error messages are programmatically associated

**Example**:
```html
<div class="form-field">
  <label for="email">
    Email Address <span aria-label="required">*</span>
  </label>
  <input
    type="email"
    id="email"
    aria-invalid="true"
    aria-describedby="email-error"
    required
  />
  <div id="email-error" class="error-message" role="alert">
    Please enter a valid email address
  </div>
</div>
```

### 2. Multi-Step Forms Pattern

Break long forms into multiple steps or pages.

**When to Use**:
- Complex forms with many fields
- Logical grouping of related information
- Onboarding flows
- Checkout processes
- User registration

**Components**:
- **Progress Indicator**: Show current step and total steps
- **Step Navigation**: Move between steps
- **Review Step**: Summary before submission
- **Save Draft**: Allow returning later

**Best Practices**:
- Keep steps focused on single topic
- Show progress clearly
- Allow backward navigation
- Validate each step before proceeding
- Save progress automatically
- Provide way to skip optional steps
- Show time estimate if possible
- Use descriptive step titles

**Progress Indicators**:
- Linear steps (1 → 2 → 3 → 4)
- Step labels with numbers
- Percentage completion
- Visual timeline

**Accessibility**:
- Use `aria-label` for step indicators
- Announce step changes
- Ensure keyboard navigation works
- Mark completed/current/upcoming steps

### 3. Inline Editing Pattern

Edit content directly in place without separate form.

**When to Use**:
- Spreadsheet-like interfaces
- Quick edits to existing content
- Data tables
- User profiles
- Settings pages

**Interaction Modes**:
- **Click to Edit**: Click field to make editable
- **Always Editable**: Fields always in edit mode
- **Edit Button**: Explicit button to enter edit mode
- **Row/Item Edit**: Edit entire row or item at once

**Best Practices**:
- Provide clear visual feedback for editable areas
- Show edit mode clearly (border, background change)
- Include Save/Cancel actions
- Auto-save on blur (optional)
- Validate before saving
- Show loading state during save
- Handle errors gracefully
- Keyboard shortcuts (Enter to save, Esc to cancel)

**Visual States**:
- **Default**: Shows content, hints at editability
- **Hover**: Indicate interactivity
- **Edit**: Clear input/editing interface
- **Saving**: Loading indicator
- **Saved**: Brief success confirmation

**Accessibility**:
- Use semantic HTML elements
- Provide clear labels
- Announce state changes
- Support keyboard-only interaction

### 4. Search Patterns

#### Autocomplete/Typeahead
Show suggestions as user types.

**Best Practices**:
- Debounce input (300ms delay)
- Highlight matching characters
- Show both recent and relevant results
- Limit number of suggestions (5-10)
- Allow keyboard navigation (arrows, Enter)
- Clear suggestions on Esc
- Show "No results" state
- Include search button as fallback

**Accessibility**:
- Use `role="combobox"` and `aria-autocomplete`
- Announce suggestion count
- Use `aria-activedescendant` for highlighted option
- Ensure screen reader support

#### Filtering
Narrow results based on criteria.

**Types**:
- **Faceted Search**: Multiple filter categories
- **Tag Filters**: Select/deselect tags
- **Range Filters**: Sliders for numeric ranges
- **Date Filters**: Date pickers or presets

**Best Practices**:
- Show active filters clearly
- Display result count
- Allow clearing individual or all filters
- Update results in real-time or with Apply button
- Preserve filter state in URL
- Provide filter presets for common queries

### 5. Form Layout Patterns

#### Single Column
Best for mobile and simplicity.

**Advantages**:
- Easier to scan vertically
- Better mobile experience
- Reduces cognitive load
- Higher completion rates

#### Multi-Column
Use for related fields or space efficiency.

**Best Practices**:
- Keep related fields together
- Left-align labels
- Use for short forms only
- Stack on mobile

#### Label Positioning
- **Top Labels**: Fastest completion, best for mobile
- **Left Labels**: Space-efficient, good for data entry
- **Inline Labels**: Placeholder-style (use carefully)

## Data Display Patterns

### 1. Table Pattern

Display structured data in rows and columns.

**When to Use**:
- Comparing data across multiple dimensions
- Large datasets requiring sorting/filtering
- Detailed data requiring precision
- Admin interfaces and dashboards

**Essential Features**:
- **Sorting**: Click headers to sort columns
- **Filtering**: Search or filter by column
- **Pagination**: Handle large datasets
- **Row Selection**: Checkboxes for bulk actions
- **Responsive**: Adapt for mobile screens

**Advanced Features**:
- **Column Resizing**: Drag to adjust width
- **Column Reordering**: Rearrange columns
- **Frozen Columns**: Keep headers/first column visible
- **Expandable Rows**: Show additional details
- **Inline Editing**: Edit cells directly
- **Export**: Download as CSV/Excel

**Best Practices**:
- Left-align text, right-align numbers
- Use consistent formatting
- Highlight on hover
- Show loading states
- Handle empty states
- Provide clear sorting indicators
- Use zebra striping sparingly
- Avoid horizontal scrolling when possible

**Responsive Strategies**:
- **Horizontal Scroll**: Simple but less ideal
- **Card View**: Transform rows into cards
- **Priority Columns**: Hide less important columns
- **Expandable Rows**: Hide details until expanded
- **Comparison View**: Show 2-3 items side-by-side

**Accessibility**:
- Use semantic `<table>`, `<thead>`, `<tbody>`, `<th>`, `<td>`
- Add `scope` attribute to headers
- Provide table caption
- Use `aria-sort` for sortable columns
- Ensure keyboard navigation for interactive elements

### 2. Card Pattern

Container for related information with visual hierarchy.

**When to Use**:
- Product listings
- User profiles
- Dashboard widgets
- Content previews
- Mixed content types

**Anatomy**:
- **Image/Visual**: Hero image or icon
- **Header**: Title and metadata
- **Body**: Description or details
- **Actions**: Buttons or links
- **Footer**: Supplementary info

**Variations**:
- **Product Card**: Image, title, price, add to cart
- **User Card**: Avatar, name, bio, follow button
- **Article Card**: Thumbnail, headline, excerpt, read time
- **Stat Card**: Number, label, trend indicator

**Best Practices**:
- Consistent card sizes in grid
- Clear visual hierarchy
- Adequate padding and spacing
- Hover states for interactivity
- Limit actions to 1-2 primary actions
- Use subtle shadows for depth
- Ensure touch targets are large enough (44x44px min)

**Grid Layouts**:
- Responsive columns (1 on mobile, 2-4 on desktop)
- Equal height cards or masonry layout
- Consistent gaps between cards

**Accessibility**:
- Use semantic HTML
- Provide alt text for images
- Ensure sufficient contrast
- Make entire card clickable when appropriate
- Use heading tags for titles

### 3. List Pattern

Sequential display of similar items.

**Types**:
- **Simple List**: Text-only items
- **Detailed List**: Multiple lines per item
- **Interactive List**: Clickable/selectable items
- **Grouped List**: Organized by categories
- **Inbox List**: Messages with preview, time, status

**Best Practices**:
- Clear visual separation between items
- Consistent item height or natural flow
- Show item count
- Highlight selected items
- Provide quick actions
- Support multi-select when appropriate
- Implement virtual scrolling for long lists

**Accessibility**:
- Use semantic list elements (`<ul>`, `<ol>`, `<li>`)
- Provide unique IDs for items
- Announce selection changes
- Support keyboard navigation

### 4. Grid Pattern

Items arranged in rows and columns.

**When to Use**:
- Image galleries
- Product catalogs
- App launchers
- Icon sets
- Media libraries

**Grid Types**:
- **Fixed Grid**: Consistent item sizes
- **Masonry**: Variable heights, Pinterest-style
- **Responsive Grid**: Adapts to screen size

**Best Practices**:
- Use CSS Grid or Flexbox
- Maintain aspect ratios
- Implement lazy loading for images
- Provide grid/list view toggle
- Consistent gaps
- Handle empty states

**Responsive Behavior**:
```
Mobile: 1-2 columns
Tablet: 2-4 columns
Desktop: 4-6 columns
```

### 5. Dashboard Pattern

Overview of key metrics and data visualizations.

**Components**:
- **KPI Cards**: Key metrics with trends
- **Charts**: Line, bar, pie, area charts
- **Tables**: Detailed data
- **Activity Feeds**: Recent events
- **Quick Actions**: Common tasks

**Layout Strategies**:
- **Fixed Layout**: Predetermined positions
- **Draggable Widgets**: User-customizable
- **Responsive Grid**: Adapts to screen size

**Best Practices**:
- Prioritize most important metrics
- Use consistent timeframes
- Provide context (comparisons, trends)
- Enable drilling down for details
- Update data in real-time or show last update time
- Support customization
- Export/share capabilities

## Feedback Patterns

### 1. Toast/Snackbar Pattern

Brief, temporary message about system state or action result.

**When to Use**:
- Confirm action completion (saved, deleted, sent)
- Show brief notifications
- Non-critical errors
- Undo opportunities

**Best Practices**:
- Display for 3-7 seconds
- Position consistently (bottom center or top right)
- One toast at a time, or queue multiple
- Provide dismiss action
- Avoid blocking important content
- Keep message concise
- Use appropriate colors (success: green, error: red, info: blue)
- Offer undo for destructive actions

**Don't Use For**:
- Critical errors requiring user action
- Information user must read
- Multiple simultaneous messages
- Long messages

**Accessibility**:
- Use `role="status"` or `role="alert"`
- Announce to screen readers
- Don't auto-dismiss too quickly
- Provide manual dismiss option

**Example Structure**:
```html
<div class="toast" role="status" aria-live="polite">
  <span>Settings saved successfully</span>
  <button aria-label="Close notification">×</button>
</div>
```

### 2. Modal/Dialog Pattern

Overlay that focuses user attention on specific task or information.

**Types**:
- **Alert Dialog**: Important message requiring acknowledgment
- **Confirmation Dialog**: Yes/No decisions
- **Form Dialog**: Input collection
- **Lightbox**: Image/media viewer

**When to Use**:
- Critical decisions
- Focus on single task
- Collect required information
- Interrupt destructive actions
- Display full-size media

**Best Practices**:
- Dim background content (overlay)
- Disable background interaction
- Provide clear close option (X button, Cancel, Esc key)
- Focus first input or close button on open
- Return focus to trigger element on close
- Keep content concise
- Position in viewport center
- Prevent body scroll when open
- Avoid modal inception (modal within modal)

**Accessibility**:
- Use `role="dialog"` or `role="alertdialog"`
- Set `aria-modal="true"`
- Use `aria-labelledby` and `aria-describedby`
- Implement focus trap
- Support Esc to close
- Announce to screen readers

**Structure**:
```html
<div class="modal-overlay">
  <div role="dialog" aria-modal="true" aria-labelledby="modal-title">
    <h2 id="modal-title">Confirm Deletion</h2>
    <p>Are you sure you want to delete this item?</p>
    <div class="modal-actions">
      <button>Cancel</button>
      <button class="danger">Delete</button>
    </div>
  </div>
</div>
```

### 3. Loading States Pattern

Indicate ongoing process or data fetching.

**Types**:
- **Spinners**: Circular or linear progress
- **Progress Bars**: Show completion percentage
- **Skeleton Screens**: Content placeholders
- **Shimmer Effect**: Animated placeholder
- **Inline Loaders**: Within buttons or sections

**When to Use**:
- Page loading
- API requests
- File uploads
- Background processing
- Infinite scroll loading

**Best Practices**:
- Show immediately (within 100ms)
- Indicate progress when possible
- Provide estimated time for long operations
- Allow cancellation when appropriate
- Use skeleton screens for better perceived performance
- Avoid blocking entire UI unnecessarily
- Show partial content as it loads

**Skeleton Screens**:
Better UX than blank screens or spinners:
- Match layout of actual content
- Use subtle animation
- Load content progressively
- Maintain scroll position

**Accessibility**:
- Use `aria-busy="true"` during loading
- Announce loading completion
- Provide text alternative for visual loaders
- Ensure keyboard users can cancel

### 4. Empty States Pattern

Communicate when no content exists and guide next action.

**Types**:
- **First Use**: Guide new users
- **No Results**: Search/filter returned nothing
- **Error State**: Something went wrong
- **Completed State**: All tasks done

**Components**:
- **Illustration**: Visual element
- **Heading**: Clear message
- **Description**: Explanation and guidance
- **Call-to-Action**: Primary next step

**Best Practices**:
- Be encouraging and helpful
- Provide clear next action
- Use appropriate tone for context
- Include relevant illustration
- Make CTA prominent
- Offer alternatives or suggestions

**Examples**:

First Use:
```
"Welcome to your inbox!"
"You don't have any messages yet.
Why not invite your team?"
[Invite Team Button]
```

No Results:
```
"No results found for 'query'"
"Try different keywords or clear filters"
[Clear Filters Button]
```

Error:
```
"Oops, something went wrong"
"We couldn't load your data. Please try again."
[Retry Button]
```

**Accessibility**:
- Provide meaningful text
- Ensure images have alt text
- Make CTAs keyboard accessible

### 5. Notification Badge Pattern

Indicate unread items or pending actions.

**Types**:
- **Numeric Badge**: Show count (5, 12, 99+)
- **Dot Badge**: Indicate presence without count
- **Status Badge**: Online, offline, busy states

**When to Use**:
- Unread messages
- Pending notifications
- Cart item count
- User status indicators

**Best Practices**:
- Position consistently (top-right of icon)
- Use contrasting colors
- Limit numbers (99+ for large counts)
- Clear when viewed
- Don't overuse
- Size appropriately

**Accessibility**:
- Include in accessible name
- Announce updates to screen readers
- Example: `aria-label="Messages (3 unread)"`

## Interaction Patterns

### 1. Drag and Drop Pattern

Move or reorder items by dragging.

**Use Cases**:
- File uploads
- List reordering
- Kanban boards
- Image galleries
- Form builders

**Interaction States**:
- **Draggable**: Visual indicator (handle icon)
- **Dragging**: Item follows cursor, original position shown
- **Drop Zone**: Highlight valid targets
- **Invalid**: Show when can't drop
- **Dropped**: Animate to final position

**Best Practices**:
- Provide clear drag handles
- Show drop zones clearly
- Animate transitions smoothly
- Support keyboard alternatives
- Confirm destructive drops
- Auto-scroll when dragging near edges
- Show preview of final state

**Keyboard Alternative**:
- Select item
- Cut/Copy
- Navigate to target
- Paste/Insert

**Accessibility**:
- Implement keyboard controls
- Announce drag/drop actions
- Provide alternative interaction method
- Use appropriate ARIA attributes

### 2. Infinite Scroll Pattern

Automatically load content as user scrolls down.

**When to Use**:
- Social media feeds
- Image galleries
- News feeds
- Product catalogs

**Best Practices**:
- Show loading indicator
- Provide "Load More" button as fallback
- Maintain scroll position on back navigation
- Include footer only after all content
- Allow jumping to specific items
- Show total count when possible
- Provide way to stop auto-loading

**Accessibility Concerns**:
- Announce new content to screen readers
- Ensure keyboard users can access all content
- Provide skip links
- Consider pagination alternative

**Performance**:
- Implement virtual scrolling for large lists
- Lazy load images
- Remove off-screen content
- Debounce scroll events

### 3. Filter and Sort Pattern

Refine and organize displayed data.

**Filter Types**:
- **Checkboxes**: Multi-select categories
- **Radio Buttons**: Single selection
- **Range Sliders**: Numeric ranges
- **Date Pickers**: Date ranges
- **Search**: Text matching

**Sort Options**:
- Alphabetical (A-Z, Z-A)
- Numeric (low-high, high-low)
- Date (newest, oldest)
- Relevance
- Popularity

**Best Practices**:
- Show active filters clearly
- Display result count
- Allow clearing individual filters
- Provide "Clear All" option
- Update results immediately or with Apply button
- Preserve filter state in URL
- Default to most useful sort
- Show sort direction clearly

**Mobile Considerations**:
- Use bottom sheet or sidebar for filters
- Provide filter button with count badge
- Allow applying filters before closing panel

### 4. Search Pattern

Help users find specific content or items.

**Components**:
- **Search Input**: Text field for query
- **Search Button**: Submit search
- **Clear Button**: Reset search
- **Autocomplete**: Suggestions while typing
- **Recent Searches**: Previously searched terms
- **Filters**: Refine results
- **Results**: Matching items

**Best Practices**:
- Make search prominent and easy to find
- Show search icon
- Provide keyboard shortcut (/, Ctrl+K)
- Show search scope if limited
- Highlight matching terms in results
- Show "No results" state with suggestions
- Preserve search in URL
- Implement debouncing (300ms)

**Search UX**:
- Instant search vs submit button
- Autocomplete suggestions
- Fuzzy matching for typos
- Search within results
- Sort by relevance

### 5. Undo/Redo Pattern

Reverse or replay actions.

**When to Use**:
- Content editors
- Drawing applications
- Email clients
- Any destructive action

**Implementation**:
- **Immediate Undo**: Toast with undo button
- **Command Pattern**: Stack of reversible actions
- **Keyboard Shortcuts**: Ctrl+Z, Ctrl+Y/Ctrl+Shift+Z
- **Menu Options**: Edit menu items

**Best Practices**:
- Provide undo for all significant actions
- Show undo option immediately (toast)
- Set reasonable time limit (5-10 seconds)
- Clear messaging about what will undo
- Support multiple undo levels
- Disable when no actions to undo
- Persist undo history appropriately

## Accessibility Patterns

### WCAG Principles

**Perceivable**: Information must be presentable to users in ways they can perceive.
- Provide text alternatives for non-text content
- Provide captions and alternatives for multimedia
- Create content that can be presented in different ways
- Make it easier to see and hear content

**Operable**: Interface components must be operable by all users.
- Make all functionality keyboard accessible
- Give users enough time to read and use content
- Don't design content that may cause seizures
- Help users navigate and find content

**Understandable**: Information and UI operation must be understandable.
- Make text readable and understandable
- Make content appear and operate in predictable ways
- Help users avoid and correct mistakes

**Robust**: Content must be robust enough to be interpreted by various user agents.
- Maximize compatibility with current and future tools

### Keyboard Navigation

**Essential Patterns**:
- **Tab**: Move forward through interactive elements
- **Shift+Tab**: Move backward
- **Enter/Space**: Activate buttons and links
- **Arrow Keys**: Navigate within components (menus, tabs)
- **Esc**: Close dialogs, cancel actions
- **Home/End**: Jump to first/last item

**Focus Management**:
- Visible focus indicators (outline, highlight)
- Logical tab order (follows visual order)
- Focus trap in modals
- Return focus after closing dialogs
- Skip links for main content

**Best Practices**:
- Don't rely on hover-only interactions
- Ensure all interactive elements are keyboard accessible
- Provide keyboard shortcuts for common actions
- Document keyboard shortcuts
- Test with keyboard only

### ARIA (Accessible Rich Internet Applications)

**Roles**:
Define what an element is or does:
- `role="button"`, `role="tab"`, `role="dialog"`
- `role="navigation"`, `role="main"`, `role="search"`
- `role="alert"`, `role="status"`, `role="log"`

**States and Properties**:
- `aria-expanded`: Expandable elements (true/false)
- `aria-selected`: Selected items (true/false)
- `aria-checked`: Checkboxes (true/false/mixed)
- `aria-disabled`: Disabled state (true/false)
- `aria-hidden`: Hide from screen readers (true/false)
- `aria-label`: Accessible name
- `aria-labelledby`: Reference to labeling element
- `aria-describedby`: Reference to description
- `aria-live`: Announce dynamic changes (polite/assertive)
- `aria-current`: Current item in set (page/step/location)

**Best Practices**:
- Use semantic HTML first
- Add ARIA when semantic HTML isn't sufficient
- Don't override native semantics
- Keep ARIA attributes updated with UI state
- Test with screen readers

### Screen Reader Support

**Considerations**:
- Logical heading hierarchy (h1, h2, h3...)
- Descriptive link text (avoid "click here")
- Alt text for images
- Labels for form inputs
- Error messages associated with inputs
- Announce dynamic content changes
- Provide text alternatives for visual information

**Common Screen Readers**:
- NVDA (Windows, free)
- JAWS (Windows, commercial)
- VoiceOver (macOS, iOS)
- TalkBack (Android)

### Color and Contrast

**Requirements**:
- **Text Contrast**: 4.5:1 for normal text, 3:1 for large text (WCAG AA)
- **Enhanced Contrast**: 7:1 for normal, 4.5:1 for large (WCAG AAA)
- **UI Components**: 3:1 for interface elements and graphics

**Best Practices**:
- Don't rely on color alone to convey information
- Use patterns, icons, or text in addition to color
- Test with color blindness simulators
- Provide high contrast mode
- Ensure focus indicators have sufficient contrast

### Form Accessibility

**Labels**:
- Associate `<label>` with inputs using `for`/`id`
- Don't use placeholder as only label
- Group related inputs with `<fieldset>` and `<legend>`

**Validation**:
- Associate errors with fields using `aria-describedby`
- Mark invalid fields with `aria-invalid="true"`
- Announce errors to screen readers with `role="alert"`
- Don't rely on color alone for validation states

**Instructions**:
- Provide clear instructions before form
- Indicate required fields
- Show format requirements
- Offer example inputs

## Responsive Patterns

### Mobile-First Approach

Design for mobile screens first, then enhance for larger screens.

**Benefits**:
- Forces focus on essential content
- Progressive enhancement
- Better performance on mobile
- Easier than desktop-first

**Breakpoints**:
```css
/* Mobile: 320px - 767px (default) */

/* Tablet: 768px+ */
@media (min-width: 768px) { }

/* Desktop: 1024px+ */
@media (min-width: 1024px) { }

/* Large Desktop: 1440px+ */
@media (min-width: 1440px) { }
```

### Adaptive Layouts

**Fluid Grids**:
- Use percentages or flexible units (fr, %)
- CSS Grid and Flexbox
- Container queries for component-level responsiveness

**Flexible Images**:
```css
img {
  max-width: 100%;
  height: auto;
}
```

**Responsive Typography**:
- Relative units (rem, em)
- Fluid typography with clamp()
- Adjust line length for readability (45-75 characters)

### Mobile Navigation Patterns

**Hamburger Menu**:
- Icon toggles slide-out menu
- Most common but can hide navigation
- Include label for clarity

**Tab Bar**:
- Fixed bottom navigation (iOS pattern)
- 3-5 main sections
- Always visible

**Priority+**:
- Show items that fit, hide overflow in menu
- Adapts to available space
- Good for primary navigation

**Bottom Sheet**:
- Slides up from bottom
- Good for filters, actions
- Easy thumb reach

### Touch Interactions

**Touch Targets**:
- Minimum 44x44px tap targets
- Adequate spacing between targets
- Larger targets for primary actions

**Gestures**:
- **Tap**: Primary action
- **Double Tap**: Zoom (use carefully)
- **Long Press**: Show context menu
- **Swipe**: Delete, archive, navigate
- **Pinch**: Zoom
- **Pull to Refresh**: Update content

**Best Practices**:
- Provide visual feedback for touches
- Avoid hover-dependent interactions
- Support both portrait and landscape
- Consider thumb zones (easy, stretch, hard to reach)
- Test on actual devices

### Responsive Tables

**Strategies**:

1. **Horizontal Scroll**: Simplest but least ideal
2. **Priority Columns**: Hide less important columns
3. **Stacked Cards**: Each row becomes a card
4. **Flip Headers**: Rotate headers to row labels
5. **Comparison View**: Show 2-3 items side by side

**Example - Stacked Cards**:
```
Desktop:
| Name | Email | Role | Status |

Mobile:
┌─────────────┐
│ John Doe    │
│ Email: j@   │
│ Role: Admin │
│ Status: ✓   │
└─────────────┘
```

## Common UI Patterns Checklist

### Button Patterns
- Primary action button (filled, high contrast)
- Secondary action button (outlined or ghost)
- Tertiary/text buttons for low priority actions
- Icon buttons for common actions
- Button groups for related actions
- Toggle buttons for on/off states
- Floating action button (FAB) for primary mobile action
- Loading state in buttons
- Disabled state with reduced opacity

### Input Patterns
- Text input with label and placeholder
- Password input with show/hide toggle
- Search input with icon and clear button
- Textarea for multi-line input
- Select/dropdown for choosing from options
- Radio buttons for single selection from few options
- Checkboxes for multi-selection
- Toggle switch for on/off settings
- Date picker for date selection
- File upload with drag-and-drop
- Range slider for numeric input
- Color picker for color selection

### Navigation Patterns
- Top navigation bar
- Sidebar navigation
- Breadcrumb navigation
- Pagination
- Tabs
- Stepper for multi-step processes
- Anchor links for in-page navigation
- Back to top button

### Overlay Patterns
- Modal dialogs
- Slideover/drawer
- Popover for contextual information
- Tooltip for hints
- Dropdown menu
- Context menu (right-click)
- Bottom sheet (mobile)

### Feedback Patterns
- Toast notifications
- Alert banners
- Inline messages
- Loading spinners
- Progress bars
- Skeleton screens
- Success/error states
- Empty states

### Content Patterns
- Card layouts
- List views
- Grid layouts
- Table displays
- Timeline/activity feed
- Hero section
- Image gallery
- Carousel/slider
- Video player
- Avatar/profile picture

## Design Tokens

Standardized design variables for consistency.

### Color Tokens
```
Primary Colors:
- primary-50 to primary-900 (shades)

Semantic Colors:
- success (green)
- warning (yellow)
- error (red)
- info (blue)

Neutral Colors:
- gray-50 to gray-900

Text Colors:
- text-primary
- text-secondary
- text-disabled
```

### Spacing Tokens
```
- spacing-xs: 4px
- spacing-sm: 8px
- spacing-md: 16px
- spacing-lg: 24px
- spacing-xl: 32px
- spacing-2xl: 48px
```

### Typography Tokens
```
Font Sizes:
- text-xs: 12px
- text-sm: 14px
- text-base: 16px
- text-lg: 18px
- text-xl: 20px
- text-2xl: 24px

Font Weights:
- normal: 400
- medium: 500
- semibold: 600
- bold: 700

Line Heights:
- tight: 1.25
- normal: 1.5
- relaxed: 1.75
```

### Border Radius Tokens
```
- rounded-none: 0
- rounded-sm: 2px
- rounded: 4px
- rounded-md: 6px
- rounded-lg: 8px
- rounded-xl: 12px
- rounded-full: 9999px
```

### Shadow Tokens
```
- shadow-sm: subtle elevation
- shadow: default elevation
- shadow-md: medium elevation
- shadow-lg: large elevation
- shadow-xl: maximum elevation
```

## Performance Considerations

### Perceived Performance
- Show content immediately (skeleton screens)
- Progressive loading
- Optimistic UI updates
- Smooth animations (60fps)

### Actual Performance
- Code splitting
- Lazy loading images and components
- Virtual scrolling for long lists
- Debouncing and throttling
- Caching strategies
- Minimize reflows and repaints

### Image Optimization
- Appropriate formats (WebP, AVIF)
- Responsive images (srcset)
- Lazy loading
- Blur-up placeholder technique
- Proper sizing and compression

## Testing UI Patterns

### Usability Testing
- User interviews
- Task completion testing
- A/B testing
- Heat maps and click tracking
- Session recordings

### Accessibility Testing
- Keyboard navigation testing
- Screen reader testing
- Color contrast checking
- Automated accessibility audits (axe, Lighthouse)
- Manual WCAG compliance review

### Cross-browser Testing
- Test in major browsers (Chrome, Firefox, Safari, Edge)
- Test on actual devices
- Use browser dev tools for responsive testing
- Check for progressive enhancement

### Performance Testing
- Lighthouse audits
- Core Web Vitals
- Loading time testing
- Interaction latency
- Animation frame rates

## Resources and Tools

### Design Systems
- Material Design (Google)
- Human Interface Guidelines (Apple)
- Fluent Design (Microsoft)
- Polaris (Shopify)
- Carbon (IBM)
- Ant Design
- Atlassian Design System

### Component Libraries
- Shadcn UI
- Radix UI
- Headless UI
- Chakra UI
- MUI (Material-UI)
- Ant Design
- Bootstrap
- Tailwind UI

### Accessibility Tools
- axe DevTools
- WAVE
- Lighthouse
- NVDA (screen reader)
- VoiceOver (screen reader)
- Color contrast checkers

### Prototyping Tools
- Figma
- Sketch
- Adobe XD
- Framer
- InVision

### Pattern Libraries
- UI Patterns
- Patternry
- Mobile Patterns
- Pttrns

## Conclusion

UI design patterns provide proven solutions to common interface challenges. By understanding and applying these patterns appropriately, you can create:

- **Consistent Interfaces**: Familiar patterns reduce learning curve
- **Accessible Experiences**: Built-in accessibility considerations
- **Efficient Development**: Reusable components and standardized approaches
- **Better UX**: Tested patterns that users understand

Remember:
- Choose patterns appropriate for your context
- Customize patterns to fit your brand and users
- Test with real users
- Prioritize accessibility
- Stay updated with evolving best practices
- Focus on user needs over trends

UI patterns are guidelines, not strict rules. Adapt them thoughtfully to create interfaces that serve your users effectively.
