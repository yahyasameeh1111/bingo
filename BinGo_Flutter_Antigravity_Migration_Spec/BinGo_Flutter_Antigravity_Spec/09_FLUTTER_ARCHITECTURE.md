# BinGo Flutter Architecture

## State management

Use Riverpod or an equivalent structured reactive solution.

Recommended:

```text
Provider
↓
Repository
↓
Firebase data source
```

Widgets should consume state rather than contain business logic.

---

## Repository examples

```dart
abstract class HouseholdRepository {
  Stream<Household?> watchCurrentHousehold();
  Future<void> updateHousehold(...);
}
```

```dart
abstract class ScheduleRepository {
  Stream<List<CollectionSchedule>> watchSchedules(...);
}
```

```dart
abstract class CommunityRepository {
  Stream<List<CommunityPost>> watchForYou();
  Stream<List<CommunityPost>> watchFollowing();
  Future<void> createPost(...);
  Future<void> toggleLike(...);
  Future<void> toggleSave(...);
  Future<void> toggleRepost(...);
  Future<void> toggleFollow(...);
}
```

---

## Models

Create typed Dart models instead of passing raw `Map<String, dynamic>` throughout the UI.

Examples:

```text
Household
CollectionSchedule
WasteType
CollectionPoint
NotificationItem
CommunityPost
CommunityReply
CommunityProfile
SupportRequest
Report
```

Models should map to the existing Firestore document shape.

Do not rename fields casually.

---

## Error handling

Create a shared error model.

UI should be able to show:

- authentication error
- permission denied
- network error
- unavailable data
- upload failure
- validation error

Avoid exposing raw Firebase exception text to ordinary users.

---

## Loading

Use skeletons/placeholders for major screens.

Avoid full-screen spinners for every tiny operation.

---

## Media

Community/profile image flow:

```text
image_picker
↓
optional resize/compression
↓
Firebase Storage
↓
download URL
↓
Firestore document
↓
live UI
```

Do not store large image binaries directly in Firestore.

---

## Navigation

Use go_router or a similarly structured navigation system.

Deep links should be considered for:

- community post
- notification
- support request
- collection point

---

## Tablet adaptation

For larger screens:

```text
Phone:
Bottom navigation

Tablet:
Navigation rail / wider floating navigation
+ multi-column content where useful
```

Do not simply scale phone widgets to 2x width.

---

## Theme

Create a central theme.

Do not hardcode colors in individual widgets.

Example:

```dart
class BinGoColors {
  static const background = ...;
  static const surface = ...;
  static const accent = ...;
  static const text = ...;
  static const muted = ...;
  static const error = ...;
}
```

Support light mode and the existing household dark-mode behavior where applicable.

Community may preserve its social-app styling while following the app's theme state.
