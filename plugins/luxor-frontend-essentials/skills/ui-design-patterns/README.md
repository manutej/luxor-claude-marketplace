# UI Design Patterns Skill

A comprehensive reference guide for implementing common user interface design patterns, components, and interactions with accessibility best practices.

## Overview

This skill provides detailed guidance on UI design patterns used in modern web and mobile applications. It covers navigation patterns, form patterns, data display, feedback mechanisms, interaction patterns, and accessibility considerations.

## What's Included

### Navigation Patterns
- **Tabs**: Organize content into switchable panels
- **Accordions**: Collapsible content sections
- **Breadcrumbs**: Hierarchical navigation trails
- **Pagination**: Navigate through large content sets
- **Menus**: Dropdown, mega menus, hamburger navigation

### Form Patterns
- **Input Validation**: Real-time and on-submit validation
- **Multi-Step Forms**: Break complex forms into steps
- **Inline Editing**: Edit content directly in place
- **Search & Autocomplete**: Type-ahead suggestions
- **Form Layouts**: Single/multi-column, label positioning

### Data Display Patterns
- **Tables**: Sortable, filterable data grids
- **Cards**: Containerized related information
- **Lists**: Sequential item displays
- **Grids**: Row and column layouts
- **Dashboards**: Metrics and visualizations overview

### Feedback Patterns
- **Toasts/Snackbars**: Temporary status messages
- **Modals/Dialogs**: Focused user attention overlays
- **Loading States**: Progress indicators and skeletons
- **Empty States**: First use and no-results guidance
- **Notification Badges**: Unread counts and status

### Interaction Patterns
- **Drag and Drop**: Move and reorder items
- **Infinite Scroll**: Auto-load content on scroll
- **Filtering**: Refine displayed results
- **Search**: Find specific content
- **Undo/Redo**: Reverse and replay actions

### Accessibility Patterns
- **WCAG Compliance**: Perceivable, Operable, Understandable, Robust
- **Keyboard Navigation**: Full keyboard support
- **ARIA Attributes**: Roles, states, and properties
- **Screen Reader Support**: Semantic HTML and announcements
- **Color Contrast**: Sufficient contrast ratios

### Responsive Patterns
- **Mobile-First Design**: Start with mobile, enhance for desktop
- **Adaptive Layouts**: Fluid grids and flexible images
- **Mobile Navigation**: Touch-friendly navigation patterns
- **Touch Interactions**: Gestures and target sizes
- **Responsive Tables**: Adapt tables for small screens

## Quick Start

### Using a Pattern

1. **Identify the Problem**: What UI challenge are you solving?
2. **Choose a Pattern**: Select the most appropriate pattern from the skill
3. **Review Guidelines**: Read the pattern's best practices and accessibility requirements
4. **Implement**: Follow the code examples and structure
5. **Test**: Verify keyboard navigation, screen reader support, and responsive behavior

### Example: Implementing a Tab Component

```html
<!-- HTML Structure -->
<div role="tablist" aria-label="Content sections">
  <button role="tab" aria-selected="true" aria-controls="panel-1" id="tab-1">
    Overview
  </button>
  <button role="tab" aria-selected="false" aria-controls="panel-2" id="tab-2">
    Details
  </button>
</div>

<div role="tabpanel" id="panel-1" aria-labelledby="tab-1">
  Overview content...
</div>
<div role="tabpanel" id="panel-2" aria-labelledby="tab-2" hidden>
  Details content...
</div>
```

**Best Practices**:
- Use semantic ARIA roles
- Implement arrow key navigation
- Provide clear visual indicators
- Support keyboard shortcuts

## When to Use This Skill

Use this skill when you need to:

- **Design New Interfaces**: Build user-friendly UI components
- **Solve Common UX Problems**: Apply proven solutions to interface challenges
- **Ensure Accessibility**: Make interfaces usable by everyone
- **Review Existing UI**: Evaluate current implementations against best practices
- **Build Design Systems**: Create consistent component libraries
- **Implement Interactions**: Add drag-drop, filtering, and dynamic behaviors
- **Optimize for Mobile**: Create responsive, touch-friendly interfaces
- **Handle Forms**: Design effective input validation and multi-step workflows
- **Display Data**: Present tables, lists, cards effectively
- **Provide Feedback**: Communicate system state with toasts, modals, loading states

## Pattern Categories

### 1. Navigation (5 patterns)
Help users move through your application efficiently.

### 2. Forms (5 patterns)
Collect user input with clear validation and feedback.

### 3. Data Display (5 patterns)
Present information in scannable, organized formats.

### 4. Feedback (5 patterns)
Communicate system state and action results.

### 5. Interaction (5 patterns)
Enable rich user interactions and manipulations.

### 6. Accessibility (5+ considerations)
Make interfaces usable by all users regardless of ability.

### 7. Responsive (4+ patterns)
Adapt interfaces for different devices and screen sizes.

## Core Principles

### Consistency
- Use patterns consistently throughout your application
- Follow established conventions users already know
- Maintain visual and behavioral consistency

### Accessibility First
- Design for keyboard navigation from the start
- Use semantic HTML elements
- Add ARIA attributes when necessary
- Test with screen readers
- Ensure sufficient color contrast

### Progressive Disclosure
- Show only what users need at each step
- Reveal complexity gradually
- Use patterns like accordions and tabs to manage information density

### Feedback and Affordance
- Provide immediate feedback for user actions
- Use visual cues to indicate interactivity
- Show system state clearly (loading, success, error)

### Mobile-First Thinking
- Design for small screens first
- Ensure touch targets are large enough (44x44px minimum)
- Optimize for touch gestures
- Test on actual devices

## Design Tokens

Standardize your design with reusable tokens:

**Colors**: Primary, semantic (success/error/warning), neutral scales
**Spacing**: Consistent scale (4px, 8px, 16px, 24px, 32px, 48px)
**Typography**: Font sizes, weights, line heights
**Borders**: Radius values for different component types
**Shadows**: Elevation levels for depth perception

## Common Mistakes to Avoid

### Navigation
- Too many tab levels or nested navigation
- Hidden navigation without clear access points
- Inconsistent navigation patterns across pages

### Forms
- Using placeholder text as labels
- Poor error message placement or timing
- No visual feedback for validation states
- Requiring unnecessary information

### Data Display
- Horizontal scrolling tables on mobile
- No empty states or error handling
- Inconsistent formatting across columns
- Poor visual hierarchy

### Feedback
- Too many simultaneous notifications
- Auto-dismissing critical messages too quickly
- Modal dialogs for non-critical information
- No loading states for async operations

### Accessibility
- Missing alt text for images
- Keyboard traps or no keyboard access
- Insufficient color contrast
- Missing form labels
- No focus indicators

### Responsive
- Fixed pixel widths instead of fluid layouts
- Touch targets too small (less than 44x44px)
- Hover-only interactions on touch devices
- Not testing on actual devices

## Testing Checklist

### Functional Testing
- [ ] All interactions work as expected
- [ ] Form validation provides helpful feedback
- [ ] Navigation flows logically
- [ ] Data displays correctly in all states
- [ ] Error handling works properly

### Accessibility Testing
- [ ] Keyboard-only navigation works
- [ ] Screen reader announcements are clear
- [ ] Focus indicators are visible
- [ ] Color contrast meets WCAG AA (4.5:1)
- [ ] ARIA attributes are correct and updated
- [ ] Form labels are associated properly

### Responsive Testing
- [ ] Layouts adapt smoothly across breakpoints
- [ ] Touch targets are large enough on mobile
- [ ] Text is readable without zooming
- [ ] Navigation works on small screens
- [ ] Tables handle mobile gracefully
- [ ] Tested on actual devices

### Performance Testing
- [ ] Animations run at 60fps
- [ ] Images are optimized and lazy-loaded
- [ ] Large lists use virtual scrolling
- [ ] No layout shifts during loading
- [ ] Bundle size is optimized

### Browser Testing
- [ ] Chrome/Edge (Chromium)
- [ ] Firefox
- [ ] Safari (macOS and iOS)
- [ ] Fallbacks for unsupported features

## Popular Design Systems

Learn from established design systems:

**Material Design (Google)**
- Comprehensive component library
- Strong motion and interaction guidelines
- Well-documented accessibility features

**Human Interface Guidelines (Apple)**
- iOS and macOS patterns
- Native mobile interactions
- Platform-specific conventions

**Fluent Design (Microsoft)**
- Windows application patterns
- Adaptive and responsive guidelines
- Cross-platform consistency

**Polaris (Shopify)**
- E-commerce focused patterns
- Excellent accessibility documentation
- Practical implementation examples

**Carbon (IBM)**
- Enterprise application patterns
- Data visualization components
- Comprehensive design tokens

## Component Libraries

Pre-built implementations of common patterns:

**Headless UI Libraries** (Unstyled, accessible):
- Radix UI
- Headless UI
- React Aria

**Styled Component Libraries**:
- Shadcn UI
- Chakra UI
- MUI (Material-UI)
- Ant Design
- Mantine

**CSS Frameworks**:
- Tailwind CSS
- Bootstrap
- Bulma

## Tools and Resources

### Design Tools
- **Figma**: Collaborative interface design
- **Sketch**: macOS design tool
- **Adobe XD**: Design and prototype
- **Framer**: Interactive prototyping

### Accessibility Tools
- **axe DevTools**: Browser extension for accessibility testing
- **WAVE**: Web accessibility evaluation tool
- **Lighthouse**: Automated auditing (built into Chrome)
- **Color Contrast Analyzer**: Check WCAG compliance
- **NVDA/VoiceOver**: Screen reader testing

### Pattern Resources
- **UI Patterns**: Pattern library and examples
- **Refactoring UI**: Design tips and patterns
- **Inclusive Components**: Accessible component patterns
- **Smashing Magazine**: UI/UX articles and guides
- **A List Apart**: Web design best practices

### Development Tools
- **Storybook**: Component development environment
- **Chromatic**: Visual regression testing
- **Percy**: Visual review platform
- **BrowserStack**: Cross-browser testing

## Integration with Development

### Component Structure

```
components/
├── Button/
│   ├── Button.tsx
│   ├── Button.test.tsx
│   ├── Button.stories.tsx
│   └── Button.module.css
├── Modal/
│   ├── Modal.tsx
│   ├── Modal.test.tsx
│   ├── Modal.stories.tsx
│   └── Modal.module.css
└── ...
```

### Documentation Template

For each component, document:

1. **Purpose**: What problem does it solve?
2. **When to Use**: Appropriate use cases
3. **Anatomy**: Component parts and structure
4. **Variants**: Different configurations
5. **Props/API**: Configuration options
6. **Accessibility**: ARIA attributes, keyboard support
7. **Examples**: Code samples and demos
8. **Best Practices**: Guidelines and pitfalls
9. **Related Components**: Alternative or complementary patterns

### Naming Conventions

Use clear, consistent names:
- **Components**: PascalCase (Button, Modal, DataTable)
- **Props**: camelCase (isOpen, onClose, ariaLabel)
- **CSS Classes**: kebab-case or BEM (button-primary, modal__header)
- **Files**: Match component name (Button.tsx, button.module.css)

## Performance Optimization

### Render Performance
- Memoize expensive computations
- Use virtualization for long lists
- Lazy load off-screen components
- Optimize re-renders with proper state management

### Loading Performance
- Code splitting by route
- Lazy load below-the-fold images
- Use skeleton screens during load
- Implement progressive loading

### Animation Performance
- Use CSS transforms and opacity (GPU-accelerated)
- Avoid animating layout properties
- Use requestAnimationFrame for JS animations
- Limit simultaneous animations

## Version History

**v1.0.0** - Initial release
- 25+ comprehensive UI patterns
- Accessibility guidelines for each pattern
- Responsive design considerations
- Code examples and best practices
- Testing checklists
- Tool and resource recommendations

## Contributing Patterns

When documenting new patterns, include:

1. **Pattern Name**: Clear, descriptive name
2. **Description**: What it does and why
3. **Use Cases**: When to use (and not use)
4. **Anatomy**: Component structure
5. **Variants**: Different configurations
6. **Best Practices**: Guidelines and recommendations
7. **Accessibility**: WCAG compliance requirements
8. **Code Example**: HTML/CSS/JS implementation
9. **Responsive**: Mobile considerations
10. **Related Patterns**: Alternatives and complements

## Getting Help

### Understanding a Pattern
1. Read the "When to Use" section
2. Review the anatomy and structure
3. Check code examples
4. Review accessibility requirements
5. See EXAMPLES.md for detailed implementations

### Choosing Between Patterns
Consider:
- User context and task
- Information hierarchy
- Screen size and device
- Accessibility requirements
- Performance implications
- Consistency with existing patterns

### Troubleshooting
- Check accessibility attributes are correct
- Verify keyboard navigation works
- Test with screen readers
- Review browser console for errors
- Validate HTML structure
- Check responsive behavior

## Next Steps

1. **Review SKILL.md**: Read the complete pattern documentation
2. **Explore EXAMPLES.md**: See detailed implementation examples
3. **Build a Component**: Pick a pattern and implement it
4. **Test Thoroughly**: Use the testing checklist
5. **Document**: Create usage guidelines for your team
6. **Iterate**: Refine based on user feedback

## License

This skill is provided as part of Claude Code for educational and development purposes.

## Acknowledgments

Built on established patterns from:
- WCAG Accessibility Guidelines
- WAI-ARIA Authoring Practices
- Material Design
- Apple Human Interface Guidelines
- Nielsen Norman Group research
- Inclusive Components by Heydon Pickering
- Community best practices and contributions

---

**Remember**: UI patterns are proven solutions, but always adapt them to your specific users, context, and brand. Test with real users and prioritize accessibility in every implementation.
