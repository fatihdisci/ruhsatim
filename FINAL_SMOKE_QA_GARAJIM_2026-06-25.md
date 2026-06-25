# Garajım — Final Smoke QA (App Store/TestFlight Öncesi)

Tarih: 2026-06-25
Repo: `~/apps/arac`
Scheme: `VehicleDossierApp`
Bundle ID: `com.ruhsatim.app` (değişmedi)
Display name: `Garajım`

## Kapsam

Yeni özellik eklenmeden; blocker, crash, bozuk akış ve App Store riskleri odaklı smoke QA yapıldı.

Kontrol yöntemleri:

- Kod tabanlı akış denetimi
- Debug build
- Release build
- Unit testler
- iPhone 16 Simulator launch smoke
- Light/Dark mode screenshot kontrolü
- Accessibility Dynamic Type screenshot kontrolü
- Privacy/Terms canlı URL kontrolü
- App Store metadata riskli ifade taraması

> Not: Fiziksel iPhone bu makinede `offline` göründüğü için gerçek cihaza kurulum yapılamadı. `xcrun xctrace list devices` çıktısında Fatih iPhone’u offline. Bu nedenle gerçek cihaz yerine iPhone 16 Simulator üzerinde launch smoke yapıldı.

---

## Build/Test Sonucu

### Debug build

Komut:

```bash
xcodebuild -project VehicleDossierApp.xcodeproj \
  -scheme VehicleDossierApp \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -configuration Debug build
```

Sonuç:

```text
** BUILD SUCCEEDED **
```

### Release build

Komut:

```bash
xcodebuild -project VehicleDossierApp.xcodeproj \
  -scheme VehicleDossierApp \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -configuration Release build
```

Sonuç:

```text
** BUILD SUCCEEDED **
```

### Unit tests

Komut:

```bash
xcodebuild test -project VehicleDossierApp.xcodeproj \
  -scheme VehicleDossierApp \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -configuration Debug
```

Sonuç:

```text
** TEST SUCCEEDED **
Executed 33 tests, with 0 failures
```

Not: Simulator erase sonrası CoreData persistent store ilk oluşturma sırasında recovery logları üretti; testler başarıyla tamamlandı. Crash/test failure yok.

---

## PASS Listesi

| # | Alan | Sonuç |
|---|---|---|
| 1 | İlk açılış / boş durum | PASS — iPhone 16 Simulator’da launch OK, boş Garaj ekranı okunur. |
| 2 | Araç ekleme/düzenleme/silme | PASS — form validation, edit sheet, delete cascade kodu mevcut; build/test OK. |
| 3 | Hatırlatıcı ekleme/tamamlama | PASS — boş durumdaki ekleme sheet’i düzeltildi; tamamla/sil swipe akışı mevcut. |
| 4 | Masraf ekleme/düzenleme/silme | PASS — boş durumdaki Masraf Ekle sheet’i bağlı; edit/sil akışı mevcut. |
| 5 | Bakım kaydı ekleme | PASS — empty/list sheet, parça ekleme ve sonraki hatırlatıcı akışı mevcut. |
| 6 | Belge ekleme: fotoğraf/PDF | PASS — PhotosPicker + fileImporter, 20 MB sınırı ve validation mevcut. |
| 7 | Belge önizleme | PASS — QuickLook preview ve eksik dosya alert’i mevcut. |
| 8 | Belge silinince dosya temizliği | PASS — `DocumentStorageService.deleteFile` belge silme ve araç silme cascade içinde çağrılıyor. |
| 9 | Ekspertiz raporu ekleme | PASS — form, belge bağlantısı ve yasal uyarı mevcut. |
| 10 | Satış dosyası PDF oluşturma | PASS — PDF export service çağrısı mevcut; ücretsiz kullanıcıda paywall artık açılıyor. |
| 11 | PDF preview/share | PASS — QuickLook preview + ShareLink mevcut. |
| 12 | Paywall açılması | PASS — ikinci araç, belge limiti, satış PDF ve Settings Pro girişi paywall’a bağlı. |
| 13 | Restore purchases görünürlüğü | PASS — Paywall ve Settings içinde restore butonu mevcut. |
| 14 | Settings privacy/terms/support/veri silme | PASS — linkler aktif, support email mevcut, veri silme confirmation var. |
| 15 | Dark mode | PASS — launch screenshot okunur; majör kontrast sorunu yok. |
| 16 | Büyük metin / Dynamic Type | PASS with note — Accessibility XXXL’de crash/overlap yok; açıklama metni kısalıyor. |
| 17 | Türkçe karakterler | PASS — `Garajım`, `Muayene`, `Trafik Sigortası`, `Ekspertiz` build/test içinde sorunsuz. |
| 18 | App Store riskli ifadeler | PASS — metadata’da resmi kurum olmadığı, ödeme/sorgulama yapılmadığı ve garanti verilmediği açık yazıyor. |

---

## QA Sırasında Düzeltilen Sorunlar

### HIGH — Hatırlatıcı boş durumunda ekleme modalı açılmıyordu

Dosya: `Features/Reminders/ReminderListView.swift`

Sorun:

- Boş durumda `showAddReminder = true` yapılıyordu ama view üzerinde `.sheet` bağlı değildi.
- İlk hatırlatıcı ekleme akışı kırılıyordu.

Düzeltme:

- `ReminderFormView()` sheet bağlantısı eklendi.

Durum: FIXED

### CRITICAL — Release build kırılıyordu

Dosya: `Features/Settings/SettingsView.swift`

Sorun:

- DEBUG demo fonksiyonları `#if DEBUG` içinde kaldığı halde confirmation dialog closure’ları Release build’de bu fonksiyonları referanslıyordu.
- Release build hatası:

```text
cannot find 'seedDemoData' in scope
cannot find 'deleteAllDemoData' in scope
```

Düzeltme:

- Developer section DEBUG-only kaldı.
- Demo fonksiyonları Release build’de de scope’ta olacak şekilde düzenlendi; fonksiyon gövdeleri DEBUG guard altında no-op.

Durum: FIXED

### HIGH — Settings “Pro’ya Geç” butonu paywall açmıyordu

Dosya: `Features/Settings/SettingsView.swift`

Sorun:

- Buton sadece Settings sheet’ini kapatıyordu; paywall gösterilmiyordu.

Düzeltme:

- Settings içine `showPaywall` state’i ve `PaywallView` sheet’i eklendi.

Durum: FIXED

### HIGH — Satış dosyası paywall koşulu serbest bırakılmıştı

Dosya: `Services/PaywallService.swift`

Sorun:

- `canCreateSaleFile()` ücretsiz kullanıcı için de `true` dönüyordu.
- App Store metadata’da satış dosyası PDF Pro değeri olarak sunulduğu için IAP/value mismatch riski vardı.

Düzeltme:

- `canCreateSaleFile()` artık `isPro` dönüyor.
- `SaleFileView` mevcut paywall sheet’ini doğru şekilde tetikliyor.

Durum: FIXED

### HIGH — Belge limit paywall servisi UI’da kullanılmıyordu

Dosya: `Features/Documents/DocumentsView.swift`

Sorun:

- `PaywallService.canAddDocument(currentCount:)` vardı ama Belgeler tabındaki `+` butonu limit kontrolü yapmadan belge formu açıyordu.

Düzeltme:

- Belgeler tabı mevcut belge sayısını okuyup 5 belge sonrası `PaywallView(feature: .documentLimit)` açacak şekilde bağlandı.

Durum: FIXED

---

## CRITICAL Sorunlar

Şu an açık CRITICAL sorun yok.

## HIGH Sorunlar

Şu an açık HIGH sorun yok.

## MEDIUM Sorunlar

1. **Fiziksel cihaz smoke yapılamadı**
   - Sebep: iPhone cihaz `offline` görünüyor.
   - Etki: Gerçek cihaz kamera/foto/PDF import/share sheet davranışı son cihazda elle doğrulanmalı.
   - App Store blocker değil, ancak TestFlight öncesi fiziksel cihazda manuel smoke önerilir.

2. **Accessibility XXXL’de boş durum açıklama metni kısalıyor**
   - Launch screenshot’ta açıklama metni `ara...` şeklinde truncate oluyor.
   - Crash/overlap yok; CTA erişilebilir.
   - App Store blocker değil, ama accessibility polish için ileride `fixedSize(horizontal:false, vertical:true)` / scroll davranışı gözden geçirilebilir.

3. **StoreKit ürünleri App Store Connect canlı ürünleriyle doğrulanmadı**
   - Kod tarafında product IDs mevcut:
     - `com.ruhsatim.pro.monthly`
     - `com.ruhsatim.pro.yearly`
     - `com.ruhsatim.pro.lifetime`
   - Simulator smoke’da gerçek App Store Connect ürün fetch/purchase doğrulaması yapılmadı.
   - TestFlight öncesi StoreKit config / sandbox account ile manuel doğrulama önerilir.

---

## App Store Risk Taraması

### Resmi kurum gibi görünme

Durum: PASS

- Metadata ve Settings yasal uyarıda uygulamanın resmi kurum uygulaması olmadığı açık.
- TÜVTÜRK, Gelir İdaresi Başkanlığı, sigorta şirketleri veya kamu kurumlarıyla bağlantı olmadığı yazıyor.

### MTV ödeme/sorgulama iddiası

Durum: PASS

- Metadata’da `MTV ... hatırlatıcıdır`, `Herhangi bir resmi ödeme veya sorgulama yapılmaz` açıklaması var.
- “MTV öde” / “resmi sorgulama” tarzı iddia yok.

### TÜVTÜRK/GİB/e-Devlet logo veya ima

Durum: PASS

- Kod/assets içinde logo kullanımı tespit edilmedi.
- Riskli kurum adları yalnızca yasal uyarı veya demo vendor gibi bağlamlarda geçiyor.

### Mekanik garanti / araç sağlığı iddiası

Durum: PASS

- Satış dosyası ve ekspertiz metinleri garanti vermediğini belirtiyor.
- Mekanik sağlık/garanti iddiası kullanıcıya vaat olarak sunulmuyor.

---

## App Store’a Göndermeden Önce Kesin Düzeltilmesi Gerekenler

Şu an build/test açısından kesin blocker yok.

Yine de TestFlight öncesi önerilen manuel son kontroller:

1. Fiziksel iPhone’da kamera/fotoğraf/PDF import + ShareLink smoke.
2. StoreKit sandbox ile ürün fetch, satın alma, restore purchases.
3. Accessibility XXXL açıklama metni truncation polish.
4. App Store Connect’te IAP ürün ID’lerinin kodla birebir aynı olduğunun kontrolü.

---

## Sonuç

- Build pass: EVET
- Test pass: EVET
- Critical: 0
- High: 0
- TestFlight’a çıkabilir mi: EVET, fiziksel cihaz ve StoreKit sandbox son manuel smoke önerisiyle.
