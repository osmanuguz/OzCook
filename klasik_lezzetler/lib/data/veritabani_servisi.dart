import 'dart:async';

import 'package:klasik_lezzetler/models/tarif_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class VeritabaniServisi {
  static final VeritabaniServisi _instance = VeritabaniServisi._internal();
  factory VeritabaniServisi() => _instance;
  VeritabaniServisi._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ozcook_veritabani.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE indirilen_tarifler (
            id TEXT PRIMARY KEY,
            baslik TEXT,
            kategori TEXT,
            pisirilis_sekli TEXT,
            sure_dk INTEGER,
            porsiyon INTEGER,
            gorsel_url TEXT,
            video_url TEXT,
            malzemeler TEXT,
            etiketler TEXT,
            yapilis TEXT,
            kalori INTEGER,
            protein REAL,
            karbonhidrat REAL,
            yag REAL
          )
        ''');

        await db.execute('''
          CREATE TABLE ozfit_gunluk_takvim (
            gun_no INTEGER PRIMARY KEY,
            hedef_tipi TEXT,
            hedef_kalori INTEGER,
            secili_oneri TEXT,
            tikler_json TEXT,
            guncelleme_tarihi TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS ozfit_gunluk_takvim (
              gun_no INTEGER PRIMARY KEY,
              hedef_tipi TEXT,
              hedef_kalori INTEGER,
              secili_oneri TEXT,
              tikler_json TEXT,
              guncelleme_tarihi TEXT
            )
          ''');
        }
        if (oldVersion < 3) {
          try {
            await db.execute(
              'ALTER TABLE indirilen_tarifler ADD COLUMN porsiyon INTEGER DEFAULT 2',
            );
          } catch (_) {}
          try {
            await db.execute(
              "ALTER TABLE indirilen_tarifler ADD COLUMN malzemeler TEXT DEFAULT ''",
            );
          } catch (_) {}
          try {
            await db.execute(
              "ALTER TABLE indirilen_tarifler ADD COLUMN yapilis TEXT DEFAULT ''",
            );
          } catch (_) {}
        }
      },
    );
  }

  Future<void> tarifKaydet(Tarif tarif) async {
    final db = await database;
    final malzemeMetni = tarif.malzemeler
        .map((m) => '${m.ad}::${m.miktar}')
        .join('||');

    await db.insert(
      'indirilen_tarifler',
      {
        'id': tarif.id,
        'baslik': tarif.baslik,
        'kategori': tarif.kategori,
        'pisirilis_sekli': tarif.pisirilisSekli,
        'sure_dk': tarif.sureDk,
        'porsiyon': tarif.porsiyon,
        'gorsel_url': tarif.gorselUrl,
        'video_url': tarif.videoUrl,
        'malzemeler': malzemeMetni,
        'etiketler': tarif.etiketler.join('||'),
        'yapilis': tarif.yapilis.join('||'),
        'kalori': tarif.besinDegerleri.kalori,
        'protein': tarif.besinDegerleri.protein,
        'karbonhidrat': tarif.besinDegerleri.karbonhidrat,
        'yag': tarif.besinDegerleri.yag,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> tarifSil(String id) async {
    final db = await database;
    await db.delete(
      'indirilen_tarifler',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> indirilenIdleriGetir() async {
    final db = await database;
    final maps = await db.query('indirilen_tarifler', columns: ['id']);
    return maps.map((e) => e['id'] as String).toList();
  }

  Future<List<Tarif>> indirilenTarifleriGetir() async {
    final db = await database;
    final maps = await db.query('indirilen_tarifler');

    return maps.map((map) {
      final hamMalzeme = ((map['malzemeler'] as String?) ?? '')
          .split('||')
          .where((s) => s.isNotEmpty)
          .toList();

      final malzemeler = hamMalzeme.map((satir) {
        final parca = satir.split('::');
        return Malzeme(
          ad: parca.isNotEmpty ? parca[0] : satir,
          miktar: parca.length > 1 ? parca[1] : '',
        );
      }).toList();

      final yapilisListesi = ((map['yapilis'] as String?) ?? '')
          .split('||')
          .where((s) => s.isNotEmpty)
          .toList();

      return Tarif(
        id: map['id'] as String,
        baslik: map['baslik'] as String,
        kategori: map['kategori'] as String,
        pisirilisSekli: (map['pisirilis_sekli'] as String?) ?? 'Ocak',
        sureDk: (map['sure_dk'] as int?) ?? 15,
        porsiyon: (map['porsiyon'] as int?) ?? 2,
        gorselUrl: (map['gorsel_url'] as String?) ?? '',
        videoUrl: (map['video_url'] as String?) ?? '',
        besinDegerleri: BesinDegerleri(
          kalori: (map['kalori'] as int?) ?? 0,
          protein: ((map['protein'] as num?) ?? 0).toDouble(),
          karbonhidrat: ((map['karbonhidrat'] as num?) ?? 0).toDouble(),
          yag: ((map['yag'] as num?) ?? 0).toDouble(),
        ),
        malzemeler: malzemeler,
        etiketler: ((map['etiketler'] as String?) ?? '')
            .split('||')
            .where((s) => s.isNotEmpty)
            .toList(),
        yapilis: yapilisListesi,
        indirildiMi: true,
      );
    }).toList();
  }

  Future<void> ozFitGunKaydet({
    required int gunNo,
    required String hedefTipi,
    required int hedefKalori,
    required String seciliOneri,
    required String tiklerJson,
  }) async {
    final db = await database;
    await db.insert(
      'ozfit_gunluk_takvim',
      {
        'gun_no': gunNo,
        'hedef_tipi': hedefTipi,
        'hedef_kalori': hedefKalori,
        'secili_oneri': seciliOneri,
        'tikler_json': tiklerJson,
        'guncelleme_tarihi': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

    Future ozFitTumGunleriGetir() async {
      final db = await database;
    final rows = await db.query('ozfit_gunluk_takvim', orderBy: 'gun_no ASC');
    final Map<int, Map<String, dynamic>> sonuc = {};
    for (final row in rows) {
      final gun = row['gun_no'] as int;
      sonuc[gun] = row;
    }
    return sonuc;
  }
}