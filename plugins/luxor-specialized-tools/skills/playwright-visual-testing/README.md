# Playwright Visual Testing & Browser Automation Skill

A comprehensive Claude skill for browser automation and visual testing using Playwright MCP server integration. Master visual regression testing, automated UI validation, and cross-browser testing for modern web applications.

## Overview

This skill transforms Claude into a Playwright expert, enabling automated browser testing, visual regression detection, and comprehensive UI validation. Built from extensive Playwright documentation and real-world testing patterns, this skill provides battle-tested workflows for web application quality assurance.

## What This Skill Does

The Playwright Visual Testing skill teaches Claude to:

- **Automate browser interactions**: Navigate, click, type, and interact with web pages programmatically
- **Capture visual states**: Take screenshots of full pages, viewports, or specific elements
- **Test responsively**: Validate layouts across mobile, tablet, and desktop viewports
- **Verify accessibility**: Use semantic snapshots to ensure proper page structure
- **Debug effectively**: Capture console messages, network requests, and page state
- **Test cross-browser**: Validate consistency across Chromium, Firefox, and WebKit
- **Automate workflows**: Test complete user journeys from start to finish
- **Visual regression testing**: Compare screenshots to detect unintended changes

## When to Use This Skill

Use this skill when:

- Testing web applications before deployment
- Implementing visual regression testing in CI/CD
- Validating responsive designs across devices
- Testing forms and user interactions
- Debugging browser-specific issues
- Creating automated E2E test suites
- Capturing screenshots for documentation
- Testing PWAs and single-page applications
- Verifying accessibility compliance
- Testing cross-browser compatibility
- Validating UI component libraries
- Automating QA workflows

## Key Features

### 1. Comprehensive Tool Reference

Every Playwright MCP server tool documented with:
- Required and optional parameters
- Detailed usage examples
- Return data structures
- Common patterns
- Best practices
- Error handling strategies

**Tools Covered:**
- Browser lifecycle (navigate, close, resize)
- Page inspection (snapshot, screenshot)
- User interactions (click, type, fill forms, drag)
- Advanced operations (JavaScript evaluation, file uploads)
- Debugging (console messages, network requests)
- Tab management
- Dialog handling
- Wait strategies

### 2. Visual Testing Workflow Patterns

Proven patterns for:
- **Basic Visual Regression**: Compare page screenshots over time
- **Responsive Design Testing**: Validate across multiple viewports
- **Form Testing**: Test validation, submission, and error states
- **Element-Specific Testing**: Test individual component states
- **Cross-Browser Testing**: Ensure consistency across browsers
- **E2E User Journeys**: Test complete workflows
- **Accessibility Testing**: Verify semantic structure and keyboard navigation

### 3. Development Acceleration Strategies

- **Test Templates**: Reusable patterns for common scenarios
- **Screenshot Organization**: Systematic file structure and naming
- **Parallel Testing**: Multi-browser test execution
- **Visual Regression Automation**: Automated comparison workflows
- **Component Library Testing**: Design system validation

### 4. Best Practices

Comprehensive guidance on:
- **Screenshot Strategies**: Naming, formats, organization
- **Snapshot vs Screenshot**: When to use each approach
- **Waiting Strategies**: Reliable element interaction
- **Form Testing**: Validation and submission patterns
- **Network Monitoring**: API call verification
- **Debugging Workflows**: Systematic issue resolution

### 5. Practical Examples

10+ detailed examples covering:
- Homepage visual regression
- Login form testing
- Responsive design validation
- Component state testing
- E2E checkout flows
- Accessibility testing
- Network debugging
- Dialog handling
- Tab management
- Animation testing

## Skill Contents

### Core Documentation

- **SKILL.md** (20KB+): Complete Playwright MCP reference with:
  - All 25+ Playwright MCP tools documented
  - Visual testing workflow patterns
  - Browser automation best practices
  - Development acceleration strategies
  - Comprehensive troubleshooting guide
  - 10+ practical examples
  - Quick reference section

### Example Workflows

The `examples/` directory contains detailed workflow guides:

1. **e-commerce-testing.md**: Complete e-commerce site testing
   - Product browsing and search
   - Shopping cart functionality
   - Checkout process
   - Payment flows
   - Order confirmation

2. **responsive-testing.md**: Responsive design validation
   - Mobile layout testing
   - Tablet breakpoint validation
   - Desktop viewport testing
   - Cross-device consistency

3. **component-library.md**: Design system testing
   - Component state validation
   - Visual regression for components
   - Accessibility verification
   - Documentation generation

## How to Use This Skill

### Installation

1. Copy the `playwright-visual-testing` folder to your Claude skills directory:
   ```
   ~/Library/Application Support/Claude/skills/playwright-visual-testing/
   ```

2. Ensure Playwright MCP server is configured in your MCP settings

3. Claude will automatically detect and load the skill when relevant

### Invoking the Skill

The skill activates automatically when you:
- Mention Playwright or browser automation
- Ask about visual testing or screenshots
- Discuss E2E testing or QA workflows
- Request help with browser debugging
- Need cross-browser testing guidance
- Ask about responsive design testing

### Example Usage

```
You: "I need to test my login form across different browsers and take screenshots"

Claude: [Activates playwright-visual-testing skill]
I'll help you set up comprehensive login form testing using Playwright. Here's the workflow:

1. First, let's navigate to your login page and capture the initial state
2. We'll test the form with valid and invalid inputs
3. Capture screenshots of error states and success states
4. Test across different viewport sizes
5. Verify form accessibility with snapshots

Let me walk you through each step...
[Uses Playwright MCP tools with skill knowledge]
```

```
You: "How can I detect visual regressions in my homepage after updates?"

Claude: [Activates playwright-visual-testing skill]
For visual regression testing, I recommend this workflow:

1. Capture baseline screenshots before changes
2. Make your updates and deploy
3. Capture new screenshots with identical parameters
4. Compare screenshots to identify differences
5. Review and validate changes

Here's the detailed process...
[Uses visual regression patterns from skill]
```

## Quick Start

### For Visual Regression Testing
See **Pattern 1** in SKILL.md for complete visual regression workflow

### For Responsive Testing
See **Pattern 2** in SKILL.md for multi-viewport testing strategy

### For Form Testing
See **Pattern 3** in SKILL.md for comprehensive form validation

### For E2E Testing
See **Pattern 6** in SKILL.md for complete user journey testing

## Example Directory

The `examples/` directory contains three comprehensive guides:

1. **e-commerce-testing.md**: Real-world e-commerce site testing with product browsing, cart, and checkout
2. **responsive-testing.md**: Complete responsive design validation across devices
3. **component-library.md**: Design system component testing and documentation

Each example includes:
- Step-by-step Playwright MCP tool usage
- Real-world scenarios
- Screenshot strategies
- Debugging techniques
- Best practices in action

## Skill Capabilities

With this skill, Claude can:

### Browser Automation
- Navigate to URLs and handle redirects
- Interact with forms and buttons
- Type text and simulate keyboard input
- Handle file uploads and downloads
- Manage multiple browser tabs
- Respond to browser dialogs

### Visual Testing
- Capture full-page screenshots
- Take viewport-specific screenshots
- Screenshot individual elements
- Organize screenshots systematically
- Compare visual states
- Document visual changes

### Quality Assurance
- Test form validation
- Verify user workflows
- Check responsive layouts
- Validate accessibility
- Debug JavaScript errors
- Monitor network requests

### Cross-Browser Testing
- Test on Chromium/Chrome/Edge
- Test on Firefox
- Test on WebKit/Safari
- Compare browser rendering
- Identify browser-specific bugs

### Debugging
- Capture console messages
- Monitor network activity
- Inspect page structure
- Verify element states
- Track user interactions
- Document issues with screenshots

## Advanced Usage

### Custom Test Suites

Adapt the patterns in SKILL.md to create custom test suites:
- Define your test scenarios
- Create reusable test templates
- Organize screenshots systematically
- Build comparison workflows
- Generate test reports

### CI/CD Integration

Use Playwright automation in continuous integration:
- Run tests on every commit
- Capture screenshots on failures
- Compare against baselines
- Block deployments on regressions
- Generate visual test reports

### Component Documentation

Generate living documentation:
- Capture all component states
- Screenshot each variant
- Organize by component type
- Include usage examples
- Update automatically

## Common Workflows

### 1. Pre-Deployment Testing
```
1. Navigate to staging environment
2. Test critical user paths
3. Capture screenshots of key pages
4. Verify responsive layouts
5. Check console for errors
6. Validate network requests
7. Document any issues
```

### 2. Visual Regression Suite
```
1. Maintain baseline screenshot library
2. Run tests after each deployment
3. Compare new vs baseline screenshots
4. Review differences
5. Update baselines for intentional changes
6. Fix unintended regressions
```

### 3. Cross-Browser Validation
```
1. Define browser matrix
2. Run identical tests per browser
3. Capture browser-specific screenshots
4. Compare rendering across browsers
5. Document browser-specific issues
6. Apply necessary fixes
```

## Viewport Reference

### Mobile Devices
- iPhone SE: 375 x 667
- iPhone 12/13/14: 390 x 844
- Android Small: 360 x 640
- Android Large: 412 x 915

### Tablets
- iPad Portrait: 768 x 1024
- iPad Landscape: 1024 x 768
- Android Tablet: 810 x 1080

### Desktop
- HD: 1280 x 720
- Laptop: 1366 x 768
- Full HD: 1920 x 1080
- 2K: 2560 x 1440

## Troubleshooting

### Screenshot Issues
- Blank screenshots: Wait for page load
- Inconsistent screenshots: Disable animations
- Wrong viewport: Set explicit dimensions
- Missing elements: Wait for dynamic content

### Interaction Issues
- Element not found: Take fresh snapshot
- Click not working: Verify element is actionable
- Form not submitting: Check validation errors
- Text not typing: Ensure field is focused

### Browser Issues
- Browser not launching: Run browser_install
- Timeout errors: Increase wait times
- Memory issues: Close unused tabs
- Performance problems: Test smaller viewports

## Resources

### Playwright Documentation
- [Playwright Official Docs](https://playwright.dev)
- [API Reference](https://playwright.dev/docs/api/class-playwright)
- [Visual Testing Guide](https://playwright.dev/docs/test-snapshots)
- [Best Practices](https://playwright.dev/docs/best-practices)

### MCP Integration
- [Playwright MCP Server](https://github.com/microsoft/playwright-mcp)
- [Model Context Protocol](https://modelcontextprotocol.io)

### Testing Resources
- [Accessibility Testing](https://playwright.dev/docs/accessibility-testing)
- [Network Mocking](https://playwright.dev/docs/mock)
- [Browser Contexts](https://playwright.dev/docs/browser-contexts)

## Skill Metadata

- **Version**: 1.0.0
- **Category**: Browser Automation, Visual Testing, Quality Assurance
- **Compatible With**: Playwright MCP Server, Chromium, Firefox, WebKit
- **Last Updated**: October 2025
- **Research Sources**: Playwright documentation, MCP server API, real-world testing patterns

## Contributing

This skill is based on:
- Comprehensive Playwright MCP server exploration
- Official Playwright documentation
- Visual testing best practices
- Real-world QA workflows
- Cross-browser testing strategies

Suggestions for improvements are welcome!

## License

This skill is provided as-is for use with Claude Code and Claude API.

---

**Test smarter. Ship confidently. Automate visual validation with Playwright + Claude.**
