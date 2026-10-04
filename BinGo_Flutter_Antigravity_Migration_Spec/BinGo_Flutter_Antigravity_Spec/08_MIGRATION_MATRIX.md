# BinGo Web → Flutter Migration Matrix

| Existing area | Flutter destination | Migration rule |
|---|---|---|
| Login | Auth screens | Preserve current Auth + verification |
| Registration | Auth/onboarding flow | Preserve current registration integration |
| Gmail/OTP verification | Verification screen/service | Do not bypass |
| Home | Home tab | Rebuild using new visual language |
| Schedule | Schedule tab | Preserve Calendar + List |
| Waste Guide | Waste Guide tab | Preserve categories/content |
| Collection Point | Collection Point route | Preserve assignment + QR |
| Notifications | Notifications route | Preserve live data |
| Community | Community tab | Preserve all social interactions |
| Profile | Profile tab | Preserve editing/account actions |
| Help & Support | Support route | Preserve support/report flows |
| Settings | Settings route | Preserve current settings |
| Firestore | Firebase repositories | Same backend |
| Storage | Firebase Storage service | Same media behavior |
| Auth | Firebase Auth service | Same account model |
| Apps Script | Server/integration layer | Do not move secrets into Flutter |
| Admin | Separate admin app | Keep operational app separate |

---

## Feature parity checklist

### Authentication

- [ ] Login
- [ ] Registration
- [ ] Verification
- [ ] Error handling
- [ ] Suspended account state
- [ ] Logout

### Home

- [ ] Greeting
- [ ] Notification
- [ ] Next collection
- [ ] Collection point
- [ ] Quick actions
- [ ] Map
- [ ] QR
- [ ] Missed collection report
- [ ] Fee/payment
- [ ] Issue report

### Schedule

- [ ] Calendar
- [ ] List
- [ ] Month/date navigation
- [ ] Live schedule
- [ ] Empty state

### Waste Guide

- [ ] Plastic
- [ ] Organic
- [ ] Paper
- [ ] Glass
- [ ] Metal
- [ ] Hazardous
- [ ] E-Waste

### Community

- [ ] For You
- [ ] Following
- [ ] Create post
- [ ] Image
- [ ] Like
- [ ] Reply
- [ ] Repost
- [ ] Save
- [ ] Share
- [ ] Follow
- [ ] Followers
- [ ] Following
- [ ] Profile
- [ ] Posts
- [ ] Replies
- [ ] Reposts
- [ ] Saved
- [ ] Realtime

### Profile

- [ ] Avatar
- [ ] Household identity
- [ ] Editable fields
- [ ] Support
- [ ] Settings
- [ ] Logout

### Support

- [ ] FAQ
- [ ] Contact support
- [ ] Chat/support queue
- [ ] Authority contact
- [ ] Report issue
- [ ] Account review where supported
