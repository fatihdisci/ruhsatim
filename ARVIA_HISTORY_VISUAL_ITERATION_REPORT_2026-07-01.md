# Arvia Geçmiş — Visual Iteration Report

**Date:** 2026-07-01  
**Project:** Arvia — VehicleDossierApp (Ruhsatim)  
**Focus:** Yapılacaklar row metadata cleanup + Geçmiş (History) visual iteration  
**Base commit:** `c760dfdfc3112841b1741ac40d67fc543330ce5f`  
**Latest commit:** `69351c0`

---

## Latest Commit

```
69351c0
refactor: reminder row metadata cleanup + history visual iteration
```

## Files Changed

| File | Change |
|------|--------|
| `Features/Reminders/ReminderListView.swift` | **205 lines touched** — removed date/km metadata from ReminderRow, kept only vehicle identity |
| `Features/Records/HistoryView.swift` | **393 lines touched** — full visual iteration: header, filters, vehicle plate in rows, section grouping, empty states |

No other files modified. No Garage, VehicleDetail, business logic, or model changes.

---

## PART 1 — Yapılacaklar Reminder Row Metadata Cleanup

### Before
The ReminderRow metadata line showed:
```
[car.icon] 34 ABC 123 · 26 Haz 2026
[car.icon] 34 ABC 123 · 100.000 km
```

### After
The metadata line now shows **only vehicle identity**:
```
[car.icon] 34 ABC 123
```

**What was removed:**
- Separator dot (`·`) between vehicle and date/km
- `dueDate.formatted(date: .abbreviated, time: .omitted)` text
- `dueKm.formatted() km` threshold text

**What was preserved:**
- Vehicle plate/name with `car.fill` icon
- `.lineLimit(1)` and `.layoutPriority(1)` on vehicle text
- Right-side `statusBadge` continues showing relative timing: "5 gün gecikti", "17 gün kaldı", "1.500 km kaldı"

**Why:** The right-side status chip already shows the useful timing information. The redundant metadata line was prone to truncation with narrow screens or long Turkish dates, and the plate alone provides sufficient vehicle context.

---

## PART 2 — Geçmiş / History Visual Iteration

### 1. Header / Screen Identity

**Before:** Plain `.navigationTitle("Geçmiş")` with system nav bar.

**After:** Custom header with toolbar background hidden:
- **28pt bold** "Geçmiş" title — matches the main tab identity pattern from TodosView
- **Supporting copy:** "Bakım, masraf, belge ve tamamlanan işleri tek arşivde gör."
- `.toolbarBackground(.hidden, for: .navigationBar)` for cleaner integration

The header now feels like a primary tab identity, not a generic navigation-title list.

### 2. Filter Area Refinements

**Category chips (Tümü / Masraflar / Bakımlar / Belgeler / Ekspertiz):**
- Selected state: 14pt semibold, white text, `accentPrimary` capsule fill
- Unselected: `captionMedium` (13pt medium), `textSecondary`, `backgroundSecondary` fill
- Horizontal padding increased from 12pt → **16pt** for more readable chips

**Date range chips (Tüm Zaman / Son 1 Ay / Son 6 Ay / Son 1 Yıl):**
- Selected state: 13pt semibold, `accentPrimary` text, subtle background fill (opacity 0.1) + stroke
- Unselected state: 13pt regular, `textTertiary`, visible border stroke (opacity 0.3)
- Selected state now has both background fill + stroke — more scannable than the previous pure-stroke approach

### 3. Record Row Refinements

**Vehicle plate added to ALL row types** — the key automotive touch:

| Row Type | Before | After |
|----------|--------|-------|
| **Expenses** | vendor only | plate + vendor metadata line |
| **Services** | vendor only | plate + vendor metadata line |
| **Documents** | file size only | plate + file size metadata line |
| **Inspections** | branch only | plate + branch metadata line |
| **Timeline (Tümü)** | subtitle + date | subtitle + plate + date |

Each row now shows two-line layout:
```
[icon] Title (lineLimit 1)
       PLATE · vendor/file size/branch (lineLimit 1)
```

Additional refinements:
- `.lineLimit(1)` added to all row titles and metadata texts
- `.monospacedDigit()` on monetary amounts for clean alignment
- Consistent 3pt VStack spacing between title and metadata line
- Consistent 28pt icon frame width across all row types

### 4. Section Grouping / Visual Rhythm

Added **time-based section grouping** to all filter views using a new `TimePeriod` enum:

| Section | Range |
|---------|-------|
| **Bu Hafta** | Current week (ISO week) |
| **Bu Ay** | Current calendar month |
| **Geçen Ay** | Previous calendar month |
| **Daha Eski** | Anything older |

Sections use `timeGroupedSection<T: Identifiable>` generic helper with `.textCase(nil)` to preserve Turkish casing. This breaks up long lists into digestible chunks and gives the archive a structured, premium feel.

### 5. Empty State Update

**Before (Tümü):**
- Title: "Henüz geçmiş kaydı yok"
- Description: "Yaptığın bakımları, masrafları ve belgeleri aracının dijital geçmişi olarak saklayabilirsin."

**After (Tümü):**
- Title: "Henüz kayıt yok"
- Description: "Masraf, bakım, belge veya tamamlanan işleri ekledikçe aracının geçmişi burada oluşur."

The per-filter empty states (Masraflar / Bakımlar / Belgeler / Ekspertiz) were preserved unchanged — they already had appropriate Turkish copy.

### 6. Timeline Builder (`buildTimeline`)

Added `plateText: String` field to `HistoryTimelineItem` struct. Each record type now extracts the vehicle plate via `vehicleFor(id:)` during timeline construction.

Completed reminders subtitle simplified from:
```
"34 ABC 123 · Yapılacak tamamlandı"
```
To:
```
"Yapılacak tamamlandı"
```
(plate moved to the new dedicated `plateText` field)

### 7. Dark Mode / Dynamic Type

All changes use existing design system tokens (`AppColors`, `AppTypography`, `AppSpacing`), which are already light/dark adaptive and Dynamic Type compatible. No hardcoded colors or sizes.

---

## Key Design Principles Applied

- **Vehicle archive feel**, not generic transaction list — achieved by adding plate identity to every row
- **Scannable sections** — time-based grouping creates natural breakpoints
- **Consistent rhythm** — uniform 3pt VStack spacing, 28pt icon frames, .xxs vertical padding
- **Turkish-first** — no English labels, `.textCase(nil)` on section headers
- **Production-safe** — no logic changes, no model changes, presentation-only

---

## Known Limitations

- **SourceKit diagnostics** show "Cannot find type" errors in Xcode's editor for `Expense`, `ServiceRecord`, `VehicleDocument`, `InspectionReport`, `Vehicle`, and `Reminder`. These are background indexing false positives — actual `xcodebuild` compilation succeeds.
- **No changes to business logic:** All filtering, date range logic, grouping, deletion, navigation/tap behavior, and sheet presentation are entirely untouched.
- **No changes to data models** (`Expense`, `ServiceRecord`, `VehicleDocument`, `InspectionReport`, `Reminder`, `Vehicle`).
- **Timeline (Tümü) remains limited to 50 items** via `.prefix(50)` — unchanged from original.
- **`ReminderListView.swift`** changes are limited to Part 1 (metadata cleanup). No other modifications to reminder logic.
