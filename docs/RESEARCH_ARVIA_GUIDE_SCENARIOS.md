# **Arvia Rehber İçerik Stratejisi — Araştırma Raporu**

## **Yönetici özeti**

Arvia mobil uygulamasının "Arvia Rehber" modülü, araç sahiplerinin dijital arşiv ve operasyonel takip süreçlerini kolaylaştırmayı hedefleyen kural tabanlı bir öneri motorudur. Yapılan kullanıcı deneyimi analizleri, mevcut 13 kural kartının tamamında zorunlu bir eylem yönlendirmesi (CTA) bulunmasının kullanıcılar üzerinde psikolojik yorgunluk ve direnç yarattığını ortaya koymuştur. Her etkileşimde veri girişi veya form doldurma zorunluluğu hissettiren bu "robotik" yaklaşım, kullanıcıların sistemi "eyleme zorlayan bir bildirim paneli" olarak algılamasına ve kartları hızla göz ardı etmesine neden olmaktadır.  
Bu araştırma raporunda, mevcut tekil eylem odaklı yapı yerine, kullanıcı psikolojisine ve bilişsel yük dengesine saygı duyan beş farklı içerik tipi kategorisi (Eylem, Bilgi, Uyarı, Pasif Hatırlatma, Yumuşak Soru) tanımlanmaktadır. Apple'ın yerel tasarım felsefesine (Settings.app sadeliği) sadık kalınarak, her kartın anlamlı bir amaca hizmet etmesi, AI jenerik söylemlerinden (AI-slop) kaçınılması ve kullanıcıya kendi kararlarını verme özgürlüğü tanınması hedeflenmektedir. Teknik altyapıda VehicleInsight veri modelinin opsiyonel eylem ve dinamik erteleme (snooze) mekanizmalarıyla esnetilmesi, Türkiye pazarına özel mevzuat (TÜVTÜRK muayenesi, MTV takvimi) ve mekanik gereksinimler (DSG/CVT şanzıman bakımları, DPF temizliği, elektrikli araç batarya optimizasyonları) ile desteklenen zengin bir tetikleyici senaryolar matrisinin kurulması önerilmektedir.

## **Bölüm 1 — İçerik tipi kategorileri**

Mevcut sistemde tüm kural kartlarının zorunlu bir eylem yönlendirmesi içermesi, kullanıcının uygulama içindeki özerkliğini kısıtlamaktadır. Kullanıcı deneyimini iyileştirmek adına, kartların bilişsel seviyelerine ve aciliyet durumlarına göre beş farklı içerik kategorisine ayrılması planlanmaktadır. Bu kategoriler, kullanıcının o anki durumuna göre esnek etkileşim modelleri sunarak eylem yorgunluğunu en aza indirmeyi hedeflemektedir.

| İçerik Kategorisi | Öncelik Seviyesi (Priority) | Temel Tetikleyici Koşul | Birincil Kullanıcı Etkileşimi | İkincil Kullanıcı Etkileşimi | Varsayılan Erteleme (Snooze) Süresi |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **A. CTA (Eylem)** | .important | Yasal gecikmeler, kritik eksik belgeler, kaçırılmış muayene tarihleri. | Belirli bir formu/ekranı açan birincil buton. | Yok (Zorunlu eyleme yönlendirme). | Erteleme yapılamaz veya 3 gün limitli. |
| **B. Bilgi** | .info | Mevsim geçişleri, yakıt tipine özel sürüş önerileri, batarya sağlığı tavsiyeleri. | "Anlaşıldı" butonu (Dismiss). | Yok. | 90 Gün (Sezonluk geçiş). |
| **C. Uyarı** | .warning | Yaklaşan ağır bakımlar, yüksek kilometre eşikleri, eski tarihli servis kayıtları. | İlgili geçmiş ekranına yönlendiren buton. | "Anlaşıldı" butonu (Dismiss). | 14 Gün veya 30 Gün. |
| **D. Hatırlatma (Pasif)** | .info | Yaklaşan vergi dönemleri, sahiplik yıl dönümü, pasif takvim olayları. | "Anlaşıldı" butonu (Dismiss). | Yok. | Olay gerçekleşene kadar gizleme. |
| **E. Soru (Yumuşak)** | .info | Uzun süredir veri girişi yapılmaması, belirsiz kalan masraf dönemleri. | Eylemi başlatan "Ekle" butonu. | "Şimdi Değil" butonu. | 30 Gün. |

### **1.1 CTA (Eylem)**

Eylem odaklı içerik tipi, kullanıcının hemen müdahale etmesi gereken yasal veya operasyonel risk durumlarında devreye girmektedir. Bu kategoride kullanıcıya doğrudan problemi çözecek olan ekran veya form açtırılmaktadır. Örneğin, TÜVTÜRK muayenesinin gecikmesi durumunda1, kullanıcının ceza ve yasal yaptırımlarla karşılaşmaması için bu kart yüksek öncelikle gösterilmektedir. VehicleInsightType modelinde yer alan .overdueReminder ve .missingDocument durumları doğrudan bu kategoriye girmektedir. Kullanıcı eylemi gerçekleştirene kadar kart Garaj Günlük Özeti ekranında kalmaya devam etmektedir.

### **1.2 Bilgi**

Bilgi tipi kartlar, kullanıcıyı herhangi bir veri girişine veya form doldurmaya zorlamayan, tamamen değer yaratma ve bilgilendirme odaklı içeriklerden oluşmaktadır. Bu kartların tasarım amacı, araç sahibinin kullanım bilincini artırmak ve araca özel mekanik hassasiyetleri hatırlatmaktır. Örnek olarak, kış aylarında tam elektrikli araçların (BEV) batarya sağlığını korumak amacıyla şarj seviyesinin yüzde 20 ile 80 arasında tutulması yönündeki mühendislik tavsiyesi gösterilebilmektedir3. .seasonalGuidance ve .fuelTypeGuidance tipleri bu kategoride konumlandırılmaktadır. Kullanıcı kartı "Anlaşıldı" buonu ile kapattığında, sistem bu kartı tüm kış sezonu boyunca (90 gün) bir daha göstermemektedir.

### **1.3 Uyarı**

Uyarı tipi kartlar, acil bir yasal yaptırım içermeyen ancak göz ardı edildiğinde uzun vadede yüksek maliyetli mekanik arızalara sebep olabilecek durumları kapsamaktadır. Islak kavramalı DSG şanzımana sahip bir aracın 60.000 kilometre eşiğine yaklaşması durumunda şanzıman yağı ve filtre değişiminin hatırlatılması bu kategoriye girmektedir5. .upcomingReminder, .odometerUpdate ve .transmissionGuidance bu sınıfa dahil edilmektedir. Kullanıcıya "Bakım Geçmişini Gör" şeklinde bir yönlendirme butonu sunulurken, dilerse kartı "Anlaşıldı" diyerek 14 gün boyunca erteleme (snooze) imkanı tanınmaktadır.

### **1.4 Hatırlatma (pasif)**

Pasif hatırlatıcılar, kullanıcının zihnini meşgul etmesini engelleyen ancak arka planda takip edildiğini bilmesini sağlayan kartlardır. Motorlu Taşıtlar Vergisi (MTV) taksit dönemlerinin hatırlatılması bu kategorinin en tipik örneğidir8. .calendarPeriod ve .quietGoodState durumları bu kategoriye aittir. Kart, "Muayene tarihin yaklaşıyor, takibimizde" benzeri sakinleştirici ve güven verici bir ton taşımaktadır. Kullanıcı "Anlaşıldı" butonuna bastığında kart ilgili takvim dönemi kapanana kadar sistem tarafından sessize alınmaktadır.

### **1.5 Soru (yumuşak)**

Yumuşak sorular, veritabanındaki eksiklikleri tamamlamak ve kullanıcıyı uygulamayı aktif kullanmaya teşvik etmek amacıyla tasarlanmış mikro anket benzeri yapılardır. "Bu ay hiç yakıt masrafı yaptın mı?" veya "Aracının kilometresi hala 45.000 mi?" gibi sorular bu kategoriye girmektedir. .monthlyExpensePrompt ve .odometerMilestone durumları burada konumlandırılmaktadır. Kullanıcıya \[Evet, Ekle\] ve \[Hayır, Güncel\] şeklinde iki seçenek sunularak bilişsel yük hafifletilmektedir. "Şimdi Değil" seçeneği tıklandığında kart 30 gün boyunca arşivlenmektedir.

## **Bölüm 2 — Tetikleyici senaryolar matrisi**

Arvia kural motorunun arka planda çalıştıracağı tetikleyiciler, aracın mekanik, yasal, mevsimsel ve kullanıcı alışkanlıklarına bağlı parametrelerinin çaprazlanmasıyla elde edilmektedir. Türkiye pazarının yasal gereksinimleri ve sürüş alışkanlıkları göz önünde bulundurularak hazırlanan matris aşağıda detaylandırılmıştır.

### **2.1 Mekanik, Yasal ve Alışkanlık Matrisi**

Aracın teknik altyapısı, yaşı ve kullanıcının veri giriş alışkanlıkları doğrultusunda sistemin üreteceği kural tabanlı içerikler aşağıdaki tabloda yapılandırılmıştır.

| No | Tetikleme Koşulu (Kural Yapısı) | İçerik Tipi | Örnek Başlık | Örnek Gövde Metni (Türkçe UX Yazımı) | Etkileşim Butonları | Erteleme (Snooze) Mantığı |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| **1** | Araç Tipi: Otomobil & Yaş: 3+ & Son Muayene Tarihi üzerinden 715 gün geçmiş olması1. | **A. CTA (Eylem)** | Muayene Tarihi Geçti | TÜVTÜRK muayene süresi dolmuş görünüyor. Gecikme cezası almamak için muayene kaydını güncelleyebilirsin2. | \[Muayene Bilgisini Güncelle\] | Erteleme kapatılır. Form doldurulana kadar her gün gösterilir. |
| **2** | Araç Tipi: Kamyonet & Kullanım Tipi: Ticari & Son Muayene üzerinden 350 gün geçmiş olması1. | **A. CTA (Eylem)** | Yıllık Muayene Zamanı | Ticari ruhsatlı kamyonetlerin muayenesi yasal olarak her yıl tekrarlanmalıdır1. Süreyi kontrol etmeyi unutma. | \[Muayene Tarihi Ekle\] | 3 gün boyunca erteleme seçeneği sunulur, ardından sabit kalır. |
| **3** | Yakıt Tipi: Tam Elektrikli (BEV) & Mevsim: Kış & Sıcaklık \< 5°C9. | **B. Bilgi** | Kışın Batarya Sağlığı | Soğuk havalarda bataryayı %20-%80 aralığında tutmak, lityum hücrelerin ömrünü uzatır3. | \[Anlaşıldı\] | 90 gün boyunca (kış sezonu bitene kadar) tekrar gösterilmez. |
| **4** | Vites Tipi: Islak DSG & Kilometre: 58.000 \- 60.000 aralığı5. | **C. Uyarı** | DSG Şanzıman Yağı | Islak kavramalı DSG şanzımanlarda her 60.000 km'de bir yağ ve filtre değişimi mekanik ömür için kritiktir5. | \[Bakım Kayıtlarına Git\] / \[Anlaşıldı\] | 30 gün boyunca erteleme uygulanır. |
| **5** | Vites Tipi: CVT & Kilometre: 40.000 veya 80.000 eşiği & Kullanım: Şehir İçi10. | **C. Uyarı** | CVT Şanzıman Kontrolü | Yoğun şehir içi trafiğinde kullanılan CVT şanzımanların yağı 40.000 km civarında yenilenmelidir10. | \[Bakım Geçmişini Kontrol Et\] / \[Anlaşıldı\] | 14 gün boyunca erteleme uygulanır. |
| **6** | Yakıt Tipi: Dizel & Kullanım: Yoğun Şehir İçi & Son 6 ayda ortalama hız \< 25 km/s13. | **B. Bilgi** | DPF Tıkanmasını Önle | Kısa mesafe kullanımlarda dizel partikül filtresinin (DPF) dolmasını önlemek için haftada bir 20 dakika yüksek devirli sürüş yapabilirsin13. | \[Anlaşıldı\] | 30 gün boyunca sessize alınır. |
| **7** | Tarih: 1-15 Ocak veya 1-15 Temmuz aralığı (MTV Taksit Dönemleri)8. | **D. Hatırlatma** | MTV 1\. Taksit Dönemi | Ocak ayı Motorlu Taşıtlar Vergisi (MTV) ödemeleri başladı8. Ödeme yaptıysan kayda alabilirsin. | \[Masraf Ekle\] / \[Anlaşıldı\] | İlgili ayın sonuna kadar (31 Ocak/31 Temmuz) sessize alınır. |
| **8** | Kullanıcı Alışkanlığı: Son 60 gündür kilometre güncellemesi yapılmamış olması. | **E. Soru (Yumuşak)** | Kilometre Güncel mi? | Aracının güncel kilometresini girmek, bakım zamanlarını daha doğru tahmin etmemize yardımcı olur. | \[Kilometreyi Güncelle\] / \[Şimdi Değil\] | 30 gün boyunca tekrar sorulmaz. |
| **9** | Araç Yaşı: 10+ & Kilometre: 150.000+ & Son 12 aydır bakım kaydı girilmemiş olması. | **C. Uyarı** | Yaş Almış Araç Bakımı | 10 yaş üzeri araçlarda yılda en az bir kez motor yağı ve filtre bakımı yaptırmak mekanik sağlığı korur5. | \[Bakım Girişi Yap\] / \[Anlaşıldı\] | 30 gün boyunca erteleme uygulanır. |
| **10** | Kayıt Durumu: Belge Arşivi Boş (Sıfır PDF yükleme). | **E. Soru (Yumuşak)** | Belgelerin Güvende mi? | Ruhsat, sigorta poliçesi veya muayene raporu gibi belgeleri dijital dosyana ekleyerek her an erişilebilir kılabilirsin. | \[Belge Yükle\] / \[Sonra Hatırlat\] | 15 gün boyunca sessize alınır. |

### **2.2 Coğrafi ve Mevsimsel Koşullar Matrisi**

Türkiye'nin iklimsel ve coğrafi çeşitliliği, araçlar üzerinde farklı mekanik stresler yaratmaktadır. Bu kapsamda, bölgesel mevsimsel koşullara göre özelleştirilmiş kural tabanlı içerikler aşağıdaki tabloda detaylandırılmıştır.

| Coğrafi Bölge | Mevsim Koşulu | Mekanik / Yasal Gerekçe | Örnek Başlık | Örnek Gövde Metni (Türkçe) | İçerik Tipi | Erteleme |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| Doğu & İç Anadolu | Kış (Aralık \- Şubat) | Sıcaklığın sürekli 7°C altına düşmesi ve zorunlu kış lastiği mevzuatı. | Kış Lastiği Hatırlatması | Bölgedeki yoğun kış koşulları ve yasal zorunluluk nedeniyle kış lastiklerine geçiş yapmayı düşünebilirsin. | **D. Hatırlatma** | 30 Gün |
| Güneydoğu & Akdeniz | Yaz (Haziran \- Ağustos) | Aşırı sıcaklıkların motor soğutma suyu ve lastik basınçları üzerindeki genleşme etkisi. | Yüksek Sıcaklık Kontrolü | 40°C'yi aşan yaz sıcaklarında motor soğutma sıvısını ve lastik havalarını kontrol etmek sürüş güvenliğini korur. | **B. Bilgi** | 45 Gün |
| Karadeniz & Marmara | Sonbahar (Eylül \- Kasım) | Yoğun yağışlar, yüksek nem seviyesi ve silecek/cam buğu önleme gereksinimleri. | Yağış Öncesi Görüş | Sonbahar yağışları başlamadan önce silecek lastiklerini yenilemek ve cam suyu seviyesini tamamlamak sürüş konforunu artırır. | **B. Bilgi** | 60 Gün |
| Akdeniz & Ege | Bahar (Mart \- Mayıs) | Sahil şeritlerindeki yüksek tuz tozu ve polen birikiminin kabin filtresi üzerindeki etkisi. | Polen Filtresi Değişimi | Bahar aylarındaki yoğun polen birikimi kabin içi hava kalitesini düşürebilir; polen filtresini kontrol etmek faydalı olabilir15. | **C. Uyarı** | 30 Gün |

### **2.3 Mekanik ve Yasal Senaryoların Detaylı Analizi**

Türkiye'deki yasal düzenlemelere göre hususi otomobiller ve motosikletler ilk üç yaşın sonunda, devamında ise her iki yılda bir TÜVTÜRK muayenesine girmek zorundadır1. Ancak ticari tescilli kamyonetler, taksiler ve şirket araçları ilk yaştan itibaren her yıl muayene edilmek mecburiyetindedir1. Kural motorunun bu iki ayrımı net olarak yapması, ticari araç sahiplerinin gereksiz cezai işlemlerle karşılaşmasını önlemektedir2. Muayene gecikmelerinde uygulanan yasal gecikme faizleri göz önüne alındığında, bu durumun birincil acil aksiyon (CTA) olarak kurgunlanması doğrulanmaktadır2.  
Mekanik tarafta ise şanzıman tipleri farklı hassasiyetler barındırmaktadır. Kuru kavramalı çift kavramalı sistemler (DQ200 DSG gibi) genellikle kapalı devre olarak kabul edilse de5, ıslak kavramalı sistemlerin (DQ250, DQ381 gibi) 60.000 ile 80.000 kilometre aralığında şanzıman yağı ve filtre değişimine ihtiyaç duyduğu bilinmektedir5. Bu değişimlerin aksatılması mekatronik ünite arızalarına yol açarak araç sahibine çok yüksek maliyetler çıkarabilmektedir7. Benzer şekilde, CVT şanzıman sistemleri de yağ kalitesine karşı aşırı hassastır ve Nissan/Honda gibi üreticiler yoğun şehir içi kullanımında 40.000 kilometrede bir yağ değişimi önermektedir10.  
Dizel araçlarda sıklıkla karşılaşılan Dizel Partikül Filtresi (DPF) tıkanması, özellikle sürekli dur-kalk trafiğinde ve kısa mesafelerde kullanılan araçların ortak sorunudur13. Sistem, kullanıcının geçmiş kilometre girişlerinden veya düşük ortalama hız verilerinden yoğun şehir içi kullanımı saptadığında, egzoz sıcaklığının pasif rejenerasyon için gereken 550°C seviyesine çıkabilmesi amacıyla otoyol sürüşü tavsiye eden bilgi kartları üretmektedir13. Bu proaktif yaklaşım filtre değişim veya temizleme maliyetlerinin önüne geçmektedir13.  
Dizel motorlarda partikül birikiminin zamana bağlı aşınma katsayısı ve yakıt tüketimindeki artış oranı aşağıdaki formülle hesaplanabilmektedir:  
![][image1]  
Burada ![][image2] aşınma sonrası güncel yakıt tüketim değerini, ![][image3] aracın fabrika çıkış bütçesini, ![][image4] toplam kat edilen mesafeyi ve ![][image5] ise sürücünün kullanım alışkanlıklarına ve DPF doluluk oranına göre değişen aşınma katsayısını temsil etmektedir.  
Elektrikli araçlarda (BEV) ise batarya State of Health (SoH) değerinin korunması kritik bir finansal öneme sahiptir18. Lityum-iyon bataryaların günlük kullanımda sürekli yüzde 100 şarj edilmesi veya yüzde 0 seviyesine kadar deşarj edilmesi kimyasal hücre gerilimini artırarak yaşlanmayı hızlandırmaktadır3. Yapılan çalışmalar, bataryasını yüzde 20-80 aralığında tutan kullanıcıların 5 yıl sonundaki kapasite kaybının, sürekli tam şarj edenlere göre yüzde 15 daha az olduğunu göstermektedir4. Ayrıca aşırı soğuk havalarda DC hızlı şarjın hücrelere zarar verme riski nedeniyle AC yavaş şarj önerilmesi, kural motorunun bölgesel hava durumu verileriyle ne kadar entegre çalışması gerektiğini göstermektedir9.  
Bataryanın zamana bağlı kimyasal bozulma (degradation) hızı ise şu matematiksel model ile ifade edilebilir:  
![][image6]  
Bu denklemde ![][image7] aracın güncel batarya sağlığını, ![][image8] başlangıçtaki batarya kapasitesini, ![][image9] takvimsel yaşlanma katsayısını, ![][image10] geçen süreyi, ![][image11] hızlı şarj aşınma katsayısını ve ![][image12] ise kullanıcının DC hızlı şarj kullanım sıklığını temsil etmektedir.

## **Bölüm 3 — Ton ve üslup**

Arvia'nın kullanıcıyla kurduğu sözel iletişim, uygulamanın benimsenmesi ve kullanıcı üzerinde baskı yaratmaması açısından kritik bir öneme sahiptir. "Yargılamayan, sakin ve rehberlik eden" bir dil yapısı kurulmalıdır.

### **3.1 Doğru örnekler**

Aşağıdaki metinler, kullanıcının karar verme mekanizmasına müdahale etmeyen, ona saygı duyan ve bilgi veren doğru dil kullanım örnekleridir:

* **MTV Dönemi İçin:** "Ocak ayı MTV ödemeleri başladı8. Dilersen yaptığın ödemeyi masraflarına kaydederek araç bütçeni güncel tutabilirsin." (Zorlama yok, "dilersen" ifadesiyle inisiyatif kullanıcıya bırakılıyor).  
* **Kilometre Güncellemesi İçin:** *"Aracınla son seyahatinden bu yana biraz zaman geçti. Kilometreyi güncellemek, yaklaşan bakım dönemlerini doğru tahmin etmemizi kolaylaştırır."* (Gerekçe açıklanıyor, komut verilmiyor).  
* **Kış Lastiği Zorunluluğu İçin:** *"Ulaştırma Bakanlığı genelgesine göre ticari araçlar için kış lastiği zorunluluğu başlıyor. Güvenli sürüş için lastik diş derinliğini kontrol etmek faydalı olabilir."* (Yasal dayanak ve güvenlik gerekçesi yumuşak bir dille sunuluyor).

### **3.2 Yanlış örnekler ve düzeltmeleri**

Mevcut yapıdaki sert, emir kipi içeren ve kullanıcıyı yetersiz hissettiren metinler, yeni içerik stratejisine göre aşağıdaki şekilde revize edilmiştir:

| Eski Metin (Hatalı) | Yeni Metin (Doğru) | Revizyon Gerekçesi (UX Yazımı Analizi) |
| :---- | :---- | :---- |
| **"Hemen Masraf Girişi Yapın"** (Zorunlu addExpense CTA kartı) | **"Bu ay bütçeni kontrol etmek ister misin?"** (E. Soru Tipi) | Eski metin emir kipi kullanarak kullanıcıda "yapılması zorunlu bir iş" algısı yaratmaktadır. Yeni metin ise kullanıcıyı kendi bütçesini yönetmeye davet eden yumuşak bir soru yöneltmektedir. |
| **"Dizel araç için bakım kaydı eksik. Hemen ekleyin."** (Hatalı fuelTypeGuidance) | "Dizel motorların performansını korumak için enjektör ve DPF (partikül filtresi) sağlığı önemlidir13. Geçmiş bakımlarını kayda almak takibi kolaylaştırır." (B. Bilgi Tipi) | Eski metin kullanıcıyı eksik veri nedeniyle suçlamaktadır. Yeni metin ise önce DPF ve enjektör gibi kritik bileşenlerin önemini parantez içi teknik açıklamalarla vermekte13, ardından kayıt tutmanın faydasını anlatmaktadır. |
| **"120.000 km ağır bakım zamanı geldi\! Bakım kaydı girin."** (Zorlayıcı maintenance kartı) | "Aracın 120.000 km eşiğinde. Bu kilometre aralığında triger seti ve ağır bakımların kontrol edilmesi mekanik ömür için faydalı olabilir15." (C. Uyarı Tipi) | Eski metin alarmist bir tonla panik yaratmaktadır. Yeni metin ise "faydalı olabilir" ifadesiyle kullanıcıyı mekanik gereksinim hakkında bilgilendirmekte ve kararı ona bırakmaktadır. |
| **"Ruhsat poliçeniz sistemde yok. Belge yükleyin."** (Zorlayıcı missingDocument) | **"Olası bir kontrol veya kaza anında belgelerine hızla erişebilmek için ruhsat fotoğrafını dijital dosyana ekleyebilirsin."** (E. Soru Tipi) | Eski metin bürokratik ve soğuktur. Yeni metin ise belgenin yüklenme amacını (kaza veya kontrol anında hızlı erişim) net bir fayda olarak sunmaktadır. |

### **3.3 Ses rehberi (yeni içerik yazarken uyulacak kurallar)**

Arvia için yeni bir kural kartı metni kaleme alınırken yazarların aşağıdaki beş temel dil kuralına uyması zorunludur:

1. **Edilgen ve Yardımcı Fiillerle Yumuşatma:** Metinlerde kesinlikle "yap", "et", "gir", "yükle" gibi doğrudan emir kipleri kullanılmamalıdır. Bunun yerine "faydalı olabilir", "işini kolaylaştırır", "tercih edebilirsin", "takibinde kalabilir" gibi olasılık veya öneri belirten yardımcı yapılar seçilmelidir.  
2. **Gerekçe Gösterme İlkesi:** Kullanıcıdan bir veri girişi isteniyorsa (örneğin kilometre güncellemesi), bunun kullanıcıya sağlayacağı doğrudan fayda açıklanmalıdır. "Kilometre gir" demek yerine, "Bakım zamanlarını doğru tahmin edebilmemiz için kilometre bilgisi gereklidir" denmelidir.  
3. **Teknik Terimlerin Parantez İçi Açıklamaları:** Türkiye pazarındaki ortalama araç sahiplerinin teknik bilgi seviyesi orta düzeydedir. Bu nedenle "DPF", "EGR", "SoH", "MTV" gibi kısaltmalar ilk kez geçtiği kartlarda mutlaka parantez içi Türkçe net açıklamalarla verilmelidir: *"DPF (Dizel Partikül Filtresi)"*13 veya *"SoH (Batarya Sağlık Oranı)"*18.  
4. **Bilişsel Sınırlar (Karakter Limitleri):** Apple-native tasarım standartlarına uyum sağlamak adına, kart başlıkları en fazla 4-5 kelimeden (maksimum 30 karakter) oluşmalıdır. Gövde metinleri ise kesinlikle iki cümleyi ve toplamda 120 karakteri geçmemelidir. Tek bakışta anlaşılabilirlik esastır.  
5. **Samimi Ama Mesafeli "Sen" Dili:** Kullanıcıyla "sen" dili üzerinden iletişim kurulmalıdır ancak bu dil laubali olmamalı, bilge bir yol arkadaşı tonunda kalmalıdır. "Arabanın bakımı gecikti dostum" gibi aşırı samimi jenerik söylemler (AI-slop) yerine, "Aracının mekanik sağlığı için bakım dönemini kontrol etmek isteyebilirsin" tonu benimsenmelidir.

## **Bölüm 4 — Best practice (otomotiv \+ diğer)**

Mobil platformlarda rehberlik ve içgörü sunan başarılı uygulamaların kullanıcı deneyimi pattern'leri incelenmiş ve Arvia'ya uyarlanabilecek pratik çıktılar elde edilmiştir.

### **4.1 Otomotiv ve Sürüş Uygulamaları**

#### **Tesla App**

Tesla mobil uygulaması, yüksek öncelikli bildirimleri (örneğin nöbetçi modu tetikleyicileri veya şarj limitine ulaşılması) ve pasif bilgilendirme kartlarını iki ana eksende sunmaktadır. Toplamda 3 farklı içerik tipi kullanmaktadır: Kritik Alarm, Standart Bilgi ve İşlemsel Bildirimler. Kullanıcılar kritik olmayan kartları sola kaydırarak (swipe) silebilirken, şarj kablosunun kilitli kalması gibi operasyonel kartlar fiziksel müdahale gerçekleşene kadar ekranda kalmaktadır20. Uygulamanın üslubu son derece minimalist ve veri odaklıdır. Arvia için sunulabilecek somut öneri, kritik mekanik alarmlar dışındaki tüm bilgilendirmelerin kaydırarak kapatılabilir (swipe-to-dismiss) olarak kurgulanmasıdır.

#### **FordPass**

FordPass uygulaması, araç sağlığı izleme süreçlerinde "Vehicle Health Alerts" (Araç Sağlığı Uyarıları) sistemini kullanmaktadır21. Bu sistem, motor performansı, fren aşınmaları, yağ ömrü ve filtre durumları gibi parametreleri anlık olarak analiz ederek kullanıcıya ulaştırmaktadır22.  
Kullanıcı deneyimi açısından en başarılı özellikleri, uyarıların önem derecelerine göre renk kodlu kartlarla gösterilmesi ve kritik olmayan durumlarda kartların sağa kaydırma (swipe-to-dismiss) hareketiyle kolayca silinebilmesidir23. Ayrıca, karmaşık mekanik sorunları kullanıcının anlayabileceği basitlikte açıklayan dijital el kitapçığı entegrasyonu sunmaktadır24. Arvia için buradan alınacak temel pattern, kullanıcıya kartı tek hamlede kapatma (dismiss) hakkı tanınması ve kapatılan kartların kullanıcı profilinde arşivlenmesidir23.

#### **Toyota MyT**

Toyota MyT uygulaması, hibrid sürüş geri bildirimleri ve periyodik servis hatırlatmaları üzerine kuruludur. Toplamda 3 içerik tipi barındırır: Servis Zamanı (CTA), Sürüş Analizi (Bilgi) ve Geri Çağırma Kampanyaları (Uyarı). Kartlar, kullanıcı ilgili yetkili servis randevusunu onaylayana veya sürüş analizini okuyana kadar pasif bir şekilde profil sekmesinde listelenir. Üslup resmi, kurumsal ve güven verici bir ton taşır. Arvia, Toyota'nın hibrid sürüş analizlerindeki gibi, kullanıcıyı eğitici ancak eyleme zorlamayan pasif mekanik bilgi kartlarını rehber bölümüne entegre edebilir.

#### **BMW Connected / My BMW**

My BMW platformu, "Proactive Care" (Proaktif Bakım) mimarisi üzerine kurulmuştur25. Araçtaki sensörler vasıtasıyla fren balatasının kalan ömrü veya mikro filtrelerin doluluk oranları hesaplanmakta ve arka planda çalışan yapay zeka motoru ile servis randevusu otomatik olarak planlanabilmektedir25.  
Uygulamanın görsel dili tamamen Apple-native standartlarına uygundur; minimalist beyaz alanlar, ince çizgisel göstergeler ve net tipografi tercih edilmektedir. BMW Connected, kullanıcılara "Öğrenen Navigasyon" kartları sunarak rutin rotalardaki trafik durumunu pasif bilgi kartları olarak iletmektedir27. Arvia'nın yerel tasarım anayasasına uyum sağlayacak en iyi pratik, verilerin görsel olarak yoğunlaştırılmış ancak göz yormayan native kart yapılarında sunulmasıdır28.

#### **Mercedes me**

Mercedes me uygulaması, güvenlik ve araç durum takibinde endüstri standartlarını belirlemektedir29. Araç kapılarının açık kalması, camların aralık olması veya park halindeyken araca çarpılması gibi durumlar anlık push bildirimleri ve in-app kartlarla kullanıcıya iletilmektedir29.  
Ancak platformun en çok eleştirilen yönü, konum tabanlı akıllı filtreleme içermemesidir; örneğin araç güvenli bir ev garajında kilitlenmemiş olarak beklediğinde bile sürekli "Kapılar Açık" uyarısı gönderilmesi kullanıcıda bildirim yorgunluğu (alert fatigue) yaratmaktadır20. Arvia'nın bu hatadan kaçınarak, "Garaj" gibi güvenli alan tanımlamalarıyla uyarı kartlarının tetiklenme sıklığını coğrafi konuma veya zamana bağlı olarak optimize etmesi gerekmektedir20.

#### **Hyundai Bluelink**

Hyundai Bluelink uygulaması, uzaktan çalıştırma, şarj yönetimi ve araç durum raporları sunar. İçerik tipi olarak 3 kategori kullanır: Kritik Güvenlik Uyarısı (CTA), Aylık Sağlık Raporu (Bilgi) ve Randevu Önerileri (Soru). Erteleme mekanizması bulunmamaktadır; rapor kartları her ayın sonunda otomatik olarak arşivlenmektedir. Tonu net, teknik ve komut odaklıdır. Arvia için çıkarılabilecek somut öneri, aylık araç sağlık raporu mantığının, kullanıcının o ay eklediği masraf ve kilometre verileriyle birleştirilerek tek bir "Aylık Özet" bilgi kartı halinde sunulmasıdır.

#### **Volvo Cars**

Volvo Cars uygulaması, İskandinav minimalizmini yansıtan, güvenlik ve batarya sağlığı odaklı bir yapıya sahiptir. 3 içerik tipi kullanır: Güvenlik Uyarıları (CTA), Sürüş İstatistikleri (Bilgi) ve Ön Isıtma Önerileri (Hatırlatma)20. Ön ısıtma ve kış mevsimi öneri kartları, yerel hava durumuna göre dinamik olarak üretilir ve tek tıkla kapatılabilir20. Üslubu son derece sıcak, koruyucu ve insan odaklıdır. Arvia, Volvo'nun yerel iklim koşullarına göre silecek veya antifriz uyarısı üreten akıllı mevsimsel mantığını kendi kural motoruna dahil etmelidir.

#### **Škoda Connect**

Škoda Connect uygulaması, Volkswagen Grubu'nun altyapısını kullanarak pratik ve bütçe odaklı bir araç takibi sunar. 3 içerik tipi kullanır: Servis Bildirimleri (CTA), Araç Durumu (Bilgi) ve Hız/Bölge Sınır İhlalleri (Uyarı). Kartlar, bildirim merkezinden sağa kaydırılarak silinir. Üslup rasyonel, net ve "Simply Clever" felsefesine uygun olarak pratik çözümler sunar. Arvia için öneri, Škoda'nın pratik bakım çözümlerini andıran, "Silecek suyunu kendin tamamlayabilirsin" gibi bütçe dostu mikro bilgi kartlarının tasarlanmasıdır.

#### **TÜVTÜRK Portal**

TÜVTÜRK muayene takip sistemi, yasal zorunlulukları ve muayene periyotlarını yöneten resmi bir yapıya sahiptir1. 2 içerik tipi kullanır: Muayene Zamanı (CTA) ve Randevu Hatırlatması (Hatırlatma)2. Erteleme mekanizması yoktur, yasal süre dolana kadar SMS ve e-posta bildirimleri devam eder2. Üslup son derece resmi, yasal ve mesafelidir. Arvia, TÜVTÜRK'ün resmi verilerini kullanarak, M1G veya N1 sınıfı araçların yasal muayene periyotlarını arka planda hatasız hesaplayan bir mevzuat doğrulama mantığı kurmalıdır1.

#### **Otokoç Partner**

Otokoç uygulaması, araç kiralama, servis randevusu ve ikinci el araç değerleme süreçlerini yönetmektedir. 3 içerik tipi kullanır: Randevu Takibi (CTA), Kampanyalar (Bilgi) ve Sigorta Poliçe Yenileme (Uyarı). Poliçe yenileme kartları Eylül-Ekim gibi yoğun dönemlerde kalıcı olarak en üstte gösterilir. Üslup ticari, profesyonel ve müşteri odaklıdır. Arvia için öneri, poliçe yenileme süreçlerinin bir eyleme zorlama yerine, "Sigorta poliçen yakında yenilenecek, teklifleri incelemek isteyebilirsin" şeklinde bir pasif hatırlatma kartı olarak tasarlanmasıdır.

### **4.2 Finans ve Bütçe Uygulamaları**

#### **Splitwise**

Splitwise bütçe ve borç paylaşım uygulaması, grup harcamalarındaki bakiye durumlarını yönetir. 2 içerik tipi kullanır: Borç Ödeme Talebi (CTA) ve Harcama Bildirimi (Bilgi). Kullanıcılar harcama bildirimlerini tek tıkla arşivleyebilirken, borç talepleri bakiye sıfırlanana kadar ana ekranda kalır. Üslup samimi, arkadaş canlısı ve nettir. Arvia, özellikle şirket araçları veya aile içinde ortak kullanılan araçlar için masraf paylaşımı yapılmasını öneren yumuşak soru kartlarında Splitwise'ın bu şeffaf üslubunu örnek alabilir.

#### **Wallet by BudgetBakers**

Wallet, gelişmiş bütçe analitiği ve banka senkronizasyonu sunan bir finansal yönetim platformudur31. 4 farklı içerik tipi kullanır: AI Kategori Eşleme (Soru)32, Harcama Limiti Aşımı (Uyarı)33, Planlı Ödemeler (Hatırlatma)32 ve Aylık Finansal Sağlık Analizi (Bilgi). Harcama limiti uyarıları kullanıcı tarafından 1 gün boyunca sessize alınabilir. Üslup analitik, objektif ve veri odaklıdır. Arvia, Wallet'ın harcama limiti aşımlarında kullandığı renk dereceli uyarı barlarını, aylık araç yakıt masrafı takibinde kullanabilir.

#### **Spendee**

Spendee bütçe uygulaması, harcamaları görsel grafiklerle sevdiren bir tasarıma sahiptir32. 3 içerik tipi barındırır: Bütçe Durumu (Bilgi)34, Manuel Veri Girişi (Soru)32 ve Ortak Cüzdan Güncellemesi (Hatırlatma)34. Kullanıcı harcama giriş kartlarını "Geç" seçeneğiyle 24 saatliğine erteleyebilir. Üslubu adeta arkadaş canlısı bir finans koçu gibidir33. Arvia, Spendee'nin "Bu hafta yakıt masrafı yaptın mı?" gibi kullanıcıyı suçlamayan, aksine ona yardımcı olmaya çalışan mikro soru kartı tasarımlarını uygulamalıdır.

### **4.3 Sağlık ve Wellness Uygulamaları**

#### **Apple Health (Sağlık)**

Apple Health, karmaşık biyolojik verileri ve uzun vadeli trendleri native bir arayüzle sunar35. 4 içerik tipi kullanır: Kritik Sağlık Uyarısı (CTA)37, Trend Analizi (Bilgi)35, Öne Çıkanlar (Hatırlatma)35 ve Kontrol Listesi Kurulumu (Soru)38. Kritik uyarılar dışındaki tüm trend kartları "Özetlerimden Çıkar" seçeneğiyle kalıcı olarak gizlenebilir. Üslup son derece bilimsel, mesafeli ve güvenilirdir. Arvia için en büyük best practice, Apple Health'in "Sağlık Kontrol Listesi" modelini "Araç Sağlık Listesi" olarak uyarlayıp, eksik belgelerin tamamlanmasını pasif bir kontrol paneli üzerinden yönetmektir38.

#### **Whoop**

Whoop performans izleme uygulaması, vücudun toparlanma (recovery) ve zorlanma (strain) dengesini analiz eder. 3 içerik tipi kullanır: Toparlanma Skoru (Bilgi), Uyku Koçu (Hatırlatma) ve Haftalık Performans Değerlendirmesi (Bilgi). Kullanıcı kartları sağa kaydırarak arşivler. Üslup yüksek motivasyonlu, performans odaklı ve nettir. Arvia, Whoop'un toparlanma skoru mantığını, aracın bakım geçmişi, yaşı ve kilometresine göre hesaplanan bir "Araç Kondisyon Skoru" olarak uyarlayabilir.

#### **Strava**

Strava sporcu topluluğu uygulaması, mil taşı (milestone) başarıları ve kulüp aktiviteleri üzerine kuruludur. 3 içerik tipi kullanır: Aktivite Tamamlama (Bilgi), Haftalık Hedef Durumu (Hatırlatma) ve Kulüp Duyuruları (Bilgi). Kartlar tıklandıktan sonra otomatik olarak okunmuş sayılır ve ana akıştan kalkar. Üslubu motive edici ve topluluk odaklıdır. Arvia, Strava'nın bu yaklaşımını "Tebrikler, aracınla ilk 10.000 kilometreyi tamamladın\!" gibi keyifli, eylem içermeyen mil taşı (milestone) bilgi kartlarında kullanabilir.

### **4.4 Genel Mobile UX Pattern'leri**

#### **Apple Settings (Ayarlar)**

Apple Settings uygulaması, sistem güncellemeleri veya dolan iCloud saklama alanı gibi kritik durumları en üst seviyede listeler. Sadece 2 içerik tipi kullanır: Sistem Uyarısı (CTA) ve Standart Ayar Listesi. Uyarılar, kullanıcı ilgili ayarlar sayfasına gidip aksiyon alana kadar kalıcı olarak orada kalır. Üslup tamamen sessiz, nötr ve görünmezdir. Arvia'nın tasarım anayasasına (01\_DESIGN.md) yön veren temel referans burasıdır; rehber kartları tıpkı bir Settings.app hücresi gibi sade, çizgisiz ve sistem renkleriyle entegre olmalıdır.

#### **Things 3**

Things 3 görev yöneticisi, yapılacak işleri tarihlere ve projelere göre bölen ödüllü bir tasarıma sahiptir39. 2 içerik tipi kullanır: Günün Görevleri (CTA) ve Yaklaşan Etkinlikler (Bilgi)39. Things 3, görevleri ertelerken kullanıcının tek bir kaydırma hareketiyle "Bu Akşam", "Yarın" veya "Daha Sonra" gibi esnek zaman dilimleri seçmesine izin verir28. Üslup son derece sakin ve üretkendir39. Arvia, Things 3'ün bu esnek erteleme (snooze) arayüzünü kendi SwiftUI kart bileşenlerine entegre etmelidir.

#### **Bear App**

Bear markdown not defteri, minimalist arayüzü ve sade tipografisiyle bilinir. Sadece tek bir pasif bilgi içerik tipi kullanır (senkronizasyon durumu). Erteleme mekanizması yoktur, her şey menülerin arkasında sessizce çalışır. Üslup yaratıcı ve tamamen gürültüsüzdür. Arvia'nın not ekleme ve dosya arşivleme sayfalarındaki metin blokları, Bear uygulamasının sade markdown yapısını andıracak şekilde okunabilirliği en üst düzeyde tutacak şekilde tasarlanmalıdır.

## **Bölüm 5 — Mimari öneriler (Swift)**

Mevcut eylem zorunluluğu olan VehicleInsight veri modelinin, esnek içerik tiplerini ve erteleme mekanizmalarını destekleyecek şekilde SwiftData uyumlu olarak yeniden yapılandırılması gerekmektedir.

### **5.1 Model değişiklikleri**

Yeni mimaride, VehicleInsight modeli içerisindeki action özelliği opsiyonel hale getirilmiş ve kartın görsel/işlevsel kategorisini belirleyen contentKind enum yapısı eklenmiştir.

Swift  
import Foundation  
import SwiftData

@Model  
final class VehicleInsight {  
    @Attribute(.unique) var id: UUID  
    var vehicleId: UUID  
    var type: VehicleInsightType  
    var contentKind: VehicleInsightContentKind  
    var priority: VehicleInsightPriority  
    var title: String  
    var body: String  
    var action: VehicleInsightAction? // Artık opsiyonel. nil değeri CTA olmadığını gösterir.  
    var relatedReminderId: UUID?  
    var createdAt: Date  
      
    init(  
        id: UUID \= UUID(),  
        vehicleId: UUID,  
        type: VehicleInsightType,  
        contentKind: VehicleInsightContentKind,  
        priority: VehicleInsightPriority,  
        title: String,  
        body: String,  
        action: VehicleInsightAction? \= nil,  
        relatedReminderId: UUID? \= nil,  
        createdAt: Date \= Date()  
    ) {  
        self.id \= id  
        self.vehicleId \= vehicleId  
        self.type \= type  
        self.contentKind \= contentKind  
        self.priority \= priority  
        self.title \= title  
        self.body \= body  
        self.action \= action  
        self.relatedReminderId \= relatedReminderId  
        self.createdAt \= createdAt  
    }  
}

enum VehicleInsightContentKind: String, Codable, CaseIterable {  
    case callToAction // A. Eylem  
    case info         // B. Bilgi  
    case warning      // C. Uyarı  
    case reminder     // D. Hatırlatma  
    case softQuestion // E. Soru  
}

enum VehicleInsightPriority: Int, Codable, Comparable {  
    case info \= 0  
    case warning \= 1  
    case important \= 2  
      
    static func \< (lhs: VehicleInsightPriority, rhs: VehicleInsightPriority) \-\> Bool {  
        return lhs.rawValue \< rhs.rawValue  
    }  
}

### **5.2 Yeni action case'leri**

Kullanıcının kart üzerindeki etkileşimlerini genişletmek amacıyla VehicleInsightAction enum yapısına sistem içi aksiyonlar eklenmiştir.

Swift  
enum VehicleInsightAction: String, Codable, CaseIterable {  
    // Mevcut veri giriş aksiyonları  
    case addServiceRecord  
    case addDocument  
    case openSaleFile  
    case updateOdometer  
    case openTodos  
    case addInspectionReport  
    case addReminder  
    case addMTVReminder  
    case addExpense  
    case addFuelExpense  
      
    // Yeni sistem ve kullanıcı etkileşim aksiyonları  
    case dismissAndSnooze  
    case markAsRead  
    case acknowledge  
    case noAction  
}

### **5.3 Snooze / dismiss mantığı**

Kullanıcının kartları belirli bir süre boyunca sessize almasını sağlayan InsightSnoozeStore mimarisi, SwiftData veya UserDefaults tabanlı anahtar-değer (key-value) deposu kullanılarak aşağıdaki şekilde kurulmalıdır:

Swift  
import Foundation

final class InsightSnoozeStore {  
    static let shared \= InsightSnoozeStore()  
    private let userDefaults \= UserDefaults.standard  
    private let snoozeKeyPrefix \= "com.arvia.snooze."  
      
    private init() {}  
      
    func snooze(insightType: VehicleInsightType, forVehicle vehicleId: UUID, days: Int) {  
        let snoozeDuration \= TimeInterval(days \* 24 \* 60 \* 60\)  
        let expireDate \= Date().addingTimeInterval(snoozeDuration)  
        let key \= makeKey(insightType: insightType, vehicleId: vehicleId)  
        userDefaults.set(expireDate.timeIntervalSince1970, forKey: key)  
    }  
      
    func isSnoozed(insightType: VehicleInsightType, forVehicle vehicleId: UUID) \-\> Bool {  
        let key \= makeKey(insightType: insightType, vehicleId: vehicleId)  
        guard let savedTime \= userDefaults.object(forKey: key) as? Double else {  
            return false  
        }  
        let expireDate \= Date(timeIntervalSince1970: savedTime)  
        if Date() \> expireDate {  
            userDefaults.removeObject(forKey: key) // Süresi dolmuş snooze kaydını temizle  
            return false  
        }  
        return true  
    }  
      
    func clearSnooze(insightType: VehicleInsightType, forVehicle vehicleId: UUID) {  
        let key \= makeKey(insightType: insightType, vehicleId: vehicleId)  
        userDefaults.removeObject(forKey: key)  
    }  
      
    private func makeKey(insightType: VehicleInsightType, vehicleId: UUID) \-\> String {  
        return "\\(snoozeKeyPrefix)\\(vehicleId.uuidString).\\(insightType.rawValue)"  
    }  
}

### **5.4 Component önerisi**

Apple-native felsefesi doğrultusunda, karmaşık ve kontrastı yüksek SaaS kart tasarımları yerine, Settings.app stilini benimseyen, sistem renk paletine (Color(.secondarySystemGroupedBackground)) uyumlu tek bir esnek SwiftUI kart bileşeni oluşturulmuştur.

Swift  
import SwiftUI

struct VehicleInsightCard: View {  
    let insight: VehicleInsight  
    var onActionTriggered: (VehicleInsightAction) \-\> Void  
    var onDismiss: () \-\> Void  
      
    var body: some View {  
        VStack(alignment: .leading, spacing: 12\) {  
            HStack(alignment: .top) {  
                // Sol Bölüm: Durum İkonu ve Kategori Etiketi  
                HStack(spacing: 8\) {  
                    Image(systemName: iconName(for: insight.contentKind))  
                        .foregroundColor(iconColor(for: insight.contentKind))  
                        .font(.system(size: 16, weight: .semibold))  
                      
                    Text(insight.title)  
                        .font(.headline)  
                        .foregroundColor(Color(.label))  
                }  
                  
                Spacer()  
                  
                // Sağ Üst: Kapatma Butonu (Dismiss)  
                if insight.contentKind \!= .callToAction {  
                    Button(action: onDismiss) {  
                        Image(systemName: "xmark.circle.fill")  
                            .foregroundColor(Color(.systemGray3))  
                            .font(.system(size: 20))  
                    }  
                    .buttonStyle(.plain)  
                }  
            }  
              
            // Gövde Metni  
            Text(insight.body)  
                .font(.subheadline)  
                .foregroundColor(Color(.secondaryLabel))  
                .lineLimit(3)  
                .fixedSize(horizontal: false, vertical: true)  
              
            // Alt Bölüm: Aksiyon Butonları  
            if let action \= insight.action {  
                HStack(spacing: 12\) {  
                    if insight.contentKind \== .softQuestion {  
                        // Soru Tipi İçin Çift Buton Tasarımı  
                        Button(action: { onActionTriggered(action) }) {  
                            Text(actionTitle(for: action))  
                                .font(.subheadline)  
                                .fontWeight(.semibold)  
                                .frame(maxWidth: .infinity)  
                                .padding(.vertical, 8\)  
                                .background(Color(.systemBlue))  
                                .foregroundColor(.white)  
                                .cornerRadius(8)  
                        }  
                          
                        Button(action: onDismiss) {  
                            Text("Şimdi Değil")  
                                .font(.subheadline)  
                                .frame(maxWidth: .infinity)  
                                .padding(.vertical, 8\)  
                                .background(Color(.systemGray6))  
                                .foregroundColor(Color(.label))  
                                .cornerRadius(8)  
                        }  
                    } else {  
                        // Standart Tek Buton Tasarımı  
                        Button(action: { onActionTriggered(action) }) {  
                            HStack {  
                                Text(actionTitle(for: action))  
                                    .font(.subheadline)  
                                    .fontWeight(.medium)  
                                Spacer()  
                                Image(systemName: "chevron.right")  
                                    .font(.system(size: 12, weight: .semibold))  
                            }  
                            .padding(.horizontal, 12\)  
                            .padding(.vertical, 8\)  
                            .background(Color(.systemGray6))  
                            .foregroundColor(Color(.link))  
                            .cornerRadius(8)  
                        }  
                    }  
                }  
                .padding(.top, 4\)  
            }  
        }  
        .padding(16)  
        .background(Color(.secondarySystemGroupedBackground))  
        .cornerRadius(12)  
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2\)  
    }  
      
    // Yardımcı Tasarım Fonksiyonları  
    private func iconName(for kind: VehicleInsightContentKind) \-\> String {  
        switch kind {  
        case .callToAction: return "exclamationmark.triangle.fill"  
        case .info: return "info.circle.fill"  
        case .warning: return "exclamationmark.octagon.fill"  
        case .reminder: return "bell.fill"  
        case .softQuestion: return "questionmark.bubble.fill"  
        }  
    }  
      
    private func iconColor(for kind: VehicleInsightContentKind) \-\> Color {  
        switch kind {  
        case .callToAction: return .red  
        case .info: return .blue  
        case .warning: return .orange  
        case .reminder: return .purple  
        case .softQuestion: return .green  
        }  
    }  
      
    private func actionTitle(for action: VehicleInsightAction) \-\> String {  
        switch action {  
        case .addServiceRecord: return "Bakım Ekle"  
        case .addDocument: return "Belge Yükle"  
        case .openSaleFile: return "Satış Dosyasını Aç"  
        case .updateOdometer: return "Kilometre Güncelle"  
        case .openTodos: return "Yapılacaklara Git"  
        case .addInspectionReport: return "Rapor Ekle"  
        case .addReminder: return "Hatırlatıcı Ekle"  
        case .addMTVReminder: return "MTV Hatırlatıcısı Kur"  
        case .addExpense: return "Masraf Kaydet"  
        case .addFuelExpense: return "Yakıt Girişi Yap"  
        default: return "Detayları Gör"  
        }  
    }  
}

### **5.5 Test senaryoları**

Yeni dinamik rehber yapısının doğrulanması için DemoDataSeeder sınıfı içerisine aşağıdaki beş farklı test senaryosunun eklenmesi planlanmaktadır:

Swift  
struct DemoDataSeeder {  
    static func seedTestScenarios(modelContext: ModelContext) {  
        let vehicleId \= UUID() // Örnek Test Aracı  
          
        // 1\. Senaryo: Kritik Eylem Kartı (TÜVTÜRK Gecikmesi)  
        let overdueInspection \= VehicleInsight(  
            vehicleId: vehicleId,  
            type: .overdueReminder,  
            contentKind: .callToAction,  
            priority: .important,  
            title: "Muayene Süresi Doldu",  
            body: "Aracının yasal muayene geçerlilik süresi tükenmiş görünüyor. Trafik cezası almamak için kaydı güncellemelisin.",  
            action: .addInspectionReport  
        )  
          
        // 2\. Senaryo: Sezonluk Bilgi Kartı (BEV Kış Tavsiyesi)  
        let evWinterInfo \= VehicleInsight(  
            vehicleId: vehicleId,  
            type: .seasonalGuidance,  
            contentKind: .info,  
            priority: .info,  
            title: "Soğuk Hava Pil Koruması",  
            body: "Hava sıcaklığı sıfıra yaklaştığında bataryayı %20-%80 arasında tutmak, pil ömrünü belirgin oranda korur.",  
            action: .dismissAndSnooze  
        )  
          
        // 3\. Senaryo: Mekanik Uyarı Kartı (DSG 60K Bakımı)  
        let dsgWarning \= VehicleInsight(  
            vehicleId: vehicleId,  
            type: .transmissionGuidance,  
            contentKind: .warning,  
            priority: .warning,  
            title: "Şanzıman Filtre Değişimi",  
            body: "Islak kavramalı şanzımanlarda her 60.000 km'de bir yağ filtresi değişimi vites geçiş sağlığı için kritiktir.",  
            action: .addServiceRecord  
        )  
          
        // 4\. Senaryo: Pasif Hatırlatma Kartı (MTV Taksit Dönemi)  
        let mtvReminder \= VehicleInsight(  
            vehicleId: vehicleId,  
            type: .calendarPeriod,  
            contentKind: .reminder,  
            priority: .info,  
            title: "MTV Taksit Hatırlatması",  
            body: "Motorlu Taşıtlar Vergisi (MTV) ödeme dönemi yaklaşmaktadır. Taksit takibini uygulamadan yapabilirsin.",  
            action: .addMTVReminder  
        )  
          
        // 5\. Senaryo: Yumuşak Soru Kartı (Aylık Masraf Prompt)  
        let expensePrompt \= VehicleInsight(  
            vehicleId: vehicleId,  
            type: .monthlyExpensePrompt,  
            contentKind: .softQuestion,  
            priority: .info,  
            title: "Masraf Listesi Boş Kalmasın",  
            body: "Bu ay aracın için otoyol geçişi, yıkama veya otopark gibi küçük harcamalar yaptın mı?",  
            action: .addExpense  
        )  
          
        // SwiftData Context İçerisine Kaydet  
        modelContext.insert(overdueInspection)  
        modelContext.insert(evWinterInfo)  
        modelContext.insert(dsgWarning)  
        modelContext.insert(mtvReminder)  
        modelContext.insert(expensePrompt)  
    }  
}

## **Bölüm 6 — Uygulama yol haritası**

Rehber içerik stratejisinin hayata geçirilmesi, teknik riskleri ve kullanıcı alışkanlıklarını yönetmek adına aşamalı bir plan dahilinde gerçekleştirilmelidir.

### **6.1 MVP sonrası ilk güncelleme (v1.1)**

İlk güncelleme dalgasında hızlı kazanımlar (quick-wins) hedeflenmektedir. Bu kapsamda yapılması gerekenler:

* **Swift Veri Modelinin Güncellenmesi:** Mevcut VehicleInsight veri tabanı şemasının SwiftData uyumlu olarak esnetilmesi ve action alanının opsiyonel hale getirilmesi.  
* **Arayüz Refaktörü:** VehicleInsightCard bileşeninin SwiftUI tarafında yeniden yazılması, kapatma (dismiss) butonu ve soru kartlarındaki çift buton yapısının entegre edilmesi.  
* **Temel Kartların Taşınması:** Mevcut 13 kartın yeni içerik tiplerine (Eylem, Bilgi, Uyarı vb.) göre yeniden sınıflandırılması ve metinlerinin güncellenmesi.  
* **Yerel Erteleme (Local Snooze):** UserDefaults tabanlı çalışan InsightSnoozeStore yapısının hayata geçirilmesi.

### **6.2 v1.2 ve sonrası**

Orta ve uzun vadeli planlamada, uygulamanın veri işleme ve bağlamsal farkındalık (context-awareness) yeteneklerinin artırılması amaçlanmaktadır:

* **Konum Tabanlı Akıllı Filtreleme:** Kullanıcının ev veya iş yeri olarak tanımladığı güvenli lokasyonlarda, Mercedes me uygulamasında yaşanan bildirim yorgunluğu sorununa benzer hatalardan kaçınmak adına20, bazı kritik olmayan güvenlik ve kilit uyarılarının sessize alınması veya ertelenmesi.  
* **Kullanıcı Alışkanlık Analizi:** Kullanıcının kartları kapatma (dismiss) oranlarının takip edilmesi. Eğer bir kullanıcı belirli bir tipteki kartı (örneğin .monthlyExpensePrompt) üst üste üç kez ertelediyse, o kategorinin tetiklenme sıklığının otomatik olarak iki katına çıkarılması (30 günden 60 güne snooze).  
* **Gelişmiş Mekanik Entegrasyon:** OBD veya üçüncü parti servis API entegrasyonları ile aracın gerçek arıza kodlarının okunması ve rehber motorunun doğrudan mekanik durum tanımlayıcı uyarılar üretmesi.

### **6.3 Açık sorular**

Tasarım ve geliştirme süreçlerinde çözümlenmesi gereken bazı teknik ve operasyonel belirsizlikler mevcuttur:

1. **Arka Plan İşlem Limitleri (iOS Background Task Budget):** iOS işletim sisteminin arka plan işlemleri (Background Tasks) için tanıdığı CPU bütçesi sınırları dahilinde, kural motorunun kullanıcının hiçbir etkileşimi yokken ne sıklıkla çalıştırılabileceği sorusu. Bu durum, yerel bildirimlerin zamanlamasını etkileyebilecektir.  
2. **SwiftData Migration (Veri Tabanı Göçü):** MVP sürümü kullanan test kullanıcılarının mevcut veritabanlarındaki zorunlu action alanlarının, veri kaybı yaşanmadan v1.1 şemasına (opsiyonel action ve yeni contentKind alanı) nasıl migrate edileceği konusu.  
3. **Hava Durumu API Maliyetleri ve Gizlilik:** Bölgesel kış koşulları ve batarya sağlığı uyarıları için gereken konum bazlı hava durumu verilerinin, kullanıcının gizlilik sınırlarını ihlal etmeden ve yüksek API sorgu maliyetleri yaratmadan nasıl çözümleneceği sorusu.

## **Ek — Mevcut 13 insight'ın yeni tip eşlemesi**

Mevcut sistemde yer alan 13 adet rehber kural kartının, bu araştırma raporuyla önerilen yeni içerik stratejisine göre uçtan uca dönüşüm eşleme tablosu aşağıda sunulmuştur:

| Eski Tip (VehicleInsightType) | Yeni İçerik Tipi (VehicleInsightContentKind) | Eski CTA (VehicleInsightAction) | Yeni CTA veya Kapatma (Dismiss) Davranışı | Önerilen Erteleme (Snooze) Süresi | Gösterim Konumu (DisplayContext) |
| :---- | :---- | :---- | :---- | :---- | :---- |
| overdueReminder | **A. CTA (Eylem)** | openTodos | openTodos (Zorunlu aksiyon) | Erteleme yapılamaz. | Garaj Günlük Özeti ve Araç Detayı |
| upcomingReminder | **C. Uyarı** | addReminder | addReminder veya Kapatma (.dismissAndSnooze) | 14 Gün | Garaj Günlük Özeti |
| calendarPeriod | **D. Hatırlatma** | addMTVReminder | addMTVReminder veya Kapatma (.acknowledge) | Dönem bitene kadar (Maks. 30 Gün) | Garaj Günlük Özeti ve Araç Detayı |
| odometerUpdate | **E. Soru (Yumuşak)** | updateOdometer | updateOdometer veya "Şimdi Değil" (.noAction) | 30 Gün | Garaj Günlük Özeti |
| seasonalGuidance | **B. Bilgi** | addReminder | Kapatma (.acknowledge \- CTA yok) | 90 Gün (Sezon boyu) | Sadece Araç Detayı |
| fuelTypeGuidance | **B. Bilgi** | addServiceRecord | Kapatma (.acknowledge \- CTA yok) | 60 Gün | Sadece Araç Detayı |
| transmissionGuidance | **C. Uyarı** | addServiceRecord | addServiceRecord veya Kapatma (.dismissAndSnooze) | 30 Gün | Garaj Günlük Özeti |
| odometerMilestone | **B. Bilgi** | addServiceRecord | Kapatma (.acknowledge \- CTA yok) | Kalıcı sessize alma | Garaj Günlük Özeti ve Araç Detayı |
| monthlyExpensePrompt | **E. Soru (Yumuşak)** | addExpense | addExpense veya "Şimdi Değil" (.noAction) | 30 Gün | Garaj Günlük Özeti |
| maintenance | **C. Uyarı** | addServiceRecord | addServiceRecord veya Kapatma (.dismissAndSnooze) | 14 Gün | Garaj Günlük Özeti ve Araç Detayı |
| missingDocument | **A. CTA (Eylem)** | addDocument | addDocument (Zorunlu aksiyon) | Erteleme yapılamaz. | Garaj Günlük Özeti ve Araç Detayı |
| quietGoodState | **D. Hatırlatma** | noAction | Kapatma (.acknowledge \- CTA yok) | 7 Gün | Garaj Günlük Özeti |
| saleFileReadiness | **B. Bilgi** | openSaleFile | openSaleFile veya Kapatma (.acknowledge) | 30 Gün | Sadece Araç Detayı |

#### **Alıntılanan çalışmalar**

1. TÜVTÜRK Araç Muayene Rehberi, Araç Muayenesi Hakkında Sorular, [https://www.tuvturk.com.tr/muayene-rehberi/sss](https://www.tuvturk.com.tr/muayene-rehberi/sss)  
2. Araç Muayene Tarihi Sorgulama Nasıl Yapılır? \- Türkiye Sigorta, [https://www.turkiyesigorta.com.tr/blog/arac/arac-muayene-tarihi-sorgulama-nasil-yapilir](https://www.turkiyesigorta.com.tr/blog/arac/arac-muayene-tarihi-sorgulama-nasil-yapilir)  
3. Elektrikli Araç Batarya Bakımı İpuçları \- Borusan Oto, [https://www.borusanoto.com/onerilerimiz/borusan-oto/elektrikli-arac-batarya-bakimi-ipuclari](https://www.borusanoto.com/onerilerimiz/borusan-oto/elektrikli-arac-batarya-bakimi-ipuclari)  
4. Elektrikli Araç (EV) Batarya Ömrü Uzatmanın Yolları \- Acamar, [https://www.acamar.com.tr/blog/elektrikli-arac-ev-batarya-omru-uzatmanin-yollari](https://www.acamar.com.tr/blog/elektrikli-arac-ev-batarya-omru-uzatmanin-yollari)  
5. Otomatik Şanzıman Yağı Ne Zaman Değişir? (DSG, CVT, Tork Konvertör) \- Araclo, [https://www.araclo.com/blog/otomatik-sanziman-yagi-ne-zaman-degisir-dsg-cvt-tork-konvertor](https://www.araclo.com/blog/otomatik-sanziman-yagi-ne-zaman-degisir-dsg-cvt-tork-konvertor)  
6. Islak Kavrama DSG Yağ Değişimi hk. | Golftutkusu \- Otomobil Tutkunlarının Adresi, [https://www.golftutkusu.com/topic/27682-islak-kavrama-dsg-yag-degisimi-hk/](https://www.golftutkusu.com/topic/27682-islak-kavrama-dsg-yag-degisimi-hk/)  
7. DSG Şanzıman Yağı Değişimi Tamiri 2026 \- Yıldızlar Grup DSG Servisi, [https://dsgservisi.com/dsg-sanziman-yagi-degisimi/](https://dsgservisi.com/dsg-sanziman-yagi-degisimi/)  
8. Sıkça Sorulan Sorular ve Cevaplar \- Ulaştırma Hizmetleri Düzenleme Genel Müdürlüğü, [https://uhdgm.uab.gov.tr/sikca-sorulan-sorular-ve-cevaplar](https://uhdgm.uab.gov.tr/sikca-sorulan-sorular-ve-cevaplar)  
9. Elektrikli Araç Batarya Ömrünü Uzatmak İçin En İyi Uygulamalar Nelerdir? %20-%80 Kuralı Nedir? | WAT Mobilite, [https://www.watmobilite.com/blog/elektrikli-arac-batarya-omrunu-uzatmak-icin-en-iyi-uygulamalar](https://www.watmobilite.com/blog/elektrikli-arac-batarya-omrunu-uzatmak-icin-en-iyi-uygulamalar)  
10. [https://www.avecrentacar.com/tr/sanziman-yagi-degisir-mi-sanziman-yagi-ne-zaman-degisir-kac-km-s2\#:\~:text=CVT%20%C5%9Eanz%C4%B1manlar%3A%20Bu%20tip%20%C5%9Fanz%C4%B1manlar,ya%C4%9F%20ve%20filtre%20de%C4%9Fi%C5%9Fimi%20%C3%B6nerilir.](https://www.avecrentacar.com/tr/sanziman-yagi-degisir-mi-sanziman-yagi-ne-zaman-degisir-kac-km-s2#:~:text=CVT%20%C5%9Eanz%C4%B1manlar%3A%20Bu%20tip%20%C5%9Fanz%C4%B1manlar,ya%C4%9F%20ve%20filtre%20de%C4%9Fi%C5%9Fimi%20%C3%B6nerilir.)  
11. 2021 Honda City CVT Şanzıman Yağı Değişimi \#makhonda \#automobile \#honda \- YouTube, [https://www.youtube.com/shorts/KyX32BFBMbY](https://www.youtube.com/shorts/KyX32BFBMbY)  
12. Şanzıman Yağı Değişir mi? Şanzıman Yağı Ne Zaman Değişir, Kaç KM? \- AVEC Rent a Car, [https://www.avecrentacar.com/tr/sanziman-yagi-degisir-mi-sanziman-yagi-ne-zaman-degisir-kac-km-s2](https://www.avecrentacar.com/tr/sanziman-yagi-degisir-mi-sanziman-yagi-ne-zaman-degisir-kac-km-s2)  
13. Dizel Partikül Filtresi Tıkanmaması İçin Ne Yapmalı? \- Oto DPF Şaşmaz, [https://www.otodpfsasmaz.com.tr/dizel-partikul-filtresi-tikanmamasi-icin-ne-yapmali](https://www.otodpfsasmaz.com.tr/dizel-partikul-filtresi-tikanmamasi-icin-ne-yapmali)  
14. DPF Tıkanması Nasıl Önlenir? Dizel Partikül Filtresi İçin Profesyonel Çözümler \- Dizel Store, [https://www.dizelstore.com/blogs/dizel-enjektor/dpf-tikanmasi-nasil-onlenir](https://www.dizelstore.com/blogs/dizel-enjektor/dpf-tikanmasi-nasil-onlenir)  
15. VOLKSWAGEN BAKIM KAPSAMLARI \- BAKIM 10.000 KM/15.000 KM/YILDA BİR 1 Motor yağı ve yağ filtresi değişimi, [https://binekarac.vw.com.tr/content/dam/onehub\_pkw/importers/tr/satis-sonrasi-hizmetler/pdf/Periyodik\_Bakim\_Araliklari.pdf](https://binekarac.vw.com.tr/content/dam/onehub_pkw/importers/tr/satis-sonrasi-hizmetler/pdf/Periyodik_Bakim_Araliklari.pdf)  
16. Araç Muayene Periyodları, [https://www.kyc.com.tr/hizmet-arac-muayene-periyodlari\_9](https://www.kyc.com.tr/hizmet-arac-muayene-periyodlari_9)  
17. Partikül Filtresi Nasıl Temizlenir? \- OilMarkt, [https://oilmarkt.com/blog/partikul-filtresi-nasil-temizlenir](https://oilmarkt.com/blog/partikul-filtresi-nasil-temizlenir)  
18. Elektrikli Araçta Batarya Sağlığı %80 Altına Düşerse Ne Olur? \- Voltify, [https://www.voltify.com.tr/elektrikli-aracta-batarya-sagligi-80-altina-duserse-ne-olur](https://www.voltify.com.tr/elektrikli-aracta-batarya-sagligi-80-altina-duserse-ne-olur)  
19. Elektrikli Araçlarda Batarya Ömrü ve Pil Ömrünü Etkileyen Faktörler | Bridgestone, [https://www.bridgestone.com.tr/elektrikli-araclarda-batarya-omru-ve-pil-omrunu-etkileyen-faktorler](https://www.bridgestone.com.tr/elektrikli-araclarda-batarya-omru-ve-pil-omrunu-etkileyen-faktorler)  
20. Mercedes Me app car unlocked notification while at home \- Reddit, [https://www.reddit.com/r/mercedes/comments/1sh3h14/mercedes\_me\_app\_car\_unlocked\_notification\_while/](https://www.reddit.com/r/mercedes/comments/1sh3h14/mercedes_me_app_car_unlocked_notification_while/)  
21. Ford All-New FordPass App | Pioneer Ford, [https://www.pioneerford.com.au/fordpass/](https://www.pioneerford.com.au/fordpass/)  
22. FordPass: Setting Up Vehicle Health Alerts and Reports \- Akins Ford, [https://www.akinsford.com/blog/fordpass-setting-up-vehicle-health-alerts-and-reports/](https://www.akinsford.com/blog/fordpass-setting-up-vehicle-health-alerts-and-reports/)  
23. How do I manage my messages in the Ford App?, [https://www.ford.co.uk/support/how-tos/ford-app/manage-my-ford-app-account/how-do-i-manage-my-messages-in-the-ford-app](https://www.ford.co.uk/support/how-tos/ford-app/manage-my-ford-app-account/how-do-i-manage-my-messages-in-the-ford-app)  
24. Understanding How The FordPass® App Can Benefit You | Wichita Falls Ford, TX, [https://www.wichitafallsford.net/fordpass-benefits](https://www.wichitafallsford.net/fordpass-benefits)  
25. BMW Connected Drive \- Sytner Group, [https://www.sytner.co.uk/bmw/service-parts-and-repair/servicing-and-mot/bmw-connecteddrive](https://www.sytner.co.uk/bmw/service-parts-and-repair/servicing-and-mot/bmw-connecteddrive)  
26. BMW ConnectedDrive App Subscription Products, Store and Services, [https://www.bmwusa.com/explore/connecteddrive.html](https://www.bmwusa.com/explore/connecteddrive.html)  
27. What notifications do I receive via the My BMW App? \- BMW Australia, [https://www.bmw.com.au/au/s/article/My-BMW-App-Push-notifications-Overview-JUhGk?language=en\_AU](https://www.bmw.com.au/au/s/article/My-BMW-App-Push-notifications-Overview-JUhGk?language=en_AU)  
28. Redesign UI/UX for OmniFocus \[Things 3\] \- The Omni Group User Forums, [https://discourse.omnigroup.com/t/redesign-ui-ux-for-omnifocus-things-3/31859](https://discourse.omnigroup.com/t/redesign-ui-ux-for-omnifocus-things-3/31859)  
29. Mercedes-Benz \- App Store, [https://apps.apple.com/tr/app/mercedes-benz/id1487652920](https://apps.apple.com/tr/app/mercedes-benz/id1487652920)  
30. Mercedes me App | Quirk Auto Park of Bangor, [https://www.quirk.mercedesdealer.com/mercedes-me-app/](https://www.quirk.mercedesdealer.com/mercedes-me-app/)  
31. Wallet: Budget & Money Manager \- App Store \- Apple, [https://apps.apple.com/id/app/wallet-budget-money-manager/id1032467659](https://apps.apple.com/id/app/wallet-budget-money-manager/id1032467659)  
32. Best Free Expense Tracker Apps in 2026: 7 Tested | Finny Blog, [https://getfinny.app/blog/best-free-expense-tracker-apps-2026](https://getfinny.app/blog/best-free-expense-tracker-apps-2026)  
33. Budget App & Tracker: Spendee \- Apps on Google Play, [https://play.google.com/store/apps/details?id=com.cleevio.spendee](https://play.google.com/store/apps/details?id=com.cleevio.spendee)  
34. Spendee: Money Manager & Budget Planner, [https://www.spendee.com/](https://www.spendee.com/)  
35. HealthFit \- App Store \- Apple, [https://apps.apple.com/tr/app/healthfit/id1202650514](https://apps.apple.com/tr/app/healthfit/id1202650514)  
36. Thriving Apple Watch & Apple Health Ecosystem Advancing Digital Intelligent Healthcare \- Counterpoint Research, [https://counterpointresearch.com/en/insights/thriving-apple-watch-apple-health-ecosystem-advancing-digital-intelligent-healthcare](https://counterpointresearch.com/en/insights/thriving-apple-watch-apple-health-ecosystem-advancing-digital-intelligent-healthcare)  
37. iOS application trends for 2023 | hedgehog lab, [https://hedgehoglab.com/ios-application-trends-for-2023/](https://hedgehoglab.com/ios-application-trends-for-2023/)  
38. Apple Health Hidden Features Finally Revealed for 2025, [https://apple.gadgethacks.com/how-to/apple-health-hidden-features-finally-revealed-for-2025/](https://apple.gadgethacks.com/how-to/apple-health-hidden-features-finally-revealed-for-2025/)  
39. ‎Things 3 Uygulaması \- App Store, [https://apps.apple.com/tr/app/things-3/id904280696?l=tr\&mt=12](https://apps.apple.com/tr/app/things-3/id904280696?l=tr&mt=12)  
40. Things 3 \- App Store, [https://apps.apple.com/tr/app/things-3/id904237743](https://apps.apple.com/tr/app/things-3/id904237743)

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAmwAAABCCAYAAADqrIpKAAAIGElEQVR4Xu3dd6gcVRTH8Ws39l6wt4gVVLBjoiIYFcEWC4i9K/ZeImhs2BWsGEui2FAssVcUjRVR7AUrFixY/7DeX+Ze9+7Zmc3Ozmyyb9/3A4edOTOb3cx7YU5uG+cAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANVtaRMoZXubAAAAqNMnPhayySHsXB//+jjeHuixyTYBAABQh9dsYkD85mM2m+yxJXxsZpMAAABVPW0TA+Ixm5hOvvCxsE0CAAB0a5KPmWxyAOzpY1MfM/uY6OONkL/Gx08+7vVxio8ffFzg41KXtciNDudVcbKPX20SAACgGyN9/G2TA+J6H3P7uNLHoS4bzzbKx6phe5FwnrY3DNuv+7g1bFexoKNgAwAANVGL0oU2OSBUiL3l4yiTVyGnFrZI56Xb+yb7Vazj6vuzAADAMKYCZTGbHBAqRkVdn7J7eNXf+diwLfck2w+H17pmy6qVbU6bBABgUI2wiS7NZRPD3Ic2MUAeDa93hNcHwqsKNrV+yfI+jgjbKtKO8bFS2K+DPmuMTQIA0CvvF8T49CTvCpe1Klzr4z4fi/tYv+mMcubw8WKyryUTdBP8OcmVcZHLvlcv2GuTRkotWrpOL7nsOl3msr9jlevUjZ18HGKTxl42MYSkEykWTbbbFe3L+JjVJivQ+MCHbBIAgF4Z7bJCSS1dWtdqXh/f+jgnOedIH7e4xmBu+cVVuwFqfNXLJqclEx4xuU7N5+Mbm6yJCgF9Lz0tYHaXdYWpIPsnPcllxaauU3SCq36duqGZjBvZZLCaj1d9PGgPoBS1YH5kkwAA9Iq6ldLB2Voq4SwfW4f9sT5uaBz+n2bdVaFB45a+xyY2WcIsPnawyRqs7pqvkYpbFWFpC6Et3qKTbGI6eM5Ne/xapwXbxjaBqVTAp78TAAD0lG46cQyQXcX9OFd8U1rRJkrKm8H4eHhVV5Nm/Em6ttbVrnVtLSuuyVWntKhVa9t+yTHRdVKrVZ4ZsQ6aWvWmpc6CTT+fr13jeaVaI23Q6Xex6N8GAAC1001HN9zPw3bqhZxcHdQSdrDJLe3jdJe1sKlrVt2bo1zz2lrzhO10bS3rO5sInsmJp3w86bICUWPqiqiLWJ/7scuKoZWbD0+9TuNMbkb6yyZy1FWw7e/jTB/P+vgy5OLszUEWn2cKAEDPqfVH467iGKvbk2OiG9IfJhctZ/b1Z2jiQCfWDZFSi9qPPm7Oyce1tfZxzTfJvBtmUddkFfocjUcTjQFLqbjM+x5ydrIdZy9WdZAr/jxRd22741HRgHlNkLgtCT0CKt1PC1uNG0x/D7ZyWcuTCm1L39v+bCN9336NIpqB2u44AAC1WdPH5GR/+WRbPnX5N6W85RGKBrnnWcHHzib3gcuKgQk+1kjyGtwdu2xvclmXaPRnsh3FVh5LxURRqCtPrX5FdA3iTE+tsG/pOqn1z3o+vOrvq7GBdVCBuJ1NJvQ5eT8zq6hgs6bVwpZa1mWtjXn0vetaA60fnOo6u84AAFR2v2t0L+bRQ65VSG2R5HSj3ztsq4XlCZe16sSuyHdcttRCbK3TbEoVEW+H/SiOUYvizU8D/Ee7xngo5WPrlLbt2lpxLa6oqBWnW+u5xqKrRXSd0iU+1NKYFkQ3uuz7Hhb2NQNXrZt3hn0Vrypo3g2vWhZEx3V9u6GWynb0GerC7GT2apmCTYbLYrJXOQo2AECfUYvXHuE1pQH+Wu9rA5cVdsu57Jz0pq0B+au41rFl2k/PU9ETLeUaLVLp2lp6jmNKa2vZ/U67ZXthF5ddp5SK17i2nIpLtcxEa4dXjc/7zGXF7RRXfWap1qOb3ya7VKZg03i2KvQzV7e3zY33cbTJa9LL4T62NflU2fcWnZ9Hrb4UbACAIUHLR+iGrrFaajFTcRLHOG0TXlXEnOHjrrAfqcUtLV7qMMkm+sACPt5zWQvbVy5b005UrKmrVAWeWgW1jIqWT9Gs2N3COXndrJ3QDNy1bLJL6cK003K3TZRwgI/vXWsRpN8bzV7WGMK0213d0LqWmjRix15GZd6r9fWKzs+jVtD0uaUAAPS1WKDF1jLd+GxXngoVO1hfTrOJCrQI7xib7FOxpTBeO12zOm3u4zyb7DGN7Uuf3dkNLfhrC7b06RU6piVDtnfNk1b0H4c8Zd77mms9vx0d78f/IAAAUFpcr0xdfUXSpydUsa9NDGMqCDtdtqNO7SZudMIWbGqd1ESTSMe09IvW4FPrZKRCy47HK/teHbfnt6PjnXSdAgAAFFJBobGDQ4kt2NQtqcH9kY6pC1NPGdCzbCPlbAtu2ffquD2/HU2uAQAAqEQzTrUY8lBiCzYtUHxdsq9jl/uY6LKJKZHGntklQ8q+V8ft+UU0YWE4PM0BAAD02IGufdHRj2zBpkkX6YQCHTvRx/muuUXtUdf6CLCy79XTIez5RabYBAAAQLcOca1LofSzca61UEqfF/t0eNVYOY1Fk5Gu8TSOvV3z+8u8d1eXf751sY9XbBIAAKCK321iCBrrWpfZ0EQB5ZY0eavse/POT02wCQAAgKq0dEq367mhmYq5dCFnAACA2rzpGovxojsjfOxokwAAAHXRWncaXI/uXWITAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMsP8AzA+cBzEddsgAAAAASUVORK5CYII=>

[image2]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAZCAYAAACRiGY9AAACyElEQVR4Xu2XWahNURzGP/M8z4QXJUN5MBTxIDKGJB54MRQlmZLZG5LEGzKmPEmUIbwZUsiToQzFgykyJGPK8H19azur1bkucrZzb+dXv+7e6792d83rf4AKFWolnelIOoLWicp7R8+5MJre+03V6GJMprfoU3qcHqCn4Q7OpCcLVfNBI9qUnqPf6SjakDagjWlPuod+C+8xPegl+oROTWLt6F36la5OYrnxnL6l9dIAaUufJWXt6Z1gmySWsQseqKFpIA/6wv/8VFLeJPytT69E5ZrZq/Q9/G1VTKHv4O9zZyHcqRVR2QB6MDyrc0ui2Eq4vpblr9AMnUkL8+II3MhB4V0zcYLO+1mjgGIv4PqTklhKM9olLcyLrJEPgloyeu8VVwqMhWMfUVieZUc/uJFaJnXhk28afRxXilgK19dM/i0t4O8foUT7bRHcSO2TjD70cPQesxGuX90x3Y1uSQsjdLfpOigJR+FGDonKtBc6RO8xc+D629JAwn46MS2M2A4P0D9HF+9LVH0/FaM1/USvpYEIHThaXnGqJDRQ6shcegPOZjL6w7OvwWoelXen6+FvxiWxogyER/1sGqiGxfB3W+HMIWY2PQ93PmY4nLWoURPoF/gkFWr0ofA8C14NohN8d3aErxj9TyUCRVFOdp++gU+xD/Qh/qxz2ouv4W93w/tH+Z5GulFUT+gAUuYxPbzrKrgcnjVDn+kCuorugJe/uECXhedh9HZ4Limt4AHSyI5HoTEpytKVO2b7VB3fHJ514V+Ek2V1PqMlnDcqvxTr6M5C+P/TFYUrQomyMvoxdA2cQB8LMaGlNhi+Wl7BR75m/jqdEdUrC7SsdMdp/+inyT74oNDs7IX36Vq6Ab7HxHx4326C95M6XHbEh0f6M0ax+CJWZ7PTU4fMzShWY9GhpWNcS08/MrVnazzqhA6H5fDVU6FW8ANEV4l+CpEanAAAAABJRU5ErkJggg==>

[image3]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADsAAAAZCAYAAACPQVaOAAAC40lEQVR4Xu2XWaiNURTH/+Z5pkhIKVORsShJZEhIJHlxzWMoQ+aIJAkvMmVIngzJFN4UCk8eJENRMkQi85Ph/2/t7Sy7c851X+53bp1//brfXmvvc/ew9vrWB5RVVllF1J6MIMNILWfv7p4z1Sjy5D/RYvJpInlAXpPz5Bi5Alv4DHIp1zVb6QQak+vkNxlJ6pN6pCHpQg6TX6Ht1ZncJK/I5MTXhjwmP8naxJe53pJPpE7qoFqTN4mtLXkUaJX4og7ANnBI6shSvWCTupzYG4W/dckdZ1ck3CVfYWMLaRL5AhtfMloMW+wqZ+tLjodnLXq5862B9Vd4F5NO9GpqzFqnYZMfGNo6uYtkzt8eOcn3DtZ/QuJL1YR0SI1ZK07+WUChp3Y33yloDMz3HbkwrzHqDZu8wq02LBNPIS99J6cVsP46+apoHnlK5qaO6tRS2OR1D6N6klOu7bUd1r+y10lHsjOxvSD9Elu16ixs8oOdTXetnWt7zYL13506Eh0l4127K/kAi55MpILiPQq/X/OpJflB7qUOJyU6hbkvGbVJGrOBbIIlOqkZLBHqTaAN7xHsksaPJutJhbNrrkqOO8h8Zy+qAbBTupY6KtEy2LhdsErJq4LcgG2K1wlYXlCBsgR2HbTg22QQrL8Kl2mhvzQVdr1Uzal4iZWdNk0lqjbjHGkeB+STalYli4+wrPqNPEfVFq27rrDU2IOw+6l6WOHdwPWL0u/3D88rYf9rIzkTbDqtz/i3/t5MHpLVyH1MaMx9MptsgW18tagFbOMUouNgdz2fdP+1kHhV9F7fC5v0omDT6aqW9lJJug+W2GIBo8pNyTGNnJKRJhYXojDW11EncosMDfZtsKS2AFZra0Eng28s7EtKOkSmh2dpOGnq2iUhTVb3T9k/LlC18x5YWCvZXICFrKQF7SfrYGN0ylIfcoQsJFvJzGAvOcUJe+l+x0os/YRUQiqUfPL9VllllVXD9QcIz4+fIU0LAgAAAABJRU5ErkJggg==>

[image4]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB0AAAAZCAYAAADNAiUZAAABwklEQVR4Xu2UzSulURzHv0zyrtmIxZiSQjY2mhhKTRNZzcoCQxY23qKwk52kppRQGiSpiYWXYkPJ/AGzmEIRCUvCBqXE9+d3nnvPPffKQo/V86lPnfM9v+ee556XBwh4Z9Jpqhv6xRC9o4+0zxnzlRbopGXugJ/8pjc0wR3wk0O66YZ+kgNd2n4ry6JfrX4eraTxpp9Ja2hhqEIPYhUttrIXaYROWgH90WE6T//TWug+S/+MjtMuukjb6DEdNDXLJvtLN/AKU/QWel3G6Bfow/IiTXSdptE/JuvVx575Re/pAo0z2Q9oXb5XFAvZz13o5EUmK6DtNAN6pYQjumXaHnP0Erq0Hq3QSWVLYvIJWnBNd2g3wm9s49X1OPkJdFltluipk0XQAP2xcujBuaDTERXKT2hdiZXlmkxe1EP+sWzViJVFMYnI+7lCD0y7jlabttxjWY0Ppi80Qye1T2u9yUqhJ3vAGguxh8iTJqdy27TXEP4W79NV0/aYha6MvR2j9Ap6C2YQ4/ok0gfaYWXf6Tl0cjm5QjK0TrbC5h+dcLJv0P2Ufe10xkJ8RvTBSYJefptspy98dANDCvTjEhAQ8DaeAPwQVZJ/xmStAAAAAElFTkSuQmCC>

[image5]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAwAAAAZCAYAAAAFbs/PAAAApklEQVR4XmNgGAWDEVgCsS26IBDwAzE7soA+EB8E4v9QvASI2ZDkNwGxCIzDCcQ3gHgZECcC8UQgfgvEOVB5EyCeBWWDQRsQFyELAIE7EJ+GskEG6SLJoXKQwBEg1gPiXegSuMA8BoimQHQJXKAeiB8AMTOaOE6QD8Tl6IL4AChkDNAF8YF7DKhxgReAQu4iuiA+kMkAiUCiQQsQm6EL4gNEB+UgAADxsBafMibDHgAAAABJRU5ErkJggg==>

[image6]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAmwAAAAwCAYAAACsRiaAAAAFgElEQVR4Xu3daaitUxzH8b95ds0kXphLJMMbmfKChJIpoVxC5hLihSlDkeGFKxkiQzJn6F5EhkuZyUyIew2RoUSZhf/Pepb9f9bezznP3vvBOed+P/XvrGGfzl5rv9jr/tdazzUDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAExTy5UNAAAAaO9Ij8c95nkc5PFBvXugjzwWVj/neuzn8aGl33239zJbxuP5UC9947Fj2dihGz2u8PjY42yPS+rdA8WxSdPYZrr7Pc6x9PltUPS19YLHDx4blh0AAGA4z3msUpX/8Hg59DXZ2uNPjyVC2zuWfj+6zOOlou0Gj12r8hkeC0Jfl9b0OLgqL2bp/e7d627UdmxTydLWm9MurOuxSVXWZ3hx6BvG25bmcqeyAwAAtHe6x4qhfqXHXqHe5DZLX8SR6nOKtreKuvxm9b+pLE7XlvT4rmgrF45N2o5tKrnI6nM6rrtD+X2P00K9rfU9Ti4bAQDA8K7yuMBj8aq+jceyve6/M1P7e6wW2uQzj++LNi1q9i3atK2WaVtNWZs3PTYN7YdYyoZ1aS1L7yf+ne1CWVb32KFok7Zj69o+ZUNLmldtPWqs6xR9o9reYz1LmbsXPVaud09qY49jPA73WL7eBQAAhqUF2U+WFiQKZaay2dY7X3aox6qhT6/VwuuRKp71eD30i7YUjy3adq8i0mLwhKItu87jqRDzPZ70eMLSYmAiOjeVx6WsXraCx4PWG2t5Zi+O7VEbPLYuveHxQFV+xuNqSxmuvCXZRpkRHEdenGtreCVL72cU95YNLeizkbgdDQDAIm2ron5cFaLD+XERcIT1zoOJMlDxS/Vy689AKVuniLT4GeTCsmFMa4SyskSfhvovoSy6kBBNNrbdPGZZ//yJFjm3N8RNvZf9Q2cHHwv1Uy3N+56hLfvcmhdmOoc4iOa1fB85dJliEF3SiH63NIeRsmdN70U0P2X/2qFNc6gLJ5kWrfrHg9xqE19UAQBgkaKboZG2wbatyq9aPSulc13aZpTNPB4OffKKpS3GSFt1B4S6sie/hnqmxdHRZWNF70df7oNC225Ndi7qypZlcSGhbcRYn2xsW4Z2HcYfl7ZBzw/1E61/oZPpvZbjEs3rqJcCBnm6qOvCRWkpm/gCxy7WPw5trX8R6sqUirbgzwvtyuZ2OR4AAKY1faEeFurfhrIySnlxdafVz6Jp+06Lu6j8cs6uD2Vtj+p12mbTlmamLdIuH/ugTI4Oyuctz7s87uh122uhrDHHx4qUY9NjTuLYdKs1WxDKo1JW6dKqrIWrFof6e1qMtj03pnnVeTPNadvfaaKsW85AKkumbeic+RrGzR5fFm3Koikzl71X/YyfBwAAKJxk6bELWjBoG2qP0KcvaWWQtB2oLbJ8EeEeS2fevrJ0vmu2pWeU/Wjp2WWbV6/L5oeyLhYs9LjPY4vQfrzVz86N60BLW7pfe5zrcY3VD75rQaaM4S1WfxTGJ9Y/Nm2PxrGdkl9s6fVdUEZPW5TXWppn1ZURbLv40rw+ZPU5HdUcS9uxWqRrq1afzSh0O1ifc6THoiiDKcoWal7l5+pnNlHmFAAA/Au0nXZm2RhoEVSeKZvKlL3LN2p1u3amKRdZw9IZSC0elZ2N5whFi1LRQlTb8fmCwVHVT8kXHgAAwH/srLIh0HkpnYeaTvTojHzWb6bZqGwYki6m6H++KC8pTEav12IYAAD8j8psS9bUDgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACd+Qtlx/GC54IjogAAAABJRU5ErkJggg==>

[image7]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEIAAAAZCAYAAACFHfjcAAAD30lEQVR4Xu2Xa6hVVRSFh5mV+CpTI/0hiVokoSkavRBSVBQlH6g98BK+FRFBSlBUsIdkKloKgYqWCoI/kgRRCUI0328r0fRKiEhGUUE+wnIM59rcdedZ+5xzL/njyvlgcM6d4+y11117rrnmBipUaOg8RjX1wQQdfKC+NKJepXpSj4RYe5Q3iXuF7n+IauWNBBuosT5YV8ZT31CfUtupq9QY6jzVIvpduXxFXaQuUdXh+9fBG0GdpS7Axtfnj9Qzwc94mDpAvePieTxJ/Uq94o1yeZfaTz0axbpQ/1JHolhdeZ76j/qWalzbussPsHt09UbgE+owLFM9/akvfJC8B1v4Jt4oRTfqNvWcN8he2GTqyxTYQszxBmzRdd/T3gi0pP6kXvJGYB/s4XkegmWZ7l0nlA2abHNvwLbJEB+sA5thY7/gDTIU5q30RmAmdcYHA5rrP9RibwTmUyd9sBSrYBNaRD3gvLhoxihVe1MjqdbOi7kMe6oPeoMsg913uDcCu2F1JkZZ0pl6G3btZNgW9tvgTdiWa+viRRkGG1S6Rm2BFScVqhQDqXPUEmo2rIak0lAT1JhK36fD35L+EUlPTJN9PLvA8RMKt+U0aid1BZYR+i75Y7MPii9yEj3dWdR11CyIpCfin2QVbF/HVfkt2KR01sdMgI2jGpBNWNpFfRe8vPRVYb2F9AIL1QeNkYeyVONP90Y5NKMGU8upG7CBBkW+Kvvf1LYoJnrAfqt0jdkU4tpCnqw+rPBGoCPM7+cN2Dy1SB95w/EbtcAH8+juA4GpsInoM+PjEOsbxYS2keJvuLjSV/UhdWwuRfHUVW2Sr0/PAJinLVoM9Sbv+2CKJ2ANVIoXYTfrFcWOw7aAjqcYnQza6+2imGqCrt8RxWKOonh9eAp2/ShvkA9h80idchnZ1projRSjYauWemJK2WrUPkW0L9UNxmgvKgU/d/Eso9TceFRLVGdOeSNCnayuT/Ufqg0Ho7/XobCWdYJdr6arJKthPx7n4i9Tv6MwLZXGWuXsuFRm6ITREecXU3VEYyuzPGrb5X3mDYeO3jU+CGv9s/gk2MnlybaPFqQkx6gZ1PewtNdxuJE6gdpFMkOni44zdZva47pemRP3GVupn2EnkPQL7JQQVbAMVN1Q0f0D9h7ybPA962GtuUdZogelLPzAeRk6ZjW+z5QkWbenJ6s3ThW912rsXPT0VQPy+oz/C9UH9TWphk6NUrEasRb5J1KDQ/VJL2VzvVECZdhN5L/INUjUb/yFws6xGNqKem2475hHfemDObxO7UHhu8d9w0KqjQ8mUI9Rzu8qVKiQzx2Bm9KZYPp30AAAAABJRU5ErkJggg==>

[image8]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADEAAAAZCAYAAACYY8ZHAAAC00lEQVR4Xu2XWaiNYRSGX0NmmQqJpEwZMpOQUjJFoehEDnHBhQslXMiNO2PGco9SFFFC5MJwY5Y5DpJEERfI/L7W95+z9jr/kb1JTu23nvb+17v/7zv/9621vv8AZZX1T9SAjCNDSbMU60KaV//iP9dicprsIMfICzKXPCCt3e9+V4fJI/KYVKXvR5M3i9wlD2Hj6/MO6Zv8krSKXCRtXawX+UYuuVixGkK+k7OkUaH1U7dhc/SORrHqT76SgdGgzpFNMViElsIeYk00YAumeW9GoxRpFzRRq2jAUmtaDBah/bCxR0WDmg7ztkejFO2CDbaeNAyeL3AvNYARZDZpHzyvZ+QdaRwNagts3pnRKEUzYIOJV+QAWUSa+h85TSL3yUayElYzSpso1ZTGVK31SdeiZ+I6rB46ZDf8ibSqK8gH1DyMOIXaK1gJy+OxLjaPfCbtXExaAhtHOX/CcZJcSJ4e5K+qJZlKtpKPsEkmO18d5D054mLSYNhv54f4vhRX2kVl9bAtGtQUshb5dZSrQTGQtAw2iT4zbUix8S4mKfUUrwjx57B6yGutm5FfDwthzUSprAdZV+DmqBPscMvTaNgkw1zsKixtmriYpA6k3O7oYqoB3X/cxbwuI78edOBlc3YmT5yXqzmwkzJvpbTNVSjsVudhp6yXOtNrsifEs51cHeKSakd1dSPE9Vage7qna9WjHjSv9VdrN+ymBSE+hryBtVcvbf0n1LRU7Yg6mV4v4kKobjS2djRKrzLydoZ4jxTXu1omXQ9317V0hSwnt2Cpopa5l1xDYUFnUhfT6a1TXDmt+7Vj/hw5SJ7COp14CetGUiVs51UnahBvYe9V/ZLfDfZHd03XygJd/7LAM1MrqjdXFeiEGrtOadWV83WdI6VKi/EFdoZILVCYXvVGZ8jE9F07dM959UYDYOmn+jtERhba9Uf6B0yp3iYaZZVVVt36AVfCnDWFPDMzAAAAAElFTkSuQmCC>

[image9]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA0AAAAZCAYAAADqrKTxAAAAy0lEQVR4Xu3QP8tBYRjH8QspJVIGoxIvwMQbULJYbc/6DGLwDmyyk7KYDCwmkQzKpMfwvBuDP9/TddPdlVmp86tPna7fue7OfUTCfGuyaKJgi3dJYYYDOhjhJHpIkJKYg5L4xwpxb37E2D0vRBdfmeKGoj8kA1xRFv2CVzK4YOcPXXq4Y4uGXwSXDoq+P3Rpi3ZLW9Rc0bIF+RXtqraI4IyhN4vhB3+iS3XR+6a9d6SCNeaiyxN0kXDzPTZilp7Jif5+mzyidhjmY3kAjP8hIpiKjE8AAAAASUVORK5CYII=>

[image10]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAcAAAAbCAYAAACwRpUzAAAAkklEQVR4XmNgGOTABYgXoQvCwFEgPo4uCAM4JXmA+DcQdyAL8gGxChDHAPF/IE4HYlUgZgVJZgHxTiB+xgDRCWKDsDRIEgZA9h1DFoABbiD+BcTt6BIg4MYAsc8dXQIE2hgg9oFcjAFAdp1E4s8DYhYY5wUQz4Gy04C4BCYBAhVA/B6IZwJxK7IEDIgy4LBzuAMAgKgZojrC66sAAAAASUVORK5CYII=>

[image11]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA0AAAAYCAYAAAAh8HdUAAAA9klEQVR4XuXSsUpCYRiH8S9BFykhN40wxUmQcvMW3JKuIgUdxNHByUEXAx2dM7B2BbFJWoMGL6BRcCsb8vk8Hn19U5zDB36gfz+PnIPG/OuSuNbjvhJ4QQVVjHG1dUIVQh9xsdVRE+//1EJKbQ/GudDOonjSI01Q0qNbA2l4cQEfcnjDmTi31RB+fOIXP/jCpTwkO0dv9TqMG5ziHW33kO4WBT1SGTM9ur3Co0fq4kOPtiCmxnkAMnsvc+TVviyLb2TEFsDIOL90IvZ1TeN8wT7aR3QwwL08pLNXdO/H/o0im492Z+/nWY+Hso+6qMdD3SGmx2NrASgAI+VmAjIeAAAAAElFTkSuQmCC>

[image12]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACMAAAAZCAYAAAC7OJeSAAAB3ElEQVR4Xu2VT0hVQRSHT1FmGhpp6cJahEZtwoSEiIhEkCAM29WqFqJBkBCIkEG0auWiIJFavIIoRUv7I7US2rUJQoMg0mgjCi5ctNHQvuPMw7nHe1/gi7uI98HHnfmdedy5M/fOEynwn3AM99owbcrwIz7BX3gwWk6Xu/gFb+IqnoqW02UGM3gAT0dL6bJf3Gp02UKaFGMtdoibzGXfLwnGpEYzvsMf4ibz3vdPBmNS5wX+tGGe7A7a24P2X5nGVzYU9yIP4Sd8hA/wDfbgtmBclhp8iCN4H5/iOewPB+WiXNwW3TZ5lms4GfR3Yp+47Qxpwa/YGGT6Ti7ijSDLiT69TqbVFjzP8Z7JqnDZX5UGXPBXy5jE57Ho56yT0SWOYxbbTLYDf+N53/+Ab9fLEdpxqw2TeIxzNvQcxhWsMPlRcQ9wHA/5dmdkxCaZwpc29OgNPtsQenHCt3V7k1Z2F1bbMIlScct9xRY8g7LxfdEbfMd639czSScT98d6HffY0HIVx/EMLmFltLzGFpzHC0F2RNzvuoNM0cPSZifwksli+SbuvMjgnWhpjbM4LO6J9TogbpVGsSkYl6VO3ISeiZuAHgdJX+cGLuJrvIVFppYP+8Rtm35tBQr8c/4AHxFRUIXZczgAAAAASUVORK5CYII=>