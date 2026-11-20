# OzCook

Flutter ile geliştirilmiş tarif keşfi, malzemeye göre arama, çevrimdışı tarif saklama ve tarif detay ekranı sunan bir mutfak uygulamasıdır.

## Öne Çıkan Özellikler

* **Tarif Keşfi ve Arama:** Yemek adına, kategoriye (`Kahvaltılık`, `Salata`, `Tatlı`, vb.) ve malzemelere göre arama ve filtreleme.
* **Malzemeye ve Pişirilme Şekline Göre Listeleme:** Eldeki malzemelere ve pişirilme türüne (`Fırın`, `Ocak`, `Pişirmesiz`) göre uygun tarifleri bulma.
* **Tarif Detay Ekranı:** Malzeme listesi, hazırlanış adımları, tahmini besin/makro değerleri ve tarif videosu görünümü.
* **YouTube Video Yedek Akışı:** Oynatıcıda video açılamadığında veya hata oluştuğunda harici olarak YouTube uygulamasında/tarayıcıda açma ve video bağlantısını panoya kopyalama desteği.
* **Çevrimdışı Kayıt:** Seçilen tarifleri yerel veritabanında saklayarak internet bağlantısı olmadan da görüntüleyebilme.
* **Tema Desteği:** Açık ve koyu tema seçenekleri ile kullanıcı tercihlerinin saklanması.

## Besin ve Makro Değerleri Hakkında Not

* Tariflerde gösterilen kalori, protein, karbonhidrat ve yağ değerleri; kategori, malzeme içeriği ve ölçü bilgilerine göre hesaplanan **tahmini** değerlerdir.

## Kullanılan Teknolojiler ve Paketler

* **Flutter**
* **TheMealDB API**
* **http**
* **sqflite**
* **shared_preferences**
* **youtube_player_iframe**
* **url_launcher**

## Kurulum ve Çalıştırma

1. Depoyu bilgisayarına klonla:
   `git clone https://github.com/osmanuguz/OzCook.git`

2. Proje dizinine gir ve paketleri yükle:
   `cd OzCook` ve `flutter pub get`

3. Uygulamayı çalıştır:
   `flutter run`