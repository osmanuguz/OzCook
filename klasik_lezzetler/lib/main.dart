import 'dart:async';

import 'package:flutter/material.dart';
import 'package:klasik_lezzetler/screens/ana_sayfa_ekrani.dart';
import 'package:klasik_lezzetler/screens/ayarlar_ekrani.dart';
import 'package:klasik_lezzetler/screens/giris_ekrani.dart';
import 'package:klasik_lezzetler/screens/oz_modlari_ekrani.dart';
import 'package:klasik_lezzetler/services/bildirim_servisi.dart';
import 'package:klasik_lezzetler/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _koyuTemaKayitAnahtari = 'koyu_tema_aktif';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BildirimServisi.instance.baslat();

  final prefs = await SharedPreferences.getInstance();
  final kaydedilmisKoyuTema = prefs.getBool(_koyuTemaKayitAnahtari);

  runApp(OzcookApp(kaydedilmisKoyuTema: kaydedilmisKoyuTema));
}

class OzcookApp extends StatefulWidget {
  final bool? kaydedilmisKoyuTema;

  const OzcookApp({
    super.key,
    this.kaydedilmisKoyuTema,
  });

  @override
  State<OzcookApp> createState() => _OzcookAppState();
}

class _OzcookAppState extends State<OzcookApp> {
  bool? _kullaniciTemaSecimi;

  @override
  void initState() {
    super.initState();
    _kullaniciTemaSecimi = widget.kaydedilmisKoyuTema;
  }

  bool _koyuTemaAktifMi(BuildContext context) {
    if (_kullaniciTemaSecimi != null) {
      return _kullaniciTemaSecimi!;
    }
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }

  ThemeMode _aktifThemeMode() {
    if (_kullaniciTemaSecimi == null) return ThemeMode.system;
    return _kullaniciTemaSecimi! ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _koyuTemaDegistir(bool aktif) async {
    setState(() => _kullaniciTemaSecimi = aktif);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_koyuTemaKayitAnahtari, aktif);
  }

  @override
  Widget build(BuildContext context) {
    final koyuTemaAktif = _koyuTemaAktifMi(context);

    return MaterialApp(
      title: 'Ozcook',
      debugShowCheckedModeBanner: false,
      navigatorKey: BildirimServisi.instance.navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _aktifThemeMode(),
      home: AcilisEkrani(
        koyuTemaAktif: koyuTemaAktif,
        onKoyuTemaDegisti: _koyuTemaDegistir,
      ),
      routes: {
        '/ana': (context) => OzcookAnaKabuk(
              koyuTemaAktif: koyuTemaAktif,
              onKoyuTemaDegisti: _koyuTemaDegistir,
            ),
        '/ozfit': (context) => OzcookAnaKabuk(
              baslangicSekmesi: 1,
              baslangicModu: 'OzFit',
              koyuTemaAktif: koyuTemaAktif,
              onKoyuTemaDegisti: _koyuTemaDegistir,
            ),
        '/ozday': (context) => OzcookAnaKabuk(
              baslangicSekmesi: 1,
              baslangicModu: 'Kalori & OzDay',
              koyuTemaAktif: koyuTemaAktif,
              onKoyuTemaDegisti: _koyuTemaDegistir,
            ),
      },
    );
  }
}

class AcilisEkrani extends StatefulWidget {
  final bool koyuTemaAktif;
  final ValueChanged<bool> onKoyuTemaDegisti;

  const AcilisEkrani({
    super.key,
    required this.koyuTemaAktif,
    required this.onKoyuTemaDegisti,
  });

  @override
  State<AcilisEkrani> createState() => _AcilisEkraniState();
}

class _AcilisEkraniState extends State<AcilisEkrani>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animKontrol;
  late final Animation<double> _opaklik;
  late final Animation<double> _olcek;
  Timer? _gecisZamanlayici;

  @override
  void initState() {
    super.initState();
    _animKontrol = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opaklik = CurvedAnimation(
      parent: _animKontrol,
      curve: Curves.easeOut,
    );
    _olcek = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animKontrol, curve: Curves.easeOutBack),
    );
    _animKontrol.forward();

    _gecisZamanlayici = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OzcookAnaKabuk(
            koyuTemaAktif: widget.koyuTemaAktif,
            onKoyuTemaDegisti: widget.onKoyuTemaDegisti,
          ),
        ),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        BildirimServisi.instance.bekleyenBildirimiIsle();
      });
    });
  }

  @override
  void dispose() {
    _gecisZamanlayici?.cancel();
    _animKontrol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.klasikKirmizi,
      body: Center(
        child: FadeTransition(
          opacity: _opaklik,
          child: ScaleTransition(
            scale: _olcek,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.safBeyaz,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/ozcook_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, _err, _stack) => const Icon(
                      Icons.restaurant_menu_rounded,
                      size: 56,
                      color: AppTheme.klasikKirmizi,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ozcook',
                  style: TextStyle(
                    color: AppTheme.safBeyaz,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tarif, Kalori & Akıllı Mutfak',
                  style: TextStyle(
                    color: AppTheme.safBeyaz.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppTheme.safBeyaz,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OzcookAnaKabuk extends StatefulWidget {
  final int baslangicSekmesi;
  final String? baslangicModu;
  final bool koyuTemaAktif;
  final ValueChanged<bool> onKoyuTemaDegisti;

  const OzcookAnaKabuk({
    super.key,
    this.baslangicSekmesi = 0,
    this.baslangicModu,
    required this.koyuTemaAktif,
    required this.onKoyuTemaDegisti,
  });

  @override
  State<OzcookAnaKabuk> createState() => _OzcookAnaKabukState();
}

class _OzcookAnaKabukState extends State<OzcookAnaKabuk> {
  late int _seciliIndex;
  KullaniciProfili? _kullanici;
  Set<String> _kaydedilenIdler = {};

  @override
  void initState() {
    super.initState();
    _seciliIndex = widget.baslangicSekmesi;
  }

  void _kaydetmeDurumunuDegistir(String tarifId) {
    setState(() {
      if (_kaydedilenIdler.contains(tarifId)) {
        _kaydedilenIdler.remove(tarifId);
      } else {
        _kaydedilenIdler.add(tarifId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final koyuTemaMi = Theme.of(context).brightness == Brightness.dark;
    final barRengi =
        koyuTemaMi ? AppTheme.koyuKirmiziBar : AppTheme.klasikKirmizi;

    final ekranlar = <Widget>[
      AnaSayfaEkrani(
        kaydedilenIdler: _kaydedilenIdler,
        onKaydetmeDegisti: _kaydetmeDurumunuDegistir,
      ),
      OzModlariEkrani(baslangicModu: widget.baslangicModu),
      AyarlarEkrani(
        mevcutKullanici: _kullanici,
        onKullaniciDegisti: (profil) {
          setState(() => _kullanici = profil);
        },
        kaydedilenIdler: _kaydedilenIdler,
        onKaydedilenlerDegisti: (yeniSet) {
          setState(() => _kaydedilenIdler = yeniSet);
        },
        koyuTemaAktif: widget.koyuTemaAktif,
        onKoyuTemaDegisti: widget.onKoyuTemaDegisti,
      ),
    ];

    const sayfaEtiketleri = <String>[
      'Ana Sayfa',
      'Oz Modları',
      'Ayarlar',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: barRengi,
        foregroundColor: AppTheme.safBeyaz,
        elevation: koyuTemaMi ? 0 : 2,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppTheme.safBeyaz,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/images/ozcook_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, _err, _stack) => const Icon(
                  Icons.restaurant_menu_rounded,
                  color: AppTheme.klasikKirmizi,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sayfaEtiketleri[_seciliIndex],
                    style: const TextStyle(
                      color: AppTheme.safBeyaz,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  if (_kullanici != null)
                    Text(
                      '${_kullanici!.ad} • ${_kullanici!.girisYontemi}',
                      style: TextStyle(
                        color: AppTheme.safBeyaz.withValues(alpha: 0.9),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ayarlar',
            icon: Icon(
              _seciliIndex == 2 ? Icons.settings : Icons.settings_outlined,
              color: AppTheme.safBeyaz,
            ),
            onPressed: () => setState(() => _seciliIndex = 2),
          ),
        ],
      ),
      body: BuguluKirmiziArkaPlan(
        child: ekranlar[_seciliIndex],
      ),
      bottomNavigationBar: Container(
        decoration: koyuTemaMi
            ? const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppTheme.koyuKirmiziKenarlik,
                    width: 0.8,
                  ),
                ),
              )
            : null,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: barRengi,
          selectedItemColor: AppTheme.safBeyaz,
          unselectedItemColor: AppTheme.safBeyaz.withValues(alpha: 0.68),
          currentIndex: _seciliIndex,
          onTap: (index) {
            setState(() => _seciliIndex = index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_outlined),
              activeIcon: Icon(Icons.tune),
              label: 'Oz Modları',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Ayarlar',
            ),
          ],
        ),
      ),
    );
  }
}