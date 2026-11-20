import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:klasik_lezzetler/data/ceviri_servisi.dart';
import 'package:klasik_lezzetler/data/tarif_api_servisi.dart';
import 'package:klasik_lezzetler/models/tarif_model.dart';
import 'package:klasik_lezzetler/screens/tarif_detay_ekrani.dart';
import 'package:klasik_lezzetler/theme/app_theme.dart';

class KaloriVeOzDayEkrani extends StatefulWidget {
  const KaloriVeOzDayEkrani({super.key});

  @override
  State<KaloriVeOzDayEkrani> createState() => _KaloriVeOzDayEkraniState();
}

class _KaloriVeOzDayEkraniState extends State<KaloriVeOzDayEkrani> {
  final TarifApiServisi _apiServisi = TarifApiServisi();
  final TextEditingController _hedefKaloriController =
      TextEditingController(text: '900');
  final TextEditingController _ogunKaloriController = TextEditingController();
  final FlutterLocalNotificationsPlugin _bildirimPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? _zamanlayici;
  List<Tarif> _tumTarifler = [];
  final Map<String, String> _cevrilenBasliklar = {};
  bool _yukleniyor = true;
  bool _basliklarCevriliyor = false;
  int _ceviriOturumId = 0;

  int _hedefKalori = 900;
  int _tukenenKalori = 0;
  int _yapilanOgunSayisi = 0;
  int _hedefOgunSayisi = 3;
  TimeOfDay _hatirlatmaSaati = const TimeOfDay(hour: 19, minute: 0);
  bool _bildirimAktif = false;
  String? _hatirlatmaMesaji;

  @override
  void initState() {
    super.initState();
    _bildirimHazirla();
    _verileriYukle();
  }

  @override
  void dispose() {
    _ceviriOturumId++;
    _zamanlayici?.cancel();
    _hedefKaloriController.dispose();
    _ogunKaloriController.dispose();
    super.dispose();
  }

  String _gosterilecekBaslik(Tarif tarif) {
    return _cevrilenBasliklar[tarif.id] ?? tarif.baslik;
  }

  Widget _tarifKucukGorseli(String gorselUrl) {
    if (gorselUrl.isEmpty) {
      return const Icon(
        Icons.restaurant,
        color: AppTheme.klasikKirmizi,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        gorselUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _err, _stack) => const Icon(
          Icons.restaurant,
          color: AppTheme.klasikKirmizi,
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

  Future<void> _bildirimGonder({
    required int id,
    required String baslik,
    required String icerik,
  }) async {
    const androidDetay = AndroidNotificationDetails(
      'ozcook_hatirlatici_kanali',
      'OzCook Hatırlatıcıları',
      channelDescription: 'Öğün, kalori ve günün menüsü bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const detaylar = NotificationDetails(android: androidDetay);

    try {
      await _bildirimPlugin.show(id, baslik, icerik, detaylar);
    } catch (_) {}
  }

  Future<void> _verileriYukle() async {
    final oturumId = ++_ceviriOturumId;
    final liste = await _apiServisi.tumTarifleriGetir();
    if (!mounted || oturumId != _ceviriOturumId) return;
    setState(() {
      _tumTarifler = liste;
      _yukleniyor = false;
    });
    unawaited(_basliklariArkaPlandaCevir(liste, oturumId));
  }

  Future<void> _basliklariArkaPlandaCevir(
    List<Tarif> tarifler,
    int oturumId,
  ) async {
    final cevrilecekler = tarifler
        .where(
          (t) =>
              t.id.isNotEmpty &&
              t.baslik.trim().isNotEmpty &&
              !_cevrilenBasliklar.containsKey(t.id),
        )
        .toList();

    if (cevrilecekler.isEmpty || !mounted || oturumId != _ceviriOturumId) {
      return;
    }

    setState(() => _basliklarCevriliyor = true);

    const grupBoyutu = 6;
    for (int i = 0; i < cevrilecekler.length; i += grupBoyutu) {
      if (!mounted || oturumId != _ceviriOturumId) return;

      final grup = cevrilecekler.skip(i).take(grupBoyutu).toList();
      final yeniEslesmeler = <String, String>{};

      await Future.wait(
        grup.map((tarif) async {
          try {
            final ceviri = await CeviriServisi.yemekAdiCevir(tarif.baslik);
            if (ceviri.trim().isNotEmpty) {
              yeniEslesmeler[tarif.id] = ceviri.trim();
            }
          } catch (_) {}
        }),
      );

      if (!mounted || oturumId != _ceviriOturumId) return;
      if (yeniEslesmeler.isNotEmpty) {
        setState(() {
          _cevrilenBasliklar.addAll(yeniEslesmeler);
        });
      }
    }

    if (mounted && oturumId == _ceviriOturumId) {
      setState(() => _basliklarCevriliyor = false);
    }
  }

  void _detayaGit(Tarif tarif) {
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

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TarifDetayEkrani(tarif: detayTarifi)),
    );
  }

  void _durumMesajiGoster(String mesaj) {
    if (!mounted) return;
    setState(() {
      _hatirlatmaMesaji = mesaj;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.klasikKirmizi,
        content: Text(mesaj),
      ),
    );
  }

  Future<void> _saatSecVeKur() async {
    final secilen = await showTimePicker(
      context: context,
      initialTime: _hatirlatmaSaati,
    );
    if (secilen == null || !mounted) return;

    _zamanlayici?.cancel();

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
      _hatirlatmaSaati = secilen;
      _bildirimAktif = true;
    });

    _zamanlayici = Timer(fark, () async {
      final kalan = (_hedefKalori - _tukenenKalori).clamp(0, 10000);
      await _bildirimGonder(
        id: 201,
        baslik: 'OzCook Öğün Hatırlatıcısı ($saatMetni)',
        icerik:
            'Bugün $_yapilanOgunSayisi/$_hedefOgunSayisi öğün ve $_tukenenKalori kcal kaydedildi. Kalan hedef: $kalan kcal.',
      );
    });

    _durumMesajiGoster(
      'Hatırlatıcı $saatMetni saatine kuruldu. Saat geldiğinde bildirim gönderilecek.',
    );
  }

  Future<void> _anlikTestBildirimiGonder() async {
    final kalan = (_hedefKalori - _tukenenKalori).clamp(0, 10000);
    await _bildirimGonder(
      id: 202,
      baslik: 'OzCook Hatırlatma Testi',
      icerik:
          'Öğün: $_yapilanOgunSayisi/$_hedefOgunSayisi • Alınan: $_tukenenKalori kcal • Kalan: $kalan kcal.',
    );
    _durumMesajiGoster(
      'Bildirim gönderildi! Telefonun bildirim çubuğunu kontrol et.',
    );
  }

  void _hedefKaloriGuncelle() {
    final deger = int.tryParse(_hedefKaloriController.text.trim());
    if (deger == null || deger < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir kalori değeri girin (örn: 900).'),
        ),
      );
      return;
    }
    setState(() => _hedefKalori = deger);
  }

  void _ogunEkle({int? hazirKalori}) {
    final kalori = hazirKalori ?? int.tryParse(_ogunKaloriController.text.trim());
    if (kalori == null || kalori <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen pozitif bir öğün kalorisi girin.')),
      );
      return;
    }

    setState(() {
      _tukenenKalori += kalori;
      _yapilanOgunSayisi += 1;
      if (hazirKalori == null) {
        _ogunKaloriController.clear();
      }
    });

    final kalan = _hedefKalori - _tukenenKalori;
    if (kalan <= 250 && kalan >= 0) {
      _bildirimGonder(
        id: 203,
        baslik: 'OzCook Kalori Hedefi Uyarısı',
        icerik: 'Günlük kalori hedefine yaklaştın! Kalan bütçen: $kalan kcal.',
      );
      _durumMesajiGoster('Kalori hedefine yaklaştın! Bildirim gönderildi.');
    }
  }

  void _gunuSifirla() {
    setState(() {
      _tukenenKalori = 0;
      _yapilanOgunSayisi = 0;
      _hatirlatmaMesaji = null;
    });
  }

  List<List<Tarif>> _kaloriyeGoreOneriler() {
    if (_tumTarifler.isEmpty) return [];

    final sirali = List<Tarif>.from(_tumTarifler)
      ..sort(
        (a, b) => (a.besinDegerleri.kalori - _hedefKalori).abs().compareTo(
              (b.besinDegerleri.kalori - _hedefKalori).abs(),
            ),
      );

    final List<List<Tarif>> kombinasyonlar = [];
    kombinasyonlar.add([sirali.first]);

    for (int i = 0; i < _tumTarifler.length; i++) {
      for (int j = i + 1; j < _tumTarifler.length; j++) {
        final toplam = _tumTarifler[i].besinDegerleri.kalori +
            _tumTarifler[j].besinDegerleri.kalori;
        if ((toplam - _hedefKalori).abs() <= 220) {
          kombinasyonlar.add([_tumTarifler[i], _tumTarifler[j]]);
        }
      }
    }

    kombinasyonlar.sort((a, b) {
      final topA = a.fold<int>(0, (acc, t) => acc + t.besinDegerleri.kalori);
      final topB = b.fold<int>(0, (acc, t) => acc + t.besinDegerleri.kalori);
      return (topA - _hedefKalori).abs().compareTo((topB - _hedefKalori).abs());
    });

    return kombinasyonlar.take(4).toList();
  }

  Map<String, Tarif?> _ozDayMenusu() {
    Tarif? kahvalti;
    Tarif? salata;
    Tarif? tatli;
    Tarif? anaYemek;

    for (final t in _tumTarifler) {
      if (kahvalti == null && t.kategori.toLowerCase().contains('kahvaltı')) {
        kahvalti = t;
      } else if (salata == null &&
          t.kategori.toLowerCase().contains('salata')) {
        salata = t;
      } else if (tatli == null && t.kategori.toLowerCase().contains('tatlı')) {
        tatli = t;
      } else if (anaYemek == null && t.kategori.toLowerCase().contains('ana')) {
        anaYemek = t;
      }
    }

    return {
      'Sabah (OzDay)':
          kahvalti ?? (_tumTarifler.isNotEmpty ? _tumTarifler.first : null),
      'Öğle / Ferah (OzDay)':
          salata ?? (_tumTarifler.length > 1 ? _tumTarifler[1] : null),
      'Akşam (OzDay)':
          anaYemek ?? (_tumTarifler.length > 2 ? _tumTarifler[2] : null),
      'Tatlı / Ara (OzDay)':
          tatli ?? (_tumTarifler.length > 3 ? _tumTarifler[3] : null),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_yukleniyor) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.klasikKirmizi),
      );
    }

    final kalanKalori = _hedefKalori - _tukenenKalori;
    final oneriler = _kaloriyeGoreOneriler();
    final ozDay = _ozDayMenusu();
    final saatMetni =
        '${_hatirlatmaSaati.hour.toString().padLeft(2, '0')}:${_hatirlatmaSaati.minute.toString().padLeft(2, '0')}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_basliklarCevriliyor) ...[
            const LinearProgressIndicator(
              color: AppTheme.klasikKirmizi,
              minHeight: 2.5,
            ),
            const SizedBox(height: 10),
          ],
          Text(
            'Günlük Öğün & Kalori Takibi',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Öğün: $_yapilanOgunSayisi / $_hedefOgunSayisi',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Alınan: $_tukenenKalori kcal',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.klasikKirmizi,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    kalanKalori >= 0
                        ? 'Kalan kalori: $kalanKalori kcal'
                        : 'Hedef ${kalanKalori.abs()} kcal aşıldı',
                    style: TextStyle(
                      color: kalanKalori >= 0
                          ? AppTheme.ikincilMetin
                          : AppTheme.klasikKirmizi,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Öğün Miktarı:'),
                      const SizedBox(width: 8),
                      IconButton.outlined(
                        onPressed: () {
                          if (_yapilanOgunSayisi > 0) {
                            setState(() => _yapilanOgunSayisi -= 1);
                          }
                        },
                        icon: const Icon(Icons.remove),
                        tooltip: 'Öğün azalt',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '$_yapilanOgunSayisi',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: () {
                          setState(() => _yapilanOgunSayisi += 1);
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.klasikKirmizi,
                          foregroundColor: AppTheme.safBeyaz,
                        ),
                        icon: const Icon(Icons.add),
                        tooltip: 'Öğün ekle',
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _hedefOgunSayisi =
                                _hedefOgunSayisi < 8 ? _hedefOgunSayisi + 1 : 3;
                          });
                        },
                        child: Text('Hedef: $_hedefOgunSayisi'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _gunuSifirla,
                        child: const Text('Sıfırla'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ogunKaloriController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Yediğin öğün kalorisi (kcal)',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _ogunEkle(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.klasikKirmizi,
                          foregroundColor: AppTheme.safBeyaz,
                        ),
                        child: const Text('Kalori Ekle'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        _bildirimAktif
                            ? Icons.notifications_active
                            : Icons.notifications_none,
                        color: AppTheme.klasikKirmizi,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Saat: $saatMetni (${_bildirimAktif ? 'Kuruldu' : 'Kapalı'})',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: _saatSecVeKur,
                        child: const Text('Saat Kur'),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        onPressed: _anlikTestBildirimiGonder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.klasikKirmizi,
                          foregroundColor: AppTheme.safBeyaz,
                        ),
                        child: const Text('Bildirim At'),
                      ),
                    ],
                  ),
                  if (_hatirlatmaMesaji != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.klasikKirmizi.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _hatirlatmaMesaji!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.klasikKirmizi,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Kaloriye Göre Yemek Önerisi',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(
            'Örn: 900 kcal girerek bu hedefe en yakın tarif veya menüleri gör.',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hedefKaloriController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Hedef Kalori (kcal)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _hedefKaloriGuncelle,
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
          const SizedBox(height: 12),
          ...oneriler.map((grup) {
            final toplamKalori = grup.fold<int>(
              0,
              (acc, t) => acc + t.besinDegerleri.kalori,
            );
            final basliklar = grup.map(_gosterilecekBaslik).join(' + ');
            final ilkTarif = grup.first;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: _tarifKucukGorseli(ilkTarif.gorselUrl),
                title: Text(
                  basliklar,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  'Toplam: $toplamKalori kcal (Hedef: $_hedefKalori kcal)',
                ),
                trailing: ElevatedButton(
                  onPressed: () => _ogunEkle(hazirKalori: toplamKalori),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.klasikKirmizi,
                    foregroundColor: AppTheme.safBeyaz,
                  ),
                  child: const Text('Yedim'),
                ),
                onTap: () => _detayaGit(ilkTarif),
              ),
            );
          }),
          const SizedBox(height: 22),
          Text(
            'Günün Menüsü (OzDay)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...ozDay.entries.map((entry) {
            final tarif = entry.value;
            if (tarif == null) return const SizedBox.shrink();
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: _tarifKucukGorseli(tarif.gorselUrl),
                title: Text('${entry.key}: ${_gosterilecekBaslik(tarif)}'),
                subtitle: Text(
                  '${tarif.kategori} • ${tarif.besinDegerleri.kalori} kcal • ${tarif.sureDk} dk',
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppTheme.klasikKirmizi,
                ),
                onTap: () => _detayaGit(tarif),
              ),
            );
          }),
        ],
      ),
    );
  }
}