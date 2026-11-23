import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:klasik_lezzetler/data/turkce_cevirici.dart';

class CeviriServisi {
  static final Map<String, String> _onbellek = {};
  static final Map<String, Future<String>> _devamEdenIstekler = {};

  static bool _gecerliCeviriMi(String orijinal, String ceviri) {
    final temiz = ceviri.trim();
    if (temiz.isEmpty) return false;

    final kucuk = temiz.toLowerCase();
    if (kucuk.contains('mymemory warning') ||
        kucuk.contains('query length limit') ||
        kucuk.contains('invalid language pair') ||
        kucuk.contains('too many requests')) {
      return false;
    }

    if (orijinal.length > 8 && temiz.toUpperCase() == temiz) {
      return false;
    }

    return true;
  }

  static Future<String> ingilizcedenTurkceye(
    String metin, {
    required String turEtiketi,
    String Function(String)? yedekCevirici,
  }) async {
    final temiz = metin.trim();
    if (temiz.isEmpty) return temiz;

    final onbellekAnahtari = '$turEtiketi:$temiz';
    final onbellekteki = _onbellek[onbellekAnahtari];
    if (onbellekteki != null) {
      return onbellekteki;
    }

    final devamEden = _devamEdenIstekler[onbellekAnahtari];
    if (devamEden != null) {
      return devamEden;
    }

    final future = _ceviriCalistir(
      temiz,
      onbellekAnahtari: onbellekAnahtari,
      yedekCevirici: yedekCevirici,
    );
    _devamEdenIstekler[onbellekAnahtari] = future;

    try {
      return await future;
    } finally {
      _devamEdenIstekler.remove(onbellekAnahtari);
    }
  }

  static Future<String> _ceviriCalistir(
    String temiz, {
    required String onbellekAnahtari,
    String Function(String)? yedekCevirici,
  }) async {
    final yerelYedek = yedekCevirici != null ? yedekCevirici(temiz) : temiz;

    try {
      final parcalar = _metniParcala(temiz, maxUzunluk: 460);
      final cevrilenParcalar = <String>[];

      for (final parca in parcalar) {
        final parcaYedek =
            yedekCevirici != null ? yedekCevirici(parca) : parca;

        try {
          final uri = Uri.parse(
            'https://api.mymemory.translated.net/get'
            '?q=${Uri.encodeComponent(parca)}&langpair=en|tr',
          );

          final res =
              await http.get(uri).timeout(const Duration(milliseconds: 2200));
          if (res.statusCode == 200) {
            final decoded = jsonDecode(res.body);
            if (decoded is Map<String, dynamic>) {
              final responseData = decoded['responseData'];
              if (responseData is Map<String, dynamic>) {
                final ceviri =
                    responseData['translatedText']?.toString().trim();
                if (ceviri != null && _gecerliCeviriMi(parca, ceviri)) {
                  cevrilenParcalar.add(ceviri);
                  continue;
                }
              }
            }
          }
        } catch (_) {}

        cevrilenParcalar.add(parcaYedek);
      }

      final birlesik =
          cevrilenParcalar.join(' ').replaceAll(RegExp(r'[ \t]+'), ' ').trim();
      final sonuc = birlesik.isNotEmpty ? birlesik : yerelYedek;

      _onbellek[onbellekAnahtari] = sonuc;
      return sonuc;
    } catch (_) {
      _onbellek[onbellekAnahtari] = yerelYedek;
      return yerelYedek;
    }
  }

  static Future<List<String>> adimlariHizliCevir(List<String> adimlar) async {
    final temizAdimlar = adimlar.map((e) => e.trim()).toList();
    if (temizAdimlar.isEmpty) return temizAdimlar;

    const ayirac = ' || ';
    final birlesik = temizAdimlar.join(ayirac);

    // Çok uzunsa tek seferde zorlamadan ilk 480 karakteri çevir
    final istekMetni =
        birlesik.length > 480 ? birlesik.substring(0, 480) : birlesik;

    try {
      final ceviri = await ingilizcedenTurkceye(
        istekMetni,
        turEtiketi: 'adim_toplu',
      );

      final parcalar = ceviri
          .split(RegExp(r'\s*\|\|\s*'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (parcalar.length == temizAdimlar.length) {
        return parcalar;
      }
    } catch (_) {}

    // Tek toplu eşleşme tutmazsa yalnızca ilk 3 adımı paralel çevir, diğerlerini koru
    final sonuc = List<String>.from(temizAdimlar);
    final limit = sonuc.length < 3 ? sonuc.length : 3;
    final ilkUc = await Future.wait(
      List.generate(limit, (i) => adimCevir(sonuc[i])),
    );
    for (int i = 0; i < limit; i++) {
      if (ilkUc[i].trim().isNotEmpty) {
        sonuc[i] = ilkUc[i].trim();
      }
    }
    return sonuc;
  }

  static List<String> _metniParcala(String metin, {int maxUzunluk = 460}) {
    if (metin.length <= maxUzunluk) return [metin];

    final cumleler = metin.split(RegExp(r'(?<=[.!?])\s+'));
    final parcalar = <String>[];
    final tampon = StringBuffer();

    for (final cumle in cumleler) {
      if (cumle.length > maxUzunluk) {
        if (tampon.isNotEmpty) {
          parcalar.add(tampon.toString().trim());
          tampon.clear();
        }
        for (int i = 0; i < cumle.length; i += maxUzunluk) {
          final son =
              (i + maxUzunluk < cumle.length) ? i + maxUzunluk : cumle.length;
          parcalar.add(cumle.substring(i, son).trim());
        }
        continue;
      }

      final eklenecekUzunluk =
          tampon.isEmpty ? cumle.length : tampon.length + 1 + cumle.length;
      if (eklenecekUzunluk > maxUzunluk) {
        parcalar.add(tampon.toString().trim());
        tampon.clear();
      }

      if (tampon.isNotEmpty) tampon.write(' ');
      tampon.write(cumle);
    }

    if (tampon.isNotEmpty) {
      parcalar.add(tampon.toString().trim());
    }

    return parcalar;
  }

  static Future<String> yemekAdiCevir(String baslik) {
    return ingilizcedenTurkceye(
      baslik,
      turEtiketi: 'yemek',
      yedekCevirici: TurkceCevirici.yemekAdiCevir,
    );
  }

  static Future<String> malzemeCevir(String malzeme) {
    return ingilizcedenTurkceye(
      malzeme,
      turEtiketi: 'malzeme',
      yedekCevirici: TurkceCevirici.malzemeCevir,
    );
  }

  static Future<String> adimCevir(String adim) {
    return ingilizcedenTurkceye(
      adim,
      turEtiketi: 'adim',
    );
  }
}