import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:klasik_lezzetler/services/ai_servisi.dart';
import 'package:klasik_lezzetler/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef MesajItem = Map<String, String>;

const String _haftalikPlanAnahtari = 'ozcook_haftalik_plan';

const List<String> _gunler = [
  'Pazartesi',
  'Salı',
  'Çarşamba',
  'Perşembe',
  'Cuma',
  'Cumartesi',
  'Pazar',
];

const List<String> _modlar = [
  'Genel',
  'KYK Yurt',
  'OzFit',
  'OzHealth',
];

const List<String> _hizliSorular = [
  'Elimde yumurta, yoğurt ve yulaf var; pratik ne yapabilirim?',
  'KYK yurdunda kettle ile yüksek proteinli akşam yemeği öner',
  'Kalan kalorime göre hafif bir akşam öğünü söyle',
];

class AiPlanlayiciEkrani extends StatefulWidget {
  final int alinanKalori;
  final int kaloriHedefi;

  const AiPlanlayiciEkrani({
    super.key,
    this.alinanKalori = 0,
    this.kaloriHedefi = 2000,
  });

  @override
  State<AiPlanlayiciEkrani> createState() => _AiPlanlayiciEkraniState();
}

class _AiPlanlayiciEkraniState extends State<AiPlanlayiciEkrani> {
  String _altSekme = 'asistan';
  String _seciliMod = 'Genel';

  final TextEditingController _soruKontrol = TextEditingController();
  final ScrollController _sohbetScroll = ScrollController();
  final List<MesajItem> _mesajlar = [
    {
      'rol': 'asistan',
      'metin':
          'Selam! Ben Ozcook Mutfak Asistanı. Elindeki malzemeleri yazabilir, kalori tahmini isteyebilir veya moduna göre tarif sorabilirsin.',
    },
  ];
  bool _asistanYukleniyor = false;

  final TextEditingController _planNotuKontrol = TextEditingController();
  JsonMap? _haftalikPlan;
  bool _planYukleniyor = false;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _kayitliPlaniYukle();
  }

  @override
  void dispose() {
    _soruKontrol.dispose();
    _sohbetScroll.dispose();
    _planNotuKontrol.dispose();
    super.dispose();
  }

  Future<void> _kayitliPlaniYukle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ham = prefs.getString(_haftalikPlanAnahtari);
      if (ham != null && ham.isNotEmpty && mounted) {
        setState(() {
          _haftalikPlan = jsonDecode(ham) as JsonMap;
        });
      }
    } catch (_) {
      // Bozuk kayıt varsa yoksay
    }
  }

  Future<void> _planiKaydet(JsonMap? yeniPlan) async {
    setState(() => _haftalikPlan = yeniPlan);
    final prefs = await SharedPreferences.getInstance();
    if (yeniPlan == null) {
      await prefs.remove(_haftalikPlanAnahtari);
    } else {
      await prefs.setString(_haftalikPlanAnahtari, jsonEncode(yeniPlan));
    }
  }

  void _asagiKaydir() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sohbetScroll.hasClients) {
        _sohbetScroll.animateTo(
          _sohbetScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _soruGonder([String? metinOverride]) async {
    final icerik = (metinOverride ?? _soruKontrol.text).trim();
    if (icerik.isEmpty || _asistanYukleniyor) return;

    setState(() {
      _hata = null;
      _soruKontrol.clear();
      _mesajlar.add({'rol': 'kullanici', 'metin': icerik});
      _asistanYukleniyor = true;
    });
    _asagiKaydir();

    try {
      final yanit = await AiServisi.mutfakAsistaniSor(
        icerik,
        alinanKalori: widget.alinanKalori,
        kaloriHedefi: widget.kaloriHedefi,
        mod: _seciliMod,
      );
      if (!mounted) return;
      setState(() {
        _mesajlar.add({'rol': 'asistan', 'metin': yanit});
      });
      _asagiKaydir();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hata = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _asistanYukleniyor = false);
      }
    }
  }

  Future<void> _planOlustur() async {
    if (_planYukleniyor) return;
    setState(() {
      _hata = null;
      _planYukleniyor = true;
    });

    try {
      final yeniPlan = await AiServisi.haftalikPlanOlustur(
        mod: _seciliMod,
        kaloriHedefi: widget.kaloriHedefi,
        not: _planNotuKontrol.text.trim(),
      );
      if (!mounted) return;
      await _planiKaydet(yeniPlan);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hata = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _planYukleniyor = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final koyuTema = Theme.of(context).brightness == Brightness.dark;
    final kartRengi = koyuTema
        ? const Color(0xFF1C1C1E).withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.92);
    final ikincilArkaPlan =
        koyuTema ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kartRengi,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.klasikKirmizi.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _sekmeButonu(
                      baslik: 'Mutfak Asistanı',
                      ikon: Icons.restaurant_menu_rounded,
                      secili: _altSekme == 'asistan',
                      ikincilArkaPlan: ikincilArkaPlan,
                      onTap: () => setState(() => _altSekme = 'asistan'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _sekmeButonu(
                      baslik: 'Haftalık Plan',
                      ikon: Icons.calendar_month_rounded,
                      secili: _altSekme == 'plan',
                      ikincilArkaPlan: ikincilArkaPlan,
                      onTap: () => setState(() => _altSekme = 'plan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      'Mod: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: koyuTema ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    ..._modlar.map((m) {
                      final secili = _seciliMod == m;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            m,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: secili
                                  ? Colors.white
                                  : (koyuTema ? Colors.white70 : Colors.black87),
                            ),
                          ),
                          selected: secili,
                          selectedColor: AppTheme.klasikKirmizi,
                          backgroundColor: ikincilArkaPlan,
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                          onSelected: (_) => setState(() => _seciliMod = m),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_hata != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
            ),
            child: Text(
              _hata!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: koyuTema ? Colors.red.shade200 : AppTheme.klasikKirmizi,
              ),
            ),
          ),
        Expanded(
          child: _altSekme == 'asistan'
              ? _asistanGorunumu(kartRengi, ikincilArkaPlan, koyuTema)
              : _planGorunumu(kartRengi, ikincilArkaPlan, koyuTema),
        ),
      ],
    );
  }

  Widget _sekmeButonu({
    required String baslik,
    required IconData ikon,
    required bool secili,
    required Color ikincilArkaPlan,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: secili ? AppTheme.klasikKirmizi : ikincilArkaPlan,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              ikon,
              size: 16,
              color: secili ? Colors.white : null,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                baslik,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: secili ? Colors.white : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _asistanGorunumu(
    Color kartRengi,
    Color ikincilArkaPlan,
    bool koyuTema,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kartRengi,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.klasikKirmizi.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _hizliSorular.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final soru = _hizliSorular[index];
                return ActionChip(
                  label: Text(
                    soru,
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: ikincilArkaPlan,
                  side: BorderSide.none,
                  onPressed:
                      _asistanYukleniyor ? null : () => _soruGonder(soru),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              controller: _sohbetScroll,
              itemCount: _mesajlar.length + (_asistanYukleniyor ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _mesajlar.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.klasikKirmizi,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Asistan yanıt hazırlıyor...',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                final mesaj = _mesajlar[index];
                final kullaniciMi = mesaj['rol'] == 'kullanici';

                return Align(
                  alignment: kullaniciMi
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: kullaniciMi
                          ? AppTheme.klasikKirmizi
                          : ikincilArkaPlan,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      mesaj['metin'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: kullaniciMi
                            ? Colors.white
                            : (koyuTema ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _soruKontrol,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _soruGonder(),
                  decoration: InputDecoration(
                    hintText: 'Malzemelerini veya sorunu yaz...',
                    hintStyle: const TextStyle(fontSize: 13),
                    filled: true,
                    fillColor: ikincilArkaPlan,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _asistanYukleniyor ? null : () => _soruGonder(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.klasikKirmizi,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Icon(Icons.send_rounded, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _planGorunumu(
    Color kartRengi,
    Color ikincilArkaPlan,
    bool koyuTema,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kartRengi,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.klasikKirmizi.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '7 Günlük Yapay Zeka Planı',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hedef: ~${widget.kaloriHedefi} kcal • Mod: $_seciliMod',
                          style: TextStyle(
                            fontSize: 12,
                            color: koyuTema ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_haftalikPlan != null)
                    IconButton(
                      tooltip: 'Planı Temizle',
                      onPressed: () => _planiKaydet(null),
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _planNotuKontrol,
                decoration: InputDecoration(
                  hintText: 'Ek not (ör. tavuk ağırlıklı, bütçe dostu...)',
                  hintStyle: const TextStyle(fontSize: 12),
                  filled: true,
                  fillColor: ikincilArkaPlan,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _planYukleniyor ? null : _planOlustur,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.klasikKirmizi,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _planYukleniyor
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: Text(
                    _planYukleniyor
                        ? 'Oluşturuluyor...'
                        : '7 Günlük Plan Oluştur',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_haftalikPlan == null)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kartRengi,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'Henüz haftalık planın yok. Yukarıdan modunu seçip "7 Günlük Plan Oluştur" butonuna basabilirsin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: koyuTema ? Colors.white60 : Colors.black54,
              ),
            ),
          )
        else
          ..._gunler.map((gun) {
            final gunVerisi = _haftalikPlan![gun] as JsonMap?;
            if (gunVerisi == null) return const SizedBox.shrink();

            final kahvalti = gunVerisi['kahvalti'] as JsonMap?;
            final ogle = gunVerisi['ogle'] as JsonMap?;
            final aksam = gunVerisi['aksam'] as JsonMap?;

            final toplamKalori = ((kahvalti?['kalori'] ?? 0) as num).toInt() +
                ((ogle?['kalori'] ?? 0) as num).toInt() +
                ((aksam?['kalori'] ?? 0) as num).toInt();

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kartRengi,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.klasikKirmizi.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        gun,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.klasikKirmizi,
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
                        child: Text(
                          '$toplamKalori kcal',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.klasikKirmizi,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _ogunSatiri('Kahvaltı', kahvalti, ikincilArkaPlan),
                  const SizedBox(height: 6),
                  _ogunSatiri('Öğle', ogle, ikincilArkaPlan),
                  const SizedBox(height: 6),
                  _ogunSatiri('Akşam', aksam, ikincilArkaPlan),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _ogunSatiri(
    String etiket,
    JsonMap? veri,
    Color arkaPlan,
  ) {
    final ad = veri?['ad']?.toString() ?? '-';
    final kalori = veri?['kalori']?.toString() ?? '0';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: arkaPlan,
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
          children: [
            TextSpan(
              text: '$etiket: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ad),
            TextSpan(
              text: ' ($kalori kcal)',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}