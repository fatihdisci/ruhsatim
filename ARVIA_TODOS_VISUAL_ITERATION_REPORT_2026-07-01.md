# Arvia Yapılacaklar — Visual Iteration Report

**Date:** 2026-07-01  
**Project:** Arvia — VehicleDossierApp (Ruhsatim)  
**Focus:** Yapılacaklar (Todos) screen only — visual refinement, no new features  
**Base commit:** `c760dfdfc3112841b1741ac40d67fc543330ce5f`

---

## Files Changed (This Iteration)

| File | Change | 
|------|--------|
| `Features/Reminders/ReminderListView.swift` | **193 lines touched** — summary counters, section headers, row redesign, km chip, empty state, preview |
| `Features/Reminders/TodosView.swift` | **40 lines touched** — screen header with supporting copy, toolbar styling |

No other files modified.

---

## 1. Top Header / Screen Identity

### TodosView

**Before:** Plain `.navigationTitle("Yapılacaklar")` with a basic `+` toolbar button. The screen had no visual identity beyond the system navigation bar.

**After:**
- Navigation bar background hidden (`toolbarBackground(.hidden, for: .navigationBar)`), keeping the nav back-button behavior but letting the screen define its own header
- A custom header section added below the navigation area:
  - **Title:** "Yapılacaklar" at `AppTypography.sectionTitle` (22pt semibold) — matches the screen's purpose
  - **Description:** "Geciken, bugün ve yaklaşan araç işlerini öncelik sırasıyla takip et." in `AppTypography.secondary` — provides vehicle ownership context
- Plus button styling refined: `.font(.body.weight(.semibold))` for slightly more presence

The header now communicates that this is a vehicle action center, not a generic to-do list.

### ReminderListView (standalone mode)

When `showHeader: Bool = true` (used in the "İşler" tab), the same description text appears as a section at the top of the list. `TodosView` passes `showHeader: false` since it provides its own header.

---

## 2. Summary Counters

**Before:** Three `summaryItem` views in an `HStack`, each being a full-width `VStack` with icon (`title3`), count (`amount` font), and label (`caption`) on a `color.opacity(0.06)` rounded background with no border. The layout felt like generic task statistics in a simple colored box.

**After:**
- Counters are now displayed in a **unified card** with `.appSurface` background and a subtle `.border.opacity(0.42)` stroke — feels more like a vehicle dashboard status module
- Each counter uses a **horizontal layout** (icon + count on one line, label below) — tighter, more like a spec-sheet than a stat block
- Count font increased to `system(size: 20, weight: .semibold)` with `.monospacedDigit()` and `.contentTransition(.numericText())` — cleaner numbers, ready for animated updates
- **Color logic refined:** counters only use their urgency color (critical/warning/accent) when `count > 0`. When count is zero, color falls back to `AppColors.textTertiary` — calmer, avoids false urgency
- **Dividers** (36pt height) separate the three counters, replacing the full-width colored blocks — cleaner visual segmentation
- Spacing reduced from `AppSpacing.md` (16pt) between items to 0 with dividers

| Before | After |
|--------|-------|
| Three separate colored boxes | Unified card with subtle border |
| Icon + count stacked | Icon + count horizontal |
| Always colored (even at 0) | Muted when empty, urgent when non-zero |
| No visual separation | Clean vertical dividers |
| `amount` font (20pt semibold) | `system(20, .semibold)` + `.monospacedDigit()` |

---

## 3. Section Headers / Reminder Grouping

**Before:** Standard iOS list section header with icon (`caption`), title, and `.count` in `textTertiary`. Used `.font(AppTypography.captionMedium)` and native `foregroundColor`.

**After:**
- Icon increased to `.caption.weight(.semibold)` — slightly more presence
- `.textCase(nil)` added to prevent iOS from auto-uppercasing the Turkish headers
- All grouping logic remains unchanged (Gecikenler → Bugün → Yaklaşanlar → Daha Sonra)
- Section ordering, filtering, and counting untouched

The section headers now feel intentional rather than inherited from the system, while staying quiet enough to not compete with the content.

---

## 4. Reminder Row Redesign

The core visual change. `ReminderRow` was rebuilt to feel vehicle-specific rather than a generic task row.

### Changed:

**Icon area:**
- Circle increased from 32pt → **38pt** for more presence
- SF Symbol font changed from `.body` → `system(size: 15, weight: .semibold)` — cleaner icon rendering inside the larger circle
- Background fill stays at `statusColor.opacity(0.1)` — subtle but visible

**Title:**
- `.lineLimit(1)` added — prevents long Turkish compound words from breaking layout unpredictably (no truncation for standard reminder titles)
- Font unchanged (`bodyMedium`), color unchanged (`textPrimary`)

**Vehicle information — the key automotive touch:**
- A small `car.fill` icon (8pt) now precedes the vehicle plate/text — instantly signals vehicle context at a glance
- `.lineLimit(1)` added to vehicle plate for safety
- All existing formatting preserved (plate vs. fullName fallback)

**Date/km info line:**
- Separator dot opacity reduced to `opacity(0.5)` — less visually dominant
- When a reminder has both a date AND odometer threshold, the odometer is shown only as the threshold value (e.g., "100.000 km"), not a gauge icon — prevents implying automatic tracking
- Date shown first if available, km threshold shown second if date is absent

**Status badge:**
- Font weight changed to `.medium` (from `.regular`), same 11pt size
- Badge background opacity at `statusColor.opacity(0.1)` — consistent, clean
- **km-based status gets a gauge icon** inside the badge — a subtle `gauge.with.needle` SF Symbol at 8pt precedes the text for km-upcoming/km-overdue statuses. This makes km-based tasks visually distinct without being loud.
- Badge text uses the same `statusText` source as the accessibility label — single source of truth, no duplication

### Preserved:

- `statusColor` computed property — unchanged logic
- `statusText` computed property — unchanged logic (no "Gecikti Gecikti" issue here)
- Swipe actions (trailing: Tamamla, leading: Sil)
- Tap behavior → `ReminderDetailView`
- Accessibility labels

---

## 5. Completion Action

No visible completion button was added to the row. Completion is handled via the existing **trailing swipe action** ("Tamamla" tinted `.success`). This keeps the row clean and avoids the "huge floating check button" issue.

The completion logic itself is unchanged — it marks the reminder as completed, handles repeat rules, and schedules the next occurrence.

---

## 6. Km-Based Reminders

Km-based reminders now get a **distinct visual treatment**:

- In the `statusBadge`, km-based reminders (where `reminder.dueOdometer != nil`) that are not overdue/today show a small **`gauge.with.needle` icon** (8pt, semibold) inside the status capsule
- This visually distinguishes "1.500 km kaldı" from "21 gün kaldı" at a glance
- The icon is subtle — 8pt, same color as the text — not loud
- **No automatic odometer tracking is implied:** the km values shown are user-entered thresholds, and the status text makes clear it's a remaining/overdue calculation against the user's manually updated odometer
- Overdue km reminders still show the critical color badge with the gauge icon

---

## 7. Empty State

**Before:**
```swift
EmptyStateView(
    icon: "checklist",
    title: "Yaklaşan iş yok",
    description: "Muayene, sigorta, bakım ve MTV gibi tarihleri ekleyerek aracını düzenli takip edebilirsin.",
    actionTitle: "Yapılacak Ekle",
    ...
)
```

**After:**
```swift
EmptyStateView(
    icon: "calendar.badge.clock",
    title: "Şu anda takip etmen gereken bir araç işi yok.",
    description: "Muayene, sigorta, bakım ve MTV gibi tarihleri ekleyerek aracını düzenli takip edebilirsin.",
    actionTitle: "Hatırlatıcı Ekle",
    ...
)
```

Key changes:
- **Icon:** `"calendar.badge.clock"` replaces `"checklist"` — removes the task-app checkbox feel, replaces with a scheduling/calendar metaphor more appropriate for upcoming vehicle tasks
- **Title:** Updated to the specified reassuring copy — feels calmer and more vehicle-specific
- **CTA:** "Hatırlatıcı Ekle" (Add Reminder) replaces "Yapılacak Ekle" (Add To-Do) — reinforces the reminder/vehicle context
- Description text preserved — it already correctly lists vehicle-related dates (muayene, sigorta, bakım, MTV)

---

## 8. Add Button / Top Action

The `+` toolbar button in TodosView is preserved. Its styling was slightly refined:
- `.font(.body.weight(.semibold))` — slightly bolder presence
- `.foregroundColor(AppColors.accentPrimary)` — unchanged
- `.accessibilityLabel("Yapılacak Ekle")` — unchanged

---

## 9. Bottom Tab Safe Area

The `.insetGrouped` list style automatically handles safe area insets. The List's content extends below the last visible row with proper spacing from the floating tab bar. No adjustments were needed.

---

## 10. Preview States

All previews compile:

| File | Preview | Status |
|------|---------|--------|
| `TodosView.swift` | "Yapılacaklar — Boş" (empty container) | ✅ |
| `TodosView.swift` | "Yapılacaklar — Dolu" (populated) | ✅ |
| `TodosView.swift` | "Yapılacaklar — Dolu Dark" (dark mode) | ✅ |
| `TodosView.swift` | "Yapılacaklar — Dynamic Type" (accessibility1) | ✅ |
| `ReminderListView.swift` | "Hatırlatıcı Listesi — Dolu" (populated) | ✅ |
| `ReminderListView.swift` | "Hatırlatıcı Listesi — Dark Mode" (dark mode) | ✅ |
| `ReminderListView.swift` | "Hatırlatıcı Listesi — Dinamik Tip" (new, accessibility1) | ✅ |

---

## 11. Build Result

```
** BUILD SUCCEEDED **
```

- Scheme: `Ruhsatim`
- SDK: `iphonesimulator` (iOS 17.0)
- Architecture: `arm64` simulator
- No warnings introduced

---

## 12. Test Result

```
Test Suite 'All tests' passed at 2026-07-01 11:21:49.648
     Executed 149 tests, with 0 failures (0 unexpected) in 0.156 (0.191) seconds
```

All 149 tests passed. No regressions.

---

## 13. Known Limitations

- **VehicleDetailView.swift** shows in the git diff (306 lines from the previous micro-fix pass), but those changes are unrelated to this Todos iteration. This round only touched `ReminderListView.swift` and `TodosView.swift`.
- **SourceKit diagnostics** show "Cannot find type" errors in Xcode's editor for `Reminder`, `Vehicle`, `AppNavigationRouter`, etc. These are background indexing false positives — the actual `xcodebuild` compilation and test execution both succeed.
- **No changes to grouping logic:** All reminder grouping (overdue, today, upcoming, later) remains identical. Only the visual presentation of groups and rows was changed.
- **No changes to business logic:** Completion, deletion, notification scheduling, repeat rules, and reminder detail/edit flows are untouched.
- **The `RemindersView` ("İşler" tab)** was not modified but uses the same `ReminderListView`. When viewed in that tab, `showHeader` defaults to `true`, showing the same description text. This was intentional to avoid duplicating the list component.
