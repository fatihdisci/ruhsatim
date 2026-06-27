# Arvia Fix Raporu — 2026-06-27

## Özet

İstek üzerine `~/apps/arvia` içindeki Garajım/Arvia repo güncellendi, Xcode target membership denetlendi, stale duplicate kaynak klasörü temizlendi ve belirtilen bug fixleri compile edilen canonical dosyalarda yapıldı.

Repo son HEAD: `c72b838`

## Pull / cache

Çalıştırılan komut:

```bash
git -C /Users/fatihdisci/apps/arvia fetch --no-tags --prune origin
git -C /Users/fatihdisci/apps/arvia pull --ff-only origin main
```

Sonuç: `Already up to date.`

Build komutlarında Swift Package repository cache'i devre dışı bırakmak için `-disablePackageRepositoryCache` kullanıldı.

## Target membership kararı

Xcode projesi: `VehicleDossierApp.xcodeproj`

Gerçek compile edilen canonical kaynaklar kökteki klasörler:

- `App/`
- `Features/`
- `Models/`
- `Services/`
- `Resources/`
- `Tests/`

Denetlenen önemli dosyaların target membership sonucu:

| Dosya | Compile edilen canonical path |
|---|---|
| DocumentFormView.swift | `Features/Documents/DocumentFormView.swift` |
| VehicleFormView.swift | `Features/Garage/VehicleFormView.swift` |
| VehicleEditView.swift | `Features/VehicleDetail/VehicleEditView.swift` |
| VehicleDetailView.swift | `Features/VehicleDetail/VehicleDetailView.swift` |
| ReminderDetailView.swift | `Features/Reminders/ReminderDetailView.swift` |
| HistoryView.swift | `Features/Records/HistoryView.swift` |
| Reminder.swift | `Models/Reminder.swift` |
| ModelTests.swift | `Tests/ModelTests.swift` |
| LaunchScreen.storyboard | `Resources/Base.lproj/LaunchScreen.storyboard` |

`VehicleDossierApp/` altındaki eski/stale kopyalar target'a bağlı değildi, ama yanlış dosyada değişiklik yapılmasına ve ileride eski kopyadan build alınmasına yol açabilecek durumdaydı. Bu nedenle `git rm -r VehicleDossierApp` ile stale duplicate kaynak ağaç kaldırıldı. Böylece tek canonical source kaldı.

Son kontrol:

```text
DocumentFormView.swift: 1 adet
VehicleFormView.swift: 1 adet
VehicleEditView.swift: 1 adet
LaunchScreen.storyboard: 1 adet
```

## Compile edilen dosyada değişiklik kanıtı

Debug/build-for-testing loglarında aşağıdaki canonical path'lerin compile edildiği görüldü:

```text
/Users/fatihdisci/apps/arvia/Features/Documents/DocumentFormView.swift (in target 'Ruhsatim')
/Users/fatihdisci/apps/arvia/Features/Garage/VehicleFormView.swift (in target 'Ruhsatim')
/Users/fatihdisci/apps/arvia/Features/VehicleDetail/VehicleEditView.swift (in target 'Ruhsatim')
/Users/fatihdisci/apps/arvia/Features/VehicleDetail/VehicleDetailView.swift (in target 'Ruhsatim')
/Users/fatihdisci/apps/arvia/Features/Reminders/ReminderDetailView.swift (in target 'Ruhsatim')
/Users/fatihdisci/apps/arvia/Features/Records/HistoryView.swift (in target 'Ruhsatim')
/Users/fatihdisci/apps/arvia/Models/Reminder.swift (in target 'Ruhsatim')
/Users/fatihdisci/apps/arvia/Tests/ModelTests.swift (in target 'RuhsatimTests')
/Users/fatihdisci/apps/arvia/Resources/Base.lproj/LaunchScreen.storyboard (in target 'Ruhsatim')
```

## Fixler

### 1) DocumentFormView

Dosya: `Features/Documents/DocumentFormView.swift`

Yapılanlar:

- `documentType` için `.onChange` eklendi.
- Kullanıcı başlığı manuel değiştirmediyse her belge türü değişiminde `title = type.displayName` yapılır.
- Kullanıcı başlığı manuel değiştirdiyse otomatik overwrite durur.
- Edit modda mevcut başlık korunur: `guard !isEditing, !hasUserEditedTitle`.

İlgili değişiklik:

```swift
.onChange(of: documentType) { _, newType in
    updateAutomaticTitle(for: newType)
}

private func updateAutomaticTitle(for type: DocumentType) {
    guard !isEditing, !hasUserEditedTitle else { return }
    title = type.displayName
    lastAutoTitle = type.displayName
}
```

### 2) VehicleFormView

Dosya: `Features/Garage/VehicleFormView.swift`

Yapılanlar:

- Gerçek `PhotosPicker` akışı canonical dosyada doğrulandı ve güçlendirildi.
- Seçilen fotoğraf `UIImage` olarak decode ediliyor.
- Save sırasında `VehiclePhotoStorageService.shared.savePhoto(image)` ile dosyaya kaydediliyor.
- `Vehicle(photoFileName: savedPhotoFileName)` ile model alanına yazılıyor.
- 20 MB üstü fotoğraf için kullanıcı dostu hata eklendi.
- Decode edilemeyen dosya için kullanıcı dostu hata eklendi.
- Kaydetmeden önce seçimi iptal etme butonu `Seçimi İptal Et` olarak netleştirildi.
- PhotosPicker label'ına `contentShape(Rectangle())` eklendi.

İlgili değişiklikler:

```swift
private let maxPhotoBytes = 20 * 1024 * 1024

PhotosPicker(selection: $selectedPhotoItem, matching: .images) { ... }

savedPhotoFileName = try VehiclePhotoStorageService.shared.savePhoto(image)

photoFileName: savedPhotoFileName
```

Hata mesajları:

```swift
Fotoğraf 20 MB'dan büyük olamaz. Daha küçük bir görsel seç.
Bu fotoğraf açılamadı. Lütfen JPG, PNG veya HEIC gibi geçerli bir görsel seç.
```

### 3) VehicleEditView / araç silme

Dosyalar:

- `Features/VehicleDetail/VehicleEditView.swift`
- `Features/VehicleDetail/VehicleDetailView.swift`

Yapılanlar:

- Compile edilen gerçek `VehicleEditView` içinde fotoğraf ekle/değiştir/sil akışları doğrulandı.
- Fotoğraf yoksa `Fotoğraf Ekle`.
- Fotoğraf varsa `Fotoğrafı Değiştir` ve `Fotoğrafı Sil`.
- Yeni fotoğraf kaydedilmeden önce eski dosya diskten temizleniyor.
- Fotoğraf kaydetme hatasında sheet artık yanlışlıkla kapanmıyor: `applyChanges() -> Bool` yapıldı.
- 20 MB / decode hataları VehicleFormView ile aynı kullanıcı dostu mesajlara bağlandı.
- Araç tamamen silindiğinde `VehicleDetailView.deleteVehicle()` içinde `VehiclePhotoStorageService.shared.deletePhoto(...)` çağrısı eklendi.

İlgili değişiklik:

```swift
if let oldFileName = vehicle.photoFileName {
    VehiclePhotoStorageService.shared.deletePhoto(fileName: oldFileName)
}
vehicle.photoFileName = try VehiclePhotoStorageService.shared.savePhoto(newImage)
```

Araç silme:

```swift
if let photoFileName = vehicle.photoFileName {
    VehiclePhotoStorageService.shared.deletePhoto(fileName: photoFileName)
}
```

### 4) ReminderDetailView / History

Dosyalar:

- `Features/Reminders/ReminderDetailView.swift`
- `Features/Records/HistoryView.swift`
- `Models/Reminder.swift`
- `Tests/ModelTests.swift`

Yapılanlar:

- Erteleme mantığı pure/test edilebilir helper'a taşındı:
  - dueDate gelecekteyse `dueDate + gün`
  - dueDate geçmiş/bugünse `bugün + gün`
- Tamamlama dialogu sadeleştirildi.
- Ana aksiyon adı: `Tamamla ve Geçmişe Ekle`.
- `Sadece tamamlandı işaretle` seçeneği kaldırıldı.
- Tamamlama her zaman `completedAt` ve `addedToHistoryAt` set ediyor.
- History query artık `completedAt != nil` yerine `addedToHistoryAt != nil` ile filtreliyor.
- History timeline tarihi `addedToHistoryAt` üzerinden gösteriliyor.

İlgili değişiklik:

```swift
func completeAndAddToHistory(now: Date = Date()) {
    statusRaw = ReminderStatus.completed.rawValue
    completedAt = now
    addedToHistoryAt = now
}
```

History predicate:

```swift
@Query(filter: #Predicate<Reminder> {
    $0.statusRaw == "Tamamlandı" && $0.addedToHistoryAt != nil
}, sort: \Reminder.addedToHistoryAt, order: .reverse)
```

Eklenen unit testler:

- `testFutureReminderSnoozeUsesDueDateAsBase`
- `testOverdueReminderSnoozeUsesTodayAsBase`
- `testCompletedReminderIsFetchedByHistoryPredicateOnlyWhenAddedToHistory`

### 5) Launch screen

Dosya: `Resources/Base.lproj/LaunchScreen.storyboard`

Kontroller:

- `INFOPLIST_KEY_UILaunchStoryboardName = LaunchScreen` Debug/Release build setting içinde mevcut.
- Storyboard target resources içinde compile ediliyor.
- Eski ortadaki yazılı launch view kaldırıldı.
- Minimal, native, hızlı açılan launch screen yapıldı: sadece `systemBackgroundColor` root view.

Kontrol çıktısı:

```text
INFOPLIST_KEY_UILaunchStoryboardName = LaunchScreen
CompileStoryboard /Users/fatihdisci/apps/arvia/Resources/Base.lproj/LaunchScreen.storyboard
```

Ayrıca:

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/VehicleDossierApp-*
```

ile DerivedData temizlendi.

Cihazda test notu: iOS launch screen cache tutabildiği için gerçek cihazda eski ekran görünürse uygulamayı cihazdan silip yeniden kurmak gerekir.

## Build / test sonuçları

### Debug build

Komut:

```bash
xcodebuild -project VehicleDossierApp.xcodeproj \
  -scheme Ruhsatim \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  -disablePackageRepositoryCache \
  CODE_SIGNING_ALLOWED=NO build
```

Sonuç:

```text
** BUILD SUCCEEDED **
```

Not: `appintentsmetadataprocessor` için benign warning var: AppIntents.framework dependency yok.

### Release build

Komut:

```bash
xcodebuild -project VehicleDossierApp.xcodeproj \
  -scheme Ruhsatim \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -disablePackageRepositoryCache \
  CODE_SIGNING_ALLOWED=NO build
```

Sonuç:

```text
** BUILD SUCCEEDED **
```

Aynı benign AppIntents warning var.

### Unit test compile / build-for-testing

Komut:

```bash
xcodebuild build-for-testing \
  -project VehicleDossierApp.xcodeproj \
  -scheme Ruhsatim \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  -disablePackageRepositoryCache \
  CODE_SIGNING_ALLOWED=NO
```

Sonuç:

```text
** TEST BUILD SUCCEEDED **
```

### Unit test runtime

`xcodebuild test` gerçek simulator/device üzerinde çalıştırılamadı.

Bloklayıcılar:

1. CoreSimulator sürüm uyumsuzluğu:

```text
CoreSimulator is out of date. Current version (1051.54.0) is older than build version (1051.55.0).
Simulator device support disabled.
```

2. My Mac destination ile test denemesinde unsigned app install edilemedi:

```text
No code signature found.
```

3. Signing açık denenince provisioning eksikleri geldi:

```text
Signing for "RuhsatimTests" requires a development team.
Provisioning profile ... doesn't include the Sign In with Apple capability.
Provisioning profile ... doesn't include the com.apple.developer.applesignin entitlement.
```

Bu yüzden unit testler gerçek runtime'da koşturulamadı, fakat test target ve yeni test dosyası `build-for-testing` ile compile edildi.

## Simulator / manuel smoke durumu

İstenen smoke kontrolleri:

- iPhone simulator launch smoke normal
- dark mode
- XXXL Dynamic Type
- gerçek iPhone fotoğraf seçme
- PDF import
- belge preview
- share sheet
- StoreKit sandbox restore/purchase

Durum: Bu ortamda CoreSimulator servisleri çalışmıyor ve gerçek iPhone'a erişim/yetkili signing yok. Bu nedenle manuel smoke yapılamadı.

Manuel smoke için önerilen sıra:

1. Xcode/macOS güncellemesi veya CoreSimulator mismatch fix.
2. `~/Library/Developer/Xcode/DerivedData/VehicleDossierApp-*` temiz kalsın.
3. Cihazdan eski app'i sil.
4. Xcode'dan gerçek iPhone'a clean install.
5. Launch screen eski yazıyı göstermiyor mu kontrol et.
6. Yeni araç ekle → fotoğraf seç → kaydet → listede/detailde gör.
7. Fotoğraf değiştir → eski dosyanın temizlendiğini ve yeni fotoğrafın geldiğini kontrol et.
8. Fotoğraf sil → placeholder'a döndüğünü kontrol et.
9. Araç sil → fotoğraf dosyasının da silindiğini kontrol et.
10. Belge ekle → belge türü değiştikçe başlık otomatik değişiyor mu kontrol et.
11. Başlığı elle değiştir → belge türü değişince başlık ezilmiyor mu kontrol et.
12. PDF import → belge preview → share sheet.
13. StoreKit sandbox restore/purchase.
14. Dark mode ve XXXL Dynamic Type launch/app smoke.

## Değişen dosyalar

Kod değişiklikleri:

- `Features/Documents/DocumentFormView.swift`
- `Features/Garage/VehicleFormView.swift`
- `Features/Records/HistoryView.swift`
- `Features/Reminders/ReminderDetailView.swift`
- `Features/VehicleDetail/VehicleDetailView.swift`
- `Features/VehicleDetail/VehicleEditView.swift`
- `Models/Reminder.swift`
- `Resources/Base.lproj/LaunchScreen.storyboard`
- `Tests/ModelTests.swift`

Stale duplicate cleanup:

- `VehicleDossierApp/` altındaki eski kaynak ağacı ve nested eski `VehicleDossierApp.xcodeproj` kaldırıldı.

Local-only build hazırlığı:

- `Configuration/Config.xcconfig` yerelde `Config.example.xcconfig` üzerinden oluşturuldu; gitignore kapsamında, raporlanan değişikliklere dahil değil.

## Açık riskler

1. Unit testler runtime'da koşturulamadı; sadece `build-for-testing` compile doğrulaması yapıldı.
2. Simulator smoke CoreSimulator mismatch yüzünden yapılamadı.
3. Gerçek cihaz smoke signing/provisioning erişimi gerektiği için yapılamadı.
4. Provisioning profile Sign in with Apple entitlement içermiyor görünüyor. Gerçek cihaz/TestFlight build öncesi Apple Developer portal ve Xcode Signing & Capabilities tarafında profile yenilenmeli.
5. `appintentsmetadataprocessor` warning benign görünüyor; AppIntents kullanılmıyorsa beklenen warning.

## Son doğrulama komutları

```bash
plutil -lint VehicleDossierApp.xcodeproj/project.pbxproj
# OK

git diff --check
# çıktı yok, whitespace hatası yok
```
