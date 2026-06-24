# TestFlight Hazırlık Denetimi — Ruhsatım

**Tarih:** 24 Haziran 2026
**Commit:** `60f13d0`
**Branch:** main
**Mod:** CloudKit kapalı, local-first

---

## 1. Checklist

| # | Kontrol | Durum | Detay |
|---|---|---|---|
| 1 | `isCloudKitSyncEnabled = false` | ✅ | `AppEnvironment.swift:19` |
| 2 | Release build | ✅ | `BUILD SUCCEEDED` (0 hata, 0 uyarı) |
| 3 | App icon | ❌ | 1024x1024 placeholder — PNG dosyası yok, sadece `Contents.json` |
| 4 | StoreKit product ID'leri | ✅ | `com.ruhsatim.pro.monthly`, `.yearly`, `.lifetime` |
| 5 | `#if DEBUG` dev mode | ✅ | Release'de `false` → gerçek StoreKit'e bağlanır |
| 6 | PrivacyInfo.xcprivacy | ✅ | pbxproj Resources'a bağlı, doğru formatta |
| 7 | Terms/Privacy URL | ⚠️ | `ruhsatim.app/privacy` + `/terms` — domain yanıt vermiyor |
| 8 | Release build (temiz) | ✅ | 0 hata |
| 9 | Archive | ❌ | Development team atanmamış (CODE_SIGN_IDENTITY gerekli) |

---

## 2. App Icon

```
Resources/Assets.xcassets/AppIcon.appiconset/
  Contents.json   ✅ var
  1024x1024 PNG   ❌ YOK
```

| Gereken | Durum |
|---|---|
| 1024x1024 @1x PNG | ❌ Eksik |

> App Store Connect upload için en az 1024x1024 icon zorunlu.

---

## 3. StoreKit Product ID'leri

| ID | Kodda | App Store Connect |
|---|---|---|
| `com.ruhsatim.pro.monthly` | ✅ | Bekliyor |
| `com.ruhsatim.pro.yearly` | ✅ | Bekliyor |
| `com.ruhsatim.pro.lifetime` | ✅ | Bekliyor |

> Release build'de `#if DEBUG` devre dışı → `isDevMode = false` → gerçek `Product.products(for:)` çağrılır. Ürünler App Store Connect'te tanımlı değilse `products` boş döner, crash olmaz.

---

## 4. Dev Mode

```swift
var isDevMode: Bool {
    #if DEBUG
    return true
    #else
    return false      // ← Release build'de bu dal çalışır
    #endif
}
```

| Build tipi | isDevMode | Davranış |
|---|---|---|
| Debug (Xcode run) | `true` | UserDefaults simülasyonu |
| Release (archive) | `false` | Gerçek StoreKit 2 |

---

## 5. PrivacyInfo.xcprivacy

| Kontrol | Durum |
|---|---|
| Dosya | `Resources/PrivacyInfo.xcprivacy` |
| pbxproj | Resources build phase'de (2 referans) |
| Tracking | `false` |
| Collected data | Boş |
| FileTimestamp | `C617.1` |
| UserDefaults | `CA92.1` |

---

## 6. Terms / Privacy URL'leri

| URL | Durum |
|---|---|
| `https://ruhsatim.app/privacy` | ⚠️ Domain yanıt vermiyor |
| `https://ruhsatim.app/terms` | ⚠️ Domain yanıt vermiyor |

> App Store review için privacy policy URL'sinin canlı ve erişilebilir olması zorunlu.

---

## 7. Archive

```
xcodebuild archive → Signing for "Ruhsatim" requires a development team
```

| Gereken | Durum |
|---|---|
| Apple Developer account | Gerekli |
| Bundle ID kaydı (`com.ruhsatim.app`) | App Store Connect'te oluşturulmalı |
| Signing certificate | Xcode → Signing & Capabilities → Team seçilmeli |
| Provisioning profile | Otomatik yönetiliyor (CODE_SIGN_STYLE = Automatic) |

---

## 8. TestFlight Upload İçin Eksikler

| # | Eksik | Öncelik | Açıklama |
|---|---|---|---|
| 🔴 1 | App icon (1024x1024 PNG) | Critical | App Store Connect reddeder |
| 🔴 2 | Apple Developer team | Critical | Archive alamaz |
| 🔴 3 | Privacy policy URL (canlı) | Critical | App Store review red sebebi |
| 🔴 4 | Terms of service URL (canlı) | Critical | App Store review red sebebi |
| 🟡 5 | App Store Connect ürün ID'leri | High | Paywall boş görünür, crash olmaz |
| 🟡 6 | App Store Connect app kaydı | High | `com.ruhsatim.app` |
| 🟢 7 | App Store metadata (açıklama, ekran görüntüleri) | Medium | `AppStoreMetadata.md` hazır, giriş bekliyor |
| 🟢 8 | Test cihazları / internal testing grubu | Medium | TestFlight dağıtımı için |

---

## 9. Sonuç

| Kriter | Durum |
|---|---|
| Kod hazır mı? | ✅ Evet |
| Release build alınıyor mu? | ✅ Evet |
| Testler geçiyor mu? | ✅ 33/33 |
| CloudKit kapalı mı? | ✅ Evet |
| App Store Connect hazır mı? | ❌ Hayır (4 critical eksik) |

**TestFlight timeline:** Kod tarafı hazır. App Store Connect tarafında 4 kritik işlem kaldıktan sonra archive → upload yapılabilir.
