# BinGo Authentication and Verification

## Household authentication

The current household system uses Firebase Auth with an internal household-auth email convention.

The Flutter implementation must inspect the current source and reproduce that behavior rather than asking the user to type a different hidden email format.

---

## Verification

There are two different concepts:

### Firebase Auth verification

Firebase may expose:

```text
emailVerified
```

### BinGo verification

The BinGo application also maintains its own household verification state in Firestore as part of its Gmail/OTP registration workflow.

These must not be treated as automatically identical.

---

## Login behavior

Expected states:

```text
Loading
↓
Sign in
↓
Authentication successful
↓
Load household profile
↓
Check BinGo verification/account state
↓
Open app
```

If verification is incomplete:

- show the correct verification flow
- do not simply open the household dashboard
- do not falsely mark the account verified

---

## Account states

Support the current website's account states, including where applicable:

- active
- suspended
- unverified
- missing profile
- authentication failure

Use the exact current source behavior.

---

## Logout

Logout must:

- cancel live listeners
- clear local session state
- sign out Firebase Auth
- return to authentication
- avoid leaving stale UI state

---

## Admin

Admin authentication remains separate.

The recent admin fix removed the problematic Firestore single-device lock behavior that caused false "another device" logout.

Do not restore that mechanism in the Flutter household app.
