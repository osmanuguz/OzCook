import 'package:flutter/material.dart';
import 'package:klasik_lezzetler/data/google_giris_servisi.dart';
import 'package:klasik_lezzetler/theme/app_theme.dart';

class KullaniciProfili {
  final String? id;
  final String ad;
  final String eposta;
  final String girisYontemi;
  final bool googleBagli;
  final String? fotoUrl;

  const KullaniciProfili({
    this.id,
    required this.ad,
    required this.eposta,
    required this.girisYontemi,
    this.googleBagli = false,
    this.fotoUrl,
  });
}

class GirisEkrani extends StatefulWidget {
  final KullaniciProfili? mevcutKullanici;
  final ValueChanged<KullaniciProfili?> onGirisTamamlandi;

  const GirisEkrani({
    super.key,
    this.mevcutKullanici,
    required this.onGirisTamamlandi,
  });

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  late final TextEditingController _adController;
  late final TextEditingController _epostaController;
  bool _yukleniyor = false;

  @override
  void initState() {
    super.initState();
    _adController = TextEditingController(
      text: widget.mevcutKullanici?.ad ?? '',
    );
    _epostaController = TextEditingController(
      text: widget.mevcutKullanici?.eposta ?? '',
    );
  }

  @override
  void dispose() {
    _adController.dispose();
    _epostaController.dispose();
    super.dispose();
  }

  void _epostaIleGiris() {
    final ad = _adController.text.trim().isEmpty
        ? 'Ozcook Kullanıcısı'
        : _adController.text.trim();
    final eposta = _epostaController.text.trim().isEmpty
        ? 'kullanici@ozcook.app'
        : _epostaController.text.trim();

    widget.onGirisTamamlandi(
      KullaniciProfili(
        id: widget.mevcutKullanici?.id,
        ad: ad,
        eposta: eposta,
        girisYontemi: 'E-posta Hesabı',
        googleBagli: false,
        fotoUrl: widget.mevcutKullanici?.googleBagli == true
            ? null
            : widget.mevcutKullanici?.fotoUrl,
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _googleIleGiris() async {
    if (_yukleniyor) return;
    setState(() => _yukleniyor = true);

    try {
      final hesap = await GoogleGirisServisi.instance.googleIleGirisYap();
      if (!mounted) return;

      if (hesap == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google ile giriş iptal edildi.'),
          ),
        );
        return;
      }

      _adController.text = hesap.adSoyad;
      _epostaController.text = hesap.eposta;

      widget.onGirisTamamlandi(
        KullaniciProfili(
          id: hesap.id,
          ad: hesap.adSoyad,
          eposta: hesap.eposta,
          girisYontemi: 'Google ile Giriş',
          googleBagli: true,
          fotoUrl: hesap.fotoUrl,
        ),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google ile giriş yapılamadı. Bağlantını veya Google hizmet ayarlarını kontrol et.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _yukleniyor = false);
      }
    }
  }

  Future<void> _cikisYap() async {
    if (_yukleniyor) return;
    setState(() => _yukleniyor = true);

    try {
      if (widget.mevcutKullanici?.googleBagli == true) {
        await GoogleGirisServisi.instance.cikisYap();
      }
      if (!mounted) return;
      widget.onGirisTamamlandi(null);
      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _yukleniyor = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mevcut = widget.mevcutKullanici;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Girişi'),
      ),
      body: BuguluKirmiziArkaPlan(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.klasikKirmizi.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.klasikKirmizi.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.restaurant_menu_rounded,
                      size: 44,
                      color: AppTheme.klasikKirmizi,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ozcook Hesabın',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tariflerini kaydet, günlük öğün ve diyet zamanlamalarını takip et.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _adController,
                enabled: !_yukleniyor,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _epostaController,
                enabled: !_yukleniyor,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-posta Adresi',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _yukleniyor ? null : _epostaIleGiris,
                icon: const Icon(Icons.login),
                label: const Text('Giriş Yap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.klasikKirmizi,
                  foregroundColor: AppTheme.safBeyaz,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _yukleniyor ? null : _googleIleGiris,
                icon: _yukleniyor
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.g_mobiledata, size: 26),
                label: const Text('Google ile Giriş Yap'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
              if (mevcut != null) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),
                ListTile(
                  leading: mevcut.fotoUrl != null && mevcut.fotoUrl!.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(mevcut.fotoUrl!),
                        )
                      : const Icon(
                          Icons.verified_user,
                          color: AppTheme.klasikKirmizi,
                        ),
                  title: Text(mevcut.ad),
                  subtitle: Text(
                    '${mevcut.eposta} • ${mevcut.girisYontemi}',
                  ),
                ),
                TextButton.icon(
                  onPressed: _yukleniyor ? null : _cikisYap,
                  icon: const Icon(Icons.logout, color: AppTheme.klasikKirmizi),
                  label: const Text(
                    'Oturumu Kapat',
                    style: TextStyle(color: AppTheme.klasikKirmizi),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}