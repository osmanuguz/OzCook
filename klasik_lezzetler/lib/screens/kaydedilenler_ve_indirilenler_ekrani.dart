import 'package:flutter/material.dart';
import 'package:klasik_lezzetler/data/tarif_api_servisi.dart';
import 'package:klasik_lezzetler/data/veritabani_servisi.dart';
import 'package:klasik_lezzetler/models/tarif_model.dart';
import 'package:klasik_lezzetler/screens/tarif_detay_ekrani.dart';
import 'package:klasik_lezzetler/theme/app_theme.dart';

class KaydedilenlerVeIndirilenlerEkrani extends StatefulWidget {
  final Set<String> kaydedilenIdler;
  final ValueChanged<Set<String>> onKaydedilenlerDegisti;
  final int baslangicSekmesi;

  const KaydedilenlerVeIndirilenlerEkrani({
    super.key,
    required this.kaydedilenIdler,
    required this.onKaydedilenlerDegisti,
    this.baslangicSekmesi = 0,
  });

  @override
  State<KaydedilenlerVeIndirilenlerEkrani> createState() =>
      _KaydedilenlerVeIndirilenlerEkraniState();
}

class _KaydedilenlerVeIndirilenlerEkraniState
    extends State<KaydedilenlerVeIndirilenlerEkrani> {
  final TarifApiServisi _apiServisi = TarifApiServisi();
  final VeritabaniServisi _vtServisi = VeritabaniServisi();

  late int _seciliListeIndex;
  List<Tarif> _indirilenTarifler = [];
  List<Tarif> _apiTarifleri = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _seciliListeIndex = widget.baslangicSekmesi;
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    setState(() => _yukleniyor = true);

    List<Tarif> indirilenler = [];
    try {
      indirilenler = await _vtServisi.indirilenTarifleriGetir();
    } catch (_) {
      indirilenler = [];
    }

    List<Tarif> apiListe = [];
    try {
      apiListe = await _apiServisi.tumTarifleriGetir();
    } catch (_) {
      apiListe = [];
    }

    if (!mounted) return;
    setState(() {
      _indirilenTarifler = indirilenler;
      _apiTarifleri = apiListe;
      _yukleniyor = false;
    });
  }

  Future<void> _kaydiKaldir(Tarif tarif) async {
    final guncel = Set<String>.from(widget.kaydedilenIdler)..remove(tarif.id);
    widget.onKaydedilenlerDegisti(guncel);
    setState(() {});

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.klasikKirmizi,
        content: Text('${tarif.baslik} kaydedilenlerden çıkarıldı.'),
      ),
    );
  }

  Future<void> _indirmeyiKaldir(Tarif tarif) async {
    await _vtServisi.tarifSil(tarif.id);
    if (!mounted) return;

    setState(() {
      _indirilenTarifler.removeWhere((t) => t.id == tarif.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.klasikKirmizi,
        content: Text('${tarif.baslik} indirilenlerden kaldırıldı.'),
      ),
    );
  }

  Future<void> _detayaGit(Tarif tarif) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TarifDetayEkrani(tarif: tarif)),
    );
    _verileriYukle();
  }

  List<Tarif> _kaydedilenTarifleriBirlestir() {
    final Map<String, Tarif> havuz = {};
    for (final t in _indirilenTarifler) {
      havuz[t.id] = t;
    }
    for (final t in _apiTarifleri) {
      havuz[t.id] = t;
    }
    return havuz.values
        .where((t) => widget.kaydedilenIdler.contains(t.id))
        .toList();
  }

  Widget _tarifKartiOlustur(Tarif tarif, {required bool indirilenListesi}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: tarif.gorselUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  tarif.gorselUrl,
                  width: 60,
                  height: 60,
                  cacheWidth: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _err, _stack) => const Icon(
                    Icons.restaurant,
                    color: AppTheme.klasikKirmizi,
                  ),
                ),
              )
            : const Icon(
                Icons.restaurant,
                color: AppTheme.klasikKirmizi,
              ),
        title: Text(
          tarif.baslik,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontSize: 16),
        ),
        subtitle: Text(
          '${tarif.kategori} • ${tarif.pisirilisSekli} • ${tarif.besinDegerleri.kalori} kcal • ${tarif.sureDk} dk',
        ),
        trailing: IconButton(
          tooltip: indirilenListesi ? 'İndirilenlerden Kaldır' : 'Kaydı Kaldır',
          icon: Icon(
            indirilenListesi
                ? Icons.download_done_rounded
                : Icons.bookmark_remove_outlined,
            color: AppTheme.klasikKirmizi,
          ),
          onPressed: () =>
              indirilenListesi ? _indirmeyiKaldir(tarif) : _kaydiKaldir(tarif),
        ),
        onTap: () => _detayaGit(tarif),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_yukleniyor) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.klasikKirmizi),
      );
    }

    final kaydedilenTarifler = _kaydedilenTarifleriBirlestir();
    final aktifListe =
        _seciliListeIndex == 0 ? kaydedilenTarifler : _indirilenTarifler;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kaydedilen & İndirilen Tarifler',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Favori olarak kaydettiğin tarifler ve veritabanına indirdiğin tarifler.',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Text('Kaydedilenler (${kaydedilenTarifler.length})'),
                  selected: _seciliListeIndex == 0,
                  selectedColor: AppTheme.klasikKirmizi,
                  labelStyle: TextStyle(
                    color: _seciliListeIndex == 0
                        ? AppTheme.safBeyaz
                        : AppTheme.koyuMetin,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => setState(() => _seciliListeIndex = 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: Text('İndirilenler (${_indirilenTarifler.length})'),
                  selected: _seciliListeIndex == 1,
                  selectedColor: AppTheme.klasikKirmizi,
                  labelStyle: TextStyle(
                    color: _seciliListeIndex == 1
                        ? AppTheme.safBeyaz
                        : AppTheme.koyuMetin,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => setState(() => _seciliListeIndex = 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (aktifListe.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  _seciliListeIndex == 0
                      ? 'Henüz kaydedilmiş bir tarif yok. Ana sayfadaki kaydet butonunu kullanabilirsin.'
                      : 'Henüz indirilmiş bir tarif yok. Tarif detay ekranındaki "Tarifi İndir" butonuna basarak indirebilirsin.',
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: aktifListe.length,
              itemBuilder: (context, index) => _tarifKartiOlustur(
                aktifListe[index],
                indirilenListesi: _seciliListeIndex == 1,
              ),
            ),
        ],
      ),
    );
  }
}