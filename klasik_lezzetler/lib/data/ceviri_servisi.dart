import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:klasik_lezzetler/data/turkce_cevirici.dart';

class CeviriServisi {
  static final Map<String, String> _onbellek = {};

  static Future<String> ingilizcedenTurkceye(
    String metin, {
    String Function(String)? yedekCevirici,
  }) async {
    final temiz = metin.trim();
    if (temiz.isEmpty) return temiz;

    final onbellekAnahtari = '${yedekCevirici.hashCode}:$temiz';
    if (_onbellek.containsKey(onbellekAnahtari)) {
      return _onbellek[onbellekAnahtari]!;
    }

    try {
      final parcalar = _metniParcala(temiz, maxUzunluk: 400);
      final cevrilenParcalar = <String>[];

      for (final parca in parcalar) {
        final uri = Uri.parse(
          'https://api.mymemory.translated.net/get'
          '?q=${Uri.encodeComponent(parca)}&langpair=en|tr',
        );

        final res = await http.get(uri).timeout(const Duration(seconds: 6));
        if (res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          if (decoded is Map<String, dynamic>) {
            final responseData = decoded['responseData'];
            if (responseData is Map<String, dynamic>) {
              final ceviri = responseData['translatedText']?.toString().trim();
              if (ceviri != null && ceviri.isNotEmpty) {
                cevrilenParcalar.add(ceviri);
                continue;
              }
            }
          }
        }

        cevrilenParcalar.add(
          yedekCevirici != null ? yedekCevirici(parca) : parca,
        );
      }

      final birlesik =
          cevrilenParcalar.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
      final sonuc = birlesik.isNotEmpty
          ? birlesik
          : (yedekCevirici != null ? yedekCevirici(temiz) : temiz);

      _onbellek[onbellekAnahtari] = sonuc;
      return sonuc;
    } catch (_) {
      final yedekSonuc = yedekCevirici != null ? yedekCevirici(temiz) : temiz;
      _onbellek[onbellekAnahtari] = yedekSonuc;
      return yedekSonuc;
    }
  }

  static List<String> _metniParcala(String metin, {int maxUzunluk = 400}) {
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
      yedekCevirici: TurkceCevirici.yemekAdiCevir,
    );
  }

  static Future<String> malzemeCevir(String malzeme) {
    return ingilizcedenTurkceye(
      malzeme,
      yedekCevirici: TurkceCevirici.malzemeCevir,
    );
  }

  static Future<String> adimCevir(String adim) {
    return ingilizcedenTurkceye(
      adim,
      yedekCevirici: TurkceCevirici.yapilisAdimiCevir,
    );
  }
}