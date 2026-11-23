import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleGirisKullanicisi {
  final String id;
  final String adSoyad;
  final String eposta;
  final String? fotoUrl;
  final String? idToken;

  const GoogleGirisKullanicisi({
    required this.id,
    required this.adSoyad,
    required this.eposta,
    this.fotoUrl,
    this.idToken,
  });
}

class GoogleGirisServisi {
  GoogleGirisServisi._();
  static final GoogleGirisServisi instance = GoogleGirisServisi._();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
  );

  bool _islemSuruyor = false;

  Future<GoogleGirisKullanicisi?> sessizGirisYap() async {
    try {
      final GoogleSignInAccount? hesap = await _googleSignIn.signInSilently();
      if (hesap == null) return null;
      return await _hesabiDonustur(hesap);
    } catch (e) {
      debugPrint('Sessiz Google giriş hatası: $e');
      return null;
    }
  }

  Future<GoogleGirisKullanicisi?> googleIleGirisYap() async {
    if (_islemSuruyor) return null;
    _islemSuruyor = true;

    try {
      final GoogleSignInAccount? hesap = await _googleSignIn.signIn();
      if (hesap == null) {
        return null;
      }
      final kullanici = await _hesabiDonustur(hesap);
      return kullanici;
    } catch (e) {
      debugPrint('Google ile giriş hatası: $e');
      rethrow;
    } finally {
      _islemSuruyor = false;
    }
  }

  Future<void> cikisYap() async {
    if (_islemSuruyor) return;
    _islemSuruyor = true;
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        debugPrint('Google çıkış hatası: $e');
      }
    } finally {
      _islemSuruyor = false;
    }
  }

  Future<GoogleGirisKullanicisi> _hesabiDonustur(
    GoogleSignInAccount hesap,
  ) async {
    String? token;
    try {
      final auth = await hesap.authentication;
      token = auth.idToken;
    } catch (_) {}

    return GoogleGirisKullanicisi(
      id: hesap.id,
      adSoyad: hesap.displayName?.trim().isNotEmpty == true
          ? hesap.displayName!.trim()
          : 'Google Kullanıcısı',
      eposta: hesap.email,
      fotoUrl: hesap.photoUrl,
      idToken: token,
    );
  }
}