# Bobeche — Build Specification

> Portfolio app 72, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Tap tonight's taper, walk three evening steps, then mark the night done.

| Field | Value |
| --- | --- |
| Product name | Bobeche |
| Bundle identifier | `com.bobeche.wick` |
| Domain | https://bobeche-wick.pro |
| Contact URL | https://bobeche-wick.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Dark |
| Asset prefix | `boc_` |
| User-Agent | `Bobeche/1.0 (iOS; +https://bobeche-wick.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Bobeche -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A person getting ready for sleep taps tonight's taper, walks reflect then breathe then ambient, and snuffs the flame so the night is saved.

### 2.1 User flow

1. Tap tonight's taper to light the Reflect chamber.
2. Sit through Reflect for 90s until Cue latches it, or skip to write a Hollow.
3. Sit through Breathe for 120s until Cue, or skip.
4. Sit through Ambient for 90s of procedural glow, or skip.
5. Snuff the taper to save a NightMark, then switch the History segment to see latches and the streak.

### 2.2 Essential behaviour

- One taper canvas with three chambers in canonical order at 90, 120 and 90 seconds.
- Cue at elapsed writes a Latch and opens the next chamber; Skip writes a Hollow and walks immediately.
- Forward-only walk: a later chamber cannot open until the previous is Latch or Hollow.
- Snuff on Ready writes a NightMark and freezes; Snuff on Dark writes Unlit and does not streak.
- Procedural ambient on the third chamber; no shipped audio files; no sleep-lab score.
- History counts NightMarks, Latches and Hollows; streak is consecutive NightMark days.
- Ritual, History and Settings are segments on one root; optional one-line Line on Reflect is not a journal.

---

## 3. Uniqueness assignment for Bobeche

| Axis | Assigned value |
| --- | --- |
| Architecture | **Taper ADT fold (Dark | Lit | Ready | Snuffed); the night is a fold over Chambers; Cue writes a Latch and opens the next; Skip writes a Hollow; Snuff writes a NightMark and freezes** |
| UI approach | **SwiftUI pure · take bedtimeritual** |
| Naming convention | **Taper / snuffer lexicon** |
| File organization | **By taper role (Taper, Chamber, Cue, Latch, Hollow, NightMark)** |
| Dependency strategy | **None** |
| Design direction | **Ocean glass depth** |
| Typography | **SF Pro** |
| Navigation pattern | **Taper-segment chrome (one root; Ritual History and Settings switch in place as segments)** |
| AI art style | **3D glass render glassmorphism · take bedtimeritual** |
| Functional twist | **Cue-then-snuff (Cue latches a chamber and opens the next; Skip writes Hollow; Snuff files the night)** |
| Persistence | **UserDefaults+Codable** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — bedtime_ritual

**Core** — A person getting ready for sleep taps tonight's taper, walks reflect then breathe then ambient, and snuffs the flame so the night is saved.

**Audience** — People who need a short ordered evening rite on one canvas, not a sleep lab and not a free-form breath hold.

**User flow**

1. Tap tonight's taper to light the Reflect chamber.
2. Sit through Reflect for 90s until Cue latches it, or skip to write a Hollow.
3. Sit through Breathe for 120s until Cue, or skip.
4. Sit through Ambient for 90s of procedural glow, or skip.
5. Snuff the taper to save a NightMark, then switch the History segment to see latches and the streak.

**Essential features**

- One taper canvas with three chambers in canonical order at 90, 120 and 90 seconds.
- Cue at elapsed writes a Latch and opens the next chamber; Skip writes a Hollow and walks immediately.
- Forward-only walk: a later chamber cannot open until the previous is Latch or Hollow.
- Snuff on Ready writes a NightMark and freezes; Snuff on Dark writes Unlit and does not streak.
- Procedural ambient on the third chamber; no shipped audio files; no sleep-lab score.
- History counts NightMarks, Latches and Hollows; streak is consecutive NightMark days.
- Ritual, History and Settings are segments on one root; optional one-line Line on Reflect is not a journal.

**Twist** — Cue-then-snuff. Home is tonight's taper. Lighting writes Flame and opens Reflect. Cue at elapsed writes a Latch and walks the flame to the next chamber. Skip writes a Hollow and walks immediately. After the third Latch or Hollow the taper is Ready. Snuff writes a NightMark and freezes. Snuff on Dark writes Unlit and does not streak. An unsnuffed Lit taper stays tonight's home until Snuff. Home verb: snuff-the-taper, not start-a-sleep-score. History counts NightMarks and Latches, not hours slept.

**Why this is not a repeat** — This is the first bedtime_ritual in the portfolio. Diapason is a single bellows you hold until Primed; early lift writes Slack and there is no ordered triple, no Skip-as-Hollow, and no snuff that files a night. Pugillar is a two-hand diary seam. Falspark parks a miss on a week wheel. This home is a glass taper you walk in one direction: Cue latches, Skip hollows, Snuff files. Analytics count NightMarks, not a sleep score and not a list of journal rows. Guideline 4.2 holds because the persisted verb is snuff, stored on device, with no WebView and no catalog to browse.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: One sequence canvas: reflect → breathe → ambient. Not a placeholder RootView.
- Invariant: Canonical order. Durations ~90/120/90s. Skip allowed. Cue(at elapsed). Procedural ambient, not shipped audio files. Streak on completed nights.
- Never: Shipping a title screen named after the app fails.
- Desk `maidenhead_path`: Maidenhead 2–8; haversine; long path; terminator from solar declination.
- Taste DNA is section 7.6. Do not invent a second look.

### 3.1 Architecture contract

The night is a Taper ADT whose only cases are Dark, Lit, Ready, and Snuffed, and one TaperStore owns that value plus the fold over three Chambers in canonical order: Reflect 90s, Breathe 120s, Ambient 90s. Lighting writes Flame and opens Reflect. Cue at elapsed writes a Latch and opens the next chamber. Skip writes a Hollow and walks immediately, and a later chamber cannot open until the previous is Latch or Hollow. After the third Latch or Hollow the taper is Ready; Snuff on Ready writes a NightMark and freezes, Snuff on Dark writes Unlit and does not streak, and an unsnuffed Lit taper stays tonight's home until Snuff. Views call lightTaper, cueAtElapsed, skipChamber, and snuffTaper and never keep a second phase enum; one unit test proves Cue-at-elapsed, Skip-as-Hollow, forward-only walk, NightMark freeze, and Unlit with no streak, without constructing a View.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

100% SwiftUI, no UIViewRepresentable, no WKWebView, no Safari sheet. The ui axis is SwiftUI pure with a bedtimeritual take-token: home is one sequence canvas (reflect then breathe then ambient) under new types and a new glass-stack layout; do not copy another app's file tree or type names, and do not ship a title screen named Bobeche. Confine Canvas plus TimelineView to Ritual: that one hero draws the glass taper and the third chamber's procedural glow; no shipped audio files. One Material blur sits on the taper card over a depth field; History and Settings are opaque fill plus hairline, never a second frost. Chambers walk along one wick with one lit chamber larger; not three equal-weight cards. Light, Cue, Skip, and Snuff are native Button controls with a ButtonStyle (default, pressed, disabled, loading); Skip is not the destructive variant; resetAllData is. Chrome lives inside the label with contentShape, min 44pt. Empty Ritual and empty History are full pages (frame maxHeight infinity) with generated cutout art, one headline, one line, and a bottom full-width CTA. Reduce Motion gates travel; fade stays. The ui axis string is never a section title.

### 3.3 Naming contract

Convention: Taper / snuffer lexicon.

Examples to follow: `Taper`, `Latch`, `Hollow`, `snuffTaper()`

### 3.4 Dependency contract

None. project.yml has no packages key. No SPM, no CocoaPods, no bundled font (SF Pro is the system face), no URLSession catalog. The leftover AVCaptureMetadataOutput scanner and cgi search pl endpoint are unused; do not import AVFoundation or Vision for capture and do not call a remote catalog. Foundation and SwiftUI only. Ambient is procedural Canvas glow, not a bundled audio file.

### 3.5 Navigation contract

Taper-segment chrome: one root, no TabView. Ritual, History, and Settings switch in place with a segmented Picker; the taper canvas never pops. Cue, Skip, and Snuff commit on Ritual; a context menu on the taper and on the open chamber holds Write Line (Reflect only) and Jump History. Line is a one-line sheet from that menu, not a pushed journal. One haptic on a successful snuffTaper (NightMark or Unlit), none on Cue, Skip, or segment change. After onboarding, read ProcessInfo.processInfo.arguments once: -ReviewScreen today stays on Ritual, log switches to History, goals switches to Settings. Contact URL https://bobeche-wick.pro/contact-us lives on Settings. Skip onboarding on Simulator after the boc.demo.v1 seed so the hook can fire.

### 3.6 Screen composition contract

Context menu dashboard. Physical screens: Ritual, History, Settings. Ritual is home: tonight's glass taper fills remaining height and the iPad width; Light, Cue, Skip, and Snuff are on-canvas Buttons; a context menu on the taper and on each chamber shows status and Write Line on Reflect only; ReviewScreen today. History is the same root switched to a flat list of NightMarks, Latches, Hollows, and the consecutive NightMark streak, not hours slept; ReviewScreen log. Settings is the third segment: contact URL, re-run onboarding, confirmed resetAllData; ReviewScreen goals. Onboarding is a one-shot cover of three pages with Continue or Next at the bottom full width. Empty Ritual is a full page: Build tonight's rite. Skip a block if you must. Empty History is a full page with generated art, one headline, one line, and a full-width CTA back to Ritual. Seeded Ritual is Ready so Snuff is enabled; Unlit is a test fixture, not the first frame. No Today, Scan, Search, or Goals screens. No title screen named Bobeche. No sleep-lab score. ReviewScreen today, log, and goals must open three different screens.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

---

## 4. Target file organization

Scheme: **By taper role (Taper, Chamber, Cue, Latch, Hollow, NightMark)**

```
Bobeche/
  Taper/
Chamber/
Cue/
Latch/
Hollow/
NightMark/
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Ritual
A first-class screen for **Ritual**. Must render empty, populated and error states.

### 5.3 History
A first-class screen for **History**. Must render empty, populated and error states.

### 5.4 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.5 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.6 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **RitualSession** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **Ocean glass depth**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#141F1A` | Screen background |
| `surface` | `#1C2B25` | Cards, rows, sheets |
| `ink` | `#EDF2F0` | Primary text and icons |
| `accent` | `#69D3A7` | Primary action, key figure, progress fill |
| `muted` | `#91ACA0` | Secondary text, dividers, disabled |

Define these as named colours in `Assets.xcassets` and reach them through one
typed accessor. Never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **SF Pro**

Light type on glass, never a second display face. SF Pro only, reached through one type-scale accessor of at most six Dynamic Type steps. The taper Material hero uses Light (UltraLight for the one-line display) ink sitting on the blur; History and Settings use Regular body at about 17pt on opaque fill. No Font.custom, no fixedSize, no rounded design, no serif, no second family. Chamber elapsed seconds, Latch, Hollow, NightMark, and streak integers go through NumberFormatter with tabular figures. At AX5 the Light glass line truncates rather than clips; chrome stays SF Pro. Day edges use Calendar.current.startOfDay then fold to Int YYYYMMDD.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **18pt** for cards, sheets and primary surfaces; **12pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **material** — SwiftUI `Material` (`.regularMaterial` / `.thinMaterial`), reused everywhere a surface sits above another.

Primary control: **tinted glass** — primary chrome sits on a tinted translucent surface (`Material` plus the accent colour at low opacity), never plain flat colour.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI pure · take bedtimeritual**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI pure · take bedtimeritual** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

### 7.6 Taste DNA

Aesthetic: **tactile** (Tactile: one material trick (glass, clay, chunk) used once.)

Reference system: **glassmorphism** — steal rhythm and restraint, not their colours or logos.

Mood: **aquatic**.

Home rhythm (`glass-stack`, comfortable): Glass card over a depth field, then a flat list. One blur, not three.

One Material / blur surface is the hero. Everything else is opaque fill plus hairline. Do not frost the whole screen.

Type move: Light type on glass, never a second display face.

Motion (`snap`): Press scale 0.97, 140-180ms ease-out. Sheets scale 0.96 to 1 plus fade. Reduce Motion: opacity only.

Voice (`dry`): Short verbs. No warmth padding. 'Saved.' not 'Your changes were saved successfully.'

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable**

One Codable root document (schemaVersion from 1, live Taper, Chamber walk, Latch, Hollow, NightMark, Unlit, optional Line) encoded to JSON Data in UserDefaults under a single versioned key such as boc.taper.v1. Day keys are Int in YYYYMMDD form derived from Calendar.current.startOfDay; never Date as a dictionary key. Midnight does not auto-snuff; an unsnuffed Lit taper remains home until snuffTaper. In-memory TaperStore is the source of truth; UserDefaults is the projection. Debounce writes and flush when scenePhase becomes inactive or background. Decoding failure falls back to Dark for tonight, never a crash. Views never touch UserDefaults. resetAllData() is reachable from Settings. Simulator seed only, once, behind boc.demo.v1: mark onboarding complete, file several NightMarks with Latches and Hollows so History is a used product, leave tonight Ready so Snuff is enabled, and never seed on a device.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Bobeche/1.0 (iOS; +https://bobeche-wick.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.healthcare-fitness`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Dark
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.healthcare-fitness
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Cue-then-snuff (Cue latches a chamber and opens the next; Skip writes Hollow; Snuff files the night)

Cue-then-snuff is the only home verb: tonight's taper is home, and lighting writes Flame and opens Reflect. Cue at elapsed writes a Latch and walks the flame to the next chamber; Skip writes a Hollow and walks immediately. After the third Latch or Hollow the taper is Ready; Snuff writes a NightMark and freezes the walk. Snuff on Dark writes Unlit and does not streak; an unsnuffed Lit taper stays tonight's home until Snuff. History counts NightMarks, Latches, and Hollows; streak is consecutive NightMark days, never hours slept and never a sleep-lab score. Unit-test Cue, Skip, Snuff, Unlit, and streak; a free-form breath canvas without the ordered triple fails.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **3D glass render glassmorphism · take bedtimeritual**


This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

Base prompt, reused and extended for every asset:

```
3D glass render, glassmorphism, studio-lit aquatic depth, one frosted glass taper with a drip collar and a small snuffer, refraction and soft bloom, isolated subjects, quiet uncluttered ground, no text, no letters, no logo, no photoreal stock, no specified colours, one glass hero not three stacked blurs
```

All 12 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `boc_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `boc_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `boc_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `boc_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `boc_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `boc_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `boc_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `boc_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `boc_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `boc_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `boc_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Cue-then-snuff (Cue latches a chamber and opens the next; Skip writes Hollow; Snuff files the night)' feature screen. |
| 11 | `boc_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `boc_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |

### Prompt per asset

**`boc_AppIcon`** — 1024x1024

```
A single 3D glass drip collar holding a short taper, glassmorphism, subject centred filling the canvas edge to edge, no text, no letters, no words, no alpha, no transparency, no rounded corners, no drop shadow outside the canvas
```

**`boc_Splash`** — 1290x2796

```
A tall vertical 3D glass taper in aquatic depth, frosted glassmorphism, quiet uncluttered centre band for a wordmark, no readable text
```

**`boc_Onboarding1`** — 1024x1536

```
3D glass still life of tonight's unlit taper on a depth field, the product in one glance, isolated cutout, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`boc_Onboarding2`** — 1024x1536

```
3D glass mid-gesture: a snuffer lowering onto a lit taper after three chambers, glassmorphism, isolated cutout, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`boc_Onboarding3`** — 1024x1536

```
3D glass taper after a filed night: snuffed wick, three latched chambers along one stem, isolated cutout, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`boc_EmptyHome`** — 1024x1024

```
An empty 3D glass taper with a cold wick, waiting to be lit, calm and inviting, never sad, isolated cutout, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`boc_EmptyList`** — 1024x1024

```
An empty 3D glass shelf of unfiled night collars, calm, isolated cutout, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`boc_CardBackdrop`** — 1200x800

```
Abstract low-contrast 3D frosted glass depth and faint taper glow, quiet enough for text on top, filling the canvas, no letters
```

**`boc_ControlFace`** — 512x512

```
The face of a small glass snuffer cone, 3D glass cutout, isolated, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`boc_TwistHero`** — 1024x1024

```
3D glass emblem of cue-then-snuff: a latched chamber glow walking into a snuffer, glassmorphism cutout, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`boc_SuccessMark`** — 512x512

```
A snuffed glass wick with a quiet NightMark bead, 3D glass cutout, confirmation not fireworks, no letters

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`boc_HeaderDecor`** — 1200x600

```
A wide low 3D glass band of a taper stem and drip collar, frosted glassmorphism, low contrast, no readable text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated subject, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`boc.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.


---

## 17. Tests

Add a unit test target `BobecheTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. Parse `ProcessInfo.processInfo.arguments` once after onboarding. 
   `-ReviewScreen today|log|goals` switches the running app's live navigation.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Bobeche -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Taper ADT fold (Dark | Lit | Ready | Snuffed); the night is a fold over Chambers; Cue writes a Latch and opens the next; Skip writes a Hollow; Snuff writes a NightMark and freezes** with no leakage across layers.
- [ ] UI approach matches **SwiftUI pure · take bedtimeritual**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Taper-segment chrome (one root; Ritual History and Settings switch in place as segments)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **SF Pro** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Bobeche
xcodegen generate
xcodebuild -scheme Bobeche -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
xcrun simctl list devices available
xcodebuild -scheme Bobeche -destination 'platform=iOS Simulator,id=<UDID>' test
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY or DEVELOPMENT_TEAM in project.yml — CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
