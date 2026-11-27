import 'package:flutter/material.dart';
import 'package:klasik_lezzetler/data/tarif_api_servisi.dart';
import 'package:klasik_lezzetler/data/turkce_cevirici.dart';
import 'package:klasik_lezzetler/models/tarif_model.dart';
import 'package:klasik_lezzetler/screens/tarif_detay_ekrani.dart';
import 'package:klasik_lezzetler/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _dolapKayitAnahtari = 'ozcook_dolap_malzemeleri_v1';

class DolapEkrani extends StatefulWidget {
  const DolapEkrani({super.key});

  @override
  State<DolapEkrani> createState() => _DolapEkraniState();
}

class _DolapEkraniState extends State<DolapEkrani> {
  final TextEditingController _malzemeController = TextEditingController();
  final TarifApiServisi _apiServisi = TarifApiServisi();

  List<String> _malzemeler = [];
  List<Tarif> _eslesenTarifler = [];
  bool _yukleniyor = false;

  @override
  void initState() {
    super.initState();
    _dolabiYukle();
  }

  @override
  void dispose() {
    _malzemeController.dispose();
    super.dispose();
  }

  Future<void> _dolabiYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final kayitli = prefs.getStringList(_dolapKayitAnahtari) ?? [];
    if (!mounted) return;
    setState(() => _malzemeler = kayitli);
    if (kayitli.isNotEmpty) {
      _tarifleriEslestir();
    }
  }

  Future<void> _dolabiKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dolapKayitAnahtari, _malzemeler);
  }

  Future<void> _malzemeEkle() async {
    final parcalar = _malzemeController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (parcalar.isEmpty) return;

    bool degisti = false;
    for (final item in parcalar) {
      final zatenVar = _malzemeler.any(
        (m) => m.toLowerCase() == item.toLowerCase(),
      );
      if (!zatenVar) {
        _malzemeler.add(item);
        degisti = true;
      }
    }

    _malzemeController.clear();
    if (degisti) {
      setState(() {});
      await _dolabiKaydet();
      await _tarifleriEslestir();
    }
  }

  Future<void> _malzemeSil(String item) async {
    setState(() {
      _malzemeler.remove(item);
      if (_malzemeler.isEmpty) {
        _eslesenTarifler = [];
      }
    });
    await _dolabiKaydet();
    if (_malzemeler.isNotEmpty) {
      await _tarifleriEslestir();
    }
  }

  Future<void> _dolabiTemizle() async {
    setState(() {
      _malzemeler.clear();
      _eslesenTarifler = [];
    });
    await _dolabiKaydet();
  }

  Future<void> _tarifleriEslestir() async {
    if (_malzemeler.isEmpty) return;
    setState(() => _yukleniyor = true);
    try {
      final sonuc = await _apiServisi.malzemelereGoreTarifBul(_malzemeler);
      if (!mounted) return;
      setState(() => _eslesenTarifler = sonuc);
    } finally {
      if (mounted) {
        setState(() => _yukleniyor = false);
      }
    }
  }

  int _eslesenSayisi(Tarif tarif) {
    int sayac = 0;
    for (final dolapItem in _malzemeler) {
      final kucuk = dolapItem.toLowerCase();
      final varMi =
          tarif.etiketler.any((e) => e.toLowerCase().contains(kucuk)) ||
          tarif.malzemeler.any((m) => m.ad.toLowerCase().contains(kucuk));
      if (varMi) sayac++;
    }
    return sayac;
  }

  void _detayaGit(Tarif tarif) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TarifDetayEkrani(tarif: tarif)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final koyuTema = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.kitchen_rounded,
                      color: AppTheme.klasikKirmizi,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Dolapta Ne Var?',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_malzemeler.isNotEmpty)
                      TextButton(
                        onPressed: _dolabiTemizle,
                        child: const Text('Temizle'),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Elindeki malzemeleri yaz (virgülle ayırabilirsin), yapabileceğin tarifleri anında bul.',
                  style: TextStyle(
                    fontSize: 12,
                    color: koyuTema ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _malzemeController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _malzemeEkle(),
                        decoration: InputDecoration(
                          hintText: 'Örn: yumurta, tavuk, domates...',
                          isDense: true,
                          filled: true,
                          fillColor: koyuTema
                              ? AppTheme.koyuKirmiziYuzey
                              : AppTheme.acikKirmiziYuzey,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _malzemeEkle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.klasikKirmizi,
                        foregroundColor: AppTheme.safBeyaz,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Ekle'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Dolabındakiler (${_malzemeler.length})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (_malzemeler.isEmpty)
                  Text(
                    'Henüz malzeme eklemedin.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _malzemeler
                        .map(
                          (item) => Chip(
                            label: Text(
                              item,
                              style: const TextStyle(
                                color: AppTheme.safBeyaz,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: AppTheme.klasikKirmizi,
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 16,
                              color: AppTheme.safBeyaz,
                            ),
                            onDeleted: () => _malzemeSil(item),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (_malzemeler.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'Tarif önerilerini görmek için yukarıdan malzeme ekle.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else if (_yukleniyor)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 36),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.klasikKirmizi),
            ),
          )
        else if (_eslesenTarifler.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'Yazdığın malzemelerle eşleşen tarif bulunamadı.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'Eşleşen Tarifler (${_eslesenTarifler.length})',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          ..._eslesenTarifler.map((tarif) {
            final eslesen = _eslesenSayisi(tarif);
            final trBaslik = TurkceCevirici.yemekAdiCevir(tarif.baslik);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: InkWell(
                onTap: () => _detayaGit(tarif),
                child: Row(
                  children: [
                    if (tarif.gorselUrl.isNotEmpty)
                      Image.network(
                        tarif.gorselUrl,
                        width: 100,
                        height: 100,
                        cacheWidth: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _err, _stack) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.restaurant),
                        ),
                      )
                    else
                      Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.restaurant),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (eslesen > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$eslesen malzeme elinde var',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              trBaslik,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${tarif.besinDegerleri.kalori} kcal • ${tarif.sureDk} dk • ${tarif.pisirilisSekli}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}