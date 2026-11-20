class TurkceCevirici {
  static const Map<String, String> _kategoriMap = {
    'beef': 'Dana Etli',
    'breakfast': 'Kahvaltılık',
    'chicken': 'Tavuklu',
    'dessert': 'Tatlı',
    'goat': 'Keçi Etli',
    'lamb': 'Kuzu Etli',
    'miscellaneous': 'Çeşitli',
    'pasta': 'Makarna',
    'pork': 'Domuz Etli',
    'seafood': 'Deniz Ürünleri',
    'side': 'Yan Lezzet',
    'starter': 'Başlangıç',
    'vegan': 'Vegan',
    'vegetarian': 'Vejetaryen',
    'general': 'Genel',
  };

  static const Map<String, String> _malzemeMap = {
    'olive oil': 'Zeytinyağı',
    'vegetable oil': 'Bitkisel yağ',
    'chicken breast': 'Tavuk göğsü',
    'chicken thighs': 'Tavuk but',
    'minced beef': 'Dana kıyma',
    'tomato paste': 'Domates salçası',
    'brown sugar': 'Esmer şeker',
    'black pepper': 'Karabiber',
    'baking powder': 'Kabartma tozu',
    'baking soda': 'Karbonat',
    'vanilla extract': 'Vanilya özütü',
    'cocoa powder': 'Kakao tozu',
    'dark chocolate': 'Bitter çikolata',
    'heavy cream': 'Sıvı krema',
    'cheddar cheese': 'Çedar peyniri',
    'parmesan cheese': 'Parmesan peyniri',
    'chicken stock': 'Tavuk suyu',
    'beef stock': 'Et suyu',
    'lemon juice': 'Limon suyu',
    'soy sauce': 'Soya sosu',
    'chili powder': 'Acı biber tozu',
    'chicken': 'Tavuk',
    'beef': 'Dana eti',
    'lamb': 'Kuzu eti',
    'salmon': 'Somon',
    'shrimp': 'Karides',
    'prawns': 'Karides',
    'tuna': 'Ton balığı',
    'egg': 'Yumurta',
    'eggs': 'Yumurta',
    'milk': 'Süt',
    'butter': 'Tereyağı',
    'oil': 'Sıvı yağ',
    'flour': 'Un',
    'sugar': 'Şeker',
    'salt': 'Tuz',
    'pepper': 'Biber',
    'garlic': 'Sarımsak',
    'onion': 'Soğan',
    'onions': 'Soğan',
    'tomato': 'Domates',
    'tomatoes': 'Domates',
    'cucumber': 'Salatalık',
    'potato': 'Patates',
    'potatoes': 'Patates',
    'carrot': 'Havuç',
    'carrots': 'Havuç',
    'cheese': 'Peynir',
    'rice': 'Pirinç',
    'pasta': 'Makarna',
    'spaghetti': 'Spagetti',
    'lemon': 'Limon',
    'chocolate': 'Çikolata',
    'honey': 'Bal',
    'cream': 'Krema',
    'yogurt': 'Yoğurt',
    'parsley': 'Maydanoz',
    'coriander': 'Kişniş',
    'basil': 'Fesleğen',
    'thyme': 'Kekik',
    'cumin': 'Kimyon',
    'paprika': 'Toz biber',
    'water': 'Su',
    'mushroom': 'Mantar',
    'mushrooms': 'Mantar',
    'spinach': 'Ispanak',
    'lettuce': 'Marul',
    'banana': 'Muz',
    'apple': 'Elma',
    'strawberry': 'Çilek',
    'strawberries': 'Çilek',
    'almonds': 'Badem',
    'walnuts': 'Ceviz',
    'hazelnuts': 'Fındık',
  };

  static const Map<String, String> _yemekKelimeMap = {
    'baked': 'Fırında',
    'roasted': 'Fırınlanmış',
    'grilled': 'Izgara',
    'fried': 'Kızarmış',
    'crispy': 'Çıtır',
    'spicy': 'Acılı',
    'sweet': 'Tatlı',
    'sour': 'Ekşi',
    'creamy': 'Kremalı',
    'garlic': 'Sarımsaklı',
    'lemon': 'Limonlu',
    'chicken': 'Tavuklu',
    'beef': 'Dana Etli',
    'lamb': 'Kuzulu',
    'fish': 'Balıklı',
    'salmon': 'Somonlu',
    'shrimp': 'Karidesli',
    'egg': 'Yumurtalı',
    'cheese': 'Peynirli',
    'chocolate': 'Çikolatalı',
    'apple': 'Elmalı',
    'banana': 'Muzlu',
    'strawberry': 'Çilekli',
    'cake': 'Kek',
    'pie': 'Turta',
    'tart': 'Tart',
    'cookie': 'Kurabiye',
    'cookies': 'Kurabiye',
    'pudding': 'Puding',
    'soup': 'Çorbası',
    'salad': 'Salatası',
    'pasta': 'Makarnası',
    'rice': 'Pilavı',
    'stew': 'Yahni',
    'curry': 'Körili Yemek',
    'pancake': 'Pankek',
    'pancakes': 'Pankek',
    'omelette': 'Omlet',
    'sandwich': 'Sandviç',
    'burger': 'Burger',
    'wrap': 'Dürüm',
  };

  static const Map<String, String> _adimKalipMap = {
    'preheat the oven': 'fırını önceden ısıtın',
    'heat oil in a pan': 'tavada yağı ısıtın',
    'heat oil in a large pan': 'geniş bir tavada yağı ısıtın',
    'add the onion and garlic': 'soğan ve sarımsağı ekleyin',
    'season with salt and pepper': 'tuz ve karabiber ile tatlandırın',
    'remove from heat': 'ocaktan alın',
    'set aside': 'bir kenara alın',
    'serve hot': 'sıcak servis edin',
    'serve immediately': 'hemen servis edin',
    'golden brown': 'altın sarısı rengini alana kadar',
    'medium heat': 'orta ateşte',
    'low heat': 'kısık ateşte',
    'high heat': 'yüksek ateşte',
    'preheat': 'önceden ısıtın',
    'oven': 'fırın',
    'bake': 'pişirin',
    'boil': 'kaynatın',
    'simmer': 'kısık ateşte kaynatın',
    'fry': 'kızartın',
    'saute': 'soteleyin',
    'chop': 'doğrayın',
    'dice': 'küp doğrayın',
    'slice': 'dilimleyin',
    'mince': 'ince kıyın',
    'mix': 'karıştırın',
    'stir': 'karıştırın',
    'whisk': 'çırpın',
    'add': 'ekleyin',
    'pour': 'dökün',
    'heat': 'ısıtın',
    'cook': 'pişirin',
    'serve': 'servis edin',
    'season': 'baharatlandırın',
    'salt': 'tuz',
    'pepper': 'karabiber',
    'water': 'su',
    'oil': 'yağ',
    'butter': 'tereyağı',
    'onion': 'soğan',
    'garlic': 'sarımsak',
    'tomato': 'domates',
    'chicken': 'tavuk',
    'beef': 'et',
    'minutes': 'dakika',
    'minute': 'dakika',
    'until': 'kadar',
    'brown': 'kahverengi',
    'pan': 'tava',
    'pot': 'tencere',
    'bowl': 'kase',
    'cool': 'soğumaya bırakın',
    'drain': 'süzün',
  };

  static String _sozlukleDegistir(String metin, Map<String, String> sozluk) {
    final siraliAnahtarlar = sozluk.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    String sonuc = metin;
    for (final anahtar in siraliAnahtarlar) {
      final karsilik = sozluk[anahtar]!;
      sonuc = sonuc.replaceAll(
        RegExp('\\b${RegExp.escape(anahtar)}\\b', caseSensitive: false),
        karsilik,
      );
    }
    return sonuc;
  }

  static String kategoriCevir(String kategori) {
    final anahtar = kategori.trim().toLowerCase();
    return _kategoriMap[anahtar] ?? kategori;
  }

  static String malzemeCevir(String malzeme) {
    final temiz = malzeme.trim();
    final kucuk = temiz.toLowerCase();
    if (_malzemeMap.containsKey(kucuk)) {
      final ceviri = _malzemeMap[kucuk]!;
      return ceviri[0].toUpperCase() + ceviri.substring(1);
    }

    final sonuc = _sozlukleDegistir(temiz, _malzemeMap);
    if (sonuc.isEmpty) return sonuc;
    return sonuc[0].toUpperCase() + sonuc.substring(1);
  }

  static String yemekAdiCevir(String baslik) {
    final orijinal = baslik.trim();
    if (orijinal.isEmpty) return orijinal;

    final kelimeler = orijinal.split(RegExp(r'\s+'));
    final cevrilenKelimeler = <String>[];
    bool herhangiCevrildi = false;

    for (final kelime in kelimeler) {
      final temiz = kelime.replaceAll(RegExp(r'[^\w\-]'), '').toLowerCase();
      if (_yemekKelimeMap.containsKey(temiz)) {
        cevrilenKelimeler.add(_yemekKelimeMap[temiz]!);
        herhangiCevrildi = true;
      } else {
        cevrilenKelimeler.add(kelime);
      }
    }

    if (!herhangiCevrildi) return orijinal;
    final birlesik = cevrilenKelimeler.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    return '$birlesik ($orijinal)';
  }

  static String yapilisAdimiCevir(String adim) {
    final temiz = adim.trim();
    if (temiz.isEmpty) return temiz;

    final sonuc = _sozlukleDegistir(temiz, _adimKalipMap).replaceAll(RegExp(r'\s+'), ' ').trim();
    if (sonuc.isEmpty) return sonuc;
    return sonuc[0].toUpperCase() + sonuc.substring(1);
  }
}