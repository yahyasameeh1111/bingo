# BinGo Flutter Implementation Plan

## Phase 0 — Source audit

Before writing UI:

- inspect household HTML
- inspect admin HTML
- inspect Firestore rules
- inspect Apps Script
- identify all Firebase collection names
- identify all page IDs
- identify all actions
- identify current authentication states
- identify all image/media flows

Produce a feature inventory before deleting or replacing code.

---

## Phase 1 — Project setup

Create Flutter project.

Set up:

- Android
- iOS where applicable
- Firebase
- environment/config strategy
- routing
- state management
- theme
- linting

---

## Phase 2 — Design system

Implement:

- colors
- typography
- spacing
- radius
- shadows
- buttons
- cards
- icon buttons
- bottom navigation
- dialogs
- loading states
- error states

Match the supplied screenshots' visual language.

---

## Phase 3 — Splash/onboarding

Implement:

- splash
- onboarding slides
- skip/continue behavior if supported
- persistence so onboarding does not repeatedly appear for existing users

Use BinGo imagery/content.

---

## Phase 4 — Authentication

Implement:

- login
- registration
- verification
- loading
- errors
- suspended/unverified state
- logout

Test against real Firebase.

---

## Phase 5 — Core household

Implement:

1. Home
2. Schedule
3. Waste Guide
4. Collection Point
5. Notifications

Validate each against the current website.

---

## Phase 6 — Community

Implement in this order:

1. feed shell
2. For You
3. Following
4. composer
5. image upload
6. post creation
7. likes
8. replies
9. reposts
10. saves
11. shares
12. follow/unfollow
13. community profile
14. followers/following
15. saved/reposted views
16. realtime reconciliation

---

## Phase 7 — Profile and support

Implement:

- profile
- edit profile
- avatar
- settings
- support
- reports
- account actions

---

## Phase 8 — Production hardening

Test:

- no internet
- slow internet
- Firestore permission errors
- image upload failures
- account sign-out
- app restart
- background/resume
- duplicate taps
- empty collections
- large feeds
- large images
- tablet layout

---

## Phase 9 — Polish

Only after functionality works:

- animations
- haptics where appropriate
- skeletons
- micro-interactions
- transitions
- performance optimization

---

## Phase 10 — Release readiness

Check:

- Android release build
- app icon
- splash
- package/application ID
- Firebase configuration
- notification configuration
- permissions
- privacy/terms links if applicable
- crash handling
- production rules
