# ARVIA MVP Monetization Simplification Report

**Tarih:** 2026-06-29  
**Proje:** Arvia iOS SwiftUI  
**Kapsam:** MVP Free/Pro modelini sadeleştirme  
**Son commit:** `e6f53fcb2d7ff7527d7e3ef3bd031e3c5ae2ffc3`  
**Commit mesajı:** `fix: simplify mvp monetization gates`

---

## 1. Özet

Arvia MVP monetization modeli ürün kararıyla uyumlu hale getirildi:

> **Arvia tek araç için ücretsiz ve reklamsızdır. Pro yalnızca ikinci ve sonraki araçları yönetmek içindir.**

Bu görevde Pro/paywall altyapısı kaldırılmadı. StoreKit, ürün ID’leri, restore purchases, dev-mode Pro simülasyonu ve paywall ekranı korunarak yalnızca mevcut MVP özelliklerinin Pro arkasından çıkarılması sağlandı.

Bildirim mantığına, AI özelliklerine, uzaktan push/APNs altyapısına veya Pro altyapısının kök mimarisine dokunulmadı.

---

## 2. Değişen Dosyalar

Commit içinde değişen dosyalar:

1. `Services/PaywallService.swift`
2. `Features/Paywall/PaywallView.swift`
3. `Features/Settings/SettingsView.swift`
4. `Features/Garage/GarageView.swift`
5. `Features/Documents/DocumentFormView.swift`
6. `Features/Documents/DocumentListView.swift`
7. `Features/Documents/DocumentsView.swift`
8. `Features/Records/HistoryView.swift`
9. `Features/Reports/ReportsView.swift`
10. `Features/SaleFile/SaleFileView.swift`
11. `Features/InspectionReport/InspectionReportView.swift`
12. `Features/VehicleDetail/VehicleDetailView.swift`
13. `Tests/ModelTests.swift`
14. `Tests/CommunityTests.swift`

---

## 3. Eski Free/Pro Modeli

Önceki modelde Free kullanıcı için şu Pro gate’ler vardı:

| Alan | Eski davranış |
|---|---|
| Araç ekleme | Free: 1 araç, Pro: sınırsız araç |
| Belge ekleme | Free: 5 belge limiti, Pro: sınırsız belge |
| Satış dosyası PDF | Pro gerekiyordu |
| Gelişmiş raporlar | Pro gerekiyordu |
| Ekspertiz raporu / arşivi | Pro gerekiyordu |
| Forum yazma | Daha önce auth-gate’e alınmıştı, Pro gerekmiyordu |

Eski paywall kopyasında Pro faydaları arasında “sınırsız belge”, “satış dosyası PDF”, “gelişmiş raporlar” ve “ekspertiz raporlarını satış dosyasına ekleme” gibi artık ücretsiz kalması gereken mevcut MVP özellikleri listeleniyordu.

---

## 4. Yeni Free/Pro Modeli

### Free

Free plan artık tek araç için mevcut MVP özelliklerinin tamamını açar:

| Özellik | Yeni durum |
|---|---|
| 1 araç | Ücretsiz |
| Sınırsız belge | Ücretsiz |
| Sınırsız hatırlatıcı | Ücretsiz |
| Sınırsız masraf kaydı | Ücretsiz |
| Sınırsız bakım/servis kaydı | Ücretsiz |
| Manuel ekspertiz / inspection report arşivi | Ücretsiz |
| Satış dosyası PDF oluşturma ve paylaşma | Ücretsiz |
| Mevcut raporlar / gelişmiş rapor kartları | Ücretsiz |
| Forum/community okuma | Ücretsiz |
| Forum/community posting/like/report | Giriş yapmış kullanıcı için açık |
| Local notifications | Ücretsiz |
| Kilometer update reminders | Ücretsiz |
| Reklam | Yok |

### Pro

Pro artık yalnızca çoklu araç yönetimi için konumlandı:

| Özellik | Yeni durum |
|---|---|
| 2. ve sonraki araçları ekleme | Pro |
| Birden fazla araçlı garaj | Pro |
| Araç bazlı bakım/masraf geçmişini çoklu araçta yönetme | Pro kullanım değeri |
| Araç bazlı belge kasasını çoklu araçta yönetme | Pro kullanım değeri |
| Tüm araçlar için hatırlatıcılar | Pro kullanım değeri |
| Gelecekteki AI / gelişmiş asistan / filo / gelişmiş export-link özellikleri | Bu görevde eklenmedi; ileride Pro olabilir |

---

## 5. PaywallService Değişiklikleri

`PaywallService` içinde MVP politikası açık hale getirildi:

```swift
enum FreeLimits {
    static let maxVehicles = 1
    static let documentLimit: Int? = nil
    static let saleFileRequiresPro = false
    static let advancedReportsRequiresPro = false
    static let inspectionReportsRequirePro = false
}
```

Yeni entitlement davranışı:

| Fonksiyon | Yeni davranış |
|---|---|
| `canAddVehicle(currentCount:)` | Free için yalnızca `currentCount < 1`; Pro için sınırsız |
| `canAddDocument(currentCount:)` | MVP’de her zaman `true` |
| `canSaveNewDocument(currentCount:)` | MVP’de her zaman `true` |
| `canCreateSaleFile()` | MVP’de her zaman `true` |
| `canAccessAdvancedReports()` | MVP’de her zaman `true` |
| `canCreateInspectionReport()` | MVP’de her zaman `true` |

Bu yapı ileride yeni Pro özellikleri eklemek için korunur; mevcut MVP özellikleri ise Pro arkasına taşınmadı.

---

## 6. Kalan Tek Paywall Tetikleyicisi

Paywall artık yalnızca şu durumda açılır:

| Ekran/Akış | Tetik |
|---|---|
| `GarageView` | Kullanıcı 1 aktif aracı varken yeni araç eklemeye çalışırsa |
| `VehicleFormView` | Form kaydı sırasında aktif araç sayısı Free limitini aşarsa |
| `SettingsView` | Kullanıcı manuel olarak “Birden fazla araç eklemek için Pro’ya geç” kartına dokunursa |

Not: `SettingsView` içindeki Pro kartı doğrudan kullanıcı tercihiyle paywall gösterir; özellik engeli değildir.

---

## 7. Kaldırılan / Bypass Edilen Paywall Tetikleyicileri

Aşağıdaki mevcut MVP gate’leri kaldırıldı veya ücretsiz akışa çevrildi:

| Önceki gate | Yeni davranış |
|---|---|
| Belge limiti | Belge ekleme sınırsız ve ücretsiz |
| Document tab “Belge Ekle” paywall | Kaldırıldı |
| Document list empty-state “Belge Ekle” paywall | Kaldırıldı |
| History tab “Belge Ekle” paywall | Kaldırıldı |
| Vehicle detail belge ekleme paywall | Kaldırıldı |
| Garage hızlı “Belge” paywall | Kaldırıldı |
| Satış dosyası PDF paywall | Kaldırıldı |
| Reports ekranında satış dosyası paywall | Kaldırıldı |
| SaleFileView kilitli state | Kaldırıldı |
| Gelişmiş raporlar kilitli state | Kaldırıldı |
| Reports ekranındaki gelişmiş rapor paywall CTA | Kaldırıldı |
| Ekspertiz raporu oluşturma paywall | Kaldırıldı |
| Ekspertiz raporunu satış dosyasına dahil etme paywall | Kaldırıldı |
| History tab “Ekspertiz Ekle” paywall | Kaldırıldı |
| Vehicle detail “Ekspertiz Ekle” paywall | Kaldırıldı |

---

## 8. Güncellenen Paywall Kopyası

Paywall artık yalnızca çoklu araç kullanımını anlatır.

### Başlık

> Birden fazla aracı tek garajda yönet

### Gövde

> Arvia tek araç için ücretsiz ve reklamsızdır. Arvia Pro ile ailedeki veya işletmendeki tüm araçların bakım, belge, masraf ve hatırlatıcılarını ayrı ayrı takip edebilirsin.

### Pro özellik maddeleri

- Sınırsız araç
- Araç bazlı bakım ve masraf geçmişi
- Araç bazlı belge kasası
- Çoklu araç garajı
- Tüm araçlar için hatırlatıcılar

### Güven satırı

> Tek araç kullanımı ücretsiz ve reklamsızdır.

### Korunan alanlar

- Satın almaları geri yükle
- Gizlilik Politikası bağlantısı
- Kullanım Koşulları bağlantısı
- Destek bağlantısı
- Apple EULA bağlantısı
- Abonelik otomatik yenileme / iptal açıklaması

### Kaldırılan Pro-only iddialar

Paywall artık şunları Pro-only olarak pazarlamaz:

- Sınırsız belge
- Satış dosyası PDF
- Gelişmiş raporlar
- Ekspertiz arşivi / ekspertiz raporlarını satış dosyasına ekleme

---

## 9. Güncellenen Settings Kopyası

`SettingsView` plan bölümü yeni modele göre güncellendi.

### Free kullanıcı

> Ücretsiz Plan  
> Tek araç için tüm temel özellikler açık. Arvia ücretsiz ve reklamsızdır.

CTA:

> Birden fazla araç eklemek için Pro’ya geç

### Pro kullanıcı

> Arvia Pro  
> Birden fazla aracı aynı garajda yönetebilirsin.

Restore purchases korunmuştur.

Settings artık tek araçtaki mevcut MVP özelliklerinin kısıtlı olduğu izlenimini vermez.

---

## 10. Testler

### Güncellenen test dosyaları

- `Tests/ModelTests.swift`
- `Tests/CommunityTests.swift`

### Eklenen/güncellenen beklentiler

| Test beklentisi | Durum |
|---|---|
| Free ilk aracı ekleyebilir | Test edildi |
| Free ikinci aracı ekleyemez | Test edildi |
| Pro ikinci/sonraki aracı ekleyebilir | Test edildi |
| Free 5’ten fazla belge ekleyebilir | Test edildi |
| Free satış dosyası PDF oluşturabilir | Test edildi |
| Free gelişmiş raporlara erişebilir | Test edildi |
| Free ekspertiz raporu oluşturabilir | Test edildi |
| Forum yazma Pro değil auth-gate olarak kalır | Test edildi |

### RED doğrulaması

Yeni test beklentileri önce mevcut kod üzerinde çalıştırıldı ve beklenen şekilde başarısız oldu:

- Free belge limiti testleri başarısız oldu.
- Free satış dosyası / gelişmiş rapor / ekspertiz erişimi testleri başarısız oldu.

Ardından uygulama kodu güncellendi ve aynı testler geçti.

---

## 11. Build Sonucu

Komut:

```bash
xcodebuild build \
  -project VehicleDossierApp.xcodeproj \
  -scheme Ruhsatim \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Sonuç:

```text
** BUILD SUCCEEDED **
```

Not: Xcode `appintentsmetadataprocessor` için “No AppIntents.framework dependency found” uyarısı verdi. Bu kod değişikliklerinden kaynaklanan bir derleme hatası değildir ve build başarılıdır.

---

## 12. Test Sonucu

Komut:

```bash
xcodebuild test \
  -project VehicleDossierApp.xcodeproj \
  -scheme Ruhsatim \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Sonuç:

```text
** TEST SUCCEEDED **
```

Tüm mevcut unit testler ve güncellenen monetization testleri geçti.

---

## 13. Manuel iPhone Kontrol Listesi

App Store öncesi cihaz üzerinde şu akışlar manuel doğrulanmalı:

- [ ] Temiz kurulumda ilk araç ücretsiz eklenebiliyor.
- [ ] Bir araç varken ikinci araç ekleme denemesi paywall açıyor.
- [ ] Free kullanıcı tek araçta sınırsız belge ekleyebiliyor.
- [ ] Free kullanıcı belge düzenleyebiliyor ve silebiliyor.
- [ ] Free kullanıcı hatırlatıcı ekleyebiliyor, düzenleyebiliyor, tamamlayabiliyor.
- [ ] Free kullanıcı masraf kaydı ekleyebiliyor.
- [ ] Free kullanıcı bakım/servis kaydı ekleyebiliyor.
- [ ] Free kullanıcı ekspertiz raporu ekleyebiliyor.
- [ ] Free kullanıcı ekspertiz raporunu satış dosyasına dahil et toggle’ını kullanabiliyor.
- [ ] Free kullanıcı satış dosyası PDF oluşturup paylaşabiliyor.
- [ ] Free kullanıcı Raporlar ekranındaki grafik/kart alanlarını görebiliyor.
- [ ] Settings Free plan açıklaması “tek araç için tüm temel özellikler açık” mesajını gösteriyor.
- [ ] Paywall yalnızca çoklu araç değerini anlatıyor.
- [ ] Paywall’da belge, satış PDF, gelişmiş rapor veya ekspertiz arşivi Pro-only olarak görünmüyor.
- [ ] Restore purchases butonu görünür ve çalıştırılabilir durumda.
- [ ] Pro dev-mode veya gerçek entitlement ile ikinci araç eklenebiliyor.
- [ ] Free planda uygulamada reklam gösterilmiyor.

---

## 14. App Store Metadata Notları

App Store açıklaması, ekran görüntüsü metinleri ve abonelik tanıtım metinleri yeni modele uyarlanmalı:

- “Tek araç için ücretsiz ve reklamsız” mesajı net verilmeli.
- Pro yalnızca “birden fazla araç / çoklu araç garajı” olarak anlatılmalı.
- Belgeler için Free limit olduğu söylenmemeli.
- Satış dosyası PDF’in Pro gerektiği söylenmemeli.
- Raporlar / gelişmiş raporlar Pro-only olarak tanıtılmamalı.
- Ekspertiz raporu arşivi Pro-only olarak tanıtılmamalı.
- Reklam destekli bir model ima edilmemeli.
- Future AI / advanced assistant / fleet-business / advanced export-link gibi gelecekteki Pro alanları bu MVP gönderiminde mevcut özellik gibi vaat edilmemeli.

---

## 15. Kapsam Dışı Bırakılanlar

Bu görevde özellikle yapılmayanlar:

- Pro/paywall altyapısı kaldırılmadı.
- StoreKit / ürün ID / restore purchases kodları kaldırılmadı.
- RevenueCat veya farklı ödeme altyapısı eklenmedi.
- Bildirim sistemi değiştirilmedi.
- AI özelliği eklenmedi.
- Reklam altyapısı eklenmedi.
- APNs / remote push / server altyapısı eklenmedi.
- Gelecekteki Pro özellikleri bugünden uygulanmadı.

---

## 16. Son Durum

MVP monetization artık şu net kurala göre çalışır:

> **Free:** Tek araç için tüm mevcut MVP özellikleri, ücretsiz ve reklamsız.  
> **Pro:** İkinci ve sonraki araçları aynı garajda yönetme.

Build ve tüm testler başarılıdır.
