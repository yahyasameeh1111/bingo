# BinGo — Project Context

## Product

**BinGo** is a household/community waste-management platform.

The existing system is a web application backed by Firebase and Google Apps Script. The Flutter migration should preserve its current behavior while giving it a native mobile experience.

## Existing technical components

- Firebase Authentication
- Cloud Firestore
- Firebase Storage where applicable
- Google Apps Script for Gmail/OTP verification and registration integration
- Household web application
- Separate admin web application
- Firestore security rules
- Live community functionality

## Existing household areas

The current household HTML contains these major pages/areas:

- Home
- Schedule
- Waste Guide
- Collection Point
- Community
- Notifications
- Profile
- Help & Support

The primary bottom navigation currently exposes:

- Home
- Schedule
- Waste Guide
- Community
- Profile

Collection Point is reachable from the Home/collection workflow.

## Existing Home behavior

Current Home includes concepts such as:

- household greeting
- current/assigned collection point
- this-week information
- quick actions
- notification access
- collection-point map access
- QR scanning
- calendar access
- missed-collection report
- payment/fee action
- issue reporting

The exact labels and data bindings must be taken from the supplied current HTML.

## Existing Schedule behavior

Schedule supports:

- calendar view
- list view
- previous/next navigation
- live schedule data
- scheduled collection information

## Existing Waste Guide

Waste Guide includes categories such as:

- Plastic
- Organic
- Paper
- Glass
- Metal
- Hazardous
- E-Waste

Do not replace the current BinGo content with generic recycling information unless the supplied source already contains it.

## Existing Collection Point

The household can view its assigned collection point and has a QR-related action such as:

- Scan QR to drop

The Flutter migration must preserve the existing intended workflow.

## Existing Community

Community is a social feed and is intentionally visually distinct from the rest of the household utility UI.

Current concepts include:

- BinGo branding
- For You feed
- Following feed
- create post
- image attachment
- post text
- replies
- likes
- comments
- reposts
- saves
- shares
- follow/unfollow
- profile section
- followers/following counts
- posts/replies/reposts/saved views
- live Firestore updates

## Existing Profile

Profile contains:

- household identity
- editable profile information
- profile photo behavior
- support access
- settings access
- logout/sign-out

## Existing Help & Support

Support includes:

- FAQ
- account/access help
- contact support
- chat/support queue
- local authority contact
- issue reporting
- support requests

## Existing Admin

Admin is a separate application and should remain separate from the household app.

Current admin areas include:

- Dashboard
- Settings
- Collection Schedule
- Notifications
- Waste Types
- Collection Points
- Households
- Help & Support
- Reports Center
- Activity Logs

The current admin app contains live operational statistics and management workflows.

## Important migration rule

Do not simplify BinGo into only:

> Home + Schedule + Profile

The existing application is substantially larger. The Flutter app should preserve the full product.
