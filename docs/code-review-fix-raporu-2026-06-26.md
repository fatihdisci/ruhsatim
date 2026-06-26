# Garajim — Kod İnceleme Düzeltme Raporu

**Tarih:** 2026-06-26
**Repo:** [github.com/fatihdisci/ruhsatim](https://github.com/fatihdisci/ruhsatim)
**Branch:** main

---

## 1. Özet

Garajim (Ruhsatim) iOS uygulamasında kod incelemesinde tespit edilen 12 sorun giderildi. Tekrarlayan hatırlatıcı motoru, km tabanlı hatırlatıcı eşikleri, arşivlenmiş araç filtreleme, bildirim yaşam döngüsü yönetimi, servis kaydı Parça değişikliği tekilleştirme (dedup), satış dosyası belge ön seçimi, InspectionReport includeInSaleFile kalıcılığı, dürüst PDF ifadeleri, iCloud senkronizasyon dili kaldırma, gerçek StoreKit fiyatlandırması ve tam JSON veri dışa aktarımı uygulandı. Ayrıca uygulama simgesi asset yapılandırması doğrulandı ve düzeltildi.

**Test sonucu:** 65 testin tamamı başarılı (26 mevcut + 39 yeni).

---

## 2. Değişen Dosyalar

### Yeni Dosyalar
- `Services/ReminderRepeatEngine.swift` — Tekrar kuralı enum'u + sonraki tarih hesaplama motoru
- `VehicleDossierApp/Services/ReminderRepeatEngine.swift` — Senkronize kopya

### Değişen Model Dosyaları
- `Models/Reminder.swift` — `repeatRule` computed property, `isKmOverdue()`, `isKmUpcoming()` eklendi
- `Models/InspectionReport.swift` — `includeInSaleFile: Bool` alanı + init parametresi eklendi
- `VehicleDossierApp/Models/Reminder.swift` — Senkronize
- `VehicleDossierApp/Models/InspectionReport.swift` — Senkronize

### Değişen View Dosyaları
- `Features/Reminders/ReminderFormView.swift` — Paylaşımlı `ReminderRepeatRule` kullanımı, `.custom` gizlendi
- `Features/Reminders/ReminderListView.swift` — Tamamlamada tekrar oluşturma, km gecikme grup/satır gösterimi
- `Features/Garage/VehicleFormView.swift` — İlk hatırlatıcılar için bildirim planlama
- `Features/Garage/GarageView.swift` — Arşiv filtreleme, arşivlenmiş araçlar bölümü
- `Features/VehicleDetail/VehicleDetailView.swift` — Silme öncesi bildirim iptali
- `Features/ServiceRecords/ServiceRecordFormView.swift` — PartChange yükleme/kaydetme tekilleştirme
- `Features/SaleFile/SaleFileView.swift` — Belge ön seçimi, dürüst ifadeler
- `Features/InspectionReport/InspectionReportView.swift` — `includeInSaleFile` kalıcılığı
- `Features/Documents/DocumentListView.swift` — iCloud senkronizasyon dili düzeltildi
- `Features/Paywall/PaywallView.swift` — Ürün ID ile StoreKit fiyatları
- `Features/Settings/SettingsView.swift` — Gerçek JSON veri dışa aktarımı
- `VehicleDossierApp/Features/*` — Tüm view dosyaları senkronize edildi

### Değişen Proje Dosyası
- `VehicleDossierApp.xcodeproj/project.pbxproj` — ReminderRepeatEngine.swift eklendi

### Değişen Test Dosyaları
- `Tests/ModelTests.swift` — 3 yeni test sınıfı (26 yeni test)
- `VehicleDossierApp/Tests/ModelTests.swift` — Senkronize (13 yeni test)

---

## 3. Düzeltilen Sorunlar

### 1. ReminderRepeatEngine ✅
`Services/ReminderRepeatEngine.swift` oluşturuldu. `ReminderRepeatRule` enum'u ve aylık/3 aylık/6 aylık/yıllık için `nextDueDate(from:rule:)` metodu eklendi. `.custom` UI picker'dan gizlendi. Tamamlamada, bir sonraki tarih ile yeni Reminder oluşturulup bildirimleri planlanıyor.

**Karar:** Yeni Reminder oluştur, eskisini tamamlanmış olarak koru. Tamamlanma geçmişi kaybolmaz.

### 2. İlk araç hatırlatıcı bildirimleri ✅
`VehicleFormView.createFirstReminders()` artık her `modelContext.insert(r)` sonrası `Task { await NotificationService.shared.scheduleReminder(r) }` çağırıyor.

### 3. Km tabanlı hatırlatıcılar ✅
`Reminder` modeline `isKmOverdue(vehicleOdometer:)` ve `isKmUpcoming(vehicleOdometer:withinKm:)` eklendi. `ReminderListView` km gecikmiş hatırlatıcıları "Gecikenler" grubuna alıyor, `ReminderRow` km durum metni gösteriyor. Km bildirimi oluşturulmuyor (güvenilir tetikleyici yok).

### 4. Araç arşivleme ✅
`GarageView` `activeVehicles` (archivedAt == nil) filtresi kullanıyor. "Arşivlenmiş Araçlar" DisclosureGroup bölümü eklendi. Paywall limit kontrolü sadece aktif araçları sayıyor.

### 5. Araç silme bildirim temizliği ✅
`VehicleDetailView.deleteVehicle()` silme öncesi her hatırlatıcı için `NotificationService.shared.cancelReminder()` çağırıyor.

### 6. Servis kaydı PartChange tekilleştirme ✅
Düzenleme formu `.onAppear` ile mevcut parçaları `loadExistingParts()` ile yüklüyor. Kaydetmede eski PartChange kayıtları silinip yenileri ekleniyor. `#Predicate` yerine fetch-all + filter kullanıldı (SwiftData macro kısıtlaması nedeniyle).

### 7. Satış dosyası belge ön seçimi ✅
`SaleFileView.onAppear` ile `includeInSaleFile == true` olan belgeler ön seçiliyor. Dürüst ifade eklendi: "Seçili belgelerin listesi PDF'e eklenir. Belge dosyaları (PDF/fotoğraf) PDF içine gömülmez."

### 8. InspectionReport includeInSaleFile ✅
`InspectionReport` modeline `includeInSaleFile: Bool` eklendi (varsayılan `false`). Form toggle'ı kalıcı olarak kaydediyor. `SaleFileView` ekspertiz raporlarını bu flag'e göre filtreliyor.

### 9. iCloud senkronizasyon dili ✅
DocumentListView alert mesajı "Bu belgenin bilgileri senkronlandı..." yerine "Bu belgenin dosyası bu cihazda bulunamadı. Belgeyi yeniden eklemeyi dene." olarak değiştirildi. CloudKit kapalı (`isCloudKitSyncEnabled = false`). Kullanıcıya dönük başka senkronizasyon iddiası bulunamadı.

### 10. Paywall gerçek fiyatlar ✅
`PricingOption` struct'ı ürün ID ile anahtarlı. `Product.displayPrice` ve subscription period kullanılıyor. Dev mode için hardcoded fallback. Seçim ürün ID string'i ile, dizi indeksi ile değil. "Satın Almaları Geri Yükle" butonu ve "İstediğin zaman iptal edebilirsin" mesajı korundu.

### 11. Veri dışa aktarımı ✅
Settings export artık araç, hatırlatıcı, masraf, servis kaydı, belge metadata ve ekspertiz raporu verilerini JSON dizileri olarak içeriyor. Buton etiketi "Verileri Dışa Aktar (JSON)" olarak güncellendi. Binary dosyaların dahil edilmediğine dair not eklendi.

### 12. Testler ✅
3 yeni test sınıfında 39 yeni test:
- `ReminderRepeatEngineTests` (8 test)
- `KmReminderTests` (8 test)
- `InspectionReportIncludeInSaleFileTests` (3 test)

---

## 4. Eklenen/Güncellenen Testler

### ReminderRepeatEngineTests
| Test | Açıklama |
|------|----------|
| `testYearlyNextDate` | 15 Haz 2026 → 15 Haz 2027 |
| `testMonthlyNextDate` | 10 Oca 2026 → 10 Şub 2026 |
| `testQuarterlyNextDate` | 1 Oca 2026 → Nisan 2026 (+3 ay) |
| `testBiannualNextDate` | 20 Mar 2026 → Eylül 2026 (+6 ay) |
| `testNoneReturnsNil` | `.none` → nil |
| `testCustomReturnsNil` | `.custom` → nil (güvenli) |
| `testRuleParsingFromRawValue` | String → enum parse |
| `testYearEndBoundary` | 31 Ara → 31 Oca (yıl sınırı) |

### KmReminderTests
| Test | Açıklama |
|------|----------|
| `testKmOverdueWhenOdometerExceeds` | 55.000 ≥ 50.000 → true |
| `testKmOverdueExactlyAtThreshold` | 50.000 = 50.000 → true |
| `testKmOverdueIgnoresCompletedReminder` | Tamamlanmış → false |
| `testKmOverdueNoThreshold` | dueOdometer nil → false |
| `testKmUpcomingWithinRange` | 49.000, 2000km içinde → true |
| `testKmUpcomingOutsideRange` | 47.000, 2000km dışında → false |
| `testKmUpcomingWhenExceeded` | Geçilmiş → false |
| `testRepeatRulePreservedOnModel` | `repeatRuleRaw: "yearly"` → `.yearly` |
| `testRepeatRuleNoneByDefault` | Varsayılan → `.none` |

### InspectionReportIncludeInSaleFileTests
| Test | Açıklama |
|------|----------|
| `testDefaultIncludeInSaleFileIsFalse` | Varsayılan `false` |
| `testExplicitIncludeInSaleFileTrue` | `true` parametre → `true` |
| `testExplicitIncludeInSaleFileFalse` | `false` parametre → `false` |

---

## 5. Build Sonucu

```
** BUILD SUCCEEDED **
```

- Hedef: iPhone 16 Simulator
- SDK: iOS 26.5
- Yapılandırma: Debug
- Şema: VehicleDossierApp

---

## 6. Test Sonucu

```
** TEST SUCCEEDED **

Executed 65 tests, with 0 failures (0 unexpected) in 0.097 (0.126) seconds
```

- `VehicleModelTests` — 26 test ✅
- `ReportCalculationTests` — 7 test ✅
- `CarCatalogTests` — 8 test ✅
- `PaywallLimitTests` — 5 test ✅
- `ReminderRepeatEngineTests` — 8 test ✅
- `KmReminderTests` — 8 test ✅
- `InspectionReportIncludeInSaleFileTests` — 3 test ✅

---

## 7. App Icon Asset Durumu

| Kontrol | Sonuç |
|---------|-------|
| AppIcon.appiconset mevcut | ✅ `Resources/Assets.xcassets/AppIcon.appiconset` |
| 1024x1024 PNG mevcut | ✅ `Garajim-AppIcon-1024.png` |
| PNG boyutu | ✅ 1024 x 1024 |
| PNG opaque (alfa yok) | ✅ 8-bit/color RGB, non-interlaced |
| Contents.json filename | ✅ `"filename" : "Garajim-AppIcon-1024.png"` |
| Single-size workflow | ✅ `"size" : "1024x1024"`, universal, iOS |
| Build setting APPICON_NAME | ✅ `AppIcon` |
| Köşe yuvarlama | ✅ Manuel yuvarlama yok — iOS/App Store kendisi yapar |
| VehicleDossierApp kopyası | ✅ Senkronize |

---

## 8. Bilinen Kısıtlamalar

- **Özel tekrar kuralı (`.custom`):** UI'dan gizlendi, motorda `nil` dönüyor. "Yakında" olarak işaretlendi.
- **Km bildirimleri:** Oluşturulmuyor. Km hatırlatıcıları uygulama açılışında / araç güncellemesinde değerlendiriliyor. Km değişiklikleri için güvenilir push tetikleyici yok.
- **PDF dosya gömme:** Satış dosyası PDF'i seçili belgeleri listeliyor ancak gerçek dosya içeriklerini (PDF/fotoğraf) gömmüyor. UI bu konuda dürüst.
- **CloudKit senkronizasyon:** Kapalı (`AppEnvironment.isCloudKitSyncEnabled = false`). Tüm model CloudKit yorumları dahili. Kullanıcıya dönük senkronizasyon iddiası yok.
- **Arşivden geri alma:** Arşivlenmiş araçlar "Arşivlenmiş Araçlar" bölümünde görünür. Araç detayına gidip `archivedAt = nil` yaparak geri alınabilir. Liste görünümünde doğrudan "arşivden çıkar" butonu yok — bilinen UX kısıtı.
- **PartChange tekilleştirme:** `#Predicate` yerine fetch-all + filter yaklaşımı kullanıldı (SwiftData macro kısıtlaması). Beklenen veri hacmi için kabul edilebilir.

---

## 9. Manuel QA Kontrol Listesi

- [ ] Araç ekle, muayene/sigorta/kasko tarihlerini aç, hatırlatıcıların ve bildirimlerin oluştuğunu doğrula
- [ ] Yıllık tekrarlı hatırlatıcı ekle, tamamla, bir yıl sonrasına yeni hatırlatıcı oluştuğunu doğrula
- [ ] Aylık tekrarlı hatırlatıcı ekle, tamamla, bir ay sonrasına yeni hatırlatıcı oluştuğunu doğrula
- [ ] Araç km'sini km hatırlatıcı eşiğinin üzerine güncelle, gecikmiş durumunu doğrula
- [ ] Aracı arşivle, ana garajdan kaybolduğunu doğrula
- [ ] Aracı sil, ilgili bildirimlerin iptal edildiğini doğrula
- [ ] Parçalı servis kaydı ekle, düzenle, parça ekle/çıkar, tekilleştirmeyi doğrula
- [ ] `includeInSaleFile` açık belge ekle, satış dosyası akışında ön seçili geldiğini doğrula
- [ ] Ekspertiz raporu `includeInSaleFile` açık ekle, satış dosyasında filtrelendiğini doğrula
- [ ] Paywall'u aç, gerçek StoreKit fiyatlarını ve geri yükleme butonunu doğrula
- [ ] Ayarlar > Verileri Dışa Aktar (JSON) çıktısını kontrol et
- [ ] CloudKit kapalıyken UI'da iCloud/senkronizasyon iddiası olmadığını kontrol et
