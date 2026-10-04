# BinGo Flutter Migration — Master Antigravity Prompt

## Mission

Convert the existing **BinGo waste-management website** into a production-quality **Flutter + Dart mobile application** while preserving the existing backend, business logic, data model, authentication behavior, and live functionality.

The existing HTML files are the **functional source of truth**. The attached design-reference screenshots are the **visual direction**, not content to copy.

Build the Flutter app as a real application, not a mockup and not a static prototype.

---

## Source-of-truth files

The developer will provide the current BinGo files separately. Treat them in this priority order:

1. Current household HTML — source of truth for household features and behavior.
2. Current admin HTML — source of truth for admin features and behavior.
3. Current Firestore rules — source of truth for allowed backend access.
4. Current Google Apps Script verification file — source of truth for Gmail/OTP verification integration.
5. Current Firebase configuration already present in the supplied files.
6. The Markdown documents in this specification pack — implementation requirements and migration guidance.
7. The three design-reference screenshots — visual direction only.

Do **not** invent a replacement backend if an existing feature can be migrated.

Do **not** remove working features merely because they are difficult to migrate.

Do **not** modify the admin application's backend behavior while migrating the household application unless required for compatibility.

---

## Visual target

The screenshots establish the new visual language:

- premium mobile-first interface
- very light warm/off-white page background
- subtle pale sage/green atmosphere
- white elevated cards
- very dark/near-black typography
- lime/bright green accent for primary states
- rounded cards and controls
- large, clean typography
- generous whitespace
- soft shadows
- minimal borders
- compact pill controls
- circular icon buttons
- pill-shaped bottom navigation
- selected navigation item becomes a dark/black pill with light text
- secondary navigation items remain circular/light
- content is layered vertically rather than packed into dense dashboards
- onboarding uses large imagery, large typography and a strong bottom CTA

The screenshots are healthcare examples. **Do not copy healthcare text, medical data, doctors, blood pressure, glucose, calories, or medical imagery.** Reinterpret the visual system for BinGo waste management.

---

## Core product identity

Brand: **BinGo**

Domain: household/community waste collection.

Primary household concepts:

- household account
- collection schedule
- assigned collection point
- waste guide
- notifications
- collection history/status
- reporting
- community
- household profile
- help/support
- settings
- live data from Firebase

Admin concepts:

- dashboard
- household management
- schedules
- notifications
- waste types
- collection points
- support
- reports
- activity logs
- settings
- live operational information

---

## Critical engineering rules

### 1. Real data only

Do not hardcode:

- household names
- collection counts
- follower counts
- post counts
- notification counts
- schedules
- collection points
- community posts
- likes
- comments
- followers/following
- reports
- support tickets
- admin dashboard statistics

Use Firebase/Firestore listeners or queries.

Temporary loading placeholders are allowed.

### 2. Preserve authentication

The current household authentication uses Firebase Auth plus BinGo's household verification workflow.

Important distinction:

- Firebase Auth `emailVerified` is not automatically equivalent to BinGo's Gmail/OTP verification.
- The existing Firestore household verification state must remain respected.
- Do not bypass verification.
- Do not silently auto-verify accounts.

Household Auth emails may use the internal `@auth.bingo.app` convention from the existing website. Read the actual current implementation from the supplied source files instead of duplicating a guessed value.

### 3. Admin authentication

Admin authentication must remain separate from household authentication.

The current admin HTML was recently fixed so that a stale Firestore single-device session lock does not falsely log an administrator out.

Do not reintroduce the old false "another device logged in" behavior.

Firebase Auth is the authentication authority.

### 4. Firestore security

Use the supplied Firestore rules as the security source of truth.

Never solve a permission problem by making the app request unrestricted access.

If a Flutter feature requires a new Firestore path, first determine whether the existing rules already support it. If not, document the required rule change rather than weakening unrelated rules.

### 5. Live behavior

Use Firestore realtime listeners where the website currently uses live data.

Examples:

- community feed
- likes
- comments
- reposts
- saves
- following
- notifications
- household status
- schedules where live
- support/report status where live
- admin operational data

### 6. Responsive design

The app must work on:

- normal Android phones
- small phones
- large phones
- Android tablets
- iPad-sized screens where practical

Do not simply stretch the phone UI to tablet width.

---

## Recommended Flutter stack

Use current stable packages compatible with the installed Flutter SDK. Prefer:

- Flutter
- Dart
- Firebase Core
- Firebase Auth
- Cloud Firestore
- Firebase Storage
- Firebase Messaging if push notifications are enabled
- Riverpod for state management
- go_router for navigation
- image_picker for post/profile images
- cached_network_image for remote images
- intl for date/time formatting
- url_launcher where external links are required

Use Material 3 as a foundation but create a custom BinGo design system rather than leaving default Material styling.

---

## Required architecture

Recommended structure:

```text
lib/
  app/
    app.dart
    router.dart
    theme/
      bingo_theme.dart
      bingo_colors.dart
      bingo_typography.dart
      bingo_spacing.dart
      bingo_radius.dart

  core/
    constants/
    errors/
    extensions/
    utils/
    widgets/

  firebase/
    auth/
    firestore/
    storage/
    messaging/

  features/
    auth/
    onboarding/
    home/
    schedule/
    waste_guide/
    collection_point/
    notifications/
    community/
    profile/
    support/
    settings/
    admin/

  shared/
    models/
    repositories/
    services/

  main.dart
```

Use feature-first organization.

Separate:

- presentation
- state/controller
- repository
- model
- Firebase/data source

Avoid putting Firestore calls directly inside large widget build methods.

---

## Navigation

Household primary navigation should follow the current BinGo app's functional navigation while adopting the new visual style.

Primary areas:

- Home
- Schedule
- Waste Guide
- Community
- Profile

Collection Point can remain accessible from Home and relevant flows without necessarily occupying a primary bottom-nav slot.

Notifications should be accessible from the Home header and notification route.

Support should be accessible from Profile and relevant error/report flows.

---

## Community

Community is intentionally different from the normal BinGo utility UI.

It should feel inspired by modern social apps such as Threads/X:

- feed-first layout
- For You
- Following
- compose post
- image attachment
- replies
- likes
- reposts
- saves
- shares
- follow/unfollow
- profile preview
- followers
- following
- posts
- replies
- reposts
- saved posts
- live Firestore updates

Do not turn Community into a generic BinGo card dashboard.

---

## Implementation sequence

1. Inspect all supplied source files.
2. Extract current feature behavior and data contracts.
3. Set up Flutter project.
4. Implement theme/design system.
5. Implement splash/onboarding.
6. Implement authentication and verification.
7. Implement Home.
8. Implement Schedule.
9. Implement Waste Guide.
10. Implement Collection Point.
11. Implement Notifications.
12. Implement Community.
13. Implement Profile.
14. Implement Help & Support.
15. Implement Settings.
16. Validate Firebase/Firestore behavior.
17. Implement admin-compatible data flows where the mobile app needs them.
18. Run full feature and regression tests.
19. Only after parity is reached, polish animations and performance.

---

## Definition of done

The migration is complete only when:

- a real household can sign in
- verification rules are respected
- real household data loads
- schedule data is live
- waste guide data is live
- collection point data is live
- notifications are live
- Community is fully live
- profile data is live
- reports/support work
- settings persist
- logout works
- no major website feature has silently disappeared
- no feature depends on demo/hardcoded content
- the UI matches the supplied design direction
- tablet layouts remain usable
- Firebase errors are handled visibly
- loading, empty and error states exist
- the app builds successfully
