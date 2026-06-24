# Post-Merge Doğrulama Denetimi — Ruhsatım

**Tarih:** 24 Haziran 2026
**Commit:** `bc40c45`
**Branch:** main
**Xcode:** 26.5 (17F42)
**Simulator:** iPhone 17 Pro, iOS 26.5

---

## 1. Git Durumu

```
bc40c45 docs: post-merge doğrulama denetimi — CloudKit/Privacy/belge temizliği
a91387d SwiftData CloudKit sync hazırlığı + belge dosya sync + privacy manifest
78d3506 docs: veri saklama mimarisi denetimi — Privacydatabasenotes.md
```

| Kontrol | Sonuç |
|---|---|
| Branch | `main` |
| Status | Clean |
| CloudKit merge | ✅ `a91387d` — 16 dosya, 207 satır |

---

## 2. CloudKit Flag Durumu

```swift
static let isCloudKitSyncEnabled = false
```

| Bulgu | Sonuç |
|---|---|
| Flag okunuyor mu? | ✅ `VehicleDossierApp.swift:29` → `ModelConfiguration.cloudKitDatabase` |
| Kapalıyken | `.none` → bugünkü davranış birebir |
| Açıkken | `.private("iCloud.com.ruhsatim.app")` |
| Capability dokümanı | ✅ `AppEnvironment.swift:14-18` |

---

## 3. Build & Test — CloudKit KAPALI

| Test | Sonuç |
|---|---|
| Clean build | ✅ `BUILD SUCCEEDED` (0 hata, 0 uyarı) |
| Unit test | ✅ 33/33 `TEST SUCCEEDED` |
| Hata | 0 |

---

## 4. CloudKit AÇIK Compile Testi

| Test | Sonuç |
|---|---|
| Build (flag=true) | ✅ `BUILD SUCCEEDED` |
| Capability: iCloud/CloudKit | ❌ Xcode'da eklenmemiş (runtime'da fatalError beklenir) |
| Container ID | `iCloud.com.ruhsatim.app` (kodda tanımlı) |
| Background Modes | ❌ Remote notifications eklenmemiş |

> Flag açılıp Xcode capability eklenmeden çalıştırılırsa `ModelContainer` init `fatalError` verir.

---

## 5. Belge Sync Mantığı (Kod Doğrulaması)

| Kontrol | Durum | Detay |
|---|---|---|
| `VehicleDocument.fileData` | ✅ | `@Attribute(.externalStorage) var fileData: Data?` (line 28) |
| Belge ekleme → disk | ✅ | `DocumentStorageService.saveFile()` |
| Belge ekleme → fileData | ✅ | `DocumentFormView.swift:366` — `doc.fileData = data` |
| Dual-write | ✅ | Disk + fileData aynı anda yazılır |
| Önizleme → disk yoksa materialize | ✅ | `DocumentListView.swift:191-196` — `materializeFileIfNeeded` |
| Dosya yok uyarısı | ✅ | `showMissingFileAlert = true` (line 199) |
| Lazy backfill (eski belgeler) | ✅ | `backfillCloudDataIfNeeded()` (line 214-226), idempotent |
| `readFileData` | ✅ | `DocumentStorageService.swift:62-67` |
| `materializeFileIfNeeded` | ✅ | `DocumentStorageService.swift:72-84` |

---

## 6. Belge Silme

| Kontrol | Durum |
|---|---|
| Belge silme → disk | ✅ `deleteFile()` |
| Belge silme → DB | ✅ `modelContext.delete()` |
| Araç silme → fiziksel belge | ✅ `VehicleDetailView.swift:616` — `deleteFile(doc.localFileName)` |
| Tüm veri silme → `VehicleDocuments/` | ✅ `SettingsView.deleteAllData()` |

---

## 7. PrivacyInfo.xcprivacy

| Kontrol | Durum |
|---|---|
| Dosya mevcut | ✅ `Resources/PrivacyInfo.xcprivacy` (40 satır) |
| pbxproj'a bağlı | ✅ Resources build phase'de |
| NSPrivacyTracking | ✅ `false` |
| NSPrivacyCollectedDataTypes | ✅ Boş dizi (veri toplanmaz) |
| FileTimestamp API | ✅ `C617.1` (kendi sandbox dosyaları) |
| UserDefaults API | ✅ `CA92.1` (uygulama ayarları) |

---


## 8. CloudKit Model Uyumu

Tüm `@Model` sınıflarında non-optional alanlara property seviyesinde default değer eklendi:

| Model | Değişiklik |
|---|---|
| Vehicle | `id`, `nickname`, `plate`, `brand`, `model`, `fuelTypeRaw`, `usageTypeRaw`, `notes`, `createdAt` |
| Reminder | `id`, `vehicleId`, `typeRaw`, `title`, `priorityRaw`, `statusRaw`, `notes`, `createdAt` |
| Expense | `id`, `vehicleId`, `categoryRaw`, `amount`, `currencyCode`, `date`, `note`, `createdAt` |
| ServiceRecord | `id`, `vehicleId`, `serviceTypeRaw`, `date`, `notes`, `createdAt` |
| PartChange | `id`, `serviceRecordId`, `partTypeRaw`, `createdAt` |
| VehicleDocument | `id`, `vehicleId`, `typeRaw`, `title`, `localFileName`, `createdAt` |
| InspectionReport | `id`, `vehicleId`, `providerName`, `reportDate`, `summary`, `verificationStatusRaw`, `createdAt` |
| SaleFile | `id`, `vehicleId`, `title`, `createdAt` |

> Init imzaları değişmedi, migration gerekmez.

---

## 9. App Privacy Metni

Mevcut (`AppStoreMetadata.md`): "Verilerin cihazında saklanır"

| CloudKit kapalıyken | ✅ Doğru |
|---|---|
| CloudKit açılınca | ⚠️ Güncellenmeli: "iCloud eşzamanlama etkinse veriler Apple iCloud üzerinden cihazlar arası eşzamanlanır" |

---

## 10. Critical Issues

| # | Sorun | Öncelik |
|---|---|---|
| — | **Yok** | Tüm critical'lar çözüldü |

## 11. High Issues

| # | Sorun | Öncelik |
|---|---|---|
| — | **Yok** | Tüm high'lar çözüldü |

## 12. Medium Issues

| # | Sorun | Öncelik |
|---|---|---|
| 🟢 M1 | AppStoreMetadata.md privacy metni CloudKit açılınca güncellenmeli | Low |
| 🟢 M2 | Xcode CloudKit capability + container + background modes eklenmeli | Low (flag kapalıyken gerekmez) |

---

## 13. TestFlight Değerlendirmesi

| Mod | Durum |
|---|---|
| **CloudKit kapalı** | ✅ **Çıkabilir** |
| **CloudKit açık** | ⚠️ Xcode capability'leri eklenmeli, sonra çıkabilir |

---

## 14. Özet

| Kriter | Sonuç |
|---|---|
| Main güvenli mi? | ✅ Evet |
| Build (CloudKit OFF) | ✅ 0 hata, 0 uyarı |
| Test (33/33) | ✅ Geçti |
| Build (CloudKit ON) | ✅ (runtime'da capability eksik) |
| Belge sync mantığı | ✅ Dual-write + materialize + backfill |
| Belge silme (disk+DB) | ✅ |
| Araç silme → belge temizliği | ✅ Düzeltildi |
| PrivacyInfo.xcprivacy | ✅ Eklendi |
| CloudKit model uyumu | ✅ 8 model, default değerler |
| `isCloudKitSyncEnabled` runtime bağlantısı | ✅ |
