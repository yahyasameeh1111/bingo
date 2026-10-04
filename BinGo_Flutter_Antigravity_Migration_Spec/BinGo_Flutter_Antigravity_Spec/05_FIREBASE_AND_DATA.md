# BinGo Firebase and Data Migration Specification

## Rule

The existing Firebase backend is already part of the product.

The Flutter app should connect to the same Firebase project and collections unless a deliberate migration is required.

Do not create a second database.

---

## Firebase services

### Firebase Authentication

Used for:

- household authentication
- admin authentication where the admin app is involved

Flutter household authentication must follow the current website's internal Auth-email strategy and verification workflow.

### Cloud Firestore

Used for:

- households
- schedules
- notifications
- waste types
- collection points
- collections
- reports
- support
- community
- activity/operational data
- settings and related application state

### Firebase Storage

Use where the existing app stores:

- profile images
- community post images
- other user-uploaded media

### Firebase Cloud Messaging

If push notifications are enabled in the existing deployment, preserve them in Flutter.

---

## Known Firestore collection families

The current supplied rules include paths such as:

```text
households
schedule
wasteTypes
notifications
collectionPoints
collections
collectionRoutes
vehicles
vehicleLocations
collectionScans
collectionPointStatus
reports
supportRequests
activityLogs

communityPosts
comments
likes
saves
reposts
communityFollows
following
communityStories
communityRSVPs
communityReports
communityProfiles
communityNotificationPreferences

payments
paymentOrders

wasteClassifications
householdScores

communityCampaigns
leaderboards
analytics

appSettings
adminSessions
users
```

Some paths are nested/subcollections.

**Do not assume every path must be used by the household UI.** Read the existing HTML and rules before implementing each feature.

---

## Security

Use the supplied Firestore rules.

The rules distinguish household users and role-based administrative/operational access.

Do not:

- make all collections public
- bypass authentication
- use admin credentials in the client
- place service-account credentials in Flutter
- move secret server credentials into the APK

---

## Realtime

Prefer:

```dart
Stream<T>
```

for data that the website already updates live.

Use repositories:

```text
HouseholdRepository
ScheduleRepository
NotificationRepository
CommunityRepository
ProfileRepository
SupportRepository
```

Do not scatter Firestore queries throughout widgets.

---

## Data loading pattern

Every live screen should have:

```text
loading
loaded
empty
error
```

Do not show fake values while loading.

---

## Offline/cache

Where useful, allow Firestore's native offline persistence.

The UI must distinguish:

- cached data
- fresh data
- unavailable data

when that distinction matters.
