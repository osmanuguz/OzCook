import 'package:flutter/material.dart';

class AppTheme {
  static const Color klasikKirmizi = Color(0xFFB71C1C);
  static const Color koyuKirmizi = Color(0xFF7F0000);
  static const Color kremZemin = Color(0xFFFAF7F5);
  static const Color safBeyaz = Color(0xFFFFFFFF);
  static const Color koyuMetin = Color(0xFF1F1F1F);
  static const Color ikincilMetin = Color(0xFF666666);

  // Beyaz temada buğulu kırmızı zemin & yüzey tonları
  static const Color acikKirmiziZemin = Color(0xFFFDF2F2);
  static const Color acikKirmiziYuzey = Color(0xFFFFFAFA);
  static const Color acikKirmiziKenarlik = Color(0xFFF2D5D5);

  // Koyu temada uyumlu buğulu kırmızı zemin, bar & yüzey tonları
  static const Color koyuKirmiziZemin = Color(0xFF220D10);
  static const Color koyuKirmiziYuzey = Color(0xFF2E1216);
  static const Color koyuKirmiziBar = Color(0xFF280F13);
  static const Color koyuKirmiziKenarlik = Color(0xFF4D1E24);
  static const Color acikMetin = Color(0xFFFFFFFF);
  static const Color ikincilAcikMetin = Color(0xFFE6CACA);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: acikKirmiziZemin,
      colorScheme: ColorScheme.fromSeed(
        seedColor: klasikKirmizi,
        brightness: Brightness.light,
        primary: klasikKirmizi,
        secondary: koyuKirmizi,
        surface: acikKirmiziYuzey,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: acikKirmiziYuzey,
        foregroundColor: klasikKirmizi,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: klasikKirmizi,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: const CardThemeData(
        color: acikKirmiziYuzey,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: acikKirmiziKenarlik),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: acikKirmiziYuzey,
        selectedColor: klasikKirmizi,
        disabledColor: const Color(0xFFF5E6E6),
        labelStyle: const TextStyle(
          color: koyuMetin,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: safBeyaz,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: koyuMetin),
        side: const BorderSide(color: acikKirmiziKenarlik),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      dividerColor: acikKirmiziKenarlik,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: koyuMetin,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: koyuMetin,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: koyuMetin,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          color: koyuMetin,
          fontSize: 14,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: koyuKirmiziZemin,
      colorScheme: ColorScheme.fromSeed(
        seedColor: klasikKirmizi,
        brightness: Brightness.dark,
        primary: klasikKirmizi,
        secondary: koyuKirmizi,
        surface: koyuKirmiziYuzey,
        onSurface: acikMetin,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: koyuKirmiziBar,
        foregroundColor: safBeyaz,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: safBeyaz,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: koyuKirmiziBar,
        selectedItemColor: safBeyaz,
        unselectedItemColor: safBeyaz.withValues(alpha: 0.65),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: koyuKirmiziYuzey,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: koyuKirmiziKenarlik),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: koyuKirmiziYuzey,
        selectedColor: klasikKirmizi,
        disabledColor: koyuKirmiziYuzey,
        labelStyle: const TextStyle(
          color: safBeyaz,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: safBeyaz,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: safBeyaz),
        side: const BorderSide(color: koyuKirmiziKenarlik),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return safBeyaz;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return klasikKirmizi;
            }
            return koyuKirmiziYuzey;
          }),
        ),
      ),
      dividerColor: koyuKirmiziKenarlik,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: acikMetin,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: acikMetin,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: acikMetin,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          color: ikincilAcikMetin,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// Ekran içeriğinin arkasında her iki temada da yumuşak, buğulu kırmızı
/// ışık/geçiş hissi oluşturan yardımcı katman.
class BuguluKirmiziArkaPlan extends StatelessWidget {
  final Widget child;

  const BuguluKirmiziArkaPlan({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final koyuTemaMi = Theme.of(context).brightness == Brightness.dark;
    final temelRenk =
        koyuTemaMi ? AppTheme.koyuKirmiziZemin : AppTheme.acikKirmiziZemin;
    final buguRengi = koyuTemaMi
        ? AppTheme.klasikKirmizi.withValues(alpha: 0.28)
        : AppTheme.klasikKirmizi.withValues(alpha: 0.12);
    final ikincilBuguRengi = koyuTemaMi
        ? AppTheme.koyuKirmizi.withValues(alpha: 0.32)
        : AppTheme.klasikKirmizi.withValues(alpha: 0.08);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  buguRengi,
                  temelRenk,
                  ikincilBuguRengi,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: -90,
          right: -70,
          child: IgnorePointer(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    buguRengi,
                    buguRengi.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -110,
          left: -80,
          child: IgnorePointer(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ikincilBuguRengi,
                    ikincilBuguRengi.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}