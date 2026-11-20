class BesinDegerleri {
  final int kalori;
  final double protein;
  final double karbonhidrat;
  final double yag;

  const BesinDegerleri({
    required this.kalori,
    required this.protein,
    required this.karbonhidrat,
    required this.yag,
  });
}

class Malzeme {
  final String ad;
  final String miktar;

  const Malzeme({required this.ad, required this.miktar});
}

class Tarif {
  final String id;
  final String baslik;
  final String kategori;
  final String pisirilisSekli;
  final int sureDk;
  final int porsiyon;
  final String gorselUrl;
  final String videoUrl;
  final BesinDegerleri besinDegerleri;
  final List<Malzeme> malzemeler;
  final List<String> etiketler;
  final List<String> yapilis;
  bool indirildiMi;

  Tarif({
    required this.id,
    required this.baslik,
    required this.kategori,
    this.pisirilisSekli = 'Ocak',
    required this.sureDk,
    required this.porsiyon,
    this.gorselUrl = '',
    this.videoUrl = '',
    required this.besinDegerleri,
    required this.malzemeler,
    required this.etiketler,
    required this.yapilis,
    this.indirildiMi = false,
  });
}