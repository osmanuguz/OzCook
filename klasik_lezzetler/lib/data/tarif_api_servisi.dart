import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:klasik_lezzetler/data/ceviri_servisi.dart';
import 'package:klasik_lezzetler/data/turkce_cevirici.dart';
import 'package:klasik_lezzetler/data/veritabani_servisi.dart';
import 'package:klasik_lezzetler/models/tarif_model.dart';

class _BesinHesapSonucu {
  final int kalori;
  final double protein;
  final double karbonhidrat;
  final double yag;

  const _BesinHesapSonucu({
    required this.kalori,
    required this.protein,
    required this.karbonhidrat,
    required this.yag,
  });
}

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

  static double _miktarKatsayisi(String miktar) {
    final temiz = miktar.trim().toLowerCase();
    if (temiz.isEmpty || temiz == 'yeterince') return 1.0;

    final kesirEslesme = RegExp(r'(\d+)\s*/\s*(\d+)').firstMatch(temiz);
    double deger = 1.0;

    if (kesirEslesme != null) {
      final pay = double.tryParse(kesirEslesme.group(1)!) ?? 1;
      final payda = double.tryParse(kesirEslesme.group(2)!) ?? 1;
      if (payda != 0) {
        deger = pay / payda;
      }
    } else {
      final sayiEslesme = RegExp(r'(\d+(?:[.,]\d+)?)').firstMatch(temiz);
      if (sayiEslesme != null) {
        final hamSayi =
            double.tryParse(sayiEslesme.group(1)!.replaceAll(',', '.'));
        if (hamSayi != null && hamSayi > 0) {
          deger = hamSayi > 30 ? (hamSayi / 100.0) : hamSayi;
        }
      }
    }

    return deger.clamp(0.4, 2.5);
  }

  static bool _kelimeIceriyorMu(String metin, List<String> anahtarlar) {
    for (final kelime in anahtarlar) {
      if (metin.contains(kelime)) return true;
    }
    return false;
  }

  static _BesinHesapSonucu _besinDegerleriniHesapla({
    required String kategori,
    required List<Malzeme> malzemeler,
    int porsiyon = 2,
  }) {
    final porsiyonSayisi = porsiyon <= 0 ? 1 : porsiyon;
    final kat = kategori.toLowerCase().trim();

    double protein = 14.0;
    double karb = 30.0;
    double yag = 11.0;

    if (kat.contains('beef') ||
        kat.contains('lamb') ||
        kat.contains('pork') ||
        kat.contains('dana') ||
        kat.contains('kuzu') ||
        kat.contains('et')) {
      protein = 26.0;
      karb = 18.0;
      yag = 17.0;
    } else if (kat.contains('chicken') ||
        kat.contains('seafood') ||
        kat.contains('tavuk') ||
        kat.contains('deniz') ||
        kat.contains('balık')) {
      protein = 25.0;
      karb = 16.0;
      yag = 11.0;
    } else if (kat.contains('pasta') ||
        kat.contains('rice') ||
        kat.contains('makarna') ||
        kat.contains('pilav')) {
      protein = 12.0;
      karb = 46.0;
      yag = 10.0;
    } else if (kat.contains('dessert') ||
        kat.contains('baking') ||
        kat.contains('tatlı')) {
      protein = 6.0;
      karb = 52.0;
      yag = 17.0;
    } else if (kat.contains('vegetarian') ||
        kat.contains('vegan') ||
        kat.contains('vejetaryen') ||
        kat.contains('vegan')) {
      protein = 15.0;
      karb = 32.0;
      yag = 10.5;
    } else if (kat.contains('breakfast') || kat.contains('kahvaltı')) {
      protein = 15.0;
      karb = 28.0;
      yag = 12.5;
    }

    for (final m in malzemeler) {
      final ad = m.ad.toLowerCase();
      final miktar = m.miktar.toLowerCase();
      final katsayi = _miktarKatsayisi(miktar);

      if (_kelimeIceriyorMu(ad, [
        'chicken',
        'beef',
        'steak',
        'lamb',
        'pork',
        'fish',
        'salmon',
        'tuna',
        'shrimp',
        'prawn',
        'egg',
        'tofu',
        'lentil',
        'chickpea',
        'bean',
        'cheese',
        'yogurt',
        'milk',
        'tavuk',
        'et',
        'kıyma',
        'balık',
        'somon',
        'yumurta',
        'peynir',
        'yoğurt',
        'süt',
        'mercimek',
        'nohut',
      ])) {
        protein += 5.0 * katsayi;
        yag += 1.4 * katsayi;
      }

      if (_kelimeIceriyorMu(ad, [
        'rice',
        'pasta',
        'spaghetti',
        'noodle',
        'flour',
        'bread',
        'potato',
        'sugar',
        'honey',
        'corn',
        'oat',
        'pirinç',
        'makarna',
        'un',
        'ekmek',
        'patates',
        'şeker',
        'bal',
        'mısır',
        'yulaf',
      ])) {
        karb += 6.5 * katsayi;
      }

      if (_kelimeIceriyorMu(ad, [
        'oil',
        'olive oil',
        'butter',
        'ghee',
        'cream',
        'mayo',
        'walnut',
        'almond',
        'hazelnut',
        'peanut',
        'avocado',
        'yağ',
        'zeytinyağı',
        'tereyağı',
        'krema',
        'ceviz',
        'fındık',
        'badem',
        'avokado',
      ])) {
        yag += 4.5 * katsayi;
      }
    }

    final pProtein = (protein / porsiyonSayisi).clamp(3.0, 75.0);
    final pKarb = (karb / porsiyonSayisi).clamp(5.0, 120.0);
    final pYag = (yag / porsiyonSayisi).clamp(2.0, 65.0);

    final kalori = ((pProtein * 4) + (pKarb * 4) + (pYag * 9))
        .round()
        .clamp(90, 1400);

    return _BesinHesapSonucu(
      kalori: kalori,
      protein: double.parse(pProtein.toStringAsFixed(1)),
      karbonhidrat: double.parse(pKarb.toStringAsFixed(1)),
      yag: double.parse(pYag.toStringAsFixed(1)),
    );
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

  Future<Tarif> tarifiTurkceyeCevir(Tarif tarif) async {
    final yerelBaslik = TurkceCevirici.yemekAdiCevir(tarif.baslik);
    final yerelMalzemeler = tarif.malzemeler
        .map(
          (m) => Malzeme(
            ad: TurkceCevirici.malzemeCevir(m.ad),
            miktar: TurkceCevirici.miktarCevir(m.miktar),
          ),
        )
        .toList();

    String sonBaslik = yerelBaslik;
    try {
      final ceviriBaslik = await CeviriServisi.yemekAdiCevir(tarif.baslik);
      if (ceviriBaslik.trim().isNotEmpty) {
        sonBaslik = ceviriBaslik.trim();
      }
    } catch (_) {}

    List<Malzeme> sonMalzemeler = yerelMalzemeler;
    try {
      if (tarif.malzemeler.isNotEmpty) {
        final cevrilenAdlar = await Future.wait(
          tarif.malzemeler.take(12).map((m) => CeviriServisi.malzemeCevir(m.ad)),
        );
        if (cevrilenAdlar.length == tarif.malzemeler.length) {
          sonMalzemeler = List.generate(tarif.malzemeler.length, (i) {
            final trAd = cevrilenAdlar[i].trim();
            return Malzeme(
              ad: trAd.isNotEmpty ? trAd : yerelMalzemeler[i].ad,
              miktar: yerelMalzemeler[i].miktar,
            );
          });
        }
      }
    } catch (_) {}

    List<String> sonYapilis = List<String>.from(tarif.yapilis);
    try {
      if (tarif.yapilis.isNotEmpty) {
        final cevrilenAdimlar = await Future.wait(
          tarif.yapilis.map((adim) => CeviriServisi.adimCevir(adim)),
        );
        if (cevrilenAdimlar.length == tarif.yapilis.length) {
          sonYapilis = cevrilenAdimlar;
        }
      }
    } catch (_) {}

    return Tarif(
      id: tarif.id,
      baslik: sonBaslik,
      kategori: TurkceCevirici.kategoriCevir(tarif.kategori),
      pisirilisSekli: tarif.pisirilisSekli,
      sureDk: tarif.sureDk,
      porsiyon: tarif.porsiyon,
      gorselUrl: tarif.gorselUrl,
      videoUrl: tarif.videoUrl,
      besinDegerleri: tarif.besinDegerleri,
      malzemeler: sonMalzemeler,
      etiketler: tarif.etiketler,
      yapilis: sonYapilis,
      indirildiMi: tarif.indirildiMi,
    );
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
            miktar: hamMiktar.isEmpty
                ? 'Yeterince'
                : TurkceCevirici.miktarCevir(hamMiktar),
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
        .toList();

    final pisirilis = _pisirilisBelirle(hamKategori, rawTalimat, etiketler);
    final sayi = malzemeler.isEmpty ? 4 : malzemeler.length;
    const porsiyon = 2;

    final makro = _besinDegerleriniHesapla(
      kategori: kategori,
      malzemeler: malzemeler,
      porsiyon: porsiyon,
    );

    return Tarif(
      id: (json['idMeal'] ?? '').toString(),
      baslik: baslik,
      kategori: kategori,
      pisirilisSekli: pisirilis,
      sureDk: (15 + sayi * 3).clamp(15, 90),
      porsiyon: porsiyon,
      gorselUrl: (json['strMealThumb'] ?? '').toString(),
      videoUrl: (json['strYoutube'] ?? '').toString(),
      besinDegerleri: BesinDegerleri(
        kalori: makro.kalori,
        protein: makro.protein,
        karbonhidrat: makro.karbonhidrat,
        yag: makro.yag,
      ),
      malzemeler: malzemeler,
      etiketler: etiketler,
      yapilis: adimlar.isEmpty ? ['Hazırlanış adımı bulunamadı.'] : adimlar,
    );
  }
}