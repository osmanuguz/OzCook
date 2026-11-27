import 'dart:convert';
import 'package:http/http.dart' as http;
import 'gizli.dart';

typedef JsonMap = Map<String, dynamic>;

class AiServisi {
  static const String _model = 'gemini-3.8-flash';
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  static Future<String> _geminiIstekAt(
    String prompt, {
    bool jsonModu = false,
  }) async {
    if (geminiApiKey.isEmpty || geminiApiKey.contains('BURAYA_')) {
      throw Exception(
        'Gemini API anahtarı bulunamadı. lib/services/gizli.dart dosyasını kontrol et.',
      );
    }

    final JsonMap generationConfig = {
      'thinkingConfig': {'thinkingBudget': 0},
    };

    if (jsonModu) {
      generationConfig['responseMimeType'] = 'application/json';
    }

    final res = await http.post(
      Uri.parse('$_endpoint?key=$geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': generationConfig,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      try {
        final hata = jsonDecode(res.body);
        throw Exception(
          hata['error']?['message'] ?? 'API Hatası: ${res.statusCode}',
        );
      } catch (_) {
        throw Exception('API Hatası: ${res.statusCode}');
      }
    }

    final data = jsonDecode(res.body);
    final metin =
        data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;

    if (metin == null || metin.isEmpty) {
      throw Exception('Yapay zekadan boş yanıt döndü.');
    }
    return metin;
  }

  /// 1) Yapay Zeka Mutfak Asistanı Sohbeti
  static Future<String> mutfakAsistaniSor(
    String soru, {
    int alinanKalori = 0,
    int kaloriHedefi = 2000,
    String mod = 'Genel',
  }) async {
    final kalanKalori =
        (kaloriHedefi - alinanKalori) > 0 ? (kaloriHedefi - alinanKalori) : 0;

    final prompt = '''
Sen Ozcook uygulamasının samimi, pratik ve bilgili Türkçe mutfak asistanısın.
Kullanıcının güncel durumu:
- Aktif mod: $mod
- Bugün alınan kalori: $alinanKalori kcal / Hedef: $kaloriHedefi kcal (Kalan: $kalanKalori kcal)

Kurallar:
- Yanıtların kısa, net, uygulanabilir ve Türkçe olsun.
- Tarif verirken yaklaşık kalori/protein tahmini ekle.
- Eğer mod "KYK Yurt" ise sadece kettle, tost makinesi veya elektrikli ocakla yapılabilecek pratik öneriler ver.
- Eğer mod "OzHealth" ise düşük tuzlu ve ilave şekersiz öneriler ver.

Kullanıcının sorusu: $soru
''';

    return _geminiIstekAt(prompt, jsonModu: false);
  }

  /// 2) 7 Günlük Haftalık Öğün Planı Oluşturma
  static Future<JsonMap> haftalikPlanOlustur({
    String mod = 'Genel',
    int kaloriHedefi = 2000,
    String not = '',
  }) async {
    final prompt = '''
Ozcook uygulaması için 7 günlük Türkçe öğün planı oluştur.
Kriterler:
- Mod: $mod (KYK Yurt ise sadece kettle/elektrikli tencere/pratik yurt yemekleri; OzFit ise hedef kaloriye uygun dengeli makrolar; OzHealth ise düşük sodyum ve şekersiz)
- Günlük kalori hedefi: yaklaşık $kaloriHedefi kcal
- Ek kullanıcı notu: ${not.isEmpty ? 'Yok' : not}

Sadece aşağıdaki JSON formatında yanıt ver:
{
  "Pazartesi": {
    "kahvalti": { "ad": "...", "kalori": 450 },
    "ogle": { "ad": "...", "kalori": 650 },
    "aksam": { "ad": "...", "kalori": 700 }
  },
  "Salı": { "kahvalti": { "ad": "...", "kalori": 0 }, "ogle": { "ad": "...", "kalori": 0 }, "aksam": { "ad": "...", "kalori": 0 } },
  "Çarşamba": { "kahvalti": { "ad": "...", "kalori": 0 }, "ogle": { "ad": "...", "kalori": 0 }, "aksam": { "ad": "...", "kalori": 0 } },
  "Perşembe": { "kahvalti": { "ad": "...", "kalori": 0 }, "ogle": { "ad": "...", "kalori": 0 }, "aksam": { "ad": "...", "kalori": 0 } },
  "Cuma": { "kahvalti": { "ad": "...", "kalori": 0 }, "ogle": { "ad": "...", "kalori": 0 }, "aksam": { "ad": "...", "kalori": 0 } },
  "Cumartesi": { "kahvalti": { "ad": "...", "kalori": 0 }, "ogle": { "ad": "...", "kalori": 0 }, "aksam": { "ad": "...", "kalori": 0 } },
  "Pazar": { "kahvalti": { "ad": "...", "kalori": 0 }, "ogle": { "ad": "...", "kalori": 0 }, "aksam": { "ad": "...", "kalori": 0 } }
}
''';

    final hamJson = await _geminiIstekAt(prompt, jsonModu: true);
    return jsonDecode(hamJson) as JsonMap;
  }
}