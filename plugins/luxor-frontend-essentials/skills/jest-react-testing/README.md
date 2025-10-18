# Jest React Testing

> Comprehensive testing guide for React applications using Jest and React Testing Library

## Overview

This skill provides a complete guide to testing React applications using Jest and React Testing Library. It covers everything from basic setup to advanced patterns, focusing on writing maintainable, user-centric tests that give you confidence in your application.

## What This Skill Covers

- **Jest Configuration**: Complete setup for JavaScript and TypeScript projects
- **React Testing Library**: Query strategies, user interactions, and best practices
- **Mocking Strategies**: Modules, functions, API calls, context, and child components
- **Async Testing**: Promises, timers, API calls, and loading states
- **Hooks Testing**: Custom hooks, context hooks, and async hooks
- **Integration Testing**: Multi-component flows, routing, and state management
- **Best Practices**: Accessible queries, test organization, and maintainable patterns

## Philosophy

This skill follows the core principles of Testing Library:

1. **Test Behavior, Not Implementation**
   - Focus on what users see and do
   - Avoid testing internal state or implementation details
   - Tests should break when behavior changes, not when code refactors

2. **Accessibility First**
   - Use queries that encourage accessible components
   - Prefer `getByRole` and `getByLabelText` over `getByTestId`
   - Build components that work for all users

3. **Confidence Over Coverage**
   - Write tests that give real confidence
   - Focus on critical user paths
   - Don't chase 100% coverage at the expense of test quality

4. **Maintainable Tests**
   - Clear, descriptive test names
   - Simple, focused test cases
   - Minimal mocking and setup

## Setup

### Installation

For React 18+ projects:
```bash
npm install --save-dev @testing-library/react @testing-library/jest-dom @testing-library/user-event jest jest-environment-jsdom
```

For TypeScript projects, also install:
```bash
npm install --save-dev @types/jest ts-jest
```

### Basic Configuration

Create `jest.config.js` in your project root:

```javascript
/** @type {import('jest').Config} */
const config = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/src/setupTests.js'],
  moduleNameMapper: {
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
  },
};

module.exports = config;
```

Create `src/setupTests.js`:

```javascript
import '@testing-library/jest-dom';
```

Add test script to `package.json`:

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  }
}
```

## Quick Start

### Basic Component Test

```javascript
import { render, screen } from '@testing-library/react';
import { Greeting } from './Greeting';

test('renders greeting message', () => {
  render(<Greeting name="World" />);
  expect(screen.getByText(/hello, world/i)).toBeInTheDocument();
});
```

### Testing User Interactions

```javascript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Counter } from './Counter';

test('increments counter on click', async () => {
  const user = userEvent.setup();
  render(<Counter />);

  await user.click(screen.getByRole('button', { name: /increment/i }));

  expect(screen.getByText(/count: 1/i)).toBeInTheDocument();
});
```

### Testing Async Operations

```javascript
import { render, screen } from '@testing-library/react';
import { UserProfile } from './UserProfile';

test('loads and displays user data', async () => {
  render(<UserProfile userId={1} />);

  expect(screen.getByText(/loading/i)).toBeInTheDocument();

  const username = await screen.findByText(/john doe/i);
  expect(username).toBeInTheDocument();
});
```

## Core Concepts

### Query Priority

Use queries in this order (most to least preferred):

1. **getByRole** - Most accessible, reflects how users find elements
   ```javascript
   screen.getByRole('button', { name: /submit/i })
   ```

2. **getByLabelText** - Good for form fields
   ```javascript
   screen.getByLabelText(/email/i)
   ```

3. **getByPlaceholderText** - For inputs with placeholders
   ```javascript
   screen.getByPlaceholderText(/search/i)
   ```

4. **getByText** - For non-interactive elements
   ```javascript
   screen.getByText(/welcome/i)
   ```

5. **getByTestId** - Last resort only
   ```javascript
   screen.getByTestId('custom-element')
   ```

### Query Types

- **getBy**: Throws error if not found (use when element should exist)
- **queryBy**: Returns null if not found (use to assert absence)
- **findBy**: Returns promise, waits for element (use for async)

```javascript
// Element should exist
const button = screen.getByRole('button');

// Element might not exist
const error = screen.queryByText(/error/i);
expect(error).not.toBeInTheDocument();

// Element appears after async operation
const data = await screen.findByText(/loaded/i);
```

### User Events vs Fire Event

Always prefer `userEvent` over `fireEvent`:

```javascript
// Good - simulates real user interactions
import userEvent from '@testing-library/user-event';

const user = userEvent.setup();
await user.click(button);
await user.type(input, 'text');

// Avoid - lower-level, doesn't simulate real interactions
import { fireEvent } from '@testing-library/react';

fireEvent.click(button);
fireEvent.change(input, { target: { value: 'text' } });
```

## Testing Patterns

### Forms

```javascript
test('submits form with user data', async () => {
  const user = userEvent.setup();
  const handleSubmit = jest.fn();

  render(<SignupForm onSubmit={handleSubmit} />);

  await user.type(screen.getByLabelText(/email/i), 'test@example.com');
  await user.type(screen.getByLabelText(/password/i), 'password123');
  await user.click(screen.getByRole('button', { name: /sign up/i }));

  expect(handleSubmit).toHaveBeenCalledWith({
    email: 'test@example.com',
    password: 'password123',
  });
});
```

### Conditional Rendering

```javascript
test('shows error when loading fails', async () => {
  render(<DataComponent url="/api/fail" />);

  const error = await screen.findByRole('alert');
  expect(error).toHaveTextContent(/failed to load/i);
});
```

### Lists

```javascript
test('renders all items', () => {
  const items = ['Apple', 'Banana', 'Cherry'];
  render(<ItemList items={items} />);

  const listItems = screen.getAllByRole('listitem');
  expect(listItems).toHaveLength(3);
});
```

## Mocking

### API Calls with MSW

```javascript
import { rest } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  rest.get('/api/user', (req, res, ctx) => {
    return res(ctx.json({ name: 'John' }));
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### Functions

```javascript
test('calls onClick when clicked', async () => {
  const user = userEvent.setup();
  const handleClick = jest.fn();

  render(<Button onClick={handleClick}>Click</Button>);

  await user.click(screen.getByRole('button'));

  expect(handleClick).toHaveBeenCalledTimes(1);
});
```

### Modules

```javascript
jest.mock('./api', () => ({
  fetchUser: jest.fn(() => Promise.resolve({ name: 'John' })),
}));
```

## Testing Custom Hooks

```javascript
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

test('increments counter', () => {
  const { result } = renderHook(() => useCounter());

  act(() => {
    result.current.increment();
  });

  expect(result.current.count).toBe(1);
});
```

## Integration Testing

### Testing with Router

```javascript
import { MemoryRouter } from 'react-router-dom';

const renderWithRouter = (ui, { initialEntries = ['/'] } = {}) => {
  return render(
    <MemoryRouter initialEntries={initialEntries}>
      {ui}
    </MemoryRouter>
  );
};
```

### Testing with Redux

```javascript
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';

const createMockStore = (initialState) => {
  return configureStore({
    reducer: rootReducer,
    preloadedState: initialState,
  });
};

const renderWithStore = (ui, { store = createMockStore() } = {}) => {
  return render(<Provider store={store}>{ui}</Provider>);
};
```

## Best Practices

### Do's

- Use accessible queries (getByRole, getByLabelText)
- Test user behavior, not implementation
- Use userEvent for interactions
- Write descriptive test names
- Keep tests simple and focused
- Use findBy for async elements
- Clean up after tests
- Test error states

### Don'ts

- Don't test implementation details
- Don't use getByTestId unless necessary
- Don't over-mock
- Don't test internal state
- Don't use fireEvent when userEvent works
- Don't skip accessibility
- Don't chase 100% coverage
- Don't write brittle tests

## Debugging

### View DOM Structure

```javascript
import { screen } from '@testing-library/react';

screen.debug(); // Prints entire DOM
screen.debug(element); // Prints specific element
```

### See Available Queries

```javascript
screen.logTestingPlaygroundURL(); // Opens Testing Playground with current DOM
```

### Common Issues

**Can't find element**:
- Use `screen.debug()` to see DOM
- Check query type (getBy vs queryBy vs findBy)
- Verify element has correct role/text
- Wait for async updates with findBy

**Act warnings**:
- Use userEvent instead of fireEvent
- Use waitFor/findBy for async updates
- Wrap state updates in act()

**Test timeout**:
- Increase timeout in waitFor
- Check for infinite loops
- Ensure promises resolve

## Resources

### Documentation

- [Jest Documentation](https://jestjs.io/)
- [React Testing Library](https://testing-library.com/react)
- [Testing Library Queries](https://testing-library.com/docs/queries/about)
- [Jest DOM Matchers](https://github.com/testing-library/jest-dom)
- [User Event](https://testing-library.com/docs/user-event/intro)

### Guides

- [Common Mistakes](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)
- [Testing Playground](https://testing-playground.com/)
- [Which Query Should I Use?](https://testing-library.com/docs/queries/about#priority)

### Tools

- [Testing Library Chrome Extension](https://chrome.google.com/webstore/detail/testing-library/testing-playground)
- [MSW (Mock Service Worker)](https://mswjs.io/)
- [Jest Preview](https://www.jest-preview.com/)

## Examples

See `EXAMPLES.md` for 15+ comprehensive test examples covering:
- Component testing
- Form validation
- API integration
- Custom hooks
- Error handling
- Accessibility
- Integration testing
- And more!

## Contributing

This skill is designed to be comprehensive but approachable. If you find areas that need clarification or additional examples, contributions are welcome!

## License

This skill documentation is provided as-is for educational purposes.

---

**Version**: 1.0.0
**Last Updated**: October 2025
**Maintained by**: Claude Skills Team
