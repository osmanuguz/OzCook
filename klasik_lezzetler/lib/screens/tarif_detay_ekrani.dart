import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klasik_lezzetler/data/veritabani_servisi.dart';
import 'package:klasik_lezzetler/models/tarif_model.dart';
import 'package:klasik_lezzetler/theme/app_theme.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class TarifDetayEkrani extends StatefulWidget {
  final Tarif tarif;

  const TarifDetayEkrani({
    super.key,
    required this.tarif,
  });

  @override
  State<TarifDetayEkrani> createState() => _TarifDetayEkraniState();
}

class _TarifDetayEkraniState extends State<TarifDetayEkrani> {
  final VeritabaniServisi _vtServisi = VeritabaniServisi();
  YoutubePlayerController? _youtubeController;
  String? _videoId;
  bool _indiriliyor = false;
  late bool _indirildiMi;

  @override
  void initState() {
    super.initState();
    _indirildiMi = widget.tarif.indirildiMi;
    _videoHazirla();
    _indirmeDurumunuKontrolEt();
  }

  String? _idAyikla(String hamDeger) {
    final trimmed = hamDeger.trim();
    if (trimmed.isEmpty) return null;

    final idRegex = RegExp(r'^[a-zA-Z0-9_-]{11}$');
    if (idRegex.hasMatch(trimmed)) {
      return trimmed;
    }

    final converted = YoutubePlayerController.convertUrlToId(trimmed);
    if (converted != null && idRegex.hasMatch(converted)) {
      return converted;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      final vParam = uri.queryParameters['v'];
      if (vParam != null && idRegex.hasMatch(vParam)) {
        return vParam;
      }
      for (final segment in uri.pathSegments.reversed) {
        if (idRegex.hasMatch(segment)) {
          return segment;
        }
      }
    }

    return null;
  }

  void _videoHazirla() {
    final id = _idAyikla(widget.tarif.videoUrl);
    if (id != null && id.isNotEmpty) {
      _videoId = id;
      _youtubeController = YoutubePlayerController.fromVideoId(
        videoId: id,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
          strictRelatedVideos: true,
          playsInline: true,
          origin: 'https://www.youtube.com',
        ),
      );
    }
  }

  String _youtubeIzlemeLinki() {
    if (_videoId != null && _videoId!.isNotEmpty) {
      return 'https://www.youtube.com/watch?v=$_videoId';
    }
    return widget.tarif.videoUrl.trim();
  }

  Future<void> _linkiKopyala() async {
    final link = _youtubeIzlemeLinki();
    if (link.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.klasikKirmizi,
        content: Text('Video bağlantısı panoya kopyalandı.'),
      ),
    );
  }

  Future<void> _indirmeDurumunuKontrolEt() async {
    try {
      final indirilenIdler = await _vtServisi.indirilenIdleriGetir();
      if (!mounted) return;
      setState(() {
        _indirildiMi = indirilenIdler.contains(widget.tarif.id);
        widget.tarif.indirildiMi = _indirildiMi;
      });
    } catch (_) {}
  }

  Future<void> _tarifIndirVeyaKaldir() async {
    if (_indiriliyor) return;
    setState(() => _indiriliyor = true);

    try {
      if (_indirildiMi) {
        await _vtServisi.tarifSil(widget.tarif.id);
        widget.tarif.indirildiMi = false;
        if (!mounted) return;
        setState(() => _indirildiMi = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.klasikKirmizi,
            content: Text('${widget.tarif.baslik} indirilenlerden kaldırıldı.'),
          ),
        );
      } else {
        widget.tarif.indirildiMi = true;
        await _vtServisi.tarifKaydet(widget.tarif);
        if (!mounted) return;
        setState(() => _indirildiMi = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.klasikKirmizi,
            content: Text('${widget.tarif.baslik} cihazına indirildi.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.klasikKirmizi,
          content: Text('İndirme işlemi sırasında bir hata oluştu.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _indiriliyor = false);
      }
    }
  }

  @override
  void deactivate() {
    _youtubeController?.pauseVideo();
    super.deactivate();
  }

  @override
  void dispose() {
    _youtubeController?.close();
    super.dispose();
  }

  bool _stepBasligiMi(String adim) {
    return RegExp(r'^step\s*\d+\b', caseSensitive: false).hasMatch(adim.trim());
  }

  Widget _youtubeBolumu(YoutubePlayerController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tarif Videosu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton.icon(
              onPressed: _linkiKopyala,
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Linki Kopyala'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.klasikKirmizi,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: YoutubePlayer(
            controller: controller,
            aspectRatio: 16 / 9,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Video oynatıcıda "Unavailable" görünüyorsa video sahibi uygulama içi gömülü oynatmayı kapatmış veya bağlantı geçersiz olabilir.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _videoYokKarti() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: const [
                Icon(
                  Icons.videocam_off_outlined,
                  color: AppTheme.klasikKirmizi,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bu tarif için kayıtlı veya geçerli bir YouTube videosu bulunmuyor.',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _hazirlanisBolumu(List<String> yapilis) {
    if (yapilis.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Text('Hazırlanış adımı bulunamadı.'),
        ),
      );
    }

    return Card(
      child: Column(
        children: List.generate(yapilis.length, (index) {
          final adim = yapilis[index].trim();
          final stepBasligi = _stepBasligiMi(adim);
          final sonrakiStepMi =
              index + 1 < yapilis.length && _stepBasligiMi(yapilis[index + 1]);
          final sonAdimMi = index == yapilis.length - 1;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  stepBasligi ? 16 : 14,
                  16,
                  stepBasligi ? 8 : 14,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    adim,
                    style: stepBasligi
                        ? TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.klasikKirmizi,
                          )
                        : Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.45,
                            ),
                  ),
                ),
              ),
              if (!sonAdimMi)
                Divider(
                  height: 1,
                  thickness: sonrakiStepMi ? 1.5 : 0.8,
                  color: sonrakiStepMi
                      ? AppTheme.klasikKirmizi.withValues(alpha: 0.45)
                      : Theme.of(context).dividerColor.withValues(alpha: 0.5),
                ),
            ],
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tarif = widget.tarif;
    final controller = _youtubeController;
    final koyuTemaMi = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            koyuTemaMi ? AppTheme.koyuKirmiziBar : AppTheme.klasikKirmizi,
        foregroundColor: AppTheme.safBeyaz,
        title: Text(tarif.baslik),
        actions: [
          IconButton(
            tooltip: _indirildiMi ? 'İndirileni Sil' : 'Tarifi İndir',
            onPressed: _indiriliyor ? null : _tarifIndirVeyaKaldir,
            icon: _indiriliyor
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _indirildiMi
                        ? Icons.download_done_rounded
                        : Icons.download_for_offline_outlined,
                  ),
          ),
        ],
      ),
      body: BuguluKirmiziArkaPlan(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tarif.gorselUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    tarif.gorselUrl,
                    width: double.infinity,
                    height: 210,
                    cacheWidth: 800,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _err, _stack) => const SizedBox.shrink(),
                  ),
                ),
              if (tarif.gorselUrl.isNotEmpty) const SizedBox(height: 16),
              Text(
                tarif.baslik,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                '${tarif.kategori} • ${tarif.pisirilisSekli} • ${tarif.sureDk} dk • ${tarif.porsiyon} porsiyon',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _besinKutusu(
                          'Kalori', '${tarif.besinDegerleri.kalori} kcal'),
                      _besinKutusu(
                          'Protein', '${tarif.besinDegerleri.protein} g'),
                      _besinKutusu(
                          'Karb.', '${tarif.besinDegerleri.karbonhidrat} g'),
                      _besinKutusu('Yağ', '${tarif.besinDegerleri.yag} g'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (controller != null && _videoId != null)
                _youtubeBolumu(controller)
              else
                _videoYokKarti(),
              Text(
                'Malzemeler',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (tarif.malzemeler.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Text('Malzeme bilgisi bulunamadı.'),
                  ),
                )
              else
                Card(
                  child: Column(
                    children: tarif.malzemeler
                        .map(
                          (m) => ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.check_circle_outline,
                              color: AppTheme.klasikKirmizi,
                              size: 20,
                            ),
                            title: Text(m.ad),
                            trailing: Text(
                              m.miktar,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Hazırlanışı',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _hazirlanisBolumu(tarif.yapilis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _besinKutusu(String baslik, String deger) {
    return Column(
      children: [
        Text(
          deger,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppTheme.klasikKirmizi,
          ),
        ),
        const SizedBox(height: 2),
        Text(baslik, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}