# BinGo Community — Flutter Functional Specification

## Product direction

Community should feel like a modern social application, inspired by the structural patterns of Threads/X.

It should **not** look like the standard BinGo utility dashboard.

The brand remains BinGo.

---

## Feed tabs

### For You

Show a live feed of available community posts using the existing website's data/query behavior.

### Following

Show content related to accounts the household follows.

Do not fabricate a Following feed when the user follows nobody. Show a useful empty state.

---

## Composer

Composer must support:

- text
- image selection
- image preview
- remove selected image
- character count
- Post action
- loading state
- upload failure state
- success state

The image button must always be visible.

---

## Post

Each post can display:

- author avatar
- author display name
- handle
- relative timestamp
- Follow button where applicable
- own-post controls where applicable
- post text
- image
- like count/state
- reply/comment count
- repost count
- save state

Actions:

```text
Like
Reply
Repost
Save
Share
```

Use proper icons, not plain text characters.

---

## Live behavior

Use Firestore realtime listeners for:

- new posts
- edited/deleted state if supported
- likes
- comments/replies
- reposts
- saves
- follow state

Optimistic UI is allowed, but must reconcile with Firestore.

Never permanently rely on local state.

---

## Follow

A user can:

- follow another community user
- unfollow
- view following count
- view followers count
- open follower/following lists

Do not allow following yourself.

---

## Profile

Community profile should support:

- avatar
- display name
- handle
- followers
- following
- posts
- replies
- reposts
- saved posts

Where the current website supports editing, preserve it.

---

## Replies

Reply flow:

1. Open post detail.
2. Show original post.
3. Show live replies.
4. Reply composer.
5. Submit.
6. Show new reply without requiring a manual refresh.

---

## Share

Use the native Flutter/share mechanism where possible.

If a post has no shareable external URL, create an appropriate internal share representation rather than inventing a fake web URL.

---

## Save/bookmark

Saved state must persist in Firestore.

A saved post should appear in the user's Saved view if supported by the existing data model.

---

## Empty states

Examples:

- no posts yet
- no followed users
- no replies
- no saved posts
- no followers
- no following

Empty states should be designed, not blank screens.

---

## Error states

Examples:

- feed unavailable
- post failed
- image upload failed
- action failed
- profile unavailable

Do not silently swallow errors.
