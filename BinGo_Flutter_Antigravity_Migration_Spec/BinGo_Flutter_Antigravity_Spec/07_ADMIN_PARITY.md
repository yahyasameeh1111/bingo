# BinGo Admin Parity Reference

## Important

The admin web application is separate from the household application.

The current admin HTML should be supplied to Antigravity as a reference for the existing operational product.

Do not merge household and admin UI into one ambiguous role-based screen unless explicitly required later.

---

## Current admin areas

### Dashboard

Includes live operational information such as:

- total households
- online households
- verified households
- suspended households
- schedules
- notifications
- collection points
- activity
- reports
- support
- next collection
- system state

### Settings

Includes operational/application settings and live configuration state.

### Collection Schedule

Supports management of collection schedules.

Concepts include:

- schedule ID
- day
- date
- waste type
- time
- panchayat
- instruction
- published schedules

### Notifications

Supports:

- composing notifications
- notification type
- publishing
- selecting existing notifications
- updating/deleting where implemented

### Waste Types

Manage waste-type information used by the household guide.

### Collection Points

Manage collection-point information.

### Households

Manage/view household records and account-related operational information.

### Help & Support

View/manage support requests.

### Reports Center

View and manage reports.

### Activity Logs

View operational/user activity.

---

## Flutter relationship

The household Flutter app does not need to reproduce every admin screen.

However, its data contracts must remain compatible with the admin app.

Example:

```text
Admin creates schedule
        ↓
Firestore
        ↓
Household Flutter Schedule screen updates live
```

Similarly:

```text
Admin publishes notification
        ↓
Firestore
        ↓
Household notification feed updates
```
