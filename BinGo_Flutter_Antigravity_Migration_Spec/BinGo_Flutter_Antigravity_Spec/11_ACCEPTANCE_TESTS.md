# BinGo Flutter Acceptance Tests

## Authentication

- [ ] Existing valid household can sign in.
- [ ] Invalid credentials show a useful error.
- [ ] Unverified household is not incorrectly treated as verified.
- [ ] Suspended household receives the correct account state.
- [ ] Logout works.
- [ ] Restarting the app restores the intended authenticated state.
- [ ] No stale session causes an unrelated logout.

## Home

- [ ] Real household name appears.
- [ ] Real avatar appears where available.
- [ ] Notification badge reflects live data.
- [ ] Next collection is real.
- [ ] Collection point is real.
- [ ] Quick actions open the correct flows.
- [ ] Loading state works.
- [ ] Empty state works.
- [ ] Error state works.

## Schedule

- [ ] Calendar loads.
- [ ] List loads.
- [ ] Previous/next navigation works.
- [ ] Live changes appear.
- [ ] No schedule produces a designed empty state.

## Waste Guide

- [ ] All current categories are present.
- [ ] Current content is preserved.
- [ ] Long content scrolls correctly.

## Collection Point

- [ ] Assigned point loads.
- [ ] Map action works.
- [ ] QR flow opens.
- [ ] Permission denial is handled.

## Notifications

- [ ] New notification appears without manual reload where realtime is supported.
- [ ] Unread state works.
- [ ] Notification details work.
- [ ] Empty state works.

## Community

- [ ] For You works.
- [ ] Following works.
- [ ] Composer works.
- [ ] Image picker opens.
- [ ] Image preview works.
- [ ] Post upload works.
- [ ] Like updates.
- [ ] Reply updates.
- [ ] Repost updates.
- [ ] Save updates.
- [ ] Share works.
- [ ] Follow/unfollow works.
- [ ] Follower/following counts are live.
- [ ] Profile views work.
- [ ] Saved posts work.
- [ ] No followed users has an appropriate empty state.
- [ ] Feed errors are visible.

## Profile

- [ ] Profile data loads.
- [ ] Editable fields work.
- [ ] Avatar update works where supported.
- [ ] Settings opens.
- [ ] Support opens.
- [ ] Logout works.

## Support

- [ ] FAQ works.
- [ ] Support request can be created where supported.
- [ ] Report flow works.
- [ ] Existing support status is visible where supported.

## Visual

- [ ] Matches the supplied reference visual direction.
- [ ] No accidental healthcare UI remains.
- [ ] Typography is consistent.
- [ ] Cards have consistent radius.
- [ ] Bottom navigation is safe-area aware.
- [ ] Tablet layout is usable.
- [ ] Dark mode does not produce unreadable text.
