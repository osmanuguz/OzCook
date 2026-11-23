import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:klasik_lezzetler/data/ceviri_servisi.dart';
import 'package:klasik_lezzetler/data/tarif_api_servisi.dart';
import 'package:klasik_lezzetler/data/turkce_cevirici.dart';
import 'package:klasik_lezzetler/data/veritabani_servisi.dart';
import 'package:klasik_lezzetler/models/tarif_model.dart';
import 'package:klasik_lezzetler/screens/kalori_ve_ozday_ekrani.dart';
import 'package:klasik_lezzetler/screens/tarif_detay_ekrani.dart';
import 'package:klasik_lezzetler/theme/app_theme.dart';

class OzModlariEkrani extends StatefulWidget {
  final String? baslangicModu;

  const OzModlariEkrani({super.key, this.baslangicModu});

  @override
  State<OzModlariEkrani> createState() => _OzModlariEkraniState();
}

class _OzModlariEkraniState extends State<OzModlariEkrani> {
  final TarifApiServisi _apiServisi = TarifApiServisi();
  final VeritabaniServisi _vtServisi = VeritabaniServisi();
  final FlutterLocalNotificationsPlugin _bildirimPlugin =
      FlutterLocalNotificationsPlugin();

  final TextEditingController _diyetKaloriController =
      TextEditingController(text: '450');
  final TextEditingController _kiloAlmaKaloriController =
      TextEditingController(text: '850');

  Timer? _diyetZamanlayici;
  TimeOfDay _diyetHatirlatmaSaati = const TimeOfDay(hour: 12, minute: 30);
  bool _diyetZamanlamaAktif = false;

  List<Tarif> _tumTarifler = [];
  final Map<String, String> _cevrilenBasliklar = {};
  final Set<String> _cevrilenModAnahtarlari = {};
  bool _yukleniyor = true;

  String? _aktifMod;
  String _ozFitModu = 'Diyet';
  int _diyetHedefKalori = 450;
  int _kiloAlmaHedefKalori = 850;
  String _seciliOneriMetni = '';

  int _aktifGun = 1;
  List<int> _gunListesi = [1, 2, 3, 4, 5, 6, 7];
  Map<int, Map<String, dynamic>> _kayitliGunler = {};

  String _ozHealthFiltre = 'Tümü';

  Map<String, bool> _gunSonuTikleri = {
    'Sabah öğünü planına uyuldu': false,
    'Ara/ana öğün porsiyonu dengelendi': false,
    'Su ve sağlıklı tercih korundu': false,
    'Gün sonu kalori/hedef özeti kontrol edildi': false,
  };

  @override
  void initState() {
    super.initState();
    _aktifMod = widget.baslangicModu;
    _bildirimHazirla();
    _verileriYukle();
  }

  @override
  void dispose() {
    _diyetZamanlayici?.cancel();
    _diyetKaloriController.dispose();
    _kiloAlmaKaloriController.dispose();
    super.dispose();
  }

  String _gosterilecekBaslik(Tarif tarif) {
    final onbellekli = _cevrilenBasliklar[tarif.id];
    if (onbellekli != null && onbellekli.trim().isNotEmpty) {
      return onbellekli;
    }
    final temiz = tarif.baslik.trim();
    if (temiz.isEmpty) return temiz;
    return TurkceCevirici.yemekAdiCevir(temiz);
  }

  Future<void> _basliklariKasmadanCevir(
    String anahtar,
    List<Tarif> tarifler,
  ) async {
    if (tarifler.isEmpty || _cevrilenModAnahtarlari.contains(anahtar)) return;
    _cevrilenModAnahtarlari.add(anahtar);

    final hedefler = tarifler
        .where((t) {
          final ham = t.baslik.trim();
          if (ham.isEmpty || _cevrilenBasliklar.containsKey(t.id)) return false;
          // Yerel sözlük zaten çevirdiyse dış isteğe gerek kalmasın
          return TurkceCevirici.yemekAdiCevir(ham) == ham;
        })
        .take(10)
        .toList();

    if (hedefler.isEmpty) return;

    bool degisti = false;
    for (int i = 0; i < hedefler.length; i += 5) {
      if (!mounted) return;
      final grup = hedefler.skip(i).take(5).toList();
      await Future.wait(
        grup.map((tarif) async {
          try {
            final ceviri = await CeviriServisi.yemekAdiCevir(tarif.baslik.trim());
            if (ceviri.trim().isNotEmpty && ceviri.trim() != tarif.baslik.trim()) {
              _cevrilenBasliklar[tarif.id] = ceviri.trim();
              degisti = true;
            }
          } catch (_) {}
        }),
      );
    }

    if (degisti && mounted) {
      setState(() {});
    }
  }

  Color _chipMetinRengi(bool secili, bool koyuTemaMi) {
    if (secili) return AppTheme.safBeyaz;
    return koyuTemaMi ? AppTheme.safBeyaz : AppTheme.koyuMetin;
  }

  Color _chipArkaPlanRengi(bool secili, bool koyuTemaMi) {
    if (secili) return AppTheme.klasikKirmizi;
    return koyuTemaMi ? AppTheme.koyuKirmiziYuzey : AppTheme.acikKirmiziYuzey;
  }

  Widget _tarifKucukGorseli(String gorselUrl, {double boyut = 58}) {
    if (gorselUrl.isEmpty) {
      return Icon(
        Icons.restaurant,
        color: AppTheme.klasikKirmizi,
        size: boyut * 0.45,
      );
    }

    final cachePx = (boyut * 2).round();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        gorselUrl,
        width: boyut,
        height: boyut,
        cacheWidth: cachePx,
        cacheHeight: cachePx,
        fit: BoxFit.cover,
        errorBuilder: (_, _err, _stack) => Icon(
          Icons.restaurant,
          color: AppTheme.klasikKirmizi,
          size: boyut * 0.45,
        ),
      ),
    );
  }

  Future<void> _bildirimHazirla() async {
    const androidAyar = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ayarlar = InitializationSettings(android: androidAyar);
    try {
      await _bildirimPlugin.initialize(ayarlar);
      final androidPlugin = _bildirimPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    } catch (_) {}
  }

  Future<void> _bildirimGonder(String baslik, String icerik) async {
    const androidDetay = AndroidNotificationDetails(
      'ozcook_ozfit_kanali',
      'OzCook OzFit Hatırlatıcıları',
      channelDescription: 'OzFit diyet, zamanlama ve günlük takvim bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const detaylar = NotificationDetails(android: androidDetay);
    try {
      await _bildirimPlugin.show(301, baslik, icerik, detaylar);
    } catch (_) {}
  }

  Future<void> _diyetZamanlamaSecVeKur() async {
    final secilen = await showTimePicker(
      context: context,
      initialTime: _diyetHatirlatmaSaati,
    );
    if (secilen == null || !mounted) return;

    _diyetZamanlayici?.cancel();

    final simdi = DateTime.now();
    var hedefZaman = DateTime(
      simdi.year,
      simdi.month,
      simdi.day,
      secilen.hour,
      secilen.minute,
    );
    if (!hedefZaman.isAfter(simdi)) {
      hedefZaman = hedefZaman.add(const Duration(days: 1));
    }

    final fark = hedefZaman.difference(simdi);
    final saatMetni =
        '${secilen.hour.toString().padLeft(2, '0')}:${secilen.minute.toString().padLeft(2, '0')}';

    setState(() {
      _diyetHatirlatmaSaati = secilen;
      _diyetZamanlamaAktif = true;
    });

    _diyetZamanlayici = Timer(fark, () async {
      await _bildirimGonder(
        'OzFit Diyet Zamanlaması ($saatMetni)',
        'Gün $_aktifGun için $_ozFitModu ($_aktifHedefKalori kcal) öğün zamanı geldi!',
      );
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.klasikKirmizi,
        content: Text('Diyet zamanlaması $saatMetni saatine kuruldu.'),
      ),
    );
  }

  Future<void> _verileriYukle() async {
    try {
      final liste = await _apiServisi.tumTarifleriGetir();
      final gunler = await _vtServisi.ozFitTumGunleriGetir();
      if (!mounted) return;

      final setGunler = <int>{..._gunListesi, ...gunler.keys}.toList()..sort();

      setState(() {
        _tumTarifler = liste;
        _kayitliGunler = gunler;
        _gunListesi = setGunler;
        _yukleniyor = false;
      });

      _gunVerisiniUygula(_aktifGun);
      if (_aktifMod != null) {
        unawaited(_aktifModBasliklariniCevir(_aktifMod!));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _yukleniyor = false);
    }
  }

  Future<void> _aktifModBasliklariniCevir(String mod) async {
    if (_tumTarifler.isEmpty) return;
    if (mod == 'OzFit') {
      final gruplar = _ozFitKaloriOnerileri();
      final tarifler = gruplar.expand((g) => g).toList();
      await _basliklariKasmadanCevir(
        'OzFit:$_ozFitModu:$_aktifHedefKalori',
        tarifler,
      );
    } else if (mod == 'OzHealth') {
      await _basliklariKasmadanCevir(
        'OzHealth:$_ozHealthFiltre',
        _ozHealthTarifleri(),
      );
    } else if (mod == 'KYK Yurt') {
      await _basliklariKasmadanCevir('KYK Yurt', _kykYurtTarifleri());
    }
  }

  Future<void> _tarifDetayinaGit(Tarif tarif) async {
    final detayTarifi = Tarif(
      id: tarif.id,
      baslik: _gosterilecekBaslik(tarif),
      kategori: tarif.kategori,
      pisirilisSekli: tarif.pisirilisSekli,
      sureDk: tarif.sureDk,
      porsiyon: tarif.porsiyon,
      gorselUrl: tarif.gorselUrl,
      videoUrl: tarif.videoUrl,
      besinDegerleri: tarif.besinDegerleri,
      malzemeler: tarif.malzemeler,
      etiketler: tarif.etiketler,
      yapilis: tarif.yapilis,
      indirildiMi: tarif.indirildiMi,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TarifDetayEkrani(tarif: detayTarifi)),
    );
  }

  void _gunVerisiniUygula(int gunNo) {
    final kayit = _kayitliGunler[gunNo];
    if (kayit == null) {
      setState(() {
        _aktifGun = gunNo;
        _seciliOneriMetni = '';
        _gunSonuTikleri = {
          for (final k in _gunSonuTikleri.keys) k: false,
        };
      });
      return;
    }

    final hedefTipi = (kayit['hedef_tipi'] as String?) ?? 'Diyet';
    final hedefKalori = (kayit['hedef_kalori'] as int?) ??
        (hedefTipi == 'Diyet' ? 450 : 850);
    final seciliOneri = (kayit['secili_oneri'] as String?) ?? '';
    final tiklerStr = (kayit['tikler_json'] as String?) ?? '{}';

    final yeniTikler = <String, bool>{
      for (final k in _gunSonuTikleri.keys) k: false,
    };

    try {
      final decoded = jsonDecode(tiklerStr) as Map<String, dynamic>;
      for (final key in yeniTikler.keys) {
        if (decoded[key] is bool) {
          yeniTikler[key] = decoded[key] as bool;
        }
      }
    } catch (_) {}

    setState(() {
      _aktifGun = gunNo;
      _ozFitModu = hedefTipi;
      if (hedefTipi == 'Diyet') {
        _diyetHedefKalori = hedefKalori;
        _diyetKaloriController.text = hedefKalori.toString();
      } else {
        _kiloAlmaHedefKalori = hedefKalori;
        _kiloAlmaKaloriController.text = hedefKalori.toString();
      }
      _seciliOneriMetni = seciliOneri;
      _gunSonuTikleri = yeniTikler;
    });
  }

  int get _aktifHedefKalori =>
      _ozFitModu == 'Diyet' ? _diyetHedefKalori : _kiloAlmaHedefKalori;

  void _kaloriHedefiniGuncelle() {
    final controller =
        _ozFitModu == 'Diyet' ? _diyetKaloriController : _kiloAlmaKaloriController;
    final deger = int.tryParse(controller.text.trim());
    if (deger == null || deger < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Lütfen geçerli bir kalori değeri girin (örn: 450 veya 850).'),
        ),
      );
      return;
    }

    setState(() {
      if (_ozFitModu == 'Diyet') {
        _diyetHedefKalori = deger;
      } else {
        _kiloAlmaHedefKalori = deger;
      }
    });
    unawaited(_aktifModBasliklariniCevir('OzFit'));
  }

  List<List<Tarif>> _ozFitKaloriOnerileri() {
    if (_tumTarifler.isEmpty) return [];
    final hedef = _aktifHedefKalori;

    final adaylar = <List<Tarif>>[];
    final sinirliListe = _tumTarifler.take(40).toList();

    for (final t in sinirliListe) {
      adaylar.add([t]);
    }

    for (int i = 0; i < sinirliListe.length && i < 18; i++) {
      for (int j = i + 1; j < sinirliListe.length && j < 18; j++) {
        adaylar.add([sinirliListe[i], sinirliListe[j]]);
      }
    }

    adaylar.sort((a, b) {
      final topA = a.fold<int>(0, (acc, t) => acc + t.besinDegerleri.kalori);
      final topB = b.fold<int>(0, (acc, t) => acc + t.besinDegerleri.kalori);
      return (topA - hedef).abs().compareTo((topB - hedef).abs());
    });

    return adaylar.take(5).toList();
  }

  Future<void> _mevcutGunuKaydet() async {
    final oneriler = _ozFitKaloriOnerileri();
    final varsayilanOneri = oneriler.isNotEmpty
        ? '${oneriler.first.map(_gosterilecekBaslik).join(' + ')} (${oneriler.first.fold<int>(0, (acc, t) => acc + t.besinDegerleri.kalori)} kcal)'
        : 'Öneri seçilmedi';

    final kayitOneri =
        _seciliOneriMetni.isNotEmpty ? _seciliOneriMetni : varsayilanOneri;

    await _vtServisi.ozFitGunKaydet(
      gunNo: _aktifGun,
      hedefTipi: _ozFitModu,
      hedefKalori: _aktifHedefKalori,
      seciliOneri: kayitOneri,
      tiklerJson: jsonEncode(_gunSonuTikleri),
    );

    final guncelGunler = await _vtServisi.ozFitTumGunleriGetir();
    if (!mounted) return;

    setState(() {
      _kayitliGunler = guncelGunler;
      _seciliOneriMetni = kayitOneri;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.klasikKirmizi,
        content: Text('Gün $_aktifGun planı ve özeti kaydedildi.'),
      ),
    );
  }

  Future<void> _ozFitBildirimiGonder() async {
    final oneriler = _ozFitKaloriOnerileri();
    final oneriMetni = _seciliOneriMetni.isNotEmpty
        ? _seciliOneriMetni
        : (oneriler.isNotEmpty
            ? '${oneriler.first.map(_gosterilecekBaslik).join(' + ')} (${oneriler.first.fold<int>(0, (acc, t) => acc + t.besinDegerleri.kalori)} kcal)'
            : 'Tarif önerisi hazır');

    final tamamlananTik = _gunSonuTikleri.values.where((v) => v).length;
    final toplamTik = _gunSonuTikleri.length;

    await _bildirimGonder(
      'OzFit • Gün $_aktifGun ($_ozFitModu: $_aktifHedefKalori kcal)',
      '$oneriMetni | Özet: $tamamlananTik/$toplamTik tamamlandı.',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.klasikKirmizi,
        content: Text('Gün $_aktifGun için OzFit bildirimi gönderildi.'),
      ),
    );
  }

  void _yeniGunEkle() {
    final sonrakiGun = _gunListesi.isEmpty ? 1 : (_gunListesi.last + 1);
    setState(() {
      _gunListesi.add(sonrakiGun);
    });
    _gunVerisiniUygula(sonrakiGun);
  }

  String _birlesikMetin(Tarif t) {
    final trBaslik = _gosterilecekBaslik(t);
    return '${t.baslik} $trBaslik ${t.kategori} ${t.pisirilisSekli} ${t.etiketler.join(' ')} ${t.malzemeler.join(' ')}'
        .toLowerCase();
  }

  List<Tarif> _ozHealthTarifleri() {
    return _tumTarifler.where((t) {
      final metin = _birlesikMetin(t);
      final hafifMi = t.besinDegerleri.kalori <= 500;

      if (_ozHealthFiltre == 'Şeker Dostu') {
        final sekerliMi = metin.contains('şeker') ||
            metin.contains('bal') ||
            metin.contains('şerbet') ||
            metin.contains('tatlı');
        return hafifMi && !sekerliMi;
      }

      if (_ozHealthFiltre == 'Tansiyon Dostu') {
        final tuzluVeyaSalcaliMi = metin.contains('turşu') ||
            metin.contains('salça') ||
            metin.contains('zeytin') ||
            metin.contains('sos');
        return hafifMi && !tuzluVeyaSalcaliMi;
      }

      return hafifMi;
    }).take(30).toList();
  }

  List<Tarif> _kykYurtTarifleri() {
    final pratikListe = _tumTarifler.where((t) {
      final metin = _birlesikMetin(t);
      final kisaSure = t.sureDk <= 25;
      final yurtUygun = t.pisirilisSekli.toLowerCase().contains('pişirmesiz') ||
          t.pisirilisSekli.toLowerCase().contains('ocak') ||
          metin.contains('yurt') ||
          metin.contains('pratik') ||
          metin.contains('sandviç') ||
          metin.contains('salata') ||
          metin.contains('yumurta');
      return kisaSure || yurtUygun;
    }).take(30).toList();

    return pratikListe.isNotEmpty ? pratikListe : _tumTarifler.take(30).toList();
  }

  Widget _tarifListeKarti(Tarif tarif) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: _tarifKucukGorseli(tarif.gorselUrl, boyut: 58),
        title: Text(
          _gosterilecekBaslik(tarif),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${tarif.kategori} • ${tarif.pisirilisSekli} • ${tarif.besinDegerleri.kalori} kcal • ${tarif.sureDk} dk',
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.klasikKirmizi,
        ),
        onTap: () => _tarifDetayinaGit(tarif),
      ),
    );
  }

  Widget _kapakKarti({
    required String baslik,
    required String altBaslik,
    required String aciklama,
    required IconData ikon,
    required List<Color> renkler,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: renkler,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: renkler.last.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.safBeyaz.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(ikon, size: 32, color: AppTheme.safBeyaz),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        altBaslik,
                        style: TextStyle(
                          color: AppTheme.safBeyaz.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        baslik,
                        style: const TextStyle(
                          color: AppTheme.safBeyaz,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        aciklama,
                        style: TextStyle(
                          color: AppTheme.safBeyaz.withValues(alpha: 0.92),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.safBeyaz,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _modSec(String mod) {
    setState(() => _aktifMod = mod);
    unawaited(_aktifModBasliklariniCevir(mod));
  }

  @override
  Widget build(BuildContext context) {
    final koyuTemaMi = Theme.of(context).brightness == Brightness.dark;

    if (_yukleniyor) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.klasikKirmizi),
      );
    }

    if (_aktifMod == null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Oz Modları',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Kalori & OzDay, OzFit, OzHealth veya KYK Yurt kapağını seçerek devam et.',
            ),
            const SizedBox(height: 16),
            _kapakKarti(
              baslik: 'Kalori & OzDay',
              altBaslik: 'Öğün Sayacı • Kalori Önerisi • Günün Menüsü',
              aciklama:
                  'Günlük öğün ve kalori takibi yap, hedef kalorine göre menü önerisi al.',
              ikon: Icons.local_fire_department_rounded,
              renkler: const [
                AppTheme.klasikKirmizi,
                Color(0xFF7A1419),
              ],
              onTap: () => _modSec('Kalori & OzDay'),
            ),
            _kapakKarti(
              baslik: 'OzFit',
              altBaslik: 'Diyet • Kilo Alma • Zamanlama',
              aciklama:
                  'Kalori hedefi belirle, diyet saatini zamanla ve günlük takvimini kaydet.',
              ikon: Icons.fitness_center_rounded,
              renkler: const [
                Color(0xFFB71C1C),
                Color(0xFF5A1014),
              ],
              onTap: () => _modSec('OzFit'),
            ),
            _kapakKarti(
              baslik: 'OzHealth',
              altBaslik: 'Şeker Dostu • Tansiyon Dostu',
              aciklama:
                  'Sağlık hassasiyetine göre dengeli ve hafif tarifleri filtrele.',
              ikon: Icons.health_and_safety_rounded,
              renkler: const [
                Color(0xFFC62828),
                Color(0xFF4A0E12),
              ],
              onTap: () => _modSec('OzHealth'),
            ),
            _kapakKarti(
              baslik: 'KYK Yurt',
              altBaslik: 'Pratik • Hızlı • Ekonomik',
              aciklama:
                  'Yurt koşullarına uygun kısa sürede hazırlanan tarifleri keşfet.',
              ikon: Icons.home_work_rounded,
              renkler: const [
                Color(0xFFD32F2F),
                Color(0xFF6D1B1B),
              ],
              onTap: () => _modSec('KYK Yurt'),
            ),
          ],
        ),
      );
    }

    final tamamlananTik = _gunSonuTikleri.values.where((v) => v).length;
    final toplamTik = _gunSonuTikleri.length;
    final ozFitOneriler = _ozFitKaloriOnerileri();
    final diyetSaatMetni =
        '${_diyetHatirlatmaSaati.hour.toString().padLeft(2, '0')}:${_diyetHatirlatmaSaati.minute.toString().padLeft(2, '0')}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _aktifMod = null),
                icon: const Icon(Icons.grid_view_rounded),
                label: const Text('Kapaklar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      koyuTemaMi ? AppTheme.safBeyaz : AppTheme.koyuMetin,
                  side: BorderSide(
                    color: koyuTemaMi
                        ? AppTheme.safBeyaz.withValues(alpha: 0.35)
                        : AppTheme.klasikKirmizi.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'Kalori & OzDay',
                      'OzFit',
                      'OzHealth',
                      'KYK Yurt',
                    ].map((bolum) {
                      final secili = _aktifMod == bolum;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(bolum),
                          selected: secili,
                          selectedColor: AppTheme.klasikKirmizi,
                          backgroundColor:
                              _chipArkaPlanRengi(secili, koyuTemaMi),
                          labelStyle: TextStyle(
                            color: _chipMetinRengi(secili, koyuTemaMi),
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) => _modSec(bolum),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_aktifMod == 'Kalori & OzDay') ...[
            const KaloriVeOzDayEkrani(icIceScroll: true),
          ] else if (_aktifMod == 'OzFit') ...[
            Text(
              'OzFit • Hedef Kalori, Zamanlama & Takvim',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Row(
              children: ['Diyet', 'Kilo Alma'].map((mod) {
                final secili = _ozFitModu == mod;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(mod, textAlign: TextAlign.center),
                      selected: secili,
                      selectedColor: AppTheme.klasikKirmizi,
                      backgroundColor: _chipArkaPlanRengi(secili, koyuTemaMi),
                      labelStyle: TextStyle(
                        color: _chipMetinRengi(secili, koyuTemaMi),
                        fontWeight: FontWeight.w700,
                      ),
                      onSelected: (_) {
                        setState(() => _ozFitModu = mod);
                        unawaited(_aktifModBasliklariniCevir('OzFit'));
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.alarm_rounded,
                      color: AppTheme.klasikKirmizi,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Diyet Zamanlaması',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Saat: $diyetSaatMetni (${_diyetZamanlamaAktif ? 'Zamanlandı' : 'Kapalı'})',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _diyetZamanlamaSecVeKur,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.klasikKirmizi,
                        foregroundColor: AppTheme.safBeyaz,
                      ),
                      child: const Text('Zaman Kur'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_ozFitModu Kalori Hedefi',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ozFitModu == 'Diyet'
                                ? _diyetKaloriController
                                : _kiloAlmaKaloriController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: '$_ozFitModu Kalori (kcal)',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _kaloriHedefiniGuncelle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.klasikKirmizi,
                            foregroundColor: AppTheme.safBeyaz,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                          ),
                          child: const Text('Öner'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kayıtlı Diyet Hedefi: $_diyetHedefKalori kcal  •  Kilo Alma Hedefi: $_kiloAlmaHedefKalori kcal',
                      style: TextStyle(
                        fontSize: 12,
                        color: koyuTemaMi
                            ? AppTheme.safBeyaz.withValues(alpha: 0.72)
                            : AppTheme.ikincilMetin,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Günlük Takvim (Gün $_aktifGun)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: _yeniGunEkle,
                  icon: const Icon(Icons.add, color: AppTheme.klasikKirmizi),
                  label: const Text(
                    'Gün Ekle',
                    style: TextStyle(color: AppTheme.klasikKirmizi),
                  ),
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _gunListesi.map((gunNo) {
                  final secili = _aktifGun == gunNo;
                  final kayitliMi = _kayitliGunler.containsKey(gunNo);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('Gün $gunNo${kayitliMi ? ' ✓' : ''}'),
                      selected: secili,
                      selectedColor: AppTheme.klasikKirmizi,
                      backgroundColor: _chipArkaPlanRengi(secili, koyuTemaMi),
                      labelStyle: TextStyle(
                        color: _chipMetinRengi(secili, koyuTemaMi),
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => _gunVerisiniUygula(gunNo),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_seciliOneriMetni.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.klasikKirmizi.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Gün $_aktifGun Seçili Plan: $_seciliOneriMetni',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: koyuTemaMi ? AppTheme.safBeyaz : AppTheme.klasikKirmizi,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gün $_aktifGun Özet Kontrolü',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '$tamamlananTik / $toplamTik Tamam',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.klasikKirmizi,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ..._gunSonuTikleri.entries.map((entry) {
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppTheme.klasikKirmizi,
                        title: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: entry.value,
                        onChanged: (val) {
                          setState(() {
                            _gunSonuTikleri[entry.key] = val ?? false;
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _mevcutGunuKaydet,
                            icon: const Icon(Icons.save_rounded),
                            label: Text('Gün $_aktifGun Kaydet'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: koyuTemaMi
                                  ? AppTheme.safBeyaz
                                  : AppTheme.koyuMetin,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _ozFitBildirimiGonder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.klasikKirmizi,
                              foregroundColor: AppTheme.safBeyaz,
                            ),
                            icon: const Icon(Icons.notifications_active_rounded),
                            label: const Text('Bildirim Gönder'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$_ozFitModu İçin Öneriler ($_aktifHedefKalori kcal Hedef)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...ozFitOneriler.map((grup) {
              final toplamKalori = grup.fold<int>(
                0,
                (acc, t) => acc + t.besinDegerleri.kalori,
              );
              final basliklar = grup.map(_gosterilecekBaslik).join(' + ');
              final tamMetin = '$basliklar ($toplamKalori kcal)';
              final ilkTarif = grup.first;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: _tarifKucukGorseli(ilkTarif.gorselUrl, boyut: 58),
                  title: Text(
                    basliklar,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    'Toplam: $toplamKalori kcal (Hedef: $_aktifHedefKalori kcal) • Detay için dokun',
                  ),
                  onTap: () => _tarifDetayinaGit(ilkTarif),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() => _seciliOneriMetni = tamMetin);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Gün $_aktifGun için seçildi: $tamMetin'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.klasikKirmizi,
                      foregroundColor: AppTheme.safBeyaz,
                    ),
                    child: const Text('Güne Seç'),
                  ),
                ),
              );
            }),
          ] else if (_aktifMod == 'OzHealth') ...[
            Text(
              'OzHealth • Sağlıklı Seçimler',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Şeker ve tansiyon hassasiyetine göre daha dengeli ve hafif tarifleri filtrele.',
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Tümü', 'Şeker Dostu', 'Tansiyon Dostu'].map((filtre) {
                  final secili = _ozHealthFiltre == filtre;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filtre),
                      selected: secili,
                      selectedColor: AppTheme.klasikKirmizi,
                      backgroundColor: _chipArkaPlanRengi(secili, koyuTemaMi),
                      labelStyle: TextStyle(
                        color: _chipMetinRengi(secili, koyuTemaMi),
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() => _ozHealthFiltre = filtre);
                        unawaited(_aktifModBasliklariniCevir('OzHealth'));
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            ..._ozHealthTarifleri().map(_tarifListeKarti),
          ] else ...[
            Text(
              'KYK Yurt • Pratik Tarifler',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Yurt odasında kısa sürede ve az malzeme ile hazırlanabilecek tarifler.',
            ),
            const SizedBox(height: 14),
            ..._kykYurtTarifleri().map(_tarifListeKarti),
          ],
        ],
      ),
    );
  }
}