import 'package:flutter/material.dart';
import 'package:klasik_lezzetler/data/tarif_api_servisi.dart';
import 'package:klasik_lezzetler/data/veritabani_servisi.dart';
import 'package:klasik_lezzetler/models/tarif_model.dart';
import 'package:klasik_lezzetler/screens/tarif_detay_ekrani.dart';
import 'package:klasik_lezzetler/theme/app_theme.dart';

class EvdeNeVarEkrani extends StatefulWidget {
  const EvdeNeVarEkrani({super.key});

  @override
  State<EvdeNeVarEkrani> createState() => _EvdeNeVarEkraniState();
}

class _EvdeNeVarEkraniState extends State<EvdeNeVarEkrani> {
  static const List<String> _pisirilisSecenekleri = [
    'Tümü',
    'Fırın',
    'Ocak',
    'Pişirmesiz',
  ];

  final TextEditingController _controller = TextEditingController();
  final TarifApiServisi _apiServisi = TarifApiServisi();

  final List<String> _secilenler = [];
  String _seciliPisirilis = 'Tümü';
  List<Tarif> _sonuclar = [];
  bool _yukleniyor = false;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _ara();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ekle(String deger) {
    final parcalar = deger
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty);

    if (parcalar.isEmpty) return;

    setState(() {
      for (final p in parcalar) {
        if (!_secilenler.contains(p)) {
          _secilenler.add(p);
        }
      }
      _controller.clear();
    });
    _ara();
  }

  Future<void> _ara() async {
    final anlikMetin = _controller.text.trim().toLowerCase();
    final aramaListesi = [
      ..._secilenler,
      if (anlikMetin.isNotEmpty) ...anlikMetin.split(',').map((e) => e.trim()),
    ].where((e) => e.isNotEmpty).toList();

    setState(() {
      _yukleniyor = true;
      _hata = null;
    });

    try {
      final indirilenIdler = await VeritabaniServisi().indirilenIdleriGetir();
      final liste = await _apiServisi.malzemelereGoreTarifBul(
        aramaListesi,
        pisirilisSekli: _seciliPisirilis,
      );
      for (final t in liste) {
        t.indirildiMi = indirilenIdler.contains(t.id);
      }

      if (!mounted) return;
      setState(() {
        _sonuclar = liste;
        _yukleniyor = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hata = 'Tarifler alınamadı. İnternet bağlantını kontrol et.';
        _yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Evde Ne Var?', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          const Text(
            'Malzeme, yemek veya tatlı yaz; pişiriliş şekline göre filtreleyerek tarifleri bul.',
          ),
          const SizedBox(height: 12),
          const Text(
            'Pişiriliş Şekli',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _pisirilisSecenekleri.map((secenek) {
              final secili = _seciliPisirilis == secenek;
              return ChoiceChip(
                label: Text(secenek),
                selected: secili,
                selectedColor: AppTheme.klasikKirmizi,
                labelStyle: TextStyle(
                  color: secili ? AppTheme.safBeyaz : AppTheme.koyuMetin,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) {
                  setState(() => _seciliPisirilis = secenek);
                  _ara();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _ekle,
                  decoration: InputDecoration(
                    hintText: 'İstediğini yaz (örn: çikolata, tavuk, domates)...',
                    filled: true,
                    fillColor: AppTheme.safBeyaz,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _ekle(_controller.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.klasikKirmizi,
                  foregroundColor: AppTheme.safBeyaz,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                child: const Text('Ekle'),
              ),
            ],
          ),
          if (_secilenler.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _secilenler
                  .map(
                    (item) => Chip(
                      label: Text(item),
                      backgroundColor: AppTheme.klasikKirmizi.withValues(alpha: 0.12),
                      deleteIconColor: AppTheme.klasikKirmizi,
                      onDeleted: () {
                        setState(() => _secilenler.remove(item));
                        _ara();
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _ara,
              icon: const Icon(Icons.search),
              label: const Text('Tarifleri Ara'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.klasikKirmizi,
                foregroundColor: AppTheme.safBeyaz,
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_yukleniyor)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppTheme.klasikKirmizi),
              ),
            )
          else if (_hata != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_hata!),
              ),
            )
          else if (_sonuclar.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Bu kriterlerle eşleşen tarif bulunamadı.'),
              ),
            )
          else
            ..._sonuclar.map(
              (tarif) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: tarif.gorselUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            tarif.gorselUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _err, _stack) => const Icon(
                              Icons.restaurant,
                              color: AppTheme.klasikKirmizi,
                            ),
                          ),
                        )
                      : const Icon(Icons.restaurant, color: AppTheme.klasikKirmizi),
                  title: Text(
                    tarif.baslik,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                  ),
                  subtitle: Text(
                    '${tarif.kategori} • ${tarif.pisirilisSekli} • ${tarif.besinDegerleri.kalori} kcal • ${tarif.sureDk} dk'
                    '${tarif.videoUrl.isNotEmpty ? ' • Videolu' : ''}',
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppTheme.klasikKirmizi),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TarifDetayEkrani(tarif: tarif)),
                    );
                    _ara();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}