# Antigravity Rules for BinGo Flutter Migration

## Non-negotiable

1. Build a real Flutter/Dart application.
2. Do not build a static UI prototype.
3. Do not hardcode production data.
4. Do not replace Firebase with mock JSON.
5. Do not remove existing BinGo functionality without explicit approval.
6. Do not silently change Firestore field names.
7. Do not weaken Firestore rules to make the app work.
8. Do not expose server/service-account credentials in Flutter.
9. Do not copy healthcare content from the reference screenshots.
10. Do not merge the admin UI into the household UI accidentally.
11. Do not reintroduce the broken admin single-device logout mechanism.
12. Do not make Community look like a normal dashboard.
13. Do not use plain Unicode characters as substitutes for important action icons.
14. Do not leave buttons non-functional.
15. Every asynchronous operation needs loading/error handling.
16. Every major live collection needs loading/empty/error states.
17. Test against the real Firebase project before declaring completion.

---

## Code quality

Prefer:

- small widgets
- typed models
- repositories
- services
- immutable state
- reusable components
- centralized theme
- clear route definitions

Avoid:

- one giant `main.dart`
- Firestore calls inside every widget
- duplicated authentication logic
- duplicated theme constants
- global mutable state without structure
- magic strings for collection names

---

## Migration behavior

When the existing HTML and this documentation disagree:

- preserve actual working backend/data behavior from the supplied current source
- preserve user-facing functionality
- adapt the presentation to Flutter
- document any unavoidable difference

Never silently delete a feature.

---

## Visual interpretation

Use the supplied screenshots for:

- spacing
- card hierarchy
- typography scale
- background treatment
- selected navigation behavior
- onboarding composition
- visual density

Do not treat them as exact pixel specifications.

BinGo's information architecture remains the source of truth.

---

## Completion report

At the end, report:

```text
Implemented
Partially implemented
Blocked
Not yet migrated
```

For each item, name the exact feature.

Do not say "complete" merely because the app builds.
