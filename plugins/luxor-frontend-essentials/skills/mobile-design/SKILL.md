---
name: mobile-design
description: Mobile UX patterns, touch interactions, gesture design, mobile-first principles, app navigation, and mobile performance
category: design
tags: [mobile, ux, touch, gestures, navigation, mobile-first, ios, android]
version: 1.0.0
---

# Mobile Design Skill

## When to Use This Skill

Use this skill when working on:

- **Mobile-First Web Applications**: Building responsive websites that prioritize mobile user experience
- **Native Mobile Apps**: Designing iOS or Android applications with platform-specific patterns
- **Progressive Web Apps (PWAs)**: Creating app-like experiences in the browser
- **Hybrid Mobile Applications**: Developing cross-platform apps using React Native, Flutter, or similar frameworks
- **Responsive Design Systems**: Creating components that adapt seamlessly across devices
- **Touch-First Interfaces**: Designing for touchscreen interactions rather than mouse/keyboard
- **Mobile E-commerce**: Building shopping experiences optimized for small screens
- **Mobile Dashboards**: Adapting data-heavy interfaces for mobile consumption
- **Gesture-Based Interfaces**: Implementing swipe, pinch, and other touch gestures
- **Accessibility Audits**: Ensuring mobile interfaces meet accessibility standards

This skill helps you create mobile experiences that feel native, perform well, and delight users on smartphones and tablets.

## Core Concepts

### Mobile-First Design Philosophy

Mobile-first design starts with the smallest screen and progressively enhances for larger devices:

**Why Mobile-First?**
- Forces prioritization of essential content and features
- Improves performance by default (lighter assets, simpler layouts)
- Easier to scale up than scale down
- Reflects actual user behavior (mobile traffic often exceeds desktop)
- Ensures core functionality works on all devices

**Mobile-First vs Desktop-First:**

```css
/* Mobile-First Approach (Recommended) */
/* Base styles for mobile */
.container {
  padding: 16px;
  font-size: 14px;
}

/* Tablet enhancements */
@media (min-width: 768px) {
  .container {
    padding: 24px;
    font-size: 16px;
  }
}

/* Desktop enhancements */
@media (min-width: 1024px) {
  .container {
    padding: 32px;
    max-width: 1200px;
    margin: 0 auto;
  }
}

/* Desktop-First Approach (Not Recommended) */
/* Base styles for desktop */
.container {
  padding: 32px;
  max-width: 1200px;
  margin: 0 auto;
  font-size: 16px;
}

/* Tablet overrides */
@media (max-width: 1023px) {
  .container {
    padding: 24px;
  }
}

/* Mobile overrides */
@media (max-width: 767px) {
  .container {
    padding: 16px;
    font-size: 14px;
  }
}
```

### Touch Targets and Ergonomics

**Minimum Touch Target Sizes:**
- Apple: 44×44 points (iOS Human Interface Guidelines)
- Google: 48×48 dp (Material Design)
- Microsoft: 40×40 pixels (Windows Phone)
- **Recommended**: 48×48 pixels minimum, 56×56 pixels optimal

**Touch Target Spacing:**
- Minimum 8px spacing between interactive elements
- Optimal 12-16px spacing for frequently used controls
- Edge-to-edge buttons can touch if they're different types (e.g., cancel vs confirm)

**Thumb Zones:**

Mobile screens have three ergonomic zones:

1. **Easy Zone** (Green): Bottom third, center - easiest to reach with thumb
2. **Stretch Zone** (Yellow): Middle area - requires slight reach
3. **Difficult Zone** (Red): Top corners - hardest to reach one-handed

**Design Implications:**
- Place primary actions in the easy zone (bottom center)
- Put destructive actions in difficult zones (top corners)
- Navigation typically at top or bottom, never middle
- Consider both left-handed and right-handed users

```jsx
// React Native: Bottom-aligned primary action (easy zone)
<View style={styles.container}>
  <ScrollView style={styles.content}>
    {/* Main content */}
  </ScrollView>

  <View style={styles.bottomActions}>
    <TouchableOpacity style={styles.primaryButton}>
      <Text>Continue</Text>
    </TouchableOpacity>
  </View>
</View>

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    flex: 1,
  },
  bottomActions: {
    padding: 16,
    paddingBottom: 32, // Extra padding for iPhone home indicator
    backgroundColor: '#fff',
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0',
  },
  primaryButton: {
    height: 56, // Optimal touch target
    borderRadius: 28,
    backgroundColor: '#007AFF',
    justifyContent: 'center',
    alignItems: 'center',
  },
});
```

### Viewport and Screen Considerations

**Common Mobile Breakpoints:**

```css
/* Extra small devices (phones, 320px - 479px) */
@media (min-width: 320px) { }

/* Small devices (large phones, 480px - 767px) */
@media (min-width: 480px) { }

/* Medium devices (tablets, 768px - 1023px) */
@media (min-width: 768px) { }

/* Large devices (small laptops, 1024px - 1279px) */
@media (min-width: 1024px) { }

/* Extra large devices (desktops, 1280px and up) */
@media (min-width: 1280px) { }
```

**Viewport Meta Tag:**

```html
<!-- Responsive viewport (required for mobile) -->
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=5, user-scalable=yes">

<!-- PWA with standalone mode -->
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
```

**Safe Areas (iPhone X and later):**

```css
/* Account for notch and home indicator */
.header {
  padding-top: env(safe-area-inset-top);
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
}

.footer {
  padding-bottom: env(safe-area-inset-bottom);
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
}
```

## Touch Interactions

### Tap (Primary Interaction)

**Single Tap:**
- Primary action on buttons, links, list items
- Should provide immediate visual feedback (0-100ms delay)
- Minimum size: 48×48 pixels

```jsx
// React: Tap with visual feedback
import { useState } from 'react';

function TapButton({ onPress, children }) {
  const [isPressed, setIsPressed] = useState(false);

  return (
    <button
      className={`tap-button ${isPressed ? 'pressed' : ''}`}
      onTouchStart={() => setIsPressed(true)}
      onTouchEnd={() => setIsPressed(false)}
      onTouchCancel={() => setIsPressed(false)}
      onClick={onPress}
    >
      {children}
    </button>
  );
}

// CSS
.tap-button {
  padding: 16px 24px;
  background: #007AFF;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  min-height: 48px;
  transition: transform 0.1s, background 0.1s;
  -webkit-tap-highlight-color: transparent;
}

.tap-button.pressed {
  transform: scale(0.96);
  background: #0051D5;
}

.tap-button:active {
  transform: scale(0.96);
}
```

**Double Tap:**
- Zoom in/out (maps, images)
- Like/favorite (Instagram, Twitter)
- Less common, use sparingly

**iOS Double-Tap Zoom Prevention:**

```css
/* Prevent double-tap zoom while allowing pinch zoom */
touch-action: manipulation;
```

### Swipe Gestures

**Horizontal Swipe:**
- Navigate between screens/pages
- Reveal actions (swipe-to-delete, swipe-to-archive)
- Dismiss cards/modals
- Switch tabs

```jsx
// React: Swipeable list item
import { useState } from 'react';

function SwipeableListItem({ children, onDelete, onArchive }) {
  const [touchStart, setTouchStart] = useState(null);
  const [touchEnd, setTouchEnd] = useState(null);
  const [translateX, setTranslateX] = useState(0);

  const minSwipeDistance = 50;

  const onTouchStart = (e) => {
    setTouchEnd(null);
    setTouchStart(e.targetTouches[0].clientX);
  };

  const onTouchMove = (e) => {
    setTouchEnd(e.targetTouches[0].clientX);
    const distance = touchStart - e.targetTouches[0].clientX;
    setTranslateX(-distance);
  };

  const onTouchEnd = () => {
    if (!touchStart || !touchEnd) return;

    const distance = touchStart - touchEnd;
    const isLeftSwipe = distance > minSwipeDistance;
    const isRightSwipe = distance < -minSwipeDistance;

    if (isLeftSwipe) {
      setTranslateX(-80); // Show actions
    } else if (isRightSwipe) {
      setTranslateX(0); // Reset
    } else {
      setTranslateX(0); // Snap back
    }
  };

  return (
    <div className="swipeable-item-container">
      <div className="swipe-actions">
        <button onClick={onArchive} className="archive-btn">Archive</button>
        <button onClick={onDelete} className="delete-btn">Delete</button>
      </div>

      <div
        className="swipeable-item"
        style={{ transform: `translateX(${translateX}px)` }}
        onTouchStart={onTouchStart}
        onTouchMove={onTouchMove}
        onTouchEnd={onTouchEnd}
      >
        {children}
      </div>
    </div>
  );
}
```

**Vertical Swipe:**
- Pull to refresh (downward swipe from top)
- Scroll content
- Dismiss bottom sheets/modals (downward swipe)

```jsx
// Pull to Refresh
function PullToRefresh({ onRefresh, children }) {
  const [pulling, setPulling] = useState(false);
  const [pullDistance, setPullDistance] = useState(0);
  const threshold = 80;

  const handleTouchStart = (e) => {
    if (window.scrollY === 0) {
      setPulling(true);
    }
  };

  const handleTouchMove = (e) => {
    if (pulling && window.scrollY === 0) {
      const distance = e.touches[0].clientY - e.touches[0].target.getBoundingClientRect().top;
      setPullDistance(Math.min(distance, threshold * 1.5));
    }
  };

  const handleTouchEnd = () => {
    if (pullDistance >= threshold) {
      onRefresh();
    }
    setPulling(false);
    setPullDistance(0);
  };

  return (
    <div
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
    >
      {pullDistance > 0 && (
        <div className="pull-indicator" style={{ height: pullDistance }}>
          {pullDistance >= threshold ? '↻ Release to refresh' : '↓ Pull to refresh'}
        </div>
      )}
      {children}
    </div>
  );
}
```

### Pinch and Spread (Zoom)

Used for:
- Image galleries
- Maps
- PDF viewers
- Any zoomable content

```jsx
// React: Pinch to Zoom
function PinchZoomImage({ src, alt }) {
  const [scale, setScale] = useState(1);
  const [lastScale, setLastScale] = useState(1);

  const handleTouchMove = (e) => {
    if (e.touches.length === 2) {
      e.preventDefault();

      const touch1 = e.touches[0];
      const touch2 = e.touches[1];

      const distance = Math.hypot(
        touch1.clientX - touch2.clientX,
        touch1.clientY - touch2.clientY
      );

      if (lastDistance) {
        const newScale = lastScale * (distance / lastDistance);
        setScale(Math.max(1, Math.min(newScale, 4))); // Limit 1x to 4x
      }

      lastDistance = distance;
    }
  };

  const handleTouchEnd = () => {
    setLastScale(scale);
    lastDistance = null;
  };

  let lastDistance = null;

  return (
    <div
      className="pinch-zoom-container"
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
    >
      <img
        src={src}
        alt={alt}
        style={{
          transform: `scale(${scale})`,
          transition: lastDistance ? 'none' : 'transform 0.2s',
        }}
      />
    </div>
  );
}
```

### Long Press

Used for:
- Context menus
- Item selection mode
- Drag-and-drop initiation
- Additional options

```jsx
// React: Long Press Handler
function useLongPress(callback, ms = 500) {
  const [startLongPress, setStartLongPress] = useState(false);

  useEffect(() => {
    let timerId;
    if (startLongPress) {
      timerId = setTimeout(callback, ms);
    } else {
      clearTimeout(timerId);
    }

    return () => {
      clearTimeout(timerId);
    };
  }, [startLongPress, callback, ms]);

  return {
    onTouchStart: () => setStartLongPress(true),
    onTouchEnd: () => setStartLongPress(false),
    onTouchMove: () => setStartLongPress(false),
  };
}

// Usage
function LongPressItem({ item }) {
  const longPressProps = useLongPress(() => {
    console.log('Long press detected!');
    // Show context menu
  }, 500);

  return (
    <div {...longPressProps} className="long-press-item">
      {item.name}
    </div>
  );
}
```

### Drag and Drop

```jsx
// React Native: Drag and Drop
import { PanResponder, Animated } from 'react-native';

function DraggableCard({ children }) {
  const pan = useRef(new Animated.ValueXY()).current;

  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onPanResponderGrant: () => {
        pan.setOffset({
          x: pan.x._value,
          y: pan.y._value,
        });
      },
      onPanResponderMove: Animated.event(
        [null, { dx: pan.x, dy: pan.y }],
        { useNativeDriver: false }
      ),
      onPanResponderRelease: () => {
        pan.flattenOffset();
        Animated.spring(pan, {
          toValue: { x: 0, y: 0 },
          useNativeDriver: true,
        }).start();
      },
    })
  ).current;

  return (
    <Animated.View
      {...panResponder.panHandlers}
      style={{
        transform: [{ translateX: pan.x }, { translateY: pan.y }],
      }}
    >
      {children}
    </Animated.View>
  );
}
```

## Navigation Patterns

### Tab Bar Navigation

**Bottom Tab Bar** (iOS standard, Android common):

```jsx
// React Native: Bottom Tab Navigation
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import Icon from 'react-native-vector-icons/Ionicons';

const Tab = createBottomTabNavigator();

function AppNavigator() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName;

          if (route.name === 'Home') {
            iconName = focused ? 'home' : 'home-outline';
          } else if (route.name === 'Search') {
            iconName = focused ? 'search' : 'search-outline';
          } else if (route.name === 'Profile') {
            iconName = focused ? 'person' : 'person-outline';
          }

          return <Icon name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: '#007AFF',
        tabBarInactiveTintColor: '#8E8E93',
        tabBarStyle: {
          height: 88, // Account for safe area
          paddingBottom: 34, // iPhone home indicator
        },
      })}
    >
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Search" component={SearchScreen} />
      <Tab.Screen name="Profile" component={ProfileScreen} />
    </Tab.Navigator>
  );
}
```

**Best Practices:**
- 3-5 tabs maximum
- Always show labels (don't rely on icons alone)
- Highlight active tab clearly
- Keep tabs visible at all times
- Most important section on the left (for LTR languages)

### Hamburger Menu (Drawer Navigation)

```jsx
// React Native: Drawer Navigation
import { createDrawerNavigator } from '@react-navigation/drawer';

const Drawer = createDrawerNavigator();

function DrawerNavigator() {
  return (
    <Drawer.Navigator
      screenOptions={{
        drawerPosition: 'left',
        drawerType: 'slide',
        drawerStyle: {
          width: 280,
        },
        headerShown: true,
      }}
    >
      <Drawer.Screen
        name="Home"
        component={HomeScreen}
        options={{
          drawerIcon: ({ color, size }) => (
            <Icon name="home-outline" color={color} size={size} />
          ),
        }}
      />
      <Drawer.Screen
        name="Settings"
        component={SettingsScreen}
        options={{
          drawerIcon: ({ color, size }) => (
            <Icon name="settings-outline" color={color} size={size} />
          ),
        }}
      />
    </Drawer.Navigator>
  );
}
```

**When to Use:**
- Secondary navigation
- Many navigation options (6+)
- Infrequently accessed features
- Settings and account options

**Avoid When:**
- Primary navigation is needed
- User needs quick access to all sections
- You have 5 or fewer main sections (use tabs instead)

### Bottom Sheets and Modals

**Bottom Sheet** (Material Design):

```jsx
// React: Bottom Sheet
function BottomSheet({ isOpen, onClose, children }) {
  const [startY, setStartY] = useState(0);
  const [currentY, setCurrentY] = useState(0);

  const handleTouchStart = (e) => {
    setStartY(e.touches[0].clientY);
  };

  const handleTouchMove = (e) => {
    const delta = e.touches[0].clientY - startY;
    if (delta > 0) { // Only allow downward drag
      setCurrentY(delta);
    }
  };

  const handleTouchEnd = () => {
    if (currentY > 100) { // Threshold for closing
      onClose();
    }
    setCurrentY(0);
  };

  if (!isOpen) return null;

  return (
    <>
      <div className="bottom-sheet-backdrop" onClick={onClose} />
      <div
        className="bottom-sheet"
        style={{ transform: `translateY(${currentY}px)` }}
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
      >
        <div className="bottom-sheet-handle" />
        <div className="bottom-sheet-content">
          {children}
        </div>
      </div>
    </>
  );
}

// CSS
.bottom-sheet-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 999;
}

.bottom-sheet {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  border-radius: 20px 20px 0 0;
  padding: 16px;
  max-height: 80vh;
  z-index: 1000;
  transition: transform 0.3s;
}

.bottom-sheet-handle {
  width: 40px;
  height: 4px;
  background: #D1D1D6;
  border-radius: 2px;
  margin: 8px auto 16px;
}
```

**Full-Screen Modal:**

```jsx
// iOS-style modal with slide-up animation
function Modal({ isOpen, onClose, children }) {
  if (!isOpen) return null;

  return (
    <div className="modal-overlay">
      <div className="modal-container">
        <div className="modal-header">
          <button onClick={onClose} className="modal-close">
            Done
          </button>
        </div>
        <div className="modal-content">
          {children}
        </div>
      </div>
    </div>
  );
}

// CSS
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 1000;
  animation: fadeIn 0.3s;
}

.modal-container {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: white;
  animation: slideUp 0.3s;
}

@keyframes slideUp {
  from {
    transform: translateY(100%);
  }
  to {
    transform: translateY(0);
  }
}
```

### Stack Navigation

```jsx
// React Navigation: Stack Navigator
import { createStackNavigator } from '@react-navigation/stack';

const Stack = createStackNavigator();

function StackNavigator() {
  return (
    <Stack.Navigator
      screenOptions={{
        headerStyle: {
          backgroundColor: '#007AFF',
        },
        headerTintColor: '#fff',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
        cardStyleInterpolator: ({ current, layouts }) => {
          return {
            cardStyle: {
              transform: [
                {
                  translateX: current.progress.interpolate({
                    inputRange: [0, 1],
                    outputRange: [layouts.screen.width, 0],
                  }),
                },
              ],
            },
          };
        },
      }}
    >
      <Stack.Screen name="List" component={ListScreen} />
      <Stack.Screen name="Details" component={DetailsScreen} />
      <Stack.Screen name="Edit" component={EditScreen} />
    </Stack.Navigator>
  );
}
```

## Mobile UI Components

### Cards

**Material Design Card:**

```jsx
function Card({ image, title, subtitle, description, actions }) {
  return (
    <div className="card">
      {image && (
        <div className="card-media">
          <img src={image} alt={title} />
        </div>
      )}

      <div className="card-content">
        <h3 className="card-title">{title}</h3>
        {subtitle && <p className="card-subtitle">{subtitle}</p>}
        <p className="card-description">{description}</p>
      </div>

      {actions && (
        <div className="card-actions">
          {actions}
        </div>
      )}
    </div>
  );
}

// CSS
.card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  margin-bottom: 16px;
}

.card-media img {
  width: 100%;
  height: 200px;
  object-fit: cover;
}

.card-content {
  padding: 16px;
}

.card-title {
  font-size: 20px;
  font-weight: 600;
  margin: 0 0 8px 0;
}

.card-subtitle {
  font-size: 14px;
  color: #666;
  margin: 0 0 8px 0;
}

.card-description {
  font-size: 14px;
  line-height: 1.5;
  color: #333;
}

.card-actions {
  padding: 8px 16px 16px;
  display: flex;
  gap: 8px;
}
```

### Lists

**iOS-Style List:**

```jsx
function IOSList({ items, onItemPress }) {
  return (
    <div className="ios-list">
      {items.map((item, index) => (
        <div
          key={item.id}
          className="ios-list-item"
          onClick={() => onItemPress(item)}
        >
          {item.icon && (
            <div className="ios-list-icon">{item.icon}</div>
          )}

          <div className="ios-list-content">
            <div className="ios-list-title">{item.title}</div>
            {item.subtitle && (
              <div className="ios-list-subtitle">{item.subtitle}</div>
            )}
          </div>

          {item.badge && (
            <div className="ios-list-badge">{item.badge}</div>
          )}

          <div className="ios-list-chevron">›</div>
        </div>
      ))}
    </div>
  );
}

// CSS
.ios-list {
  background: white;
  border-radius: 12px;
  overflow: hidden;
}

.ios-list-item {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  min-height: 56px;
  border-bottom: 0.5px solid #E5E5EA;
  -webkit-tap-highlight-color: transparent;
}

.ios-list-item:active {
  background: #F2F2F7;
}

.ios-list-item:last-child {
  border-bottom: none;
}

.ios-list-icon {
  width: 32px;
  height: 32px;
  margin-right: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.ios-list-content {
  flex: 1;
}

.ios-list-title {
  font-size: 17px;
  color: #000;
}

.ios-list-subtitle {
  font-size: 15px;
  color: #8E8E93;
  margin-top: 2px;
}

.ios-list-badge {
  background: #FF3B30;
  color: white;
  font-size: 13px;
  font-weight: 600;
  padding: 2px 8px;
  border-radius: 12px;
  margin-right: 8px;
}

.ios-list-chevron {
  font-size: 24px;
  color: #C7C7CC;
}
```

### Forms

**Mobile-Optimized Form:**

```jsx
function MobileForm() {
  return (
    <form className="mobile-form">
      <div className="form-group">
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          inputMode="email"
          autoComplete="email"
          placeholder="you@example.com"
        />
      </div>

      <div className="form-group">
        <label htmlFor="phone">Phone</label>
        <input
          id="phone"
          type="tel"
          inputMode="tel"
          autoComplete="tel"
          placeholder="(555) 123-4567"
        />
      </div>

      <div className="form-group">
        <label htmlFor="amount">Amount</label>
        <input
          id="amount"
          type="number"
          inputMode="decimal"
          placeholder="0.00"
        />
      </div>

      <button type="submit" className="submit-button">
        Submit
      </button>
    </form>
  );
}

// CSS
.mobile-form {
  padding: 16px;
}

.form-group {
  margin-bottom: 24px;
}

.form-group label {
  display: block;
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 8px;
  color: #333;
}

.form-group input {
  width: 100%;
  height: 56px;
  padding: 16px;
  font-size: 16px; /* Prevents zoom on iOS */
  border: 2px solid #E5E5EA;
  border-radius: 12px;
  background: white;
  -webkit-appearance: none;
}

.form-group input:focus {
  outline: none;
  border-color: #007AFF;
}

.submit-button {
  width: 100%;
  height: 56px;
  background: #007AFF;
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 17px;
  font-weight: 600;
}
```

**Input Types for Mobile Keyboards:**

```html
<!-- Email keyboard -->
<input type="email" inputmode="email">

<!-- Numeric keyboard -->
<input type="number" inputmode="numeric">

<!-- Decimal keyboard (includes . and ,) -->
<input type="number" inputmode="decimal">

<!-- Telephone keyboard -->
<input type="tel" inputmode="tel">

<!-- URL keyboard (includes .com, /, etc.) -->
<input type="url" inputmode="url">

<!-- Search keyboard (includes search button) -->
<input type="search" inputmode="search">
```

### Action Sheets

```jsx
// iOS-style Action Sheet
function ActionSheet({ isOpen, onClose, title, options }) {
  if (!isOpen) return null;

  return (
    <>
      <div className="action-sheet-backdrop" onClick={onClose} />
      <div className="action-sheet">
        {title && <div className="action-sheet-title">{title}</div>}

        <div className="action-sheet-options">
          {options.map((option, index) => (
            <button
              key={index}
              className={`action-sheet-option ${option.destructive ? 'destructive' : ''}`}
              onClick={() => {
                option.onPress();
                onClose();
              }}
            >
              {option.icon && <span className="option-icon">{option.icon}</span>}
              {option.label}
            </button>
          ))}
        </div>

        <button className="action-sheet-cancel" onClick={onClose}>
          Cancel
        </button>
      </div>
    </>
  );
}

// CSS
.action-sheet {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: transparent;
  z-index: 1001;
  padding: 8px;
  animation: slideUp 0.3s;
}

.action-sheet-title {
  background: rgba(255, 255, 255, 0.95);
  padding: 16px;
  text-align: center;
  border-radius: 14px 14px 0 0;
  font-size: 13px;
  color: #8E8E93;
}

.action-sheet-options {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 14px;
  overflow: hidden;
  margin-bottom: 8px;
}

.action-sheet-option {
  width: 100%;
  padding: 16px;
  background: transparent;
  border: none;
  border-bottom: 0.5px solid #E5E5EA;
  font-size: 20px;
  color: #007AFF;
  -webkit-tap-highlight-color: transparent;
}

.action-sheet-option:active {
  background: rgba(0, 0, 0, 0.05);
}

.action-sheet-option.destructive {
  color: #FF3B30;
}

.action-sheet-cancel {
  width: 100%;
  padding: 16px;
  background: rgba(255, 255, 255, 0.95);
  border: none;
  border-radius: 14px;
  font-size: 20px;
  font-weight: 600;
  color: #007AFF;
}
```

## Platform Conventions

### iOS Human Interface Guidelines

**Navigation Bar:**
- Height: 44pt (plus status bar)
- Large title: 52pt collapsible header
- Back button always shows previous screen title
- Right-aligned action buttons

**Tab Bar:**
- Height: 49pt (plus safe area)
- 5 tabs maximum
- Badge notifications on tab icons
- Selected tab uses accent color

**Typography:**
- SF Pro (system font)
- Dynamic Type support required
- Font sizes: 11pt to 34pt
- Weight hierarchy: Regular, Medium, Semibold, Bold

**Colors:**
- System colors adapt to light/dark mode
- Blue (#007AFF) for tappable elements
- Red (#FF3B30) for destructive actions
- Semantic colors: label, secondaryLabel, tertiaryLabel

**Spacing:**
- Minimum margins: 16pt
- Standard spacing: 8pt, 16pt, 24pt, 32pt
- Component padding: 16pt horizontal, 12pt vertical

```swift
// SwiftUI: iOS Navigation
struct ContentView: View {
    var body: some View {
        NavigationView {
            List(items) { item in
                NavigationLink(destination: DetailView(item: item)) {
                    HStack {
                        Image(systemName: item.icon)
                            .foregroundColor(.accentColor)

                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.headline)
                            Text(item.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Items")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
```

### Material Design (Android)

**App Bar:**
- Height: 56dp (64dp for tablets)
- Elevation: 4dp
- Hamburger icon or back arrow on left
- Title centered or left-aligned
- Action icons on right (max 3)

**Bottom Navigation:**
- Height: 56dp
- 3-5 destinations
- Icons with text labels
- Active indicator

**FAB (Floating Action Button):**
- Size: 56×56dp (regular), 40×40dp (mini)
- Position: 16dp from edges
- Primary action only
- Extended FAB includes text label

**Typography:**
- Roboto font family
- Scale: 12sp to 96sp
- Line height: 1.5× font size
- Letter spacing varies by size

**Elevation:**
- Shadow depth indicates hierarchy
- 0dp: flat surface
- 1-8dp: raised components
- 16-24dp: modals and dialogs

**Spacing:**
- 4dp grid system
- Keylines: 16dp, 72dp from edges
- Component spacing: 8dp, 16dp, 24dp

```kotlin
// Jetpack Compose: Material Design
@Composable
fun MaterialCard(item: Item) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                text = item.title,
                style = MaterialTheme.typography.headlineSmall
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = item.description,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            Spacer(modifier = Modifier.height(16.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.End
            ) {
                TextButton(onClick = { /* Action */ }) {
                    Text("ACTION")
                }
            }
        }
    }
}
```

## Accessibility

### Touch Target Sizes

**WCAG 2.1 Level AAA:**
- Minimum: 44×44 pixels
- Recommended: 48×48 pixels or larger
- Spacing: 8px minimum between targets

```jsx
// Accessible button component
function AccessibleButton({ children, onPress, variant = 'primary' }) {
  return (
    <button
      className={`accessible-button ${variant}`}
      onClick={onPress}
      style={{
        minWidth: '48px',
        minHeight: '48px',
        padding: '12px 24px',
      }}
    >
      {children}
    </button>
  );
}
```

### Screen Reader Support

**Semantic HTML:**

```jsx
function AccessibleMobileNav() {
  return (
    <nav role="navigation" aria-label="Main navigation">
      <ul>
        <li>
          <a href="/home" aria-current="page">
            <Icon name="home" aria-hidden="true" />
            <span>Home</span>
          </a>
        </li>
        <li>
          <a href="/search">
            <Icon name="search" aria-hidden="true" />
            <span>Search</span>
          </a>
        </li>
      </ul>
    </nav>
  );
}
```

**React Native Accessibility:**

```jsx
import { View, Text, TouchableOpacity } from 'react-native';

function AccessibleCard({ title, description, onPress }) {
  return (
    <TouchableOpacity
      accessible={true}
      accessibilityLabel={`${title}. ${description}`}
      accessibilityRole="button"
      accessibilityHint="Double tap to view details"
      onPress={onPress}
    >
      <View>
        <Text>{title}</Text>
        <Text>{description}</Text>
      </View>
    </TouchableOpacity>
  );
}
```

### Color Contrast

**WCAG AA Requirements:**
- Normal text: 4.5:1 contrast ratio
- Large text (18pt+): 3:1 contrast ratio
- UI components: 3:1 contrast ratio

```css
/* Good contrast examples */
.primary-button {
  background: #0066CC; /* Blue */
  color: #FFFFFF; /* White - 6.4:1 ratio */
}

.secondary-button {
  background: #FFFFFF; /* White */
  color: #333333; /* Dark gray - 12.6:1 ratio */
  border: 2px solid #333333;
}

/* Bad contrast (avoid) */
.bad-button {
  background: #FFCC00; /* Yellow */
  color: #FFFFFF; /* White - 1.4:1 ratio ❌ */
}
```

### Focus Indicators

```css
/* Visible focus states for keyboard navigation */
button:focus-visible {
  outline: 3px solid #007AFF;
  outline-offset: 2px;
}

input:focus-visible {
  border-color: #007AFF;
  box-shadow: 0 0 0 4px rgba(0, 122, 255, 0.2);
}

/* Remove default focus ring, add custom */
*:focus {
  outline: none;
}

*:focus-visible {
  outline: 3px solid #007AFF;
  outline-offset: 2px;
}
```

## Performance

### Image Optimization

**Responsive Images:**

```html
<!-- Serve different sizes based on screen width -->
<img
  src="image-800w.jpg"
  srcset="
    image-400w.jpg 400w,
    image-800w.jpg 800w,
    image-1200w.jpg 1200w
  "
  sizes="
    (max-width: 480px) 100vw,
    (max-width: 768px) 50vw,
    33vw
  "
  alt="Product image"
  loading="lazy"
>

<!-- WebP with fallback -->
<picture>
  <source srcset="image.webp" type="image/webp">
  <source srcset="image.jpg" type="image/jpeg">
  <img src="image.jpg" alt="Fallback image">
</picture>
```

**Lazy Loading:**

```jsx
// React: Intersection Observer for lazy loading
function LazyImage({ src, alt }) {
  const [isLoaded, setIsLoaded] = useState(false);
  const [isInView, setIsInView] = useState(false);
  const imgRef = useRef();

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsInView(true);
          observer.disconnect();
        }
      },
      { rootMargin: '50px' }
    );

    if (imgRef.current) {
      observer.observe(imgRef.current);
    }

    return () => observer.disconnect();
  }, []);

  return (
    <div ref={imgRef} className="lazy-image-container">
      {!isLoaded && <div className="skeleton-loader" />}
      {isInView && (
        <img
          src={src}
          alt={alt}
          onLoad={() => setIsLoaded(true)}
          style={{ opacity: isLoaded ? 1 : 0 }}
        />
      )}
    </div>
  );
}
```

### Loading Strategies

**Skeleton Screens:**

```jsx
function SkeletonCard() {
  return (
    <div className="skeleton-card">
      <div className="skeleton skeleton-image" />
      <div className="skeleton skeleton-title" />
      <div className="skeleton skeleton-text" />
      <div className="skeleton skeleton-text short" />
    </div>
  );
}

// CSS
.skeleton {
  background: linear-gradient(
    90deg,
    #f0f0f0 25%,
    #e0e0e0 50%,
    #f0f0f0 75%
  );
  background-size: 200% 100%;
  animation: loading 1.5s infinite;
}

@keyframes loading {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}

.skeleton-image {
  height: 200px;
  border-radius: 8px 8px 0 0;
}

.skeleton-title {
  height: 24px;
  margin: 16px;
  border-radius: 4px;
}

.skeleton-text {
  height: 16px;
  margin: 8px 16px;
  border-radius: 4px;
}

.skeleton-text.short {
  width: 60%;
}
```

**Progressive Web App (PWA):**

```javascript
// service-worker.js
const CACHE_NAME = 'mobile-app-v1';
const urlsToCache = [
  '/',
  '/styles/main.css',
  '/scripts/main.js',
  '/images/logo.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // Return cached version or fetch new
        return response || fetch(event.request);
      })
  );
});
```

### Performance Metrics

**Core Web Vitals for Mobile:**
- **LCP** (Largest Contentful Paint): < 2.5s
- **FID** (First Input Delay): < 100ms
- **CLS** (Cumulative Layout Shift): < 0.1

```javascript
// Measure performance
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    console.log(entry.name, entry.startTime);
  }
});

observer.observe({ entryTypes: ['navigation', 'paint', 'largest-contentful-paint'] });
```

## Responsive Breakpoints

### Common Device Widths

```css
/* iPhone SE (2022) */
@media (min-width: 375px) and (max-width: 667px) {
  /* Small phone styles */
}

/* iPhone 12/13/14 Pro */
@media (min-width: 390px) and (max-width: 844px) {
  /* Standard phone styles */
}

/* iPhone 14 Pro Max */
@media (min-width: 428px) and (max-width: 926px) {
  /* Large phone styles */
}

/* iPad Mini */
@media (min-width: 768px) and (max-width: 1024px) {
  /* Tablet styles */
}

/* iPad Pro */
@media (min-width: 1024px) and (max-width: 1366px) {
  /* Large tablet styles */
}
```

### Orientation-Specific Styles

```css
/* Portrait mode */
@media (orientation: portrait) {
  .container {
    flex-direction: column;
  }
}

/* Landscape mode */
@media (orientation: landscape) {
  .container {
    flex-direction: row;
  }

  .sidebar {
    width: 300px;
  }
}

/* Prevent layout shift on keyboard open */
@media (max-height: 500px) {
  .bottom-nav {
    display: none;
  }
}
```

### Container Queries (Modern Approach)

```css
/* Component adapts to container size, not viewport */
.card-container {
  container-type: inline-size;
}

@container (min-width: 400px) {
  .card {
    display: grid;
    grid-template-columns: 1fr 2fr;
  }
}

@container (min-width: 600px) {
  .card {
    grid-template-columns: 1fr 1fr;
  }
}
```

## Examples

### 1. Mobile E-commerce Product List

```jsx
function ProductList({ products }) {
  return (
    <div className="product-list">
      {products.map((product) => (
        <div key={product.id} className="product-card">
          <div className="product-image-container">
            <img
              src={product.image}
              alt={product.name}
              loading="lazy"
            />
            {product.badge && (
              <span className="product-badge">{product.badge}</span>
            )}
          </div>

          <div className="product-info">
            <h3 className="product-name">{product.name}</h3>
            <p className="product-price">${product.price}</p>

            {product.rating && (
              <div className="product-rating">
                {'★'.repeat(product.rating)}
                {'☆'.repeat(5 - product.rating)}
                <span className="review-count">
                  ({product.reviewCount})
                </span>
              </div>
            )}
          </div>

          <button className="add-to-cart-btn">
            Add to Cart
          </button>
        </div>
      ))}
    </div>
  );
}

// CSS
.product-list {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  padding: 16px;
}

@media (min-width: 768px) {
  .product-list {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (min-width: 1024px) {
  .product-list {
    grid-template-columns: repeat(4, 1fr);
  }
}

.product-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.product-image-container {
  position: relative;
  aspect-ratio: 1;
  background: #f5f5f5;
}

.product-image-container img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.product-badge {
  position: absolute;
  top: 8px;
  right: 8px;
  background: #FF3B30;
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 600;
}

.product-info {
  padding: 12px;
}

.product-name {
  font-size: 14px;
  font-weight: 600;
  margin: 0 0 4px 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.product-price {
  font-size: 16px;
  font-weight: 700;
  color: #007AFF;
  margin: 0 0 8px 0;
}

.product-rating {
  font-size: 14px;
  color: #FFB800;
}

.review-count {
  color: #666;
  font-size: 12px;
  margin-left: 4px;
}

.add-to-cart-btn {
  width: 100%;
  height: 44px;
  background: #007AFF;
  color: white;
  border: none;
  font-size: 14px;
  font-weight: 600;
  -webkit-tap-highlight-color: transparent;
}

.add-to-cart-btn:active {
  background: #0051D5;
}
```

### 2. Infinite Scroll Feed

```jsx
function InfiniteFeed() {
  const [posts, setPosts] = useState([]);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const observerTarget = useRef(null);

  const loadMore = async () => {
    if (loading || !hasMore) return;

    setLoading(true);
    const newPosts = await fetchPosts(page);

    if (newPosts.length === 0) {
      setHasMore(false);
    } else {
      setPosts(prev => [...prev, ...newPosts]);
      setPage(prev => prev + 1);
    }

    setLoading(false);
  };

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting) {
          loadMore();
        }
      },
      { threshold: 0.5 }
    );

    if (observerTarget.current) {
      observer.observe(observerTarget.current);
    }

    return () => observer.disconnect();
  }, [loading, hasMore]);

  return (
    <div className="feed">
      {posts.map(post => (
        <FeedCard key={post.id} post={post} />
      ))}

      {loading && <LoadingSpinner />}

      <div ref={observerTarget} style={{ height: '20px' }} />

      {!hasMore && (
        <div className="feed-end">No more posts</div>
      )}
    </div>
  );
}
```

### 3. Mobile Search with Autocomplete

```jsx
function MobileSearch() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [isFocused, setIsFocused] = useState(false);
  const [recentSearches, setRecentSearches] = useState([]);

  const handleSearch = async (value) => {
    setQuery(value);

    if (value.length >= 2) {
      const searchResults = await fetchSearchResults(value);
      setResults(searchResults);
    } else {
      setResults([]);
    }
  };

  const handleSubmit = (searchQuery) => {
    // Save to recent searches
    const updated = [searchQuery, ...recentSearches.slice(0, 4)];
    setRecentSearches(updated);
    localStorage.setItem('recentSearches', JSON.stringify(updated));

    // Navigate to results
    window.location.href = `/search?q=${encodeURIComponent(searchQuery)}`;
  };

  return (
    <div className="mobile-search">
      <div className="search-bar">
        <input
          type="search"
          inputMode="search"
          placeholder="Search products..."
          value={query}
          onChange={(e) => handleSearch(e.target.value)}
          onFocus={() => setIsFocused(true)}
          onBlur={() => setTimeout(() => setIsFocused(false), 200)}
        />

        {query && (
          <button
            className="clear-button"
            onClick={() => {
              setQuery('');
              setResults([]);
            }}
          >
            ✕
          </button>
        )}
      </div>

      {isFocused && (
        <div className="search-dropdown">
          {query.length === 0 && recentSearches.length > 0 && (
            <div className="recent-searches">
              <h4>Recent Searches</h4>
              {recentSearches.map((search, index) => (
                <button
                  key={index}
                  className="search-suggestion"
                  onClick={() => handleSubmit(search)}
                >
                  <span className="icon">🕐</span>
                  {search}
                </button>
              ))}
            </div>
          )}

          {results.length > 0 && (
            <div className="search-results">
              {results.map((result) => (
                <button
                  key={result.id}
                  className="search-result-item"
                  onClick={() => handleSubmit(result.name)}
                >
                  <img src={result.thumbnail} alt="" />
                  <div>
                    <div className="result-name">{result.name}</div>
                    <div className="result-category">{result.category}</div>
                  </div>
                </button>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
```

### 4. Filter Drawer

```jsx
function FilterDrawer({ isOpen, onClose, onApply }) {
  const [filters, setFilters] = useState({
    priceRange: [0, 1000],
    category: [],
    rating: 0,
    inStock: false,
  });

  return (
    <>
      {isOpen && (
        <div className="filter-drawer-overlay" onClick={onClose} />
      )}

      <div className={`filter-drawer ${isOpen ? 'open' : ''}`}>
        <div className="filter-header">
          <h2>Filters</h2>
          <button onClick={onClose}>✕</button>
        </div>

        <div className="filter-content">
          <div className="filter-section">
            <h3>Price Range</h3>
            <input
              type="range"
              min="0"
              max="1000"
              value={filters.priceRange[1]}
              onChange={(e) => setFilters({
                ...filters,
                priceRange: [0, parseInt(e.target.value)]
              })}
            />
            <div className="price-display">
              ${filters.priceRange[0]} - ${filters.priceRange[1]}
            </div>
          </div>

          <div className="filter-section">
            <h3>Category</h3>
            {['Electronics', 'Clothing', 'Books', 'Home'].map(cat => (
              <label key={cat} className="checkbox-label">
                <input
                  type="checkbox"
                  checked={filters.category.includes(cat)}
                  onChange={(e) => {
                    if (e.target.checked) {
                      setFilters({
                        ...filters,
                        category: [...filters.category, cat]
                      });
                    } else {
                      setFilters({
                        ...filters,
                        category: filters.category.filter(c => c !== cat)
                      });
                    }
                  }}
                />
                {cat}
              </label>
            ))}
          </div>

          <div className="filter-section">
            <label className="checkbox-label">
              <input
                type="checkbox"
                checked={filters.inStock}
                onChange={(e) => setFilters({
                  ...filters,
                  inStock: e.target.checked
                })}
              />
              In Stock Only
            </label>
          </div>
        </div>

        <div className="filter-actions">
          <button
            className="clear-button"
            onClick={() => setFilters({
              priceRange: [0, 1000],
              category: [],
              rating: 0,
              inStock: false,
            })}
          >
            Clear All
          </button>

          <button
            className="apply-button"
            onClick={() => {
              onApply(filters);
              onClose();
            }}
          >
            Apply Filters
          </button>
        </div>
      </div>
    </>
  );
}

// CSS
.filter-drawer {
  position: fixed;
  right: -100%;
  top: 0;
  bottom: 0;
  width: 85%;
  max-width: 400px;
  background: white;
  z-index: 1001;
  transition: right 0.3s;
  display: flex;
  flex-direction: column;
}

.filter-drawer.open {
  right: 0;
}

.filter-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-bottom: 1px solid #E5E5EA;
}

.filter-content {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
}

.filter-section {
  margin-bottom: 24px;
}

.filter-section h3 {
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 12px;
}

.checkbox-label {
  display: flex;
  align-items: center;
  padding: 12px 0;
  font-size: 15px;
}

.checkbox-label input {
  margin-right: 12px;
  width: 20px;
  height: 20px;
}

.filter-actions {
  display: flex;
  gap: 12px;
  padding: 16px;
  border-top: 1px solid #E5E5EA;
}

.clear-button,
.apply-button {
  flex: 1;
  height: 48px;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
}

.clear-button {
  background: white;
  border: 2px solid #007AFF;
  color: #007AFF;
}

.apply-button {
  background: #007AFF;
  border: none;
  color: white;
}
```

### 5. Mobile Payment Form

```jsx
function MobilePaymentForm() {
  const [cardNumber, setCardNumber] = useState('');
  const [expiry, setExpiry] = useState('');
  const [cvv, setCvv] = useState('');

  const formatCardNumber = (value) => {
    return value
      .replace(/\s/g, '')
      .match(/.{1,4}/g)
      ?.join(' ') || '';
  };

  const formatExpiry = (value) => {
    const cleaned = value.replace(/\D/g, '');
    if (cleaned.length >= 2) {
      return `${cleaned.slice(0, 2)}/${cleaned.slice(2, 4)}`;
    }
    return cleaned;
  };

  return (
    <form className="payment-form">
      <div className="form-group">
        <label>Card Number</label>
        <input
          type="text"
          inputMode="numeric"
          maxLength="19"
          placeholder="1234 5678 9012 3456"
          value={formatCardNumber(cardNumber)}
          onChange={(e) => setCardNumber(e.target.value.replace(/\s/g, ''))}
        />
      </div>

      <div className="form-row">
        <div className="form-group">
          <label>Expiry</label>
          <input
            type="text"
            inputMode="numeric"
            maxLength="5"
            placeholder="MM/YY"
            value={expiry}
            onChange={(e) => setExpiry(formatExpiry(e.target.value))}
          />
        </div>

        <div className="form-group">
          <label>CVV</label>
          <input
            type="text"
            inputMode="numeric"
            maxLength="4"
            placeholder="123"
            value={cvv}
            onChange={(e) => setCvv(e.target.value.replace(/\D/g, ''))}
          />
        </div>
      </div>

      <button type="submit" className="pay-button">
        Pay $99.99
      </button>
    </form>
  );
}
```

### 6-20. Additional Examples

For brevity, here are summaries of 14 more essential mobile design patterns:

**6. Sticky Header with Scroll Progress**
- Header shrinks on scroll
- Progress bar shows reading position
- Back-to-top button appears after scroll

**7. Image Gallery with Pinch Zoom**
- Full-screen image viewer
- Swipe between images
- Pinch to zoom functionality

**8. Mobile-Optimized Data Table**
- Horizontal scroll with sticky first column
- Card view on small screens
- Expandable rows for details

**9. Bottom Sheet Menu**
- Swipe up to expand
- Drag to dismiss
- Multiple snap points (collapsed, half, full)

**10. Mobile Calendar Picker**
- Month view optimized for touch
- Date range selection
- Quick actions (Today, Tomorrow, Next Week)

**11. Floating Action Button (FAB) with Speed Dial**
- Primary action always visible
- Expands to show related actions
- Smooth animations

**12. Pull to Refresh**
- Custom loading animation
- Haptic feedback
- Success/error states

**13. Swipeable Tabs**
- Horizontal scroll tabs
- Active tab indicator
- Snap to tab on scroll

**14. Mobile Video Player**
- Custom controls optimized for touch
- Picture-in-picture mode
- Gesture controls (tap to pause, double-tap to skip)

**15. Mobile Toast Notifications**
- Non-intrusive messaging
- Auto-dismiss with manual override
- Action buttons

**16. Collapsible Accordion**
- Touch-friendly expand/collapse
- Smooth animations
- Multiple sections

**17. Mobile Stepper Form**
- Multi-step process
- Progress indicator
- Back/Next navigation

**18. Voice Input Interface**
- Microphone button
- Real-time transcription
- Voice feedback

**19. Onboarding Carousel**
- Swipeable introduction screens
- Skip option
- Progress dots

**20. Mobile Share Sheet**
- Native-like sharing interface
- Common share targets
- Copy link functionality

---

## Conclusion

Mobile design requires deep understanding of touch interactions, platform conventions, and performance optimization. By following mobile-first principles, respecting thumb zones, and implementing platform-appropriate patterns, you create experiences that feel natural and performant on mobile devices.

Remember: mobile users are often on-the-go, have limited attention, and expect instant responsiveness. Prioritize speed, clarity, and ease of use above all else.
