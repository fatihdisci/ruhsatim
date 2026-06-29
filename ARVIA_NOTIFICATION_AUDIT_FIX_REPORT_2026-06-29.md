# ARVIA Notification Audit & Fix Report — 2026-06-29

## Özet

Arvia iOS SwiftUI projesindeki **yerel bildirim sistemi** App Store gönderimi öncesi denetlendi ve güçlendirildi. Çalışma yalnızca bildirimlerle sınırlı tutuldu; Pro/paywall, monetizasyon, AI, remote push/APNs veya sunucu altyapısına dokunulmadı.

## Latest commit hash

`376597d02550b698b954b24f87b50e8f8bccb8c5`

Commit mesajı:

`fix: harden local notification routing`

## Files changed

- `App/AppRouter.swift`
- `App/VehicleDossierApp.swift`
- `Features/Documents/DocumentFormView.swift`
- `Features/Garage/GarageView.swift`
- `Features/Garage/VehicleFormView.swift`
- `Features/Reminders/ReminderFormView.swift`
- `Features/Reminders/ReminderListView.swift`
- `Features/Reminders/TodosView.swift`
- `Features/Settings/SettingsView.swift`
- `Features/VehicleDetail/VehicleDetailView.swift`
- `Features/VehicleDetail/VehicleEditView.swift`
- `Services/NotificationService.swift`
- `Services/RetentionNotificationService.swift`
- `Tests/ModelTests.swift`

## Mevcut desteklenen bildirim tipleri

| Bildirim tipi | Trigger | Schedule timing | Title/body copy | Deep link destination | Setting toggle key | Cancellation behavior |
|---|---|---|---|---|---|---|
| Reminder / Important Dates | Kullanıcının tarihli hatırlatıcısı | 30 gün önce, 7 gün önce, 1 gün önce, aynı gün. Geçmiş tarihler planlanmaz. Sessiz saatlere denk gelirse 09:00’a alınır. | Title: `Hatırlatıcı` Body: `{30 gün kaldı / 7 gün kaldı / Yarın / Bugün}: {hatırlatıcı başlığı} — {tarih}` | `AppTab.todos`; `vehicleId` + `reminderId` route intent taşınır. Minimum güvenli davranış: Yapılacaklar sekmesi açılır ve bağlamsal banner gösterilir. | `notif_pref_important_dates` | Hatırlatıcı tamamlanınca, silinince, düzenlenince veya toggle OFF olunca `reminder-{id}-{offset}d` identifier’ları iptal edilir. |
| Kilometer Update | Aktif araç + geçerli `currentOdometer > 0` | Seçili frekansa göre: haftalık, aylık, 3 ayda 1, 6 ayda 1. Sessiz saat dışına alınır. | Title: `Kilometre Güncelleme` Body: `Güncel kilometre bilgisini ekleyerek bakım ve masraf takibini düzenli tutabilirsin.` | `AppTab.garage` → ilgili araç detayına push; araç detayında “Kilometre güncelleme” banner’ı ve `Km Güncelle` CTA’sı gösterilir. | `notif_pref_km_update`, frekans: `notif_pref_km_freq` | Toggle OFF veya frekans değişiminde `retention-km-*` iptal edilip yeni ayara göre yeniden planlanır. Arşivli/silinmiş veya km’si 0 olan araçlara planlanmaz. |
| File Completeness | Aktif araç dosya skoru düşükse | Veri değişikliği sonrası refresh; uygun araç için yaklaşık 2 gün sonrası, sessiz saat dışı. | Title: `Araç Dosyanı Tamamla` Body: `Araç dosyanda eksik bilgiler var. Belgeleri ve temel bilgileri tamamlayabilirsin.` | `AppTab.garage` → ilgili araç detayına push; “Dosya tamlığı” banner’ı gösterilir ve Dosya Tamlığı/Belgeler alanı görünür. | `notif_pref_doc_complete` | Toggle OFF veya veri refresh sırasında `retention-doc-*` iptal edilir. Stable identifier kullanılır. |
| Monthly Summary | En az bir araç varsa | Her ayın 2’si 10:00. O ayın tarihi geçtiyse bir sonraki ay planlanır. Sessiz saat dışı. | Title: `Aylık Garaj Özetin` Body: `Bu ay araçlarının masraf ve bakım özetini görüntülemek için Arvia uygulamasına göz at.` | `AppTab.reports` | `notif_pref_monthly_summary` | Toggle OFF veya refresh sırasında `retention-summary-*` iptal edilir. Aylık identifier yıl/ay içerir. |
| Seasonal Maintenance | Mevsimsel bakım planı | Mevsim başlangıcından 1 hafta önce: Mart, Haziran, Eylül, Aralık hedefleri. Sessiz saat dışı. | Örnek title/body: `Kış Bakımı` / `Kış öncesi antifriz, akü ve lastik kontrolü yapmayı unutma.` | `AppTab.todos`; mevsimsel bakım banner’ı gösterilir. | `notif_pref_seasonal` | Toggle OFF veya refresh sırasında `retention-seasonal-*` iptal edilir. |
| Sale File Reminder | Satış dosyası hatırlatıcısı açık + aktif araç | Uygun araç için yaklaşık 3 gün sonrası, sessiz saat dışı. Varsayılan olarak OFF. | Title: `Satış Dosyası Hazırla` Body: `Satış dosyası için araç bilgilerini ve belgelerini gözden geçirebilirsin.` | `AppTab.garage` → ilgili araç detayına push; “Satış dosyası” banner’ı ve `Satış Dosyası` CTA’sı gösterilir. | `notif_pref_sale_file` | Toggle OFF veya refresh sırasında `retention-salefile-*` iptal edilir. Stable identifier kullanılır. |

## Ne düzeltildi?

### 1. App-level notification deep link routing eklendi

- `AppNotificationRoute` eklendi.
- `AppNavigationRouter` eklendi ve `UNUserNotificationCenterDelegate` olarak bağlandı.
- Bildirim tap’leri artık güvenli şekilde parse edilip doğru tab’a yönlendiriliyor.
- Fragile nested navigation hack yerine minimum sağlam davranış seçildi:
  - Doğru tab seçiliyor.
  - Araç odaklı bildirimlerde ilgili araç detayına `NavigationStack(path:)` ile gidiliyor.
  - Araç detayında bağlamsal banner/CTA gösteriliyor.
  - Hatırlatıcı/mevsimsel bakım bildirimlerinde Yapılacaklar sekmesinde banner gösteriliyor.
  - Aylık özet bildiriminde Raporlar sekmesine gidiliyor.

### 2. Bildirim ayar toggle’ları gerçek scheduling davranışına bağlandı

Ayar değişiklikleri artık sadece `UserDefaults` yazmakla kalmıyor; hemen cancel/reschedule tetikliyor.

- Important Dates OFF → reminder bildirimleri iptal.
- Important Dates ON → aktif tarihli reminder bildirimleri yeniden planlanır.
- Kilometer Update OFF → km update bildirimleri iptal.
- Km frekansı değişince → eski km bildirimleri iptal edilip yeni frekansla planlanır.
- Monthly Summary OFF → monthly summary bildirimleri iptal.
- File Completeness OFF → file completeness bildirimleri iptal.
- Seasonal Maintenance OFF → seasonal bildirimler iptal.
- Sale File Reminder OFF → sale file bildirimleri iptal.

### 3. Veri değişikliklerinden sonra bildirim refresh eklendi

`NotificationRefreshService` eklendi ve önemli veri değişikliklerinden sonra çağrıldı:

- Araç eklendiğinde
- Araç düzenlendiğinde / km güncellendiğinde
- Araç arşivlendiğinde / silindiğinde
- Hatırlatıcı eklendiğinde / düzenlendiğinde / tamamlandığında / silindiğinde
- Belge eklendiğinde / silindiğinde
- Bildirim ayarı değiştiğinde

Duplicate spam önlemek için retention bildirimleri cancel-before-reschedule yapıyor; reminder bildirimleri stable identifier ile kendi eski request’lerini iptal edip yeniden ekliyor.

### 4. Kilometer update bildirimi güçlendirildi

- Sadece aktif araçlar için planlanır.
- `currentOdometer <= 0` ise planlanmaz.
- Bildirim metninde plaka veya hassas araç detayı yok.
- Frekans seçenekleri korunup gerçek scheduling’e bağlandı:
  - Weekly
  - Monthly
  - Every 3 months
  - Every 6 months
- Tap → ilgili araç detayına gider ve `Km Güncelle` CTA’sı görünür.

### 5. Reminder bildirimleri App Review açısından sakinleştirildi

- Title artık hatırlatıcı başlığını doğrudan göstermiyor: `Hatırlatıcı`.
- Body hâlâ kullanıcıya anlamlı bilgi veriyor ama resmi kurum/ödeme/garanti ima etmiyor.
- Geçmiş offset’ler planlanmıyor.
- Sessiz saat desteği reminder scheduling’e de uygulandı.
- Badge ataması kaldırıldı; stale badge riski azaltıldı.

### 6. Badge handling düzeltildi

- Yeni notification content’lerde `content.badge = 1` kullanılmıyor.
- App aktif olduğunda badge sıfırlanıyor.
- Bildirim tap routing sırasında badge temizleniyor.

### 7. Aylık özet scheduling düzeltildi

Önceden ayın 2’si geçmişse aynı ay için planlama yapılamıyordu. Artık ayın 2’si 10:00 geçmişse bir sonraki ay planlanıyor.

### 8. Test kapsamı eklendi

Yeni testler:

- Reminder identifier generation
- Reminder offset date calculation
- Past notification skipping
- Quiet hours adjustment
- Notification route parsing
- Retention identifier prefix mapping

## Bilerek kapsam dışında bırakılanlar

- Remote push/APNs/server notification altyapısı eklenmedi.
- AI özellikleri eklenmedi.
- Pro/paywall/monetization mantığı değiştirilmedi.
- Reminder detayına tam nested deep-link push yapılmadı; MVP için güvenli minimum olan doğru tab + route intent + banner tercih edildi.
- iOS’un background’da odometer değişimini kendiliğinden bilemeyeceği gerçeği değiştirilmedi. Km tabanlı reminder due/overdue görünürlüğü app açılışında/foreground’da mevcut `currentOdometer` ile listede hesaplanmaya devam eder.
- Konum izni istenmedi.

## Build result

Komut:

```bash
xcodebuild build -project VehicleDossierApp.xcodeproj -scheme Ruhsatim -destination 'platform=iOS Simulator,name=iPhone 17'
```

Sonuç:

```text
** BUILD SUCCEEDED **
```

Not:

```text
warning: Metadata extraction skipped. No AppIntents.framework dependency found.
```

Bu mevcut Xcode/AppIntents metadata uyarısıdır; bildirim değişikliklerinden kaynaklanan compile error yoktur.

## Test result

Komut:

```bash
xcodebuild test -project VehicleDossierApp.xcodeproj -scheme Ruhsatim -destination 'platform=iOS Simulator,name=iPhone 17'
```

Sonuç:

```text
Test Suite 'All tests' passed
** TEST SUCCEEDED **
```

Ek olarak yeni notification testleri ayrı çalıştırıldı ve geçti:

```text
Test Suite 'NotificationRoutingAndSchedulingTests' passed
** TEST SUCCEEDED **
```

## Manual test checklist for iPhone

- [ ] Temiz kurulumda bildirim izni prompt’unu Yapılacaklar sekmesinde gör.
- [ ] Bildirim izni ver.
- [ ] Tarihli bir hatırlatıcı oluştur; pending notification request’lerin `reminder-{id}-30d/7d/1d/0d` formatında oluştuğunu doğrula.
- [ ] Hatırlatıcıyı düzenle; eski identifier’ların iptal edilip yeni tarih için yeniden planlandığını doğrula.
- [ ] Hatırlatıcıyı tamamla; pending reminder request’lerin iptal edildiğini doğrula.
- [ ] Ayarlar → Önemli Tarihler OFF; tüm reminder notification’larının iptal edildiğini doğrula.
- [ ] Önemli Tarihler ON; aktif reminder notification’larının yeniden planlandığını doğrula.
- [ ] Ayarlar → Kilometre Güncelleme OFF; `retention-km-*` request’lerinin iptal edildiğini doğrula.
- [ ] Kilometre frekansını haftalık/aylık/3 ay/6 ay değiştir; eski km request’leri iptal edilip yeni tarihli request oluştuğunu doğrula.
- [ ] Km bildirimi tap simülasyonu yap; Garaj → ilgili araç detayına gidip “Kilometre güncelleme” banner’ını ve `Km Güncelle` CTA’sını gör.
- [ ] Dosya tamlığı bildirimi tap simülasyonu yap; ilgili araç detayında “Dosya tamlığı” banner’ını gör.
- [ ] Aylık özet bildirimi tap simülasyonu yap; Raporlar sekmesine geçtiğini doğrula.
- [ ] Mevsimsel bakım bildirimi tap simülasyonu yap; Yapılacaklar sekmesine geçtiğini ve banner’ı gör.
- [ ] Satış dosyası bildirimi tap simülasyonu yap; ilgili araç detayında “Satış dosyası” banner/CTA’sını gör.
- [ ] Uygulama foreground’a alınca badge’in sıfırlandığını doğrula.
- [ ] Plaka veya hassas araç detayının bildirim body’sinde görünmediğini doğrula.

## App Store review notes related to notifications

- Bildirimler yalnızca kullanıcının girdiği araç hatırlatıcıları ve araç organizasyonu içindir.
- Reklam/pazarlama bildirimi gönderilmez.
- Bildirim metinlerinde plaka veya gereksiz hassas araç detayı gösterilmez.
- Bildirim metinleri resmi kurum, TÜVTÜRK, GİB, e-Devlet veya garanti/ödeme entegrasyonu ima etmez.
- Konum izni istenmez.
- Kullanıcı bildirim kategorilerini uygulama içinden kapatabilir; toggle değişiklikleri kalıcıdır ve hemen uygulanır.
