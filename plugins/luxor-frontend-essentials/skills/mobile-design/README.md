# Mobile Design Skill

A comprehensive guide to mobile UX patterns, touch interactions, gesture design, and mobile-first development principles.

## Overview

This skill provides expert guidance on designing and building mobile-first user interfaces that work seamlessly across smartphones and tablets. It covers touch interactions, navigation patterns, platform-specific conventions (iOS and Android), accessibility standards, and performance optimization techniques.

## What You'll Learn

### Mobile-First Design

- **Progressive Enhancement**: Start with the smallest screen and build up
- **Content Prioritization**: Focus on essential features first
- **Performance by Default**: Lighter assets, simpler layouts
- **Touch-First Thinking**: Design for fingers, not mice

### Touch Interactions

Master all touch gestures:
- **Tap**: Single tap, double tap, and tap-and-hold patterns
- **Swipe**: Horizontal and vertical swipes for navigation and actions
- **Pinch/Spread**: Zoom gestures for images, maps, and content
- **Long Press**: Context menus and selection modes
- **Drag and Drop**: Touch-based reordering and organization

### Navigation Patterns

Essential mobile navigation systems:
- **Bottom Tab Bar**: Primary navigation for 3-5 main sections (iOS standard)
- **Hamburger Menu**: Drawer navigation for secondary features
- **Bottom Sheets**: Contextual actions and options
- **Stack Navigation**: Hierarchical screen flow with back navigation
- **Modal Presentations**: Full-screen overlays for focused tasks

### Platform Conventions

#### iOS (Human Interface Guidelines)
- 44×44pt minimum touch targets
- SF Pro font system with Dynamic Type
- Navigation bars with large titles
- Tab bars with 5 items maximum
- System colors that adapt to light/dark mode
- Edge swipe gestures for back navigation

#### Android (Material Design)
- 48×48dp minimum touch targets
- Roboto font family
- Material elevation system (shadows)
- Floating Action Buttons (FAB)
- Bottom navigation for 3-5 destinations
- Material You theming system

### UI Components

Mobile-optimized components:
- **Cards**: Grouped content containers
- **Lists**: Scrollable item collections with iOS/Android styles
- **Forms**: Touch-friendly input fields with proper keyboard types
- **Action Sheets**: iOS-style option menus
- **Modals**: Full-screen and bottom sheet overlays
- **Toasts/Snackbars**: Non-intrusive notifications

### Accessibility

Make your mobile apps inclusive:
- **Touch Target Sizes**: Minimum 48×48 pixels for all interactive elements
- **Screen Reader Support**: Proper ARIA labels and semantic HTML
- **Color Contrast**: WCAG AA compliance (4.5:1 for normal text)
- **Focus Indicators**: Visible keyboard navigation support
- **Dynamic Type**: Support user font size preferences

### Performance Optimization

Speed is critical on mobile:
- **Image Optimization**: Responsive images, lazy loading, WebP format
- **Loading Strategies**: Skeleton screens, progressive loading
- **PWA Techniques**: Service workers, offline support
- **Core Web Vitals**: LCP < 2.5s, FID < 100ms, CLS < 0.1
- **Bundle Size**: Code splitting and tree shaking

## When to Use This Skill

Use mobile-design when:

1. **Building Mobile-First Web Apps**: Creating responsive websites that prioritize mobile experience
2. **Developing Native Apps**: Building iOS or Android applications
3. **Creating PWAs**: Progressive web apps with app-like experiences
4. **Designing Touch Interfaces**: Any project requiring touch-first interactions
5. **Optimizing for Mobile Performance**: Improving load times and responsiveness
6. **Implementing Gestures**: Adding swipe, pinch, and other touch gestures
7. **Following Platform Guidelines**: Ensuring iOS/Android compliance
8. **Improving Mobile Accessibility**: Meeting WCAG standards on mobile
9. **Building Responsive Design Systems**: Components that adapt across devices
10. **Conducting Mobile UX Audits**: Reviewing and improving mobile experiences

## Quick Start Examples

### Example 1: Mobile-First Button

```jsx
// Optimal touch target with visual feedback
function MobileButton({ children, onPress }) {
  const [isPressed, setIsPressed] = useState(false);

  return (
    <button
      className={`mobile-btn ${isPressed ? 'pressed' : ''}`}
      onTouchStart={() => setIsPressed(true)}
      onTouchEnd={() => setIsPressed(false)}
      onClick={onPress}
      style={{
        minHeight: '48px',
        minWidth: '48px',
        padding: '12px 24px',
      }}
    >
      {children}
    </button>
  );
}
```

### Example 2: Responsive Grid

```css
/* Mobile-first grid layout */
.grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 16px;
  padding: 16px;
}

/* Tablet: 2 columns */
@media (min-width: 768px) {
  .grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* Desktop: 4 columns */
@media (min-width: 1024px) {
  .grid {
    grid-template-columns: repeat(4, 1fr);
    max-width: 1200px;
    margin: 0 auto;
  }
}
```

### Example 3: Swipe-to-Delete

```jsx
function SwipeableListItem({ onDelete, children }) {
  const [offset, setOffset] = useState(0);
  const [startX, setStartX] = useState(0);

  const handleTouchStart = (e) => {
    setStartX(e.touches[0].clientX);
  };

  const handleTouchMove = (e) => {
    const currentX = e.touches[0].clientX;
    const diff = startX - currentX;
    setOffset(Math.max(0, diff)); // Only allow left swipe
  };

  const handleTouchEnd = () => {
    if (offset > 80) {
      onDelete();
    } else {
      setOffset(0);
    }
  };

  return (
    <div className="swipe-container">
      <div className="delete-action">Delete</div>
      <div
        className="swipe-content"
        style={{ transform: `translateX(-${offset}px)` }}
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
      >
        {children}
      </div>
    </div>
  );
}
```

### Example 4: Bottom Sheet

```jsx
function BottomSheet({ isOpen, onClose, children }) {
  return (
    <>
      {isOpen && (
        <div className="bottom-sheet-backdrop" onClick={onClose} />
      )}
      <div className={`bottom-sheet ${isOpen ? 'open' : ''}`}>
        <div className="bottom-sheet-handle" />
        {children}
      </div>
    </>
  );
}

// CSS
.bottom-sheet {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  border-radius: 20px 20px 0 0;
  padding: 16px;
  transform: translateY(100%);
  transition: transform 0.3s ease-out;
  z-index: 1000;
}

.bottom-sheet.open {
  transform: translateY(0);
}

.bottom-sheet-handle {
  width: 40px;
  height: 4px;
  background: #D1D1D6;
  border-radius: 2px;
  margin: 0 auto 16px;
}
```

## Common Breakpoints

```css
/* Mobile-first breakpoint strategy */

/* Extra small (320px - 479px) */
/* Default styles here */

/* Small devices (480px+) */
@media (min-width: 480px) {
  /* Large phones */
}

/* Medium devices (768px+) */
@media (min-width: 768px) {
  /* Tablets */
}

/* Large devices (1024px+) */
@media (min-width: 1024px) {
  /* Laptops */
}

/* Extra large (1280px+) */
@media (min-width: 1280px) {
  /* Desktops */
}
```

## Touch Target Guidelines

| Platform | Minimum Size | Optimal Size | Spacing |
|----------|-------------|--------------|---------|
| iOS | 44×44 pt | 56×56 pt | 8pt |
| Android | 48×48 dp | 56×56 dp | 8dp |
| Web (WCAG) | 44×44 px | 48×48 px | 8px |

## Thumb Zones

Mobile screens have three ergonomic zones for one-handed use:

1. **Easy Zone** (Green): Bottom center - most accessible
   - Place primary actions here
   - Bottom tab bar
   - Main CTAs

2. **Stretch Zone** (Yellow): Middle areas - requires slight reach
   - Secondary actions
   - Content area
   - Form fields

3. **Difficult Zone** (Red): Top corners - hardest to reach
   - Destructive actions (delete, cancel)
   - Secondary navigation
   - Less frequent actions

## Input Types for Mobile Keyboards

```html
<!-- Email keyboard -->
<input type="email" inputmode="email" autocomplete="email">

<!-- Phone keyboard -->
<input type="tel" inputmode="tel" autocomplete="tel">

<!-- Numeric keypad -->
<input type="number" inputmode="numeric">

<!-- Decimal keypad -->
<input type="number" inputmode="decimal">

<!-- URL keyboard -->
<input type="url" inputmode="url">

<!-- Search keyboard -->
<input type="search" inputmode="search">
```

## Safe Areas (iPhone X and later)

```css
/* Account for notch and home indicator */
.header {
  padding-top: max(16px, env(safe-area-inset-top));
}

.content {
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
}

.footer {
  padding-bottom: max(16px, env(safe-area-inset-bottom));
}
```

## Performance Checklist

- [ ] Images use lazy loading
- [ ] Responsive images with srcset
- [ ] WebP format with fallback
- [ ] Critical CSS inlined
- [ ] JavaScript code split
- [ ] Service worker for caching
- [ ] Skeleton screens for loading
- [ ] Touch interactions < 100ms
- [ ] LCP < 2.5 seconds
- [ ] CLS < 0.1

## Accessibility Checklist

- [ ] Touch targets ≥ 48×48 pixels
- [ ] Color contrast ≥ 4.5:1
- [ ] Focus indicators visible
- [ ] Screen reader labels present
- [ ] Keyboard navigation works
- [ ] Zoom up to 200% supported
- [ ] Orientation changes handled
- [ ] Form inputs labeled properly
- [ ] Error messages clear
- [ ] Dynamic Type supported

## Platform-Specific Resources

### iOS Development
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [iOS Design Resources](https://developer.apple.com/design/resources/)

### Android Development
- [Material Design](https://material.io/)
- [Material Components](https://material.io/components)
- [Android Design Guidelines](https://developer.android.com/design)

### Cross-Platform
- [React Native](https://reactnative.dev/)
- [Flutter](https://flutter.dev/)
- [Ionic](https://ionicframework.com/)

## Testing on Real Devices

### iOS Testing
```bash
# Install on iOS Simulator
npx react-native run-ios

# Specific device
npx react-native run-ios --simulator="iPhone 14 Pro"
```

### Android Testing
```bash
# Install on Android Emulator
npx react-native run-android

# Specific device
adb devices
npx react-native run-android --deviceId=<device-id>
```

### Browser DevTools
```javascript
// Chrome DevTools device mode
// Toggle device toolbar: Cmd+Shift+M (Mac) / Ctrl+Shift+M (Windows)

// Common presets:
// - iPhone SE (375×667)
// - iPhone 14 Pro (390×844)
// - iPad Air (820×1180)
// - Samsung Galaxy S20 (360×800)
```

## Common Pitfalls to Avoid

1. **Too-Small Touch Targets**: Always use minimum 48×48 pixels
2. **Ignoring Thumb Zones**: Don't place primary actions in corners
3. **Desktop-First Thinking**: Start with mobile, enhance for desktop
4. **Slow Loading**: Optimize images and defer non-critical resources
5. **Fixed Viewport**: Always include proper viewport meta tag
6. **Ignoring Gestures**: Support swipe, pinch, and platform conventions
7. **Inconsistent Spacing**: Use 4px/8px grid system
8. **Poor Contrast**: Test with accessibility tools
9. **Tiny Text**: Minimum 16px font size to prevent zoom on focus
10. **Missing Input Types**: Use proper inputmode for mobile keyboards

## Design Tools

- **Figma**: Best for collaborative mobile design
- **Sketch**: macOS-only design tool with iOS templates
- **Adobe XD**: Cross-platform design and prototyping
- **Framer**: Interactive prototypes with real code
- **Principle**: Advanced animation prototypes

## Prototyping Tools

- **ProtoPie**: Complex interaction prototypes
- **InVision**: Design collaboration and handoff
- **Marvel**: Quick mockups and user testing
- **Origami Studio**: Facebook's prototyping tool

## Testing Tools

- **BrowserStack**: Cross-device testing
- **LambdaTest**: Cloud-based mobile testing
- **Responsively**: Open-source responsive design tool
- **Chrome DevTools**: Built-in device emulation

## Further Learning

### Books
- "Mobile Design Pattern Gallery" by Theresa Neil
- "Designing Mobile Interfaces" by Steven Hoober
- "Don't Make Me Think, Revisited" by Steve Krug

### Courses
- Apple's Human Interface Guidelines
- Material Design documentation
- A11y Project for accessibility

### Communities
- Dribbble (mobile design inspiration)
- Mobbin (mobile app patterns)
- iOS Dev Weekly
- Android Weekly

## Related Skills

- **responsive-design**: General responsive web design principles
- **accessibility**: WCAG compliance and inclusive design
- **performance-optimization**: Web performance best practices
- **react-native**: Cross-platform mobile development
- **pwa**: Progressive web app development

## Tips for Success

1. **Test on Real Devices**: Emulators don't capture actual touch feel
2. **Use Real Content**: Lorem ipsum hides layout problems
3. **Consider Network Conditions**: Test on 3G/4G, not just WiFi
4. **Support Landscape**: Don't lock orientation unnecessarily
5. **Optimize for One Hand**: Most users operate phones one-handed
6. **Provide Haptic Feedback**: Confirm actions with vibration (where appropriate)
7. **Keep Navigation Visible**: Don't hide critical navigation
8. **Progressive Disclosure**: Show details on demand
9. **Reduce Input**: Use smart defaults and autocomplete
10. **Test Accessibility**: Use VoiceOver/TalkBack regularly

## Conclusion

Mobile design is about more than shrinking desktop layouts. It requires understanding touch ergonomics, platform conventions, and mobile user behavior. By following mobile-first principles and implementing touch-friendly patterns, you'll create experiences that feel native and delight users across all devices.

Remember: mobile users are often distracted, on slow networks, and using one hand. Design accordingly.
