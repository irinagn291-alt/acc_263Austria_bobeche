# Bobeche

A short ordered evening rite. Light tonight's taper, walk Reflect then Breathe then Ambient, and snuff the flame so the night is saved. For people who want one canvas at bedtime, not a sleep lab and not a free-form breath hold.

## Architecture

The night is a **Taper** ADT whose only cases are Dark, Lit, Ready, and Snuffed. One `TaperStore` owns that value plus the fold over three Chambers in canonical order (Reflect 90s, Breathe 120s, Ambient 90s). Lighting writes Flame and opens Reflect. Cue at elapsed writes a Latch and opens the next chamber. Skip writes a Hollow and walks immediately. After the third Latch or Hollow the taper is Ready. Snuff on Ready writes a NightMark and freezes. Snuff on Dark writes Unlit and does not streak.

Views observe `WickWatch` and call `lightTaper`, `cueAtElapsed`, `skipChamber`, and `snuffTaper`. They never keep a second phase enum. The fold matches the product: the home verb is snuff-the-taper, History counts NightMarks and Latches, and an unsnuffed Lit taper stays tonight's home until Snuff.

Persistence is UserDefaults+Codable under `boc.taper.v1`. Memory is the source of truth. There is no package dependency.

## Cue then Snuff

This is why someone would pick Bobeche. Cue latches a chamber and opens the next. Skip writes a Hollow. Snuff files the night. Streak is consecutive NightMark days, never hours slept. The walk lives on Ritual. A dedicated Cue then Snuff sheet explains the same fold.

## Design

Ocean glass depth. One Material blur on the taper card over a depth field. History and Settings are opaque fill plus hairline. SF Pro only. Ritual, History, and Settings switch in place as segments on one root.

Art style: 3D glass render, glassmorphism. Base prompt reused for every asset:

```
3D glass render, glassmorphism, studio-lit aquatic depth, one frosted glass taper with a drip collar and a small snuffer, refraction and soft bloom, isolated subjects, quiet uncluttered ground, no text, no letters, no logo, no photoreal stock, no specified colours, one glass hero not three stacked blurs
```

Exact prompts:

**boc_AppIcon** — 1024x1024

```
A single 3D glass drip collar holding a short taper, glassmorphism, subject centred filling the canvas edge to edge, no text, no letters, no words, no alpha, no transparency, no rounded corners, no drop shadow outside the canvas
```

**boc_Splash** — 1290x2796

```
A tall vertical 3D glass taper in aquatic depth, frosted glassmorphism, quiet uncluttered centre band for a wordmark, no readable text
```

**boc_Onboarding1** — 1024x1536

```
3D glass still life of tonight's unlit taper on a depth field, the product in one glance, isolated cutout, no text
```

**boc_Onboarding2** — 1024x1536

```
3D glass mid-gesture: a snuffer lowering onto a lit taper after three chambers, glassmorphism, isolated cutout, no text
```

**boc_Onboarding3** — 1024x1536

```
3D glass taper after a filed night: snuffed wick, three latched chambers along one stem, isolated cutout, no text
```

**boc_EmptyHome** — 1024x1024

```
An empty 3D glass taper with a cold wick, waiting to be lit, calm and inviting, never sad, isolated cutout, no text
```

**boc_EmptyList** — 1024x1024

```
An empty 3D glass shelf of unfiled night collars, calm, isolated cutout, no text
```

**boc_CardBackdrop** — 1200x800

```
Abstract low-contrast 3D frosted glass depth and faint taper glow, quiet enough for text on top, filling the canvas, no letters
```

**boc_ControlFace** — 512x512

```
The face of a small glass snuffer cone, 3D glass cutout, isolated, no text
```

**boc_TwistHero** — 1024x1024

```
3D glass emblem of cue-then-snuff: a latched chamber glow walking into a snuffer, glassmorphism cutout, no text
```

**boc_SuccessMark** — 512x512

```
A snuffed glass wick with a quiet NightMark bead, 3D glass cutout, confirmation not fireworks, no letters
```

**boc_HeaderDecor** — 1200x600

```
A wide low 3D glass band of a taper stem and drip collar, frosted glassmorphism, low contrast, no readable text
```

## How this differs

This is the first bedtime ritual in the portfolio. Diapason is a single bellows you hold until Primed. Pugillar is a two-hand diary seam. Falspark parks a miss on a week wheel. Bobeche is a glass taper you walk in one direction: Cue latches, Skip hollows, Snuff files.

## Build

```bash
cd Bobeche
xcodegen generate
xcodebuild -scheme Bobeche -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build-for-testing
```

Simulator seed is once, behind `boc.demo.v1`. After onboarding, `-ReviewScreen today|log|goals` opens Ritual, History, and Settings.
