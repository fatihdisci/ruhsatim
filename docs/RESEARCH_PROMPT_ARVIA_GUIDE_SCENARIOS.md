# Gemini Deep Research Promptu — Arvia Rehber İçerik Stratejisi

> Bu prompt, **Gemini Deep Research** modunda çalıştırılmak üzere hazırlanmıştır. Çıktısı `docs/RESEARCH_ARVIA_GUIDE_SCENARIOS.md` olarak kaydedilecek ve Manifesto Karar 4.2'nin (yeni eklenecek) girdisi olacak.
> Kullanım: Gemini'ye direkt yapıştır, çıkan raporu bu dosya yoluna kaydet.

---

## Araştırma görevin

Sen bir **iOS SwiftUI otomotiv uygulaması (Arvia)** için içerik stratejisti ve UX yazarı olarak çalışıyorsun. Görevin: uygulamanın **"Arvia Rehber"** bölümünde gösterilen kural-tabanlı (rule-based) içerik kartlarının tasarımını ve içeriğini sıfırdan gözden geçirmek.

**Bugünkü sorun:** Mevcut 13 rehber kartının hepsi **CTA'lı** (eylem yönlendirmesi — "Bakım Kaydı Ekle", "Hatırlatıcı Ekle", "Masraf Ekle" gibi). Kullanıcı bunları çok "robotik" ve "neyse, sonra hallederim" hissi verici buluyor. Her kart eyleme zorlamamalı — bazı kartlar sadece **bilgi**, **uyarı**, **hatırlatma** veya **"Anlaşıldı"** ile dismiss edilebilir olmalı.

---

## Ürün bağlamı (araştırmadan önce oku)

**Arvia** — Türkiye pazarı için iOS SwiftUI + SwiftData uygulaması. Araç sahiplerinin dijital dosyasını tutar (muayene, sigorta, bakım, masraf, belge, satış dosyası PDF). MVP yakın zamanda TestFlight'a gönderilecek.

**Hedef kullanıcı:** Türk araç sahipleri (ortalama 25-55 yaş, şehir içi + şehirler arası kullanım). Teknik bilgi seviyesi orta. App'i açtığında **neye dikkat etmesi gerektiğini** bilmek istiyor ama **neyi ne zaman yapacağına kendisi karar vermek** istiyor.

**Tasarım anayasası (`01_DESIGN.md`):** Token-only, AI-slop yasak, Apple-native (Settings.app hissi), her element anlamlı. Subtle, sıcak, ciddi ama davetkar. Mavi-mor gradient / glassmorphism / generic SaaS kart grid **kesinlikle yasak**.

**Mevcut rehber modeli (`Models/VehicleInsight.swift`):**

```swift
struct VehicleInsight {
    let type: VehicleInsightType       // 13 tip — overdueReminder, upcomingReminder, calendarPeriod,
                                       //            odometerUpdate, seasonalGuidance, fuelTypeGuidance,
                                       //            transmissionGuidance, odometerMilestone,
                                       //            monthlyExpensePrompt, maintenance,
                                       //            missingDocument, quietGoodState, saleFileReadiness
    let priority: VehicleInsightPriority  // .info, .warning, .important
    let title: String                  // "120.000 km çevresi"
    let body: String                   // "Bu km aralığında bakım kayıtlarını kontrol etmek faydalı olabilir."
    let action: VehicleInsightAction   // ZORUNLU CTA — 10 tip var (addServiceRecord, addExpense, ...)
    let relatedReminderId: UUID?
}

enum VehicleInsightAction: String, CaseIterable {
    case addServiceRecord, addDocument, openSaleFile, updateOdometer,
         openTodos, addInspectionReport, addReminder, addMTVReminder,
         addExpense, addFuelExpense
}
```

**Mevcut CTA'ların hepsi "Ekle" odaklı** — bu kullanıcının eleştirdiği nokta. Hiçbir bilgilendirme / hatırlatma / uyarı tipi yok.

**Mevcut "Daha sonra" butonu** → kullanıcı **"Anlaşıldı"** olmalı diyor. Dismiss sonrası **aynı rehber döngüsünde bir daha göstermesin** (örn. snoozeStore ile — `Services/InsightSnoozeStore.swift` mevcut yapı bu iş için kullanılabilir).

---

## Araştırman gereken 5 ana konu

### 1) İçerik tipi kategorileri — CTA zorunluluğunu kaldır

Mevcut yapıda her kart bir CTA'ya sahip. Yeni yapıda **5 farklı içerik tipi** olmalı. Her birini detaylıca tanımla, ne zaman kullanılacağını açıkla, somut örnekler ver:

| Tip | Tanım | Örnek tetikleyici | Örnek metin | Örnek etkileşim |
|---|---|---|---|---|
| **A. CTA (Eylem)** | Kullanıcıyı belirli bir formu açmaya yönlendiren | Geciken hatırlatıcı, eksik belge | "Muayene 5 gün gecikti." | [Yapılacaklara Git →] |
| **B. Bilgi** | Sadece bilgilendirme, CTA yok | Mevsim hatırlatması, yakıt tipi önerisi | "Yaz döneminde klima kontrolü faydalı olabilir." | [Anlaşıldı] |
| **C. Uyarı** | Dikkat çekici ama acil değil, bilgilendirme + hafif yönlendirme | Yüksek km, eski bakım | "Son bakımın üzerinden 14 ay geçmiş." | [Anlaşıldı] veya [Bakım Geçmişi →] |
| **D. Hatırlatma (pasif)** | Kullanıcıya "kontrol etmeyi unutma" diyen, eylem yok | Sahiplik yıl dönümü, mevsim geçişi | "Muayene tarihin yaklaşıyor, hatırlatmanda." | [Anlaşıldı] |
| **E. Soru (yumuşak)** | Kullanıcıyı düşünmeye davet eden | Eksik veri, belirsiz kayıt | "Bu ay masraf kaydı eklemek ister misin?" | [Ekle] veya [Hayır, Anlaşıldı] |

Her tip için:
- Hangi `VehicleInsightType` enum case'leri bu tipe geçmeli? (mevcut 13'ü yeniden eşle)
- Yeni `VehicleInsightAction` case'leri öner (örn. `.dismissAndSnooze`, `.markAsRead`, `.noAction`).
- Hangi `priority` seviyesinde gösterilmeli?
- Dismiss sonrası davranış: snooze süresi (örn. 30 gün / bu döngü / kalıcı)?
- Konum: Garaj daily summary mi yoksa sadece Araç Detay rehber'de mi?

### 2) Tetikleyici senaryolar — tüm varyasyonlar

Aşağıdaki boyutları **eksiksiz** çaprazla ve her kombinasyon için potansiyel rehber içeriği öner:

**a) Araç tipi:**
- Otomobil / Motosiklet / (gelecekte) Kamyonet / Elektrikli scooter

**b) Yakıt tipi:**
- Benzin / Dizel / LPG / Hibrit (HEV) / Plug-in hibrit (PHEV) / Tam elektrik (BEV)

**c) Vites tipi:**
- Manuel / Otomatik ( klasik torque converter) / DSG / CVT / Yarı otomatik

**d) Kullanım tipi:**
- Kişisel / Şirket / Ticari (taksi, uber) / Kiralık / Uzun yol ağırlıklı / Şehir içi ağırlıklı

**e) Mevsim (Türkiye):**
- Kış (Aralık-Şubat) / Bahar (Mart-Mayıs) / Yaz (Haziran-Ağustos) / Sonbahar (Eylül-Kasım)
- Her mevsim için Türkiye'ye özel durumlar: kar yağışı bölgeleri, aşırı sıcak (Güneydoğu), nem (Karadeniz, Marmara), toz (Akdeniz)

**f) Yaş (model yılından itibaren):**
- 0-1 yıl (yeni) / 1-3 yıl / 3-5 yıl / 5-10 yıl / 10+ yıl (klasik)
- Her yaş için tipik bakım profili, garanti durumu, parça bulunabilirliği

**g) Km milestone:**
- 5.000 / 10.000 / 15.000 / 20.000 / 30.000 / 50.000 / 75.000 / 100.000 / 150.000 / 200.000+
- Her milestone için tipik bakım gereksinimi

**h) Tarih / takvim:**
- MTV 1. taksit (Ocak) / MTV 2. taksit (Temmuz) / Trafik sigortası yenileme (genelde Eylül-Ekim) / Kış lastiği zorunluluğu (Aralık-Şubarda bazı illerde)
- Yaklaşan tatil / uzun yol sezonu (bayram, yaz tatili)
- Dini bayramlar (kullanıcı seyahat alışkanlığı)

**i) Mevcut kayıt durumu:**
- Hiç kayıt yok / Sadece temel bilgiler / Kısmen dolu / Çok dolu
- Belge var mı? Bakım var mı? Masraf var mı? Km güncel mi?
- Hangi kayıt tipleri eksikse farklı rehber tetiklenmeli

**j) Kullanıcı alışkanlıkları (ör. son 6 ay):**
- Km güncelleme sıklığı / masraf ekleme sıklığı / hatırlatıcı tamamlama oranı
- Hiç km güncellememişse → özel rehber
- Sürekli "Daha sonra"ya basıyorsa → sıklığı azalt

**Her kombinasyon için** şunu ver:
- Tetik koşulu (kural)
- Önerilen içerik tipi (A/B/C/D/E)
- Örnek başlık
- Örnek gövde metni (Türkçe, 1-2 cümle, samimi ama ciddi ton)
- Önerilen etkileşim butonu / butonları
- Snooze davranışı

### 3) Ton ve üslup kuralları

Arvia'nın sesi şöyle olmalı — bu kısıtlamalara uy:

- **Samimi ama ciddi:** "Sen" dili, ama "bilge patron" değil "yanındaki arkadaş" tonda.
- **Kısa:** Kart başlığı max 4-5 kelime, gövde max 2 cümle.
- **Yargılamayan:** "Şunu yapmalısın" değil, "faydalı olabilir" veya "kontrol etmeyi düşünebilirsin".
- **Saygılı:** Kullanıcının bilgisini küçümsemeden, abartmadan bilgi ver.
- **Türkçe doğal:** "Kayıt altında tutmak faydalı olabilir" yerine "kayda almak işini kolaylaştırır" gibi.
- **Teknik terim açıklaması:** "DPF" gibi terimler gerekiyorsa parantez içinde 1 kelimelik açıklama.

**Olumlu örnekler (mevcut iyi):**
- "Her şey yolunda görünüyor." — sakin, onaylayıcı
- "MTV 1. taksit dönemindesin" — bilgilendirici

**Olumsuz örnekler (düzeltilecek):**
- ~~"Dizel için kayıt önerisi" + "Bakım Kaydı Ekle"~~ → kullanıcı neden ekleyeceğini bilmiyor, eylem dayatıyor
- ~~"120.000 km çevresi" + "Bakım Kaydı Ekle"~~ → aynı sorun
- ~~"Yaz dönemi kontrolü" + "Hatırlatıcı Ekle"~~ → kullanıcı zaten mevsimde, hatırlatıcıya ne gerek?

**Her düzeltme için:**
- Eski metin
- Yeni metin (içerik tipine göre)
- Neden daha iyi

### 4) Best practice araştırması

Aşağıdaki uygulamaların rehber / içgörü / hatırlatma sistemlerini **web'den araştır** ve Arvia için uygulanabilir pattern'leri çıkar:

- **Otomotiv / sürüş:** Tesla app, FordPass, Toyota MyT, BMW Connected, Mercedes me, Hyundai Bluelink, Volvo Cars, Škoda Connect, TÜVTÜRK, Otokoç
- **Finans / fatura:** Splitwise, Wallet by BudgetBakers, Spendee
- **Sağlık / wellness:** Apple Health, Whoop, Strava (kişiselleştirilmiş insight örnekleri)
- **Genel mobile UX:** Apple Settings, Things 3, Bear (içerik kartı pattern'leri)

**Her uygulama için:**
- Kaç farklı içerik tipi kullanıyor? (CTA / bilgi / uyarı / soru)
- Dismiss / snooze mekanizması nasıl?
- Ton ve üslup örnekleri (1-2 screenshot description)
- Arvia'ya uygulanabilir 1-2 somut öneri

### 5) Mimari öneriler (Swift tarafı)

Mevcut `VehicleInsight` modeli CTA-zorunlu. Yeni model için öner:

- `VehicleInsight` struct'ında `action: VehicleInsightAction?` opsiyonel olmalı (nil = CTA yok).
- Yeni `VehicleInsightAction` case'leri: `.dismissAndSnooze(days: Int)`, `.markAsRead`, `.noAction`, `.acknowledge`.
- `InsightSnoozeStore` mevcut yapıyı kullan (clearReminderSnoozes mantığını genelle).
- `VehicleInsightDisplayContext` zaten `garageDaily` vs `vehicleDetailGuide` ayrımı yapıyor — yeni içerik tipleri için hangi context'te gösterileceğini belirle.
- Yeni `VehicleInsightContentKind` enum'u öner: `.callToAction`, `.info`, `.warning`, `.reminder`, `.softQuestion`.
- Component tarafı: `OwnershipInsightCard` zaten var — sadece CTA'sı olmayan varyantı için `InsightInfoCard` veya `DismissableInsightCard` öner.
- Test stratejisi: `DemoDataSeeder`'a yeni senaryolar ekle (Karar 3.4 genişletmesi).

---

## Çıktı formatı (kesinlikle uy)

Raporunu **Türkçe** olarak, aşağıdaki yapıda, **Markdown** formatında ver. Tahmini uzunluk: 8000-12000 kelime. Kod bloklarında Swift örnekleri olabilir.

```
# Arvia Rehber İçerik Stratejisi — Araştırma Raporu

## Yönetici özeti
(200 kelime: mevcut durum, ana sorun, önerilen çözüm)

## Bölüm 1 — İçerik tipi kategorileri
### 1.1 CTA (Eylem)
### 1.2 Bilgi
### 1.3 Uyarı
### 1.4 Hatırlatma (pasif)
### 1.5 Soru (yumuşak)
(her biri için: tanım, kullanım koşulu, mevcut hangi type'lar buna geçmeli, örnek)

## Bölüm 2 — Tetikleyici senaryolar matrisi
(her boyut için tablo, çapraz kombinasyonlar)

## Bölüm 3 — Ton ve üslup
### 3.1 Doğru örnekler
### 3.2 Yanlış örnekler ve düzeltmeleri
### 3.3 Ses rehberi (yeni içerik yazarken uyulacak kurallar)

## Bölüm 4 — Best practice (otomotiv + diğer)
(her uygulama için 200-400 kelime)

## Bölüm 5 — Mimari öneriler (Swift)
### 5.1 Model değişiklikleri
### 5.2 Yeni action case'leri
### 5.3 Snooze / dismiss mantığı
### 5.4 Component önerisi
### 5.5 Test senaryoları

## Bölüm 6 — Uygulama yol haritası
### 6.1 MVP sonrası ilk güncelleme (v1.1)
### 6.2 v1.2 ve sonrası
### 6.3 Açık sorular

## Ek — Mevcut 13 insight'ın yeni tip eşlemesi
(tablo: Eski tip → Yeni tip → Eski CTA → Yeni CTA veya dismiss)
```

---

## Araştırma ipuçları

- Web'de "otomotiv app reminder best practices", "in-app contextual onboarding", "non-intrusive notification patterns iOS" gibi sorgular çalıştır.
- Apple Human Interface Guidelines içinde "Notifications", "Surfaces and Materials", "Feedback" bölümlerine bak.
- Türkiye'ye özel: MTV takvim, kış lastiği zorunluluğu illeri, sigorta yenileme dönemleri için resmi kaynaklara başvur (Gelir İdaresi Başkanlığı, TÜVTÜRK, Sigorta Bilgi ve Gözetim Merkezi).
- 2024-2026 yılı makalelerine öncelik ver (eski pattern'ler modası geçmiş olabilir).

---

## Kısıtlamalar

- ❌ Mevcut `01_DESIGN.md` kurallarını ihlal etme (token-only, AI-slop yasak, native hissi).
- ❌ "Sürekli bildirim gönderen" veya "kullanıcıyı rahatsız eden" pattern önerme — Arvia pasif, saygılı.
- ❌ Jenerik SaaS / fintech / e-ticaret önerisi getirme — bağlam otomotiv sahipliği.
- ✅ Türkiye pazarına özel içerikler öner (Türkçe, yerel düzenlemeler, yerel mevsim koşulları).
- ✅ Arvia'nın MVP kararlarıyla çelişme (Karar 3.1-3.6, Karar 4.1 referans alınacak).

---

## Teslim

Rapor tamamlandığında `docs/RESEARCH_ARVIA_GUIDE_SCENARIOS.md` olarak kaydet. Manifestoya **Karar 4.2: Arvia Rehber içerik yeniden yapılandırma** eklenecek (bu rapor referans alınarak).