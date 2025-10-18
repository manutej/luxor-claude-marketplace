# Mobile App Development Workflow

Complete workflow for managing a Flutter/React Native mobile app project in Linear.

## Project: Chat Application (iOS + Android)

### Initial Project Setup

```
Tool: create_project

Parameters:
name: "Chatz - Mobile Chat App"
team: "Mobile"
summary: "WhatsApp-inspired chat app with voice/video calls and microtransaction system"
description: |
  # Chatz Mobile App

  ## Overview
  A modern chat application for iOS and Android with the following features:
  - Real-time messaging
  - Voice and video calls (pay-per-minute with Agora)
  - International phone authentication
  - Group chats
  - Media sharing (photos, videos, documents)
  - End-to-end encryption

  ## Tech Stack
  - Flutter for cross-platform development
  - Firebase for authentication and real-time database
  - Agora SDK for voice/video calls
  - Stripe for payment processing
  - Firebase Cloud Messaging for push notifications

  ## Platforms
  - iOS 14+ (iPhone, iPad)
  - Android 8.0+ (phones and tablets)

  ## Development Phases
  1. **Phase 1**: Core messaging (Weeks 1-4)
  2. **Phase 2**: Voice/Video calls (Weeks 5-7)
  3. **Phase 3**: Payment integration (Weeks 8-9)
  4. **Phase 4**: Polish & Testing (Weeks 10-12)

  ## Success Criteria
  - App Store and Play Store submission ready
  - < 100ms message latency
  - 99.9% call connection success rate
  - Payment success rate > 95%
  - 5-star rating average in beta testing

lead: "me"
priority: 1
startDate: "2025-01-15"
targetDate: "2025-04-15"
labels: ["mobile", "flutter", "ios", "android"]
```

## Phase 1: Core Messaging Features

### Epic: Authentication System

```
Tool: create_issue

Parent Issue:
title: "[EPIC] Phone Authentication & User Management"
team: "Mobile"
description: |
  ## Features
  - Phone number entry with country code picker
  - SMS OTP verification
  - User profile creation
  - Profile photo upload
  - Contact sync and permissions

  ## Design
  Figma: [link]

  ## Platform Considerations
  - iOS: Handle App Store review requirements
  - Android: Handle SMS permissions properly
project: "Chatz - Mobile Chat App"
labels: ["epic", "auth", "mobile"]
priority: 1
```

### Child Issues for Authentication

```
Issue 1: Phone Input Screen
title: "[iOS/Android] Phone number input screen"
team: "Mobile"
description: |
  ## Tasks
  - [ ] Create PhoneInputScreen widget
  - [ ] Implement country code picker
  - [ ] Add phone number formatting
  - [ ] Input validation
  - [ ] Handle iOS keyboard properly
  - [ ] Test on various Android devices

  ## Platform-Specific
  - iOS: Match iOS design guidelines
  - Android: Material Design compliance

  ## Acceptance Criteria
  - Works on iOS 14+
  - Works on Android 8.0+
  - Proper keyboard handling on both platforms
  - Accessibility labels
parentId: "[auth-epic-id]"
assignee: "mobile-dev-1"
project: "Chatz - Mobile Chat App"
labels: ["mobile", "flutter", "ui", "ios", "android"]
priority: 1
```

```
Issue 2: SMS OTP Verification
title: "[Backend + Mobile] SMS verification implementation"
team: "Mobile"
description: |
  ## Tasks
  - [ ] Integrate Firebase Auth
  - [ ] Implement SMS sending
  - [ ] Create OTP input screen
  - [ ] Auto-read SMS on Android
  - [ ] Manual entry on iOS
  - [ ] Handle verification errors
  - [ ] Implement retry logic

  ## Platform Testing
  - Test on real iOS devices
  - Test on real Android devices
  - Test with different carriers
  - Test in different regions

  ## Acceptance Criteria
  - OTP arrives within 10 seconds
  - Auto-read works on Android
  - Clear error messages
  - Resend OTP functionality
parentId: "[auth-epic-id]"
assignee: "mobile-dev-1"
project: "Chatz - Mobile Chat App"
labels: ["mobile", "flutter", "auth", "backend"]
priority: 1
links: [
  {
    url: "https://firebase.google.com/docs/auth/flutter/phone-auth",
    title: "Firebase Phone Auth Documentation"
  }
]
```

### Epic: Real-Time Messaging

```
Tool: create_issue

Parent Issue:
title: "[EPIC] Real-Time Messaging System"
team: "Mobile"
description: |
  ## Features
  - One-on-one chat
  - Real-time message sync
  - Message status (sent, delivered, read)
  - Typing indicators
  - Message reactions
  - Reply to messages
  - Forward messages

  ## Technical Requirements
  - Firebase Realtime Database for messages
  - Local caching with sqflite
  - Optimistic UI updates
  - Background sync

  ## Acceptance Criteria
  - Messages appear instantly
  - Works offline with queue
  - Battery efficient
  - Handles 1000+ messages per chat
project: "Chatz - Mobile Chat App"
labels: ["epic", "messaging", "mobile"]
priority: 1
```

### Child Issues for Messaging

```
Issue 1: Chat List Screen
title: "[iOS/Android] Chat list screen with real-time updates"
team: "Mobile"
description: |
  ## Tasks
  - [ ] Create ChatListScreen widget
  - [ ] Implement chat list tile
  - [ ] Real-time updates from Firebase
  - [ ] Unread message badges
  - [ ] Last message preview
  - [ ] Swipe actions (iOS style, Android style)
  - [ ] Pull to refresh
  - [ ] Empty state design

  ## Performance
  - Lazy loading for 100+ chats
  - Efficient list rebuilding
  - Image caching

  ## Platform Differences
  - iOS: Swipe to delete/archive
  - Android: Long press context menu

  ## Acceptance Criteria
  - Smooth scrolling with 500+ chats
  - Real-time updates without lag
  - Proper platform conventions
parentId: "[messaging-epic-id]"
assignee: "mobile-dev-2"
project: "Chatz - Mobile Chat App"
labels: ["mobile", "flutter", "ui", "ios", "android"]
priority: 1
```

```
Issue 2: Chat Screen Implementation
title: "[iOS/Android] Individual chat screen"
team: "Mobile"
description: |
  ## Tasks
  - [ ] Create ChatScreen widget
  - [ ] Message bubbles (sent/received)
  - [ ] Timestamp display
  - [ ] Message status indicators
  - [ ] Input field with attachment button
  - [ ] Emoji keyboard
  - [ ] Scroll to bottom behavior
  - [ ] Load more messages on scroll up

  ## Message Features
  - [ ] Copy message
  - [ ] Reply to message
  - [ ] Forward message
  - [ ] Delete message
  - [ ] React to message

  ## Platform-Specific
  - iOS: Native keyboard handling
  - Android: Custom keyboard toolbar

  ## Acceptance Criteria
  - Handles 10,000+ messages smoothly
  - Optimistic updates work correctly
  - Proper keyboard behavior
  - Works in landscape mode
parentId: "[messaging-epic-id]"
assignee: "mobile-dev-2"
project: "Chatz - Mobile Chat App"
labels: ["mobile", "flutter", "messaging", "ui"]
priority: 1
```

## Phase 2: Voice/Video Calls

### Platform-Specific Issues

```
Issue: iOS Call Integration
title: "[iOS] CallKit integration for native call experience"
team: "Mobile"
description: |
  ## Overview
  Integrate CallKit for native iOS calling experience

  ## Tasks
  - [ ] Setup CallKit provider
  - [ ] Handle incoming call UI
  - [ ] Lock screen call interface
  - [ ] Call history in iOS phone app
  - [ ] Handle interruptions
  - [ ] Background call handling

  ## Apple Requirements
  - [ ] VoIP push notifications
  - [ ] Proper Info.plist permissions
  - [ ] App Store review compliance

  ## Testing
  - Test on various iOS versions (14, 15, 16, 17)
  - Test with AirPods, Bluetooth
  - Test during other calls
  - Test with Do Not Disturb

  ## Acceptance Criteria
  - Native iOS call experience
  - Works with locked screen
  - Proper audio routing
  - App Store compliant
assignee: "ios-specialist"
project: "Chatz - Mobile Chat App"
labels: ["mobile", "ios", "calls", "platform-specific"]
priority: 1
```

```
Issue: Android Call Integration
title: "[Android] ConnectionService integration for native calls"
team: "Mobile"
description: |
  ## Overview
  Integrate ConnectionService for native Android calling

  ## Tasks
  - [ ] Implement ConnectionService
  - [ ] Full-screen incoming call UI
  - [ ] Lock screen call interface
  - [ ] Call logs integration
  - [ ] Handle Bluetooth audio
  - [ ] Background call handling

  ## Android-Specific
  - [ ] Request proper permissions
  - [ ] Handle battery optimization
  - [ ] Foreground service for active calls

  ## Testing
  - Test on different Android versions (8-14)
  - Test on various manufacturers (Samsung, Pixel, OnePlus)
  - Test with Bluetooth devices
  - Test battery drain

  ## Acceptance Criteria
  - Native Android call experience
  - Works with locked screen
  - Appears in call logs
  - Battery efficient
assignee: "android-specialist"
project: "Chatz - Mobile Chat App"
labels: ["mobile", "android", "calls", "platform-specific"]
priority: 1
```

## Bug Tracking Workflow

### Creating a Bug Report

```
Tool: create_issue

Bug Example:
title: "[BUG][iOS] Messages not syncing in background"
team: "Mobile"
description: |
  ## Bug Description
  Messages received while app is in background don't appear until app is opened

  ## Environment
  - Platform: iOS
  - iOS Version: 16.5
  - Device: iPhone 14 Pro
  - App Version: 0.8.2 (build 45)

  ## Steps to Reproduce
  1. Open app and log in
  2. Have active chat conversation
  3. Put app in background (home button)
  4. Have someone send you messages
  5. Wait 30 seconds
  6. Open app again
  7. Messages appear only after opening

  ## Expected Behavior
  - Background fetch should sync new messages
  - Push notification should trigger sync
  - Messages should be ready when app opens

  ## Actual Behavior
  - Messages only sync when app opens
  - 2-5 second delay before messages appear
  - Push notification arrives but no data sync

  ## Additional Context
  - Works correctly on Android
  - Background fetch is enabled in settings
  - Push notifications work for other events

  ## Screenshots
  [Attach screenshots]

  ## Logs
  ```
  [Paste relevant logs]
  ```
labels: ["bug", "ios", "messaging", "background-sync"]
priority: 1
assignee: "ios-specialist"
project: "Chatz - Mobile Chat App"
```

## Testing and QA Workflow

### Creating Test Issues

```
Tool: create_issue

Test Plan Issue:
title: "[QA] iOS App Store submission testing checklist"
team: "Mobile"
description: |
  ## Pre-Submission Testing

  ### Functionality
  - [ ] All features work on iOS 14, 15, 16, 17
  - [ ] Tested on iPhone SE, 13, 14, 15
  - [ ] Tested on iPad
  - [ ] Landscape mode works
  - [ ] Dark mode works correctly
  - [ ] All localizations tested

  ### Permissions
  - [ ] Camera permission flow
  - [ ] Microphone permission flow
  - [ ] Photo library permission
  - [ ] Contacts permission
  - [ ] Notifications permission
  - [ ] All permission messages clear

  ### App Store Requirements
  - [ ] Privacy policy linked
  - [ ] Terms of service linked
  - [ ] Support URL working
  - [ ] Account deletion flow
  - [ ] App Store screenshots prepared
  - [ ] App preview video created

  ### Performance
  - [ ] App size < 50MB
  - [ ] Launch time < 2 seconds
  - [ ] No memory leaks
  - [ ] Battery drain acceptable

  ### Edge Cases
  - [ ] Poor network handling
  - [ ] Offline mode works
  - [ ] Background refresh works
  - [ ] Push notifications work
  - [ ] Deep linking works

  ## Review Checklist
  - [ ] Metadata prepared
  - [ ] Build uploaded to TestFlight
  - [ ] Internal testing complete
  - [ ] External beta testing complete
  - [ ] All blocking bugs fixed

  ## Assigned Testers
  - iOS Tester 1: Functionality
  - iOS Tester 2: Performance
  - QA Lead: Final review
labels: ["qa", "testing", "ios", "app-store"]
priority: 1
project: "Chatz - Mobile Chat App"
```

## Release Management

### Creating Release Issues

```
Tool: create_issue

Release Issue:
title: "[RELEASE] iOS v1.0.0 App Store Submission"
team: "Mobile"
description: |
  ## Release Information
  - Version: 1.0.0
  - Build: 100
  - Target Date: March 15, 2025
  - Platform: iOS

  ## Pre-Release Checklist
  - [ ] All features complete
  - [ ] All bugs fixed
  - [ ] QA testing passed
  - [ ] Performance benchmarks met
  - [ ] Privacy policy updated
  - [ ] App Store assets ready

  ## Submission Checklist
  - [ ] Build uploaded to App Store Connect
  - [ ] TestFlight testing complete
  - [ ] App Store metadata complete
  - [ ] Screenshots uploaded (all sizes)
  - [ ] Privacy nutrition labels filled
  - [ ] Age rating set
  - [ ] Support URL working
  - [ ] Submit for review

  ## Post-Submission
  - [ ] Monitor review status
  - [ ] Respond to review feedback
  - [ ] Release after approval
  - [ ] Monitor crash reports
  - [ ] Monitor user reviews

  ## Rollback Plan
  - Previous version: 0.9.5 (build 95)
  - Rollback procedure: [link to docs]

  ## Links
  - App Store Connect: [link]
  - TestFlight: [link]
  - Release notes: [link]
labels: ["release", "ios", "app-store"]
priority: 1
assignee: "release-manager"
project: "Chatz - Mobile Chat App"
dueDate: "2025-03-15"
```

## Daily Workflow Queries

### My Tasks for Today

```
Tool: list_issues

Parameters:
assignee: "me"
state: "In Progress"
project: "Chatz - Mobile Chat App"
orderBy: "updatedAt"
limit: 5
```

### Platform-Specific Issues

```
Tool: list_issues

iOS Issues:
label: "ios"
state: "Todo"
project: "Chatz - Mobile Chat App"

Android Issues:
label: "android"
state: "Todo"
project: "Chatz - Mobile Chat App"

Cross-Platform Issues:
label: "shared"
state: "In Progress"
project: "Chatz - Mobile Chat App"
```

### Bugs by Priority

```
Tool: list_issues

Critical Bugs:
label: "bug"
priority: 1
state: "Todo"
project: "Chatz - Mobile Chat App"

Platform-Specific Bugs:
label: "bug"
label: "ios"  # or "android"
orderBy: "createdAt"
```

## Project Status Updates

### Weekly Update

```
Tool: update_project

Parameters:
  id: "[project-id]"
  description: |
    # Chatz Mobile App

    ## Status: Week 8 of 12 - On Track ✅

    ## Progress This Week
    - ✅ Voice calls implementation complete
    - ✅ iOS CallKit integration done
    - ✅ Android ConnectionService working
    - 🔄 Payment integration in progress

    ## Platform Status

    ### iOS
    - Features: 85% complete
    - Bugs: 3 open (0 critical)
    - TestFlight: v0.9.2 available
    - App Store: Preparing for submission

    ### Android
    - Features: 82% complete
    - Bugs: 5 open (1 high priority)
    - Internal testing: v0.9.1
    - Play Store: Beta track ready

    ## Metrics
    - Total Issues: 78
    - Completed: 58 (74%)
    - In Progress: 12 (15%)
    - Todo: 8 (10%)

    ## Next Week
    - Complete payment integration
    - Fix remaining high-priority bugs
    - Start App Store submission prep
    - Begin Play Store beta testing

    ## Risks
    - ⚠️ App Store review timing uncertain
    - Mitigation: Submit early, plan buffer

    [Previous content...]
```

## Tips for Mobile Development

1. **Label Platform-Specific Issues**:
   - Use "ios", "android", "shared" labels
   - Filter easily by platform

2. **Track Device-Specific Bugs**:
   - Include device info in bug titles
   - Example: "[BUG][Samsung S21] Camera crash"

3. **Separate Release Tracks**:
   - iOS and Android have different timelines
   - Create separate release issues

4. **Test Across Devices**:
   - Document device testing in comments
   - Track which devices have been tested

5. **Version Tracking**:
   - Link issues to version milestones
   - Track features per release

6. **App Store/Play Store Requirements**:
   - Create comprehensive checklists
   - Update as requirements change

7. **Performance Metrics**:
   - Include performance criteria in acceptance
   - Document benchmark results

This workflow ensures organized, efficient mobile app development with clear platform-specific tracking.
