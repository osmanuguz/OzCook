import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:klasik_lezzetler/data/turkce_cevirici.dart';
import 'package:klasik_lezzetler/data/veritabani_servisi.dart';
import 'package:klasik_lezzetler/models/tarif_model.dart';

List<Tarif> _hamVerileriTariflereDonustur(List<dynamic> hamYemekler) {
  final Map<String, Tarif> tarifHaritasi = {};

  for (final item in hamYemekler) {
    if (item is Map<String, dynamic>) {
      final tarif = TarifApiServisi.mealToTarifPublic(item);
      if (tarif.id.isNotEmpty) {
        tarifHaritasi[tarif.id] = tarif;
      }
    }
  }

  final liste = tarifHaritasi.values.toList();
  liste.sort(
    (a, b) => a.baslik.toLowerCase().compareTo(b.baslik.toLowerCase()),
  );
  return liste;
}

class TarifApiServisi {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static List<Tarif>? _onbellekTarifler;
  static Future<List<Tarif>>? _devamEdenIstek;

  static const Map<String, String> _trToEn = {
    'domates': 'tomato',
    'salatalik': 'cucumber',
    'salatalık': 'cucumber',
    'yumurta': 'egg',
    'biber': 'pepper',
    'sogan': 'onion',
    'soğan': 'onion',
    'kiyma': 'beef',
    'kıyma': 'beef',
    'et': 'beef',
    'tavuk': 'chicken',
    'patates': 'potato',
    'pirinc': 'rice',
    'pirinç': 'rice',
    'makarna': 'pasta',
    'peynir': 'cheese',
    'sarimsak': 'garlic',
    'sarımsak': 'garlic',
    'limon': 'lemon',
    'havuc': 'carrot',
    'havuç': 'carrot',
    'mantar': 'mushroom',
    'balık': 'salmon',
    'balik': 'salmon',
    'cikolata': 'chocolate',
    'çikolata': 'chocolate',
    'un': 'flour',
    'seker': 'sugar',
    'şeker': 'sugar',
    'sut': 'milk',
    'süt': 'milk',
    'muz': 'banana',
    'findik': 'hazelnut',
    'fındık': 'hazelnut',
    'elma': 'apple',
    'çilek': 'strawberry',
    'cilek': 'strawberry',
    'tatli': 'cake',
    'tatlı': 'cake',
    'kek': 'cake',
    'kurabiye': 'cookie',
    'çorba': 'soup',
    'corba': 'soup',
    'salata': 'salad',
    'kahvaltı': 'breakfast',
    'kahvalti': 'breakfast',
    'fırın': 'bake',
    'firin': 'bake',
    'ızgara': 'grill',
    'izgara': 'grill',
  };

  String _cevir(String metin) {
    final temiz = metin.trim().toLowerCase();
    return _trToEn[temiz] ?? temiz;
  }

  static String _pisirilisBelirle(
    String kategori,
    String talimat,
    List<String> malzemeler,
  ) {
    final birlesik = '$kategori $talimat ${malzemeler.join(' ')}'.toLowerCase();
    if (birlesik.contains('bake') ||
        birlesik.contains('oven') ||
        birlesik.contains('roast') ||
        birlesik.contains('fırın')) {
      return 'Fırın';
    }
    if (birlesik.contains('salad') ||
        birlesik.contains('chill') ||
        birlesik.contains('refrigerate') ||
        birlesik.contains('no cook') ||
        birlesik.contains('salata')) {
      return 'Pişirmesiz';
    }
    return 'Ocak';
  }

  bool kategoriEslestiMi(Tarif tarif, String seciliKategori) {
    if (seciliKategori == 'Tümü') return true;
    final kat = tarif.kategori.toLowerCase();
    final baslik = tarif.baslik.toLowerCase();
    final etiketler = tarif.etiketler.join(' ');

    if (seciliKategori == 'Kahvaltılık') {
      return kat.contains('kahvaltı') ||
          kat.contains('breakfast') ||
          baslik.contains('egg') ||
          baslik.contains('yumurta') ||
          baslik.contains('omlet') ||
          baslik.contains('pankek');
    }
    if (seciliKategori == 'Salata') {
      return kat.contains('salata') ||
          kat.contains('salad') ||
          baslik.contains('salata') ||
          baslik.contains('salad') ||
          etiketler.contains('lettuce') ||
          etiketler.contains('cucumber');
    }
    if (seciliKategori == 'Tatlı') {
      return kat.contains('tatlı') ||
          kat.contains('dessert') ||
          baslik.contains('kek') ||
          baslik.contains('cake') ||
          baslik.contains('turta') ||
          baslik.contains('kurabiye') ||
          baslik.contains('çikolata');
    }
    return true;
  }

  Future<List<Tarif>> tumTarifleriGetir({bool zorlaYenile = false}) async {
    if (!zorlaYenile &&
        _onbellekTarifler != null &&
        _onbellekTarifler!.isNotEmpty) {
      return _onbellekTarifler!;
    }

    if (!zorlaYenile && _devamEdenIstek != null) {
      return _devamEdenIstek!;
    }

    _devamEdenIstek = _tarifleriAgdanCek();
    try {
      final sonuc = await _devamEdenIstek!;
      if (sonuc.isNotEmpty) {
        _onbellekTarifler = sonuc;
      }
      return sonuc;
    } finally {
      _devamEdenIstek = null;
    }
  }

  Future<List<Tarif>> _tarifleriAgdanCek() async {
    const alfabe = 'abcdefghijklmnopqrstuvwxyz';
    final harfler = alfabe.split('');
    final List<dynamic> tumHamYemekler = [];

    const grupBoyutu = 7;
    for (int i = 0; i < harfler.length; i += grupBoyutu) {
      final grup = harfler.skip(i).take(grupBoyutu);
      await Future.wait(
        grup.map((harf) async {
          try {
            final res = await http
                .get(Uri.parse('$_baseUrl/search.php?f=$harf'))
                .timeout(const Duration(seconds: 4));
            if (res.statusCode == 200) {
              final decoded = jsonDecode(res.body);
              if (decoded is Map<String, dynamic>) {
                final meals = decoded['meals'];
                if (meals is List) {
                  tumHamYemekler.addAll(meals);
                }
              }
            }
          } catch (_) {}
        }),
      );
    }

    if (tumHamYemekler.isEmpty) {
      try {
        return await VeritabaniServisi().indirilenTarifleriGetir();
      } catch (_) {
        return [];
      }
    }

    return await compute(_hamVerileriTariflereDonustur, tumHamYemekler);
  }

  Future<List<Tarif>> malzemelereGoreTarifBul(
    List<String> kelimeler, {
    String pisirilisSekli = 'Tümü',
  }) async {
    final temizKelimeler = kelimeler
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();

    List<Tarif> adayListe;

    if (temizKelimeler.isEmpty) {
      adayListe = await tumTarifleriGetir();
    } else {
      final Set<String> adayIdler = {};
      final Map<String, Tarif> bulunanTarifler = {};

      for (final kelime in temizKelimeler) {
        final enKelime = _cevir(kelime);

        try {
          final filterRes = await http
              .get(
                Uri.parse(
                  '$_baseUrl/filter.php?i=${Uri.encodeComponent(enKelime)}',
                ),
              )
              .timeout(const Duration(seconds: 5));
          if (filterRes.statusCode == 200) {
            final decoded = jsonDecode(filterRes.body);
            if (decoded is Map<String, dynamic>) {
              final meals = decoded['meals'];
              if (meals is List) {
                for (final m in meals.take(15)) {
                  if (m is Map) {
                    final id = m['idMeal']?.toString();
                    if (id != null && id.isNotEmpty) adayIdler.add(id);
                  }
                }
              }
            }
          }
        } catch (_) {}

        try {
          final searchRes = await http
              .get(
                Uri.parse(
                  '$_baseUrl/search.php?s=${Uri.encodeComponent(enKelime)}',
                ),
              )
              .timeout(const Duration(seconds: 5));
          if (searchRes.statusCode == 200) {
            final decoded = jsonDecode(searchRes.body);
            if (decoded is Map<String, dynamic>) {
              final meals = decoded['meals'];
              if (meals is List) {
                for (final m in meals.take(15)) {
                  if (m is Map<String, dynamic>) {
                    final t = mealToTarifPublic(m);
                    bulunanTarifler[t.id] = t;
                  }
                }
              }
            }
          }
        } catch (_) {}
      }

      final eksikIdler = adayIdler
          .where((id) => !bulunanTarifler.containsKey(id))
          .take(25)
          .toList();

      await Future.wait(
        eksikIdler.map((id) async {
          final detay = await _detayGetir(id);
          if (detay != null) {
            bulunanTarifler[detay.id] = detay;
          }
        }),
      );

      adayListe = bulunanTarifler.values.toList();
      adayListe.sort((a, b) {
        int skorA = 0;
        int skorB = 0;
        for (final k in temizKelimeler) {
          final en = _cevir(k);
          final metinA =
              '${a.baslik} ${a.kategori} ${a.etiketler.join(' ')}'.toLowerCase();
          final metinB =
              '${b.baslik} ${b.kategori} ${b.etiketler.join(' ')}'.toLowerCase();
          if (metinA.contains(k) || metinA.contains(en)) skorA++;
          if (metinB.contains(k) || metinB.contains(en)) skorB++;
        }
        return skorB.compareTo(skorA);
      });
    }

    if (pisirilisSekli != 'Tümü') {
      adayListe = adayListe
          .where(
            (t) => t.pisirilisSekli.toLowerCase() == pisirilisSekli.toLowerCase(),
          )
          .toList();
    }

    return adayListe;
  }

  Future<Tarif?> _detayGetir(String id) async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/lookup.php?i=$id'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return null;
      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) return null;
      final meals = decoded['meals'];
      if (meals is! List || meals.isEmpty) return null;
      final first = meals.first;
      if (first is! Map<String, dynamic>) return null;
      return mealToTarifPublic(first);
    } catch (_) {
      return null;
    }
  }

  static Tarif mealToTarifPublic(Map<String, dynamic> json) {
    final List<Malzeme> malzemeler = [];
    final List<String> etiketler = [];

    for (int i = 1; i <= 20; i++) {
      final hamAd = (json['strIngredient$i'] ?? '').toString().trim();
      final hamMiktar = (json['strMeasure$i'] ?? '').toString().trim();
      if (hamAd.isNotEmpty) {
        final cevrilenAd = TurkceCevirici.malzemeCevir(hamAd);
        malzemeler.add(
          Malzeme(
            ad: cevrilenAd,
            miktar: hamMiktar.isEmpty ? 'Yeterince' : hamMiktar,
          ),
        );
        etiketler.add(hamAd.toLowerCase());
        etiketler.add(cevrilenAd.toLowerCase());
      }
    }

    final hamKategori = (json['strCategory'] ?? 'Genel').toString();
    final kategori = TurkceCevirici.kategoriCevir(hamKategori);
    final hamBaslik = (json['strMeal'] ?? 'İsimsiz Tarif').toString();
    final baslik = TurkceCevirici.yemekAdiCevir(hamBaslik);

    final rawTalimat = (json['strInstructions'] ?? '').toString();
    final adimlar = rawTalimat
        .split(RegExp(r'\r?\n|\.\s+'))
        .map((e) => e.trim())
        .where((e) => e.length > 3)
        .map(TurkceCevirici.yapilisAdimiCevir)
        .toList();

    final pisirilis = _pisirilisBelirle(hamKategori, rawTalimat, etiketler);
    final sayi = malzemeler.isEmpty ? 4 : malzemeler.length;
    final kalori = (180 + sayi * 40).clamp(200, 900);
    final protein = double.parse((sayi * 3.2).toStringAsFixed(1));
    final karb = double.parse((sayi * 5.0).toStringAsFixed(1));
    final yag = double.parse((sayi * 2.7).toStringAsFixed(1));

    return Tarif(
      id: (json['idMeal'] ?? '').toString(),
      baslik: baslik,
      kategori: kategori,
      pisirilisSekli: pisirilis,
      sureDk: (15 + sayi * 3).clamp(15, 90),
      porsiyon: 2,
      gorselUrl: (json['strMealThumb'] ?? '').toString(),
      videoUrl: (json['strYoutube'] ?? '').toString(),
      besinDegerleri: BesinDegerleri(
        kalori: kalori,
        protein: protein,
        karbonhidrat: karb,
        yag: yag,
      ),
      malzemeler: malzemeler,
      etiketler: etiketler,
      yapilis: adimlar.isEmpty ? ['Hazırlanış adımı bulunamadı.'] : adimlar,
    );
  }
}