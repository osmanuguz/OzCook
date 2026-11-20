import 'dart:async';

import 'package:flutter/material.dart';
import 'package:klasik_lezzetler/data/tarif_api_servisi.dart';
import 'package:klasik_lezzetler/data/veritabani_servisi.dart';
import 'package:klasik_lezzetler/models/tarif_model.dart';
import 'package:klasik_lezzetler/screens/tarif_detay_ekrani.dart';
import 'package:klasik_lezzetler/theme/app_theme.dart';

class AnaSayfaEkrani extends StatefulWidget {
  final Set<String> kaydedilenIdler;
  final ValueChanged<String> onKaydetmeDegisti;

  const AnaSayfaEkrani({
    super.key,
    required this.kaydedilenIdler,
    required this.onKaydetmeDegisti,
  });

  @override
  State<AnaSayfaEkrani> createState() => _AnaSayfaEkraniState();
}

class _AnaSayfaEkraniState extends State<AnaSayfaEkrani> {
  static const List<String> _cesitSecenekleri = [
    'Tümü',
    'Kahvaltılık',
    'Çorba',
    'Ana Yemek',
    'Tatlı',
    'Salata',
  ];

  final TarifApiServisi _apiServisi = TarifApiServisi();
  final TextEditingController _aramaController = TextEditingController();

  List<Tarif> _tumTarifler = [];
  String _seciliCesit = 'Tümü';
  String _aramaMetni = '';
  bool _yukleniyor = true;
  String? _hata;
  Timer? _aramaDebounce;

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  @override
  void dispose() {
    _aramaDebounce?.cancel();
    _aramaController.dispose();
    super.dispose();
  }

  void _aramaDegisti(String val) {
    _aramaDebounce?.cancel();
    _aramaDebounce = Timer(const Duration(milliseconds: 160), () {
      if (!mounted) return;
      setState(() => _aramaMetni = val);
    });
  }

  Future<void> _verileriYukle() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });

    try {
      final indirilenIdler = await VeritabaniServisi().indirilenIdleriGetir();
      final liste = await _apiServisi.tumTarifleriGetir();
      for (final t in liste) {
        t.indirildiMi = indirilenIdler.contains(t.id);
      }

      if (!mounted) return;
      setState(() {
        _tumTarifler = liste;
        _yukleniyor = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hata = 'Tarifler yüklenemedi. İnternet bağlantını kontrol et.';
        _yukleniyor = false;
      });
    }
  }

  void _kaydetButonunaBasildi(Tarif tarif) {
    final kaydedildiMi = widget.kaydedilenIdler.contains(tarif.id);
    widget.onKaydetmeDegisti(tarif.id);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.klasikKirmizi,
        content: Text(
          !kaydedildiMi
              ? '${tarif.baslik} kaydedilenlere eklendi.'
              : '${tarif.baslik} kaydedilenlerden çıkarıldı.',
        ),
      ),
    );
  }

  Tarif? _gununMenusuBul() {
    if (_tumTarifler.isEmpty) return null;
    final gunIndex = (DateTime.now().day - 1) % _tumTarifler.length;
    return _tumTarifler[gunIndex];
  }

  bool _cesitEslesiyorMu(Tarif tarif, String seciliCesit) {
    if (seciliCesit == 'Tümü') return true;

    final kat = tarif.kategori.toLowerCase();
    final baslik = tarif.baslik.toLowerCase();
    final etiketler = tarif.etiketler.join(' ').toLowerCase();
    final birlesik = '$kat $baslik $etiketler';

    switch (seciliCesit) {
      case 'Kahvaltılık':
        return birlesik.contains('kahvalt') ||
            birlesik.contains('yumurta') ||
            birlesik.contains('omlet') ||
            birlesik.contains('börek') ||
            birlesik.contains('pankek');
      case 'Çorba':
        return birlesik.contains('çorba') ||
            birlesik.contains('corba') ||
            birlesik.contains('soup');
      case 'Ana Yemek':
        return birlesik.contains('ana') ||
            birlesik.contains('kebap') ||
            birlesik.contains('tavuk') ||
            birlesik.contains('et') ||
            birlesik.contains('balık') ||
            birlesik.contains('balik') ||
            birlesik.contains('makarna') ||
            birlesik.contains('pilav') ||
            birlesik.contains('deniz');
      case 'Tatlı':
        return birlesik.contains('tatl') ||
            birlesik.contains('kek') ||
            birlesik.contains('pasta') ||
            birlesik.contains('kurabiye') ||
            birlesik.contains('şerbet') ||
            birlesik.contains('serbet') ||
            birlesik.contains('çikolata') ||
            birlesik.contains('cikolata');
      case 'Salata':
        return birlesik.contains('salata') || birlesik.contains('salad');
      default:
        return true;
    }
  }

  bool _aramaEslesiyorMu(Tarif tarif, String sorgu) {
    final q = sorgu.trim().toLowerCase();
    if (q.isEmpty) return true;

    final malzemelerStr = tarif.malzemeler.map((m) => m.ad).join(' ');
    final birlesik =
        '${tarif.baslik} ${tarif.kategori} ${tarif.pisirilisSekli} $malzemelerStr'
            .toLowerCase();
    return birlesik.contains(q);
  }

  Future<void> _detayaGit(Tarif tarif) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TarifDetayEkrani(tarif: tarif)),
    );
    _verileriYukle();
  }

  Widget _tarifGorseli(
    String url, {
    required double boyut,
    required int cacheGenislik,
  }) {
    if (url.isEmpty) {
      return Icon(
        Icons.restaurant,
        color: AppTheme.klasikKirmizi,
        size: boyut * 0.65,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: boyut,
        height: boyut,
        cacheWidth: cacheGenislik,
        fit: BoxFit.cover,
        errorBuilder: (_, _err, _stack) => Icon(
          Icons.restaurant,
          color: AppTheme.klasikKirmizi,
          size: boyut * 0.65,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final koyuTemaMi = Theme.of(context).brightness == Brightness.dark;

    if (_yukleniyor) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.klasikKirmizi),
      );
    }

    if (_hata != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_hata!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _verileriYukle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.klasikKirmizi,
                      foregroundColor: AppTheme.safBeyaz,
                    ),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final gununMenusu = _gununMenusuBul();
    final filtrelenmisYemekler = _tumTarifler
        .where(
          (t) =>
              _cesitEslesiyorMu(t, _seciliCesit) &&
              _aramaEslesiyorMu(t, _aramaMetni),
        )
        .toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                'Günün Menüsü',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              if (gununMenusu != null)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppTheme.klasikKirmizi.withValues(alpha: 0.25),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: _tarifGorseli(
                      gununMenusu.gorselUrl,
                      boyut: 72,
                      cacheGenislik: 144,
                    ),
                    title: Text(
                      gununMenusu.baslik,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 16),
                    ),
                    subtitle: Text(
                      '${gununMenusu.kategori} • ${gununMenusu.pisirilisSekli} • ${gununMenusu.besinDegerleri.kalori} kcal • ${gununMenusu.sureDk} dk',
                    ),
                    trailing: IconButton(
                      tooltip: widget.kaydedilenIdler.contains(gununMenusu.id)
                          ? 'Kaydı Kaldır'
                          : 'Tarifi Kaydet',
                      icon: Icon(
                        widget.kaydedilenIdler.contains(gununMenusu.id)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: AppTheme.klasikKirmizi,
                      ),
                      onPressed: () => _kaydetButonunaBasildi(gununMenusu),
                    ),
                    onTap: () => _detayaGit(gununMenusu),
                  ),
                )
              else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Text('Günün menüsü henüz hazır değil.'),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Çeşit Seçim',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _cesitSecenekleri.length,
                  separatorBuilder: (_, _sep) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cesit = _cesitSecenekleri[index];
                    final secili = _seciliCesit == cesit;
                    final yaziRengi = secili
                        ? AppTheme.safBeyaz
                        : (koyuTemaMi ? AppTheme.safBeyaz : AppTheme.koyuMetin);

                    return ChoiceChip(
                      label: Text(cesit),
                      selected: secili,
                      selectedColor: AppTheme.klasikKirmizi,
                      backgroundColor: koyuTemaMi
                          ? AppTheme.koyuKirmiziYuzey
                          : AppTheme.acikKirmiziYuzey,
                      labelStyle: TextStyle(
                        color: yaziRengi,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() => _seciliCesit = cesit);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _aramaController,
                onChanged: _aramaDegisti,
                style: TextStyle(
                  color: koyuTemaMi ? AppTheme.safBeyaz : AppTheme.koyuMetin,
                ),
                decoration: InputDecoration(
                  hintText: 'Yemek veya malzeme ara...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.klasikKirmizi,
                  ),
                  suffixIcon: _aramaMetni.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _aramaDebounce?.cancel();
                            _aramaController.clear();
                            setState(() => _aramaMetni = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: koyuTemaMi
                      ? AppTheme.koyuKirmiziYuzey
                      : AppTheme.acikKirmiziYuzey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _seciliCesit == 'Tümü'
                    ? 'Yemekler'
                    : 'Yemekler • $_seciliCesit',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              if (filtrelenmisYemekler.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child:
                        Text('Aramana veya seçili çeşide uygun tarif bulunamadı.'),
                  ),
                ),
            ]),
          ),
        ),
        if (filtrelenmisYemekler.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tarif = filtrelenmisYemekler[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: _tarifGorseli(
                        tarif.gorselUrl,
                        boyut: 64,
                        cacheGenislik: 128,
                      ),
                      title: Text(
                        tarif.baslik,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: 16),
                      ),
                      subtitle: Text(
                        '${tarif.kategori} • ${tarif.pisirilisSekli} • ${tarif.besinDegerleri.kalori} kcal • ${tarif.sureDk} dk'
                        '${tarif.videoUrl.isNotEmpty ? ' • Videolu' : ''}',
                      ),
                      trailing: IconButton(
                        tooltip: widget.kaydedilenIdler.contains(tarif.id)
                            ? 'Kaydı Kaldır'
                            : 'Tarifi Kaydet',
                        icon: Icon(
                          widget.kaydedilenIdler.contains(tarif.id)
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: AppTheme.klasikKirmizi,
                        ),
                        onPressed: () => _kaydetButonunaBasildi(tarif),
                      ),
                      onTap: () => _detayaGit(tarif),
                    ),
                  );
                },
                childCount: filtrelenmisYemekler.length,
              ),
            ),
          ),
      ],
    );
  }
}