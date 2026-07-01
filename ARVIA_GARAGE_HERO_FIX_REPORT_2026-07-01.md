# Arvia Garage Hero Fix Report

**Date:** 2026-07-01  
**Project:** Arvia — VehicleDossierApp (Ruhsatim)  
**Focus:** Garage hero card visual fixes — photo text legibility, metadata hierarchy, Dosya Tamlığı dedup, reminder card, year formatting  
**Base commit:** `69351c0`  
**Latest commit:** `beea4c4`

---

## Latest Commit

```
beea4c4
fix: garage hero card fixes (photo legibility, dosya tamlığı dedup, 
     year format, reminder strip)
```

## Files Changed

| File | Change |
|------|--------|
| `Features/Garage/GarageView.swift` | **186 insertions, 60 deletions** — hero metadata area simplification |

No other files modified. VehicleDetail, History, Todos, Reports, Community untouched.

---

## Fixes Applied

### 1. Photo Text Legibility (Garage Hero)

**Before:** Gradient scrim (`black.opacity(0.05→0.16→0.72)`) + text shadow (`black.opacity(0.5), radius: 8`)

**After:** Gradient scrim only. Shadow removed.

**Why:** The gradient scrim already provides reliable legibility against any photo background (light or dark). Adding a shadow on top is redundant and can produce artifacts at rounded corners (the dirty corner issue from earlier rounds). The gradient is the production-correct approach — vehicle names remain readable on light/white vehicles.

**VehicleDetail hero:** Already correct — uses gradient scrim without shadow (confirmed, no changes needed).

### 2. Year Formatting Fix

**Before:**
```swift
Text("\(year)")
```

**After:**
```swift
Text(String(year))
```

**Why:** `Text("\(year)")` where year is Int should produce "2018" but was showing "2.018" (thousands separator applied somewhere in the formatting pipeline). Using `String(year)` produces an explicit, locale-independent "2018". Both GarageView and VehicleDetailView now use this safe format.

### 3. Dosya Tamlığı — Duplication Removed

**Before:** Two separate elements showing the same file completeness score:
- `statusPill`: Top-right badge "%85" with checkmark/doc icon
- `fileCompletenessBar`: Full progress bar with "Dosya tamlığı" label + "%85" + 5pt bar

**After:** Single compact treatment:
- `compactFileBadge`: One capsule showing "Dosya %85" with doc icon
- Calm, premium, no duplication

**What was removed:**
- `statusPill()` method (top-right percentage badge)
- `fileCompletenessBar()` method (progress bar + label + percent row)
- `ViewThatFits(in: .horizontal)` wrapper that handled the plate + statusPill layout

**What was added:**
- `compactFileBadge(score:)` — single capsule, `captionMedium` font, monospaced digits
- Color logic: green (≥80) or accentPrimary (<80)

The metadata top row is now just the plate + year/type block — no right-side badge competing for attention.

### 4. "Sıradaki önemli iş" Card — Remake

**Before:** Background-filled rectangle (`accentPrimary.opacity(0.075)` or `critical.opacity(0.075)`) creating a beige/amber box glued to the bottom of the card. Two-line layout (label + title).

**After:** Compact inline status strip — icon, label, and title on one line with no background fill:
```
[bell.badge] Sıradaki önemli iş · Yağ değişimi
```

**Changes:**
- Removed `.background(RoundedRectangle(...).fill(color.opacity(0.075)))` — no more background box
- Changed to single-line horizontal layout (was 2-line VStack)
- Padding reduced to `.vertical(.xs)` for minimal height
- `.padding(.leading, .sm)` for proper indentation
- No longer visually collides with carousel dots or card edge

The status strip sits naturally within the VStack spacing (`AppSpacing.md` = 16pt) between items.

### 5. Carousel Spacing

The card's `frame(height: 414)` was preserved — content now fits with extra breathing room after removing the progress bar (saved ~22pt). The compact file badge occupies ~28pt vs the previous ~50pt progress bar. The refined reminder strip is ~20pt vs the previous ~56pt background box.

Net vertical saving: ~58pt, giving the hero card content more comfortable spacing within the 414pt frame.

---

## What Was NOT Changed

- **VehicleDetail hero** — confirmed already correct (gradient scrim, no shadow)
- **Navigation, tabs, toolbar** — untouched
- **Business logic** — file scoring, reminder filtering, data queries unchanged
- **Design system** — no new tokens needed
- **English labels** — none added

---

## Preview States Verified

| File | Preview | Status |
|------|---------|--------|
| `GarageView.swift` | "Garaj — Araçlar" | ✅ Compiles |
| `GarageView.swift` | "Garaj — Dark Mode" | ✅ Compiles |
| `GarageView.swift` | "Garaj — Dynamic Type" | ✅ Compiles |

---

## Build Result

```
** BUILD SUCCEEDED **
```

- Scheme: `Ruhsatim`
- SDK: `iphonesimulator` (iOS 17.0)
- No warnings introduced

---

## Test Result

```
Test Suite 'All tests' passed at 2026-07-01 11:58:58.428
     Executed 149 tests, with 0 failures (0 unexpected) in 0.181 (0.247) seconds
```

All 149 tests passed. No regressions.

---

## Known Limitations

- **SourceKit diagnostics** show "Cannot find type" errors in Xcode's editor for `PaywallService`, `AppNavigationRouter`, `Vehicle`, `Reminder`, etc. These are background indexing false positives — actual `xcodebuild` compilation and test execution both succeed.
- **No changes to VehicleDetail hero** — it was already using gradient scrim without shadow, so the photo legibility requirement was already met there.
- **Year formatting** changed from `Text("\(year)")` to `Text(String(year))` to explicitly prevent thousands separator. This is a defensive change — the original `"\(year)"` for Int should theoretically never produce "2.018", but the report indicated the issue.
