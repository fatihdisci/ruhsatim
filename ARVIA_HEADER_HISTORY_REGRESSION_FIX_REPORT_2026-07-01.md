# Arvia Header / History Regression Fix Report

**Date:** 2026-07-01  
**Project:** Arvia — VehicleDossierApp (Ruhsatim)  
**Focus:** Fix header/navigation/background regressions in Yapılacaklar and Geçmiş, simplify Geçmiş list  
**Base commit:** `beea4c4`  
**Latest commit:** `da74577`

---

## Latest Commit

```
da74577
fix: header/navigation regressions — restore native tab titles, 
     fix backgrounds, simplify history
```

## Files Changed

| File | Change |
|------|--------|
| `Features/Reminders/TodosView.swift` | **120 lines** — removed custom title block, native nav title, background fix |
| `Features/Records/HistoryView.swift` | **550 lines** — removed custom title block, native nav title, background fix, removed TimePeriod grouping, flattened sections, truncated subtitle fix |

No other files modified.

---

## PART 1 — Native Tab Headers Restored

### TodosView

**Before:** Custom 28pt bold "Yapılacaklar" in-content title block with supporting description, pushed below the nav area. `.toolbarBackground(.hidden)` created blank top spacing.

**After:**
- `.navigationTitle("Yapılacaklar")` with `.navigationBarTitleDisplayMode(.large)` — system-level large title
- Supporting copy kept as compact intro row in VStack content area
- `.toolbarBackground(.hidden)` removed
- Plus toolbar button preserved

### HistoryView

**Before:** Custom 28pt bold "Geçmiş" in-content title block (same pattern as TodosView). `.toolbarBackground(.hidden)` causing top background issues.

**After:**
- `.navigationTitle("Geçmiş")` with `.navigationBarTitleDisplayMode(.large)`
- Supporting copy "Bakım, masraf, belge ve tamamlanan işleri tek arşivde gör." placed as compact intro row above filters
- `.toolbarBackground(.hidden)` removed
- Plus toolbar menu preserved

---

## PART 2 — Root Backgrounds Fixed

**Problem:** Both screens fell back to plain white (light mode) / plain black (dark mode) in the header/top area, instead of the app background color.

**Fix:** Added `Color.appBackground.ignoresSafeArea()` at the root VStack level on both screens:
```swift
.background(Color.appBackground.ignoresSafeArea())
```

This ensures the nav bar, header area, filters, and list content all share the consistent app background in both light and dark modes.

---

## PART 3 — History Time Grouping Removed

**Before:** Records grouped by `TimePeriod` ("Bu Hafta", "Bu Ay", "Geçen Ay", "Daha Eski") across all filter views — expense, service, document, inspection, and timeline (Tümü).

**After:** Flat `ForEach` in a single `Section` for all filter views. Records displayed in date-descending order.

**Removed:**
- `TimePeriod` enum (with `thisWeek`, `thisMonth`, `lastMonth`, `older` cases)
- `periodForDate(_:)` helper function
- `timeGroupedSection<T: Identifiable>(items:dateKey:rowContent:)` generic grouped section builder

**Preserved:**
- Date range filters (Tüm Zaman, Son 1 Ay, Son 6 Ay, Son 1 Yıl)
- Date-descending sort order
- All existing row content and interactions

**Why:** The date range filters already control what's shown, and the list is already sorted by date descending. Adding time-based section headers was redundant and added visual clutter rather than improving scannability.

---

## PART 4 — Row Secondary Text Truncation Fixed

**Before:** Completed reminders showed:
```
Yapılacak tamamlandı · 34 RSM 034
```
Long string "Yapılacak tamamlandı" could truncate to "Yapılacak tamam..."

**After:** Shorter copy:
```
Tamamlandı · 34 RSM 034
```
Changed `subtitle: "Yapılacak tamamlandı"` → `subtitle: "Tamamlandı"` in `buildTimeline()`.

---

## PART 5 — Yapılacaklar Row Cleanup Preserved

Reminder rows continue showing **only vehicle identity** in the metadata line. No due date, no due km text. Status chips on the right side continue showing "5 gün gecikti", "17 gün kaldı", "1.500 km kaldı". Confirmed unchanged from commit `69351c0`.

---

## Build Result

```
** BUILD SUCCEEDED **
```

- Scheme: `Ruhsatim`
- SDK: `iphonesimulator` (iOS 17.0)

---

## Test Result

```
Test Suite 'All tests' passed at 2026-07-01 12:19:54.464
     Executed 149 tests, with 0 failures (0 unexpected) in 0.193 (0.276) seconds
```

All 149 tests passed. No regressions.

---

## Known Limitations

- **SourceKit diagnostics** show "Cannot find type" errors for `Reminder`, `Vehicle`, `AppNavigationRouter`, `AppSpacing`, `AppTypography`, `AppColors`, `Expense`, `ServiceRecord`, `VehicleDocument`, `InspectionReport`. These are background indexing false positives — actual `xcodebuild` compilation and test execution both succeed.
- **Native `.large` navigation title** shows the back-swipe friendly large title that shrinks on scroll. This is the standard iOS pattern for tab-level screens.
- **No Garage/VehicleDetail changes** — those screens were not touched.
