# Arvia Pro Future and Arvia Rehber Foundation Report

Date: 2026-06-30

## Latest Commit Hash

`f4592ae11e0cc03c1d5b2c26f10db1ef532c27fd`

No new commit was created by this task; this is the latest repository commit before the working tree changes.

## Files Changed

- `Models/VehicleInsight.swift`
- `Services/VehicleInsightService.swift`
- `DesignSystem/Components/ArviaGuideCard.swift`
- `Features/VehicleDetail/VehicleDetailView.swift`
- `Features/InspectionReport/InspectionReportView.swift`
- `Features/Settings/SettingsView.swift`
- `Tests/ModelTests.swift`
- `VehicleDossierApp.xcodeproj/project.pbxproj`
- `ARVIA_PRO_FUTURE_AND_ARVIA_REHBER_FOUNDATION_REPORT_2026-06-29.md`

Note: `docs/ARVIA_TEST_SEED.md` was already untracked and was not changed.

## What Was Implemented

- Added Arvia Rehber as a native section inside vehicle detail.
- Added rule-based local insight generation with AI-ready models and source metadata.
- Added reusable Arvia Rehber card UI.
- Added safe CTA routing to existing app flows.
- Added subtle future-Pro roadmap copy in Settings.
- Added tests for insight generation, action routing metadata, and current Free/Pro behavior.

No real AI API, API key, backend endpoint, remote push infrastructure, ads, or notification logic changes were added.

## New Arvia Rehber UI Behavior

Arvia Rehber appears inside `VehicleDetailView` after the hero/upcoming/completeness area and before the lower record sections.

Section title:

`Arvia Rehber`

Subtitle:

`Aracının kayıtlarına göre bakım, belge ve satış hazırlığı önerileri.`

The section shows up to 3 calm guidance cards. If no rule needs attention, it shows a quiet complete-state message. A short Pro roadmap teaser and legal disclaimer are shown below the cards without blocking any current MVP action.

## Rule-Based Insight Types and Rules

Implemented insight types:

- Maintenance insight
- Missing document insight
- Sale file readiness insight
- Odometer update insight
- Overdue reminder insight

Implemented rules:

- No service record: suggest adding the first maintenance/service record.
- Last service older than 12 months: suggest reviewing maintenance history.
- Missing or non-positive odometer: suggest updating km.
- Stale odometer: suggest km update only when dated odometer evidence exists and is older than 6 months.
- No documents: suggest adding key vehicle documents.
- No inspection report: suggest adding an inspection/expertise report for sale readiness.
- Overdue reminders: show the most relevant overdue reminder insight.
- Weak sale file: suggest strengthening the sale file when multiple readiness signals are missing.

All current insights are marked `ruleBased`. `aiGenerated` exists only as a future-compatible source value.

## CTA Routing Behavior

- `Bakım Kaydı Ekle`: opens the existing service record form with the vehicle preselected.
- `Belge Ekle`: opens the existing document form with the vehicle preselected.
- `Satış Dosyasına Git`: opens the existing sale file screen.
- `Km Güncelle`: opens the existing vehicle edit sheet.
- `Yapılacaklara Git`: selects the existing todos/reminders tab.
- `Ekspertiz Raporu Ekle`: opens the inspection report form with the vehicle preselected.

No fragile navigation hack or new tab was added.

## Pro / Free Impact

Current MVP features remain free and ad-free for the first vehicle:

- Documents
- Reminders
- Expenses
- Service records
- Manual inspection reports
- Sale file PDF
- Current reports
- Local notifications

Pro still gates only the second and later vehicles. Arvia Rehber v1 rule-based cards are visible for free users and do not block current MVP flows.

## Future-Pro Placeholders Added

Settings now includes a small future roadmap section:

- Arvia Rehber gelişmiş öneriler
- Belge/fatura akıllı okuma
- Satış dosyası link/QR
- Araç karşılaştırma
- Business/Filo Lite

Vehicle detail includes a subtle non-blocking teaser:

`Arvia Rehber Pro yakında`

These are worded as future possibilities, not active paid features.

## Legal / Safety Copy Added

Arvia Rehber disclaimer:

`Arvia Rehber, araç kayıtlarına göre genel öneriler sunar. Teknik teşhis, ekspertiz veya servis görüşü yerine geçmez.`

The new copy avoids technical diagnosis, chronic failure, official institution, safety certification, and risk-score claims.

## Tests Added / Updated

Added coverage in `Tests/ModelTests.swift` for:

- Empty data does not crash insight generation.
- No service record creates a maintenance insight.
- No documents creates a document insight.
- No inspection report creates a sale readiness insight.
- Overdue reminder creates an overdue insight.
- Visible insights do not exceed the intended max of 3.
- Insight actions map to valid app destinations.
- Free user current MVP feature surfaces remain unlocked.
- Pro still only gates the second vehicle for free users.

## Build Result

Command:

`xcodebuild -project VehicleDossierApp.xcodeproj -scheme Ruhsatim -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/ArviaDerivedData -clonedSourcePackagesDirPath /private/tmp/ArviaSourcePackages build`

Result:

`BUILD SUCCEEDED`

## Test Result

Command:

`xcodebuild -project VehicleDossierApp.xcodeproj -scheme Ruhsatim -destination 'platform=iOS Simulator,name=iPhone 16' -derivedDataPath /private/tmp/ArviaDerivedData -clonedSourcePackagesDirPath /private/tmp/ArviaSourcePackages test`

Result:

`TEST SUCCEEDED`

Executed 117 tests, 0 failures.

## Manual Test Checklist

- App installed and launched on iPhone 16 simulator: done.
- Dark-mode launch/onboarding and empty garage visual smoke check: done.
- Vehicle detail shows Arvia Rehber section: not completed manually because the simulator did not have a seeded vehicle/detail path available during this run.
- Empty/new vehicle gets useful but not noisy guidance: covered by unit tests; not manually completed.
- Vehicle with records shows fewer/more relevant insights: covered by rule tests; not manually completed.
- Card CTAs open the correct existing flows: compile-verified and action metadata tested; not fully tapped manually.
- Dark mode looks clean: smoke-checked on onboarding/garage; Rehber card not manually checked on device.
- Dynamic Type does not break cards: implemented with SwiftUI text wrapping/fixed sizing; not manually completed.
- VoiceOver reads card title/body/action: accessibility labels added; not manually completed.
- Free first-vehicle features remain unlocked: covered by tests.
- Second vehicle still opens paywall for Free: covered by tests.
- No risky AI/diagnosis/official institution language in new Rehber copy: scanned.

No `xcodebuild` process was left running after verification.

## Known Limitations

- Arvia Rehber v1 is local and rule-based only.
- Odometer staleness is intentionally conservative and only uses dated local evidence; it does not invent timestamps.
- Dismissed cards are local view state only and are not persisted.
- Manual simulator verification of the vehicle-detail Rehber cards was limited by lack of seeded vehicle data in the installed app state.
- Telegram delivery could not be performed from this environment because no Telegram connector/tool is available.

## Recommended Next Phase

- Add a safe internal debug seed path or UI test fixture for manual App Store smoke testing.
- Persist dismissed insight IDs per vehicle if product wants long-lived card dismissal.
- Add UI tests for vehicle detail Rehber rendering and CTA flows.
- Add document-intelligence prototypes behind explicit future-Pro copy only after App Review-safe wording is finalized.
- Keep advanced AI features server-mediated in the future, with clear consent, no hidden API keys, and no technical diagnosis claims.
