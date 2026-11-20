import 'package:flutter/material.dart';
import 'package:klasik_lezzetler/screens/giris_ekrani.dart';
import 'package:klasik_lezzetler/screens/kaydedilenler_ve_indirilenler_ekrani.dart';
import 'package:klasik_lezzetler/theme/app_theme.dart';

class AyarlarEkrani extends StatefulWidget {
  final KullaniciProfili? mevcutKullanici;
  final ValueChanged<KullaniciProfili?> onKullaniciDegisti;
  final Set<String> kaydedilenIdler;
  final ValueChanged<Set<String>> onKaydedilenlerDegisti;
  final bool koyuTemaAktif;
  final ValueChanged<bool> onKoyuTemaDegisti;

  const AyarlarEkrani({
    super.key,
    this.mevcutKullanici,
    required this.onKullaniciDegisti,
    required this.kaydedilenIdler,
    required this.onKaydedilenlerDegisti,
    required this.koyuTemaAktif,
    required this.onKoyuTemaDegisti,
  });

  @override
  State<AyarlarEkrani> createState() => _AyarlarEkraniState();
}

class _AyarlarEkraniState extends State<AyarlarEkrani> {
  bool _appleHealthBagli = false;
  bool _googleSaglikBagli = false;
  bool _bildirimlerAcik = true;

  Future<void> _hesapEkleVeyaDuzenle() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GirisEkrani(
          mevcutKullanici: widget.mevcutKullanici,
          onGirisTamamlandi: (profil) {
            widget.onKullaniciDegisti(profil);
            setState(() {});
          },
        ),
      ),
    );
  }

  Future<void> _kaydedilenleriAc({int sekme = 0}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: AppTheme.klasikKirmizi,
            foregroundColor: AppTheme.safBeyaz,
            title: Text(
              sekme == 0 ? 'Kaydedilen Tarifler' : 'İndirilen Tarifler',
            ),
          ),
          body: KaydedilenlerVeIndirilenlerEkrani(
            kaydedilenIdler: widget.kaydedilenIdler,
            onKaydedilenlerDegisti: (yeniSet) {
              widget.onKaydedilenlerDegisti(yeniSet);
              setState(() {});
            },
            baslangicSekmesi: sekme,
          ),
        ),
      ),
    );
    setState(() {});
  }

  void _durumBildir(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.klasikKirmizi,
        content: Text(mesaj),
      ),
    );
  }

  Widget _hakkindaBilgiSatiri(IconData ikon, String metin) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          ikon,
          size: 18,
          color: AppTheme.klasikKirmizi,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            metin,
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _uygulamaHakkindaKarti(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.restaurant_menu_rounded,
                  color: AppTheme.klasikKirmizi,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OzCook',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Akıllı Tarif Keşfi ve Mutfak Asistanı',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Theme.of(context).textTheme.bodyMedium?.color ??
                              AppTheme.ikincilMetin,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.klasikKirmizi.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.klasikKirmizi,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Malzemelere, kategoriye ve pişirilme yöntemine göre tarif arayabilir, tarif detaylarını inceleyebilir ve beğendiğin tarifleri cihazına indirip çevrimdışı görüntüleyebilirsin.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const Divider(height: 20),
            _hakkindaBilgiSatiri(
              Icons.cloud_done_outlined,
              'Tarif Verileri: TheMealDB API üzerinden sağlanır.',
            ),
            const SizedBox(height: 8),
            _hakkindaBilgiSatiri(
              Icons.storage_rounded,
              'Çevrimdışı Arşiv: İndirilen tarifler yerel veritabanında (sqflite) saklanır.',
            ),
            const SizedBox(height: 8),
            _hakkindaBilgiSatiri(
              Icons.calculate_outlined,
              'Besin ve Makrolar: Kalori, protein, karbonhidrat ve yağ değerleri kategori ve malzeme bazlı tahmini hesaplamadır.',
            ),
            const SizedBox(height: 8),
            _hakkindaBilgiSatiri(
              Icons.ondemand_video_outlined,
              'Videolar: Oynatıcıda açılmayan videoları harici olarak YouTube uygulamasında açabilir veya bağlantısını kopyalayabilirsin.',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kullanici = widget.mevcutKullanici;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ayarlar',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Hesap yönetimi, Apple Health / Google Sağlık, kaydedilen/indirilen tarifler ve tercihler.',
          ),
          const SizedBox(height: 16),

          // 1. HESAP & KULLANICI YÖNETİMİ
          Text(
            'Hesap & Kullanıcı',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_circle_rounded,
                        size: 36,
                        color: AppTheme.klasikKirmizi,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kullanici?.ad ?? 'Henüz Hesap Eklenmedi',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              kullanici != null
                                  ? '${kullanici.eposta} • ${kullanici.girisYontemi}'
                                  : 'E-posta veya Google hesabı ile giriş yapabilirsin.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.ikincilMetin,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _hesapEkleVeyaDuzenle,
                          icon: const Icon(Icons.person_add_alt_1_rounded),
                          label: Text(
                            kullanici != null ? 'Hesabı Değiştir' : 'Hesap Ekle / Giriş',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.klasikKirmizi,
                            foregroundColor: AppTheme.safBeyaz,
                          ),
                        ),
                      ),
                      if (kullanici != null) ...[
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {
                            widget.onKullaniciDegisti(null);
                            setState(() {});
                            _durumBildir('Hesap oturumu kapatıldı.');
                          },
                          child: const Text('Çıkış'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 2. SAĞLIK UYGULAMALARI
          Text(
            'Sağlık Uygulamaları',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  activeThumbColor: AppTheme.klasikKirmizi,
                  secondary: const Icon(
                    Icons.favorite_rounded,
                    color: AppTheme.klasikKirmizi,
                  ),
                  title: const Text(
                    'Apple Health',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _appleHealthBagli
                        ? 'Bağlandı • Kalori ve aktivite verileri eşitleniyor'
                        : 'Bağlı değil • Apple Health ile eşitle',
                  ),
                  value: _appleHealthBagli,
                  onChanged: (deger) {
                    setState(() => _appleHealthBagli = deger);
                    _durumBildir(
                      deger
                          ? 'Apple Health bağlantısı aktifleştirildi.'
                          : 'Apple Health bağlantısı kapatıldı.',
                    );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  activeThumbColor: AppTheme.klasikKirmizi,
                  secondary: const Icon(
                    Icons.monitor_heart_rounded,
                    color: AppTheme.klasikKirmizi,
                  ),
                  title: const Text(
                    'Google Sağlık (Health Connect)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _googleSaglikBagli
                        ? 'Bağlandı • Google Sağlık verileri eşitleniyor'
                        : 'Bağlı değil • Health Connect ile eşitle',
                  ),
                  value: _googleSaglikBagli,
                  onChanged: (deger) {
                    setState(() => _googleSaglikBagli = deger);
                    _durumBildir(
                      deger
                          ? 'Google Sağlık (Health Connect) bağlantısı aktifleştirildi.'
                          : 'Google Sağlık bağlantısı kapatıldı.',
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. KAYDEDİLEN & İNDİRİLEN TARİFLER
          Text(
            'Tarif Arşivi',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.bookmark_rounded,
                    color: AppTheme.klasikKirmizi,
                  ),
                  title: const Text(
                    'Kaydedilen Tarifler',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${widget.kaydedilenIdler.length} kayıtlı tarif',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppTheme.klasikKirmizi,
                  ),
                  onTap: () => _kaydedilenleriAc(sekme: 0),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.download_for_offline_rounded,
                    color: AppTheme.klasikKirmizi,
                  ),
                  title: const Text(
                    'İndirilen Tarifler',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Çevrimdışı erişim için indirilenler'),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppTheme.klasikKirmizi,
                  ),
                  onTap: () => _kaydedilenleriAc(sekme: 1),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. UYGULAMA TERCİHLERİ
          Text(
            'Uygulama Tercihleri',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  activeThumbColor: AppTheme.klasikKirmizi,
                  secondary: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppTheme.klasikKirmizi,
                  ),
                  title: const Text(
                    'Öğün & Diyet Hatırlatıcıları',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Günlük öğün, kalori ve zamanlama bildirimlerine izin ver.',
                  ),
                  value: _bildirimlerAcik,
                  onChanged: (deger) {
                    setState(() => _bildirimlerAcik = deger);
                    _durumBildir(
                      deger
                          ? 'Hatırlatıcı bildirimleri açık.'
                          : 'Hatırlatıcı bildirimleri sessize alındı.',
                    );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  activeThumbColor: AppTheme.klasikKirmizi,
                  secondary: const Icon(
                    Icons.dark_mode_rounded,
                    color: AppTheme.klasikKirmizi,
                  ),
                  title: const Text(
                    'Koyu Tema',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    widget.koyuTemaAktif
                        ? 'Koyu tema aktif • Beyaz temaya dönmek için kapat'
                        : 'Beyaz tema aktif • Koyu temaya geçmek için aç',
                  ),
                  value: widget.koyuTemaAktif,
                  onChanged: (deger) {
                    widget.onKoyuTemaDegisti(deger);
                    _durumBildir(
                      deger ? 'Koyu tema açıldı.' : 'Beyaz temaya geçildi.',
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 5. UYGULAMA HAKKINDA
          Text(
            'Uygulama Hakkında',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          _uygulamaHakkindaKarti(context),
        ],
      ),
    );
  }
}