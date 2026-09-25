<!-- gf-brief source=7b4f4353f6317e6501724bab1630b84661e5070575566a6a0470693ceaa3bc19 written=2026-09-26T01:41:44+03:00 -->
# Bobeche

## What it is
Bobeche is a dark, portrait evening ritual for people who want a short wind-down before sleep. You light tonight’s taper, sit through Reflect, Breathe, and Ambient (or Skip), then Snuff to file a NightMark and keep a streak of consecutive NightMark days.

## Launch and onboarding
Cold launch shows a brief loading state (spinner while tonight’s taper is read), then the main shell with the **Taper** segmented control: **Ritual**, **History**, **Settings**. Dark appearance is forced.

If onboarding is not finished, a full-screen cover appears and cannot be dismissed by gesture. Three pages, in order:

1. Title **Walk tonight's taper**. Body **Light the wick. Reflect, then Breathe, then Ambient.** Buttons **Next** and **Skip**.
2. Title **Cue, Skip, Snuff**. Body **Cue latches a chamber when it is due. Skip writes a Hollow and walks on.** Buttons **Next** and **Skip**.
3. Title **File the night**. Body **Snuff files a NightMark. History counts nights, not hours slept.** Buttons **Continue** and **Skip**.

**Next** advances the page. **Continue** or **Skip** finishes onboarding and lands on **Ritual**. Onboarding can be shown again later from **Settings** via **Re-run onboarding**.

On first launch the system may also show the standard notifications permission alert.

## Screens

### Ritual
Segment title **Ritual**.

**Empty (no walk yet):** Headline **Build tonight's rite**. Line **Skip a block if you must.** Button **Light the taper** (starts the walk).

**Fault:** Headline **Tonight's taper could not be read**. Supporting line is the fault text, or **The last copy failed. Try again.** Button **Retry**.

**Populated:** Dynamic title and line (examples):
- **Light tonight's taper** / **Reflect, then Breathe, then Ambient. Snuff files the night.**
- **Sit through Reflect** / **Cue when the chamber is due. Skip writes a Hollow.**
- **Sit through Breathe** / **Cue at elapsed. Skip walks on.**
- **Sit through Ambient** / **Glow is the room. Cue or Skip, then Snuff.**
- **Snuff the taper** / **Tonight is Ready. Snuff files a NightMark.**
- **Tonight is filed** / **History counts NightMarks and Latches.**
- **Unlit** / **This day does not streak.**

Chip **Cue then Snuff** opens the **Cue then Snuff** sheet.

Glass card shows the wick and three chambers along it: **Reflect**, **Breathe**, **Ambient**. Open chamber status looks like **Open. N s left**. Sealed chambers show **Latch. N s** or **Hollow**; unopened show **Wait**.

Controls:
- **Snuff** — detail **Walk first** while still walking; **Files tonight** when Ready; **Writes Unlit** when still Dark. Files a NightMark when Ready, or Unlit when Dark.
- **Light** — lights the taper and opens Reflect (only when Dark).
- **Cue** — detail **Due** when ready, otherwise **N s**; latches the open chamber and opens the next when the wait is over.
- **Skip** — detail **Writes a Hollow**; skips the open chamber immediately.

Banners may show fault text with **Retry**, or **Restored from a backup copy.** with **OK**.

Night rail: **Streak** and **NightMarks** counts (tap opens **History**). Up to two recent **NightMark** rows also open **History**.

Long-press on the taper card: **Write Line** (when allowed), **Cue then Snuff**, **Jump History**. On a chamber: **Write Line** (Reflect when allowed), **Jump History**. Tapping Reflect (when a line can be written) opens **Write Line**; tapping a sealed chamber jumps to **History**; tapping an unsealed chamber opens **Cue then Snuff**.

### History
Segment title **History**.

**Empty:** Headline **No nights filed**. Line **Snuff a Ready taper to write the first NightMark.** Button **Open Ritual**.

**Fault:** Headline **History could not be read**. Supporting line as above. Button **Retry**.

**Populated:** Large streak number with **Consecutive NightMark days**, plus **NightMarks N**, **Latches N. Hollows N**. Scrollable filings titled **NightMark**, **Latch Reflect|Breathe|Ambient**, **Hollow Reflect|Breathe|Ambient**, or **Unlit**, with lines such as **N Latches, N Hollows** (plus optional saved line), **N s**, **Skipped**, or **No streak**, and a medium-style date.

### Settings
Segment title **Settings**.

**Empty:** **No nights on this device**. **Contact stays here. Light a taper from Ritual.** Contact row (below). Buttons **Open Ritual**, **Re-run onboarding**, **Reset all data** (detail **Erase nights on this device**).

**Fault:** Headline **Settings could not be read**. Button **Retry**.

**Populated:** Current job title, copy **Cue writes a Latch. Skip writes a Hollow. Snuff files a NightMark.**, chamber stage, figures **NightMarks**, **Latches**, **Hollows**, **Streak**. Contact row. Buttons **Cue then Snuff** (detail **How the walk files a night**), **Re-run onboarding**, **Reset all data** (detail **Erase nights on this device**).

**Contact** shows label **Contact** and opens `https://bobeche-wick.pro/contact-us` (URL shown on screen).

**Reset all data** confirmation: title **Erase all nights?** Message **Latches, Hollows, and NightMarks leave this device.** Actions **Erase all nights** / **Keep**.

### Cue then Snuff (sheet)
Title **Cue then Snuff** with **Close**.

**Empty:** **Cue latches. Skip hollows.** / **Snuff files the night. Light tonight's taper to begin.** Button **Open Ritual**.

**Fault:** **The walk could not be read.** Button **Retry**.

**Populated:** Latch count, **Latches on this device**, body **Cue latches a chamber and opens the next. Skip writes a Hollow. Snuff files the night.**, caption **Hollows N. NightMarks N.**, current job line, button **Open Ritual**.

### Write Line (sheet)
Title **Write Line** with **Close**. Copy **One line on Reflect. Not a journal.** Field placeholder **Quiet water**. **Save** (disabled until there is non-blank text). Keyboard **Done**. Faults may appear under the field (for example **Write one line first.** / **Line sits on Reflect only.**).

## Features
- Segmented **Ritual** / **History** / **Settings** taper shell
- Light tonight’s taper and walk **Reflect** → **Breathe** → **Ambient**
- Timed **Cue** (Latch) vs immediate **Skip** (Hollow)
- **Snuff** to file a **NightMark** when Ready, or **Unlit** when still Dark
- Streak of consecutive **NightMark** days (Unlit does not streak)
- Optional one-line note on Reflect via **Write Line**
- **Cue then Snuff** explainer sheet
- Onboarding with **Next** / **Continue** / **Skip**; **Re-run onboarding** from Settings
- **Contact** support link
- **Reset all data** with confirmation
- Local history of NightMarks, Latches, Hollows, and Unlits

## Behaviours that can look like bugs
- **Cue** stays disabled until the open chamber’s wait ends (**Reflect** 90 s, **Breathe** 120 s, **Ambient** 90 s); detail shows remaining **N s**, then **Due**. Wait it out or use **Skip**.
- **Snuff** shows **Walk first** and stays disabled while a chamber is still open; finish with **Cue** or **Skip** until Ready (**Snuff the taper** / **Files tonight**).
- **Light** only works when Dark; after **Snuff**, **Light** stays off until the next calendar day returns the taper to Dark.
- **Snuff** while still Dark is allowed and writes **Unlit** (**Writes Unlit**); that day does not streak — intentional miss, not a crash.
- **Save** on **Write Line** is disabled until the field has text; blank save surfaces **Write one line first.**
- **Write Line** only when Reflect is open or already sealed; otherwise **Line sits on Reflect only.**
- Empty **History**: **No nights filed** until you **Snuff** a Ready taper.
- Empty **Ritual**: **Build tonight's rite** until **Light the taper**.
- Empty **Settings**: **No nights on this device** until a walk exists; **Contact** and reset/onboarding still work.
- After Snuff, title **Tonight is filed** (or **Unlit**); further Cue/Skip/Light refuse until the next Dark night.
- Fault screens (**Tonight's taper could not be read**, and similar) need **Retry**. Banner **Restored from a backup copy.** dismisses with **OK**.
- Onboarding cover cannot be swiped away; use **Continue** / **Skip** (or finish the pages with **Next** then **Continue**).

## Starter content and resume
On the Simulator only, first launch may seed demo nights (sample NightMarks with lines such as **Still pond.**, **Low wick.**, **Filed.**, and a Ready taper with line **Ready to snuff.**). On a device, no seeded nights.

Unfinished work resumes: a lit or Ready taper, history, and the optional Reflect line stay on the device across launches. After Snuff, the next Dark night starts on a later calendar day.

## Permissions
- Notifications: asked on cold launch (system alert). No custom usage-description string in the build settings.
- Camera: usage description present — **This app does not use the camera.** — but the native UI never requests camera access.

## Absent
Login or accounts; in-app purchase; ads; analytics; account deletion flow; App Tracking Transparency prompt.

User-generated content is limited to the optional one-line Reflect note (**Write Line**); there is no social or shared feed. Local erase is **Reset all data**, not account deletion.

## Data and support
NightMarks, Latches, Hollows, Unlits, and the Reflect line stay on this device (confirmed by reset copy: **Latches, Hollows, and NightMarks leave this device.**).

Support: **Contact** in Settings, opening `https://bobeche-wick.pro/contact-us`.

## Scanning and health
None. No barcode or QR scanning in the native UI. No medical, clinical, or product-health claims or citations; chambers are a personal evening walk, not a health score.

## Platform
No special region gate; dates use the device locale. Portrait only on iPhone and iPad. Dark interface style. Minimum iOS 17.0.

## Category
Health & Fitness
