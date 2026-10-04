# BinGo Flutter Screen Map

## App shell

```text
Splash
  ↓
Onboarding (new users where applicable)
  ↓
Authentication
  ├── Sign in
  ├── Registration
  ├── Email/Gmail verification
  └── Account state/error handling
  ↓
Household App
```

---

## Primary household navigation

```text
Home
Schedule
Waste Guide
Community
Profile
```

---

## Secondary routes

```text
Notifications
Collection Point
QR Scan
Report Missed Collection
Report Issue
Payment/Fee
Help & Support
Settings
Community Post Detail
Community Profile
Community Followers
Community Following
Saved Community Posts
```

---

## Home

Required areas:

- greeting
- household identity/avatar
- notification button
- next collection
- collection point
- this-week summary
- quick actions
- schedule shortcut
- collection point map shortcut
- QR shortcut
- missed collection report
- fee/payment shortcut if available
- issue report shortcut

All values must be live.

---

## Schedule

Modes:

- Calendar
- List

Controls:

- previous period
- next period
- selected date

Schedule cards should display the fields actually available in Firestore.

---

## Waste Guide

Categories:

- Plastic
- Organic
- Paper
- Glass
- Metal
- Hazardous
- E-Waste

Use current website content as the authoritative copy.

---

## Collection Point

Show:

- assigned point
- point ID/name
- location
- relevant status
- QR action

Where the website has a map action, provide a native map/external map action rather than embedding a desktop iframe.

---

## Notifications

Show:

- live notifications
- unread state
- type
- received time
- detail view where supported

Support notification badge counts.

---

## Profile

Show:

- avatar
- household name
- household information
- editable fields supported by the website
- support
- settings
- logout

---

## Help & Support

Show:

- FAQ
- account/access
- contact support
- live/chat support if currently implemented
- authority contact
- issue reporting
- support request status

---

## Community

Top:

- BinGo wordmark
- create button
- refresh
- profile summary
- followers
- following
- posts
- For You / Following

Feed:

- avatar
- author
- handle
- time
- follow button
- text
- image
- like
- reply
- repost
- save
- share

Profile:

- avatar
- identity
- followers
- following
- posts
- replies
- reposts
- saved

Everything is live.
