# Arvia Yapılacaklar — Second Pass Report

**Date:** 2026-07-01  
**Project:** Arvia — VehicleDossierApp (Ruhsatim)  
**Focus:** Yapılacaklar (Todos) screen only — scale, readability, and hierarchy  
**Base commit:** `c760dfdfc3112841b1741ac40d67fc543330ce5f`

---

## Files Changed

| File | Change |
|------|--------|
| `Features/Reminders/ReminderListView.swift` | **202 lines touched** — summary counters, reminder row padding/typography, status chips, group headers |
| `Features/Reminders/TodosView.swift` | **40 lines touched** — title size/weight, spacing, toolbar |

No other files modified. `VehicleDetailView.swift` shows in the working tree (from a previous uncommitted iteration) but is unrelated to this round.

---

## 1. Header Refinements

### TodosView

**Before:**
```swift
Text("Yapılacaklar")
    .font(AppTypography.sectionTitle)  // 22pt semibold
    .padding(.top, AppSpacing.sm)      // 12pt top
```

**After:**
```swift
Text("Yapılacaklar")
    .font(.system(size: 28, weight: .bold))  // 28pt bold
    .padding(.top, AppSpacing.md)            // 16pt top
```

| Metric | Before | After |
|--------|--------|-------|
| Title size/weight | 22pt semibold (`sectionTitle`) | **28pt bold** — feels like a main tab screen |
| Title-to-subtitle spacing | `AppSpacing.xs` (8pt) | **`AppSpacing.sm`** (12pt) |
| Bottom subtitle padding | `AppSpacing.xxs` (4pt) | **`AppSpacing.xs`** (8pt) |
| Top section padding | `AppSpacing.sm` (12pt) | **`AppSpacing.md`** (16pt) |
| Plus button weight | `.body.weight(.semibold)` | unchanged |

The 28pt bold title makes "Yapılacaklar" read as the primary tab identity. The increased spacing gives the header room to breathe.

---

## 2. Summary Counter Refinements

| Metric | Before | After |
|--------|--------|-------|
| Count font | 20pt semibold | **24pt bold** |
| Label font | `AppTypography.caption` (12pt) | **`AppTypography.captionMedium`** (13pt medium) |
| Icon size | `.caption2.weight(.medium)` (~11pt) | **`.caption.weight(.semibold)`** (~12pt) |
| Icon-count spacing | 4pt | **6pt** |
| Count-label spacing | 2pt | **4pt** |
| Container vertical padding | `AppSpacing.sm` (12pt) | **`AppSpacing.md`** (16pt) |
| Divider height | 36pt | **40pt** |

The counter numbers are now noticeably larger (24pt bold), making the summary block feel like a vehicle dashboard status readout rather than a compressed stat bar. Label text at captionMedium provides better readability. The card container has more internal padding (16pt vs 12pt), giving the summary more presence without becoming "toy-like."

Color logic unchanged: counters display in their urgency color only when > 0. At zero they fall to `textTertiary` — calm, no false urgency.

---

## 3. Reminder Row Refinements

### Vertical Height

**Before:** `.padding(.vertical, AppSpacing.xxs)` = **4pt** — rows felt compressed and tight  
**After:** `.padding(.vertical, AppSpacing.xs)` = **8pt** — rows now have comfortable breathing room

This is the single most impactful change for row readability. Combined with the insetGrouped list style's default section padding, each row now has proper vertical space.

### Title Readability

- `.lineLimit(1)` retained — prevents layout breaks from long Turkish compound words
- `.font(AppTypography.bodyMedium)` (16pt medium) unchanged — well-balanced for primary content
- Internal `VStack.spacing` increased from 3pt → **4pt** — better separation between title and metadata line

### Vehicle Plate / Metadata Line

- **`.layoutPriority(1)`** added to the vehicle plate text — prevents the plate from being compressed or truncated when the status badge takes space
- Separator dot opacity reduced from 0.5 → **0.4** — even more subtle, keeps focus on the data
- All other metadata styling unchanged

### Status Chip Readability

| Metric | Before | After |
|--------|--------|-------|
| Badge font size | 11pt medium | **12pt medium** |
| Badge horizontal padding | `AppSpacing.xs` (8pt) | **`AppSpacing.sm`** (12pt) |
| Badge vertical padding | 3pt | **4pt** |
| Gauge icon size | 8pt semibold | **9pt semibold** |

The status chip is now slightly larger (12pt text, 4pt vertical padding) making it more readable at a glance, especially for values like "5 gün gecikti" or "1.500 km kaldı". The 12pt text ensures dates like "26 Haz 2026" don't feel cramped or split awkwardly.

### Color Scheme (Unchanged — Already Correct)

- **Red (critical):** Overdue and km-overdue items
- **Amber (warning):** Today's items and km-upcoming items
- **Teal (accentPrimary):** Date-based upcoming and later items

This matches the spec: red only for overdue, amber for km-based, teal/green for upcoming.

### Badge Layout

- Km-based badges (non-overdue, non-today) retain the `gauge.with.needle` icon prefix for quick visual scanning
- All other date-based badges show plain text

---

## 4. Group Section Header Refinements

**Before:**
```swift
HStack(spacing: AppSpacing.xxs) {
    Image(systemName: icon).font(.caption.weight(.semibold))
    Text(title).font(AppTypography.captionMedium)       // 13pt medium
    Text("· \(reminders.count)").font(AppTypography.caption).foregroundColor(AppColors.textTertiary)
}
```

**After:**
```swift
HStack(spacing: AppSpacing.xs) {
    Image(systemName: icon).font(.caption.weight(.semibold))
    Text(title).font(AppTypography.bodyMedium).fontWeight(.medium)   // 16pt medium
    Text("· \(reminders.count)").font(AppTypography.caption).foregroundColor(AppColors.textTertiary)
}
```

| Metric | Before | After |
|--------|--------|-------|
| Title font | `captionMedium` (13pt medium) | **`bodyMedium` + `.fontWeight(.medium)`** (16pt medium) |
| HStack spacing | `AppSpacing.xxs` (4pt) | **`AppSpacing.xs`** (8pt) |

The section titles ("Gecikenler", "Bugün", "Yaklaşanlar", "Daha Sonra") are now 16pt medium — significantly more readable than 13pt. The increased spacing between icon, title, and count prevents crowding. `.textCase(nil)` preserved to keep Turkish casing.

---

## 5. Completion Affordance

No changes to completion behavior. The trailing swipe action ("Tamamla", tinted `.success`) remains the completion mechanism. No visible check button was added to the row — the row stays clean and swipe-based.

---

## 6. Bottom Tab Safe Area

The `.insetGrouped` list style continues to handle safe area insets correctly. The List's bottom inset ensures content scrolls above the floating tab bar. No changes needed.

---

## 7. Preview States

| File | Preview | Status |
|------|---------|--------|
| `TodosView.swift` | "Yapılacaklar — Boş" | ✅ |
| `TodosView.swift` | "Yapılacaklar — Dolu" | ✅ |
| `TodosView.swift` | "Yapılacaklar — Dolu Dark" | ✅ |
| `TodosView.swift` | "Yapılacaklar — Dynamic Type" | ✅ |
| `ReminderListView.swift` | "Hatırlatıcı Listesi — Dolu" | ✅ |
| `ReminderListView.swift` | "Hatırlatıcı Listesi — Dark Mode" | ✅ |
| `ReminderListView.swift` | "Hatırlatıcı Listesi — Dinamik Tip" | ✅ |

All 7 previews compile.

---

## 8. Build Result

```
** BUILD SUCCEEDED **
```

- Scheme: `Ruhsatim`
- SDK: `iphonesimulator` (iOS 17.0)
- Architecture: `arm64` simulator
- No warnings introduced

---

## 9. Test Result

```
Test Suite 'All tests' passed at 2026-07-01 11:24:32.085
     Executed 149 tests, with 0 failures (0 unexpected) in 0.149 (0.183) seconds
```

All 149 tests passed. No regressions.

---

## 10. Known Limitations

- **`VehicleDetailView.swift`** appears in the working tree diff from a prior uncommitted round. This round only modified `ReminderListView.swift` and `TodosView.swift`.
- **SourceKit diagnostics** show "Cannot find type" errors in Xcode's editor for `Reminder`, `Vehicle`, `AppNavigationRouter`, etc. These are background indexing false positives. The actual `xcodebuild` compilation and test execution both succeed.
- **No changes to logic:** Grouping, filtering, completion, deletion, notification scheduling, and repeat rules are entirely untouched.
- **No changes to the Reminder model, Enums, or Services.**
- **Row vertical padding** increased from 4pt to 8pt. Combined with `.insetGrouped` section insets, rows now have cleaner height. If very long lists need to show more items without scrolling, this is the trade-off.
