import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

enum OzSaglikModu {
  ozDay,
  ozFit,
  ozHealth,
}

class GoogleSaglikServisi {
  GoogleSaglikServisi._();
  static final GoogleSaglikServisi instance = GoogleSaglikServisi._();

  final Health _health = Health();
  bool _yapilandirildi = false;

  Future<void> _hazirla() async {
    if (!_yapilandirildi) {
      await _health.configure();
      _yapilandirildi = true;
    }
  }

  /// Seçilen moda göre gerekli veri tiplerini döner
  List<HealthDataType> modVeriTipleri(OzSaglikModu mod) {
    switch (mod) {
      case OzSaglikModu.ozDay:
        return [
          HealthDataType.WATER,
          HealthDataType.NUTRITION,
        ];
      case OzSaglikModu.ozFit:
        return [
          HealthDataType.STEPS,
          HealthDataType.ACTIVE_ENERGY_BURNED,
          HealthDataType.WORKOUT,
        ];
      case OzSaglikModu.ozHealth:
        return [
          HealthDataType.HEART_RATE,
          HealthDataType.SLEEP_ASLEEP,
        ];
    }
  }

  /// Seçilen moda göre okuma/yazma yetkilerini döner
  List<HealthDataAccess> modIzinYetkileri(OzSaglikModu mod) {
    switch (mod) {
      case OzSaglikModu.ozDay:
        return [
          HealthDataAccess.READ_WRITE,
          HealthDataAccess.READ_WRITE,
        ];
      case OzSaglikModu.ozFit:
        return [
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
        ];
      case OzSaglikModu.ozHealth:
        return [
          HealthDataAccess.READ,
          HealthDataAccess.READ,
        ];
    }
  }

  /// Cihazda Health Connect kurulu ve kullanılabilir mi?
  Future<bool> healthConnectKullanilabilirMi() async {
    try {
      await _hazirla();
      final durum = await _health.getHealthConnectSdkStatus();
      return durum == HealthConnectSdkStatus.sdkAvailable;
    } catch (e) {
      debugPrint('Health Connect durum kontrolü hatası: $e');
      return false;
    }
  }

  /// Belirli bir mod için izinlerin önceden verilip verilmediğini kontrol eder
  Future<bool> modIzniVarMi(OzSaglikModu mod) async {
    try {
      await _hazirla();
      final tipler = modVeriTipleri(mod);
      final yetkiler = modIzinYetkileri(mod);
      return await _health.hasPermissions(tipler, permissions: yetkiler) ??
          false;
    } catch (e) {
      debugPrint('Health Connect izin kontrol hatası ($mod): $e');
      return false;
    }
  }

  /// Belirli bir mod (OzDay, OzFit, OzHealth) için izin ister
  Future<bool> modIzniIste(OzSaglikModu mod) async {
    try {
      await _hazirla();
      final tipler = modVeriTipleri(mod);
      final yetkiler = modIzinYetkileri(mod);

      final mevcutIzin = await _health.hasPermissions(
            tipler,
            permissions: yetkiler,
          ) ??
          false;

      if (mevcutIzin) return true;

      return await _health.requestAuthorization(
        tipler,
        permissions: yetkiler,
      );
    } catch (e) {
      debugPrint('Health Connect izin hatası ($mod): $e');
      return false;
    }
  }

  /// Tüm modlar (OzDay + OzFit + OzHealth) için tek seferde toplu izin ister
  Future<bool> tumModlarIcinIzinIste() async {
    try {
      await _hazirla();
      final tumTipler = <HealthDataType>[
        ...modVeriTipleri(OzSaglikModu.ozDay),
        ...modVeriTipleri(OzSaglikModu.ozFit),
        ...modVeriTipleri(OzSaglikModu.ozHealth),
      ];
      final tumYetkiler = <HealthDataAccess>[
        ...modIzinYetkileri(OzSaglikModu.ozDay),
        ...modIzinYetkileri(OzSaglikModu.ozFit),
        ...modIzinYetkileri(OzSaglikModu.ozHealth),
      ];

      return await _health.requestAuthorization(
        tumTipler,
        permissions: tumYetkiler,
      );
    } catch (e) {
      debugPrint('Toplu Health Connect izin hatası: $e');
      return false;
    }
  }

  /// OzDay: Bugünkü toplam su tüketimini (litre cinsinden) okur
  Future<double> bugunkuSuTuketimiLitre() async {
    try {
      await _hazirla();
      final simdi = DateTime.now();
      final gunBasi = DateTime(simdi.year, simdi.month, simdi.day);

      final noktalar = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WATER],
        startTime: gunBasi,
        endTime: simdi,
      );

      double toplamLitre = 0.0;
      for (final p in noktalar) {
        if (p.value is NumericHealthValue) {
          toplamLitre += (p.value as NumericHealthValue).numericValue.toDouble();
        }
      }
      return toplamLitre;
    } catch (e) {
      debugPrint('Su tüketimi okuma hatası: $e');
      return 0.0;
    }
  }

  /// OzDay: Su tüketimi kaydeder (örneğin 0.25 = 250 ml)
  Future<bool> suTuketimiEkle(double litre) async {
    try {
      await _hazirla();
      final simdi = DateTime.now();
      return await _health.writeHealthData(
        value: litre,
        type: HealthDataType.WATER,
        startTime: simdi.subtract(const Duration(minutes: 1)),
        endTime: simdi,
      );
    } catch (e) {
      debugPrint('Su tüketimi yazma hatası: $e');
      return false;
    }
  }

  /// OzDay: Tarif veya öğün kalorisini beslenme verisi olarak kaydeder
  Future<bool> ogunKalorisiEkle({
    required double kaloriKcal,
    required String ogunAdi,
    double proteinGram = 0,
    double karbonhidratGram = 0,
    double yagGram = 0,
  }) async {
    try {
      await _hazirla();
      final simdi = DateTime.now();
      return await _health.writeMeal(
        mealType: MealType.UNKNOWN,
        startTime: simdi.subtract(const Duration(minutes: 5)),
        endTime: simdi,
        caloriesConsumed: kaloriKcal,
        carbohydrates: karbonhidratGram,
        protein: proteinGram,
        fatTotal: yagGram,
        name: ogunAdi,
      );
    } catch (e) {
      debugPrint('Öğün kalorisi yazma hatası: $e');
      return false;
    }
  }

  /// OzFit: Bugünkü toplam adım sayısını okur
  Future<int> bugunkuAdimSayisi() async {
    try {
      await _hazirla();
      final simdi = DateTime.now();
      final gunBasi = DateTime(simdi.year, simdi.month, simdi.day);
      final adim = await _health.getTotalStepsInInterval(gunBasi, simdi);
      return adim ?? 0;
    } catch (e) {
      debugPrint('Adım sayısı okuma hatası: $e');
      return 0;
    }
  }

  /// OzFit: Bugünkü aktif yakılan kaloriyi (kcal) okur
  Future<double> bugunkuAktifKalori() async {
    try {
      await _hazirla();
      final simdi = DateTime.now();
      final gunBasi = DateTime(simdi.year, simdi.month, simdi.day);

      final noktalar = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: gunBasi,
        endTime: simdi,
      );

      double toplamKcal = 0.0;
      for (final p in noktalar) {
        if (p.value is NumericHealthValue) {
          toplamKcal += (p.value as NumericHealthValue).numericValue.toDouble();
        }
      }
      return toplamKcal;
    } catch (e) {
      debugPrint('Aktif kalori okuma hatası: $e');
      return 0.0;
    }
  }

  /// OzHealth: Son 24 saatteki ortalama kalp atış hızını (BPM) okur
  Future<double?> sonOrtalamaNabiz() async {
    try {
      await _hazirla();
      final simdi = DateTime.now();
      final dun = simdi.subtract(const Duration(hours: 24));

      final noktalar = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: dun,
        endTime: simdi,
      );

      if (noktalar.isEmpty) return null;

      double toplam = 0.0;
      int sayac = 0;
      for (final p in noktalar) {
        if (p.value is NumericHealthValue) {
          toplam += (p.value as NumericHealthValue).numericValue.toDouble();
          sayac++;
        }
      }
      return sayac == 0 ? null : toplam / sayac;
    } catch (e) {
      debugPrint('Nabız okuma hatası: $e');
      return null;
    }
  }

  /// OzHealth: Son 24 saatteki toplam uyku süresini (dakika) okur
  Future<int> sonUykuSuresiDakika() async {
    try {
      await _hazirla();
      final simdi = DateTime.now();
      final dun = simdi.subtract(const Duration(hours: 24));

      final noktalar = await _health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_ASLEEP],
        startTime: dun,
        endTime: simdi,
      );

      int toplamDakika = 0;
      for (final p in noktalar) {
        toplamDakika += p.dateTo.difference(p.dateFrom).inMinutes;
      }
      return toplamDakika;
    } catch (e) {
      debugPrint('Uyku süresi okuma hatası: $e');
      return 0;
    }
  }
}