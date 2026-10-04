# BinGo Flutter UI/UX Design System

## Design reference

The three supplied screenshots are visual references.

They demonstrate:

1. A schedule-oriented dashboard.
2. A data-rich home dashboard.
3. A large-image onboarding screen.

They are not BinGo screenshots and their healthcare content must not be copied.

---

## Overall visual language

### Background

Use a very light warm neutral/off-white base.

Suggested direction:

- page background: warm off-white
- secondary background: extremely pale sage
- cards: white
- overlays: white with transparency

Avoid making the entire application green.

### Accent

Use a fresh lime/green accent for:

- selected dates
- active states
- primary action indicators
- status dots
- progress indicators
- small highlights
- important confirmation states

### Primary text

Near-black/dark charcoal.

### Secondary text

Soft gray/gray-green.

### Error

Use a restrained red only for:

- errors
- destructive actions
- failed operations

Do not make red a brand color.

---

## Cards

Cards should be:

- white
- rounded
- spacious
- lightly elevated
- minimally bordered

Recommended radius family:

```text
small: 12
medium: 18
large: 24
extra-large: 30
pill: 999
```

Do not overuse borders.

---

## Typography

Use a clean modern sans-serif.

Hierarchy:

```text
Display:
40–52 px equivalent

Page title:
28–34

Section title:
18–22

Card title:
15–18

Body:
14–16

Supporting text:
11–13

Metadata:
10–12
```

Prefer strong hierarchy and whitespace over heavy decoration.

---

## Icons

Use one consistent icon family.

Do not mix random Unicode symbols with Material/Cupertino icons.

Community actions should use recognizable iconography:

- heart
- comment/reply
- repost
- bookmark
- share
- image
- more
- follow

---

## Buttons

Primary CTA:

- dark/black or BinGo green depending on context
- rounded/pill
- high contrast
- comfortable touch target

Secondary:

- white/light
- subtle border
- dark text

Destructive:

- restrained red

---

## Bottom navigation

The reference screenshots use a floating pill-style bottom navigation.

BinGo should adapt this concept:

- floating above the content
- rounded capsule container
- light background
- selected item = dark/black pill
- unselected items = light circular/rounded controls
- icon + label for selected item
- icon-first for unselected items
- safe-area aware

On tablets, use a wider floating navigation or adaptive rail rather than stretching tiny phone controls.

---

## Home composition

Use a vertical rhythm similar to the reference:

1. compact greeting/header
2. notification action
3. primary collection status
4. schedule preview
5. quick actions
6. relevant collection-point/status information
7. additional live information

Do not reproduce the health dashboard's metrics.

BinGo equivalents could include:

- next collection
- collection point
- waste type for next collection
- household collection status
- missed pickup status
- recent notifications

Only show metrics supported by the existing data.

---

## Schedule

Reference direction:

- clean white card
- horizontal date selector or calendar
- selected date highlighted in lime
- schedule cards below
- compact metadata
- clear status

Use both:

- Calendar
- List

because the existing BinGo website already supports both.

---

## Onboarding

Use the third screenshot as a visual model:

- full-height image/illustration
- soft fade/gradient
- large title
- short supporting copy
- strong bottom CTA
- minimal UI chrome

BinGo onboarding should communicate:

- smarter waste collection
- collection schedules
- waste segregation
- community participation

Do not copy the screenshot's healthcare language.

---

## Motion

Use subtle animation:

- page transitions
- card entrance
- selected navigation state
- like/follow confirmation
- pull-to-refresh
- skeleton loading

Avoid excessive animation.

---

## Accessibility

Minimum:

- readable contrast
- touch targets >= 44 logical pixels where practical
- semantic labels for icons
- text scaling support
- no essential information conveyed by color alone
- screen-reader labels for community actions
