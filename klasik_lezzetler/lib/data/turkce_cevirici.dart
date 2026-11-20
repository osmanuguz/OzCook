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
    'sunflower oil': 'Ayçiçek yağı',
    'chicken breast': 'Tavuk göğsü',
    'chicken breasts': 'Tavuk göğsü',
    'chicken thighs': 'Tavuk but',
    'chicken thigh': 'Tavuk but',
    'minced beef': 'Dana kıyma',
    'ground beef': 'Dana kıyma',
    'tomato paste': 'Domates salçası',
    'tomato sauce': 'Domates sosu',
    'brown sugar': 'Esmer şeker',
    'powdered sugar': 'Pudra şekeri',
    'icing sugar': 'Pudra şekeri',
    'black pepper': 'Karabiber',
    'baking powder': 'Kabartma tozu',
    'baking soda': 'Karbonat',
    'vanilla extract': 'Vanilya özütü',
    'cocoa powder': 'Kakao tozu',
    'dark chocolate': 'Bitter çikolata',
    'milk chocolate': 'Sütlü çikolata',
    'heavy cream': 'Sıvı krema',
    'double cream': 'Yoğun krema',
    'sour cream': 'Ekşi krema',
    'cheddar cheese': 'Çedar peyniri',
    'parmesan cheese': 'Parmesan peyniri',
    'mozzarella cheese': 'Mozzarella peyniri',
    'feta cheese': 'Beyaz peynir',
    'cream cheese': 'Krem peynir',
    'chicken stock': 'Tavuk suyu',
    'beef stock': 'Et suyu',
    'vegetable stock': 'Sebze suyu',
    'lemon juice': 'Limon suyu',
    'soy sauce': 'Soya sosu',
    'chili powder': 'Acı biber tozu',
    'red chili': 'Kırmızı acı biber',
    'green pepper': 'Yeşil biber',
    'red pepper': 'Kırmızı biber',
    'bell pepper': 'Dolmalık biber',
    'spring onion': 'Taze soğan',
    'spring onions': 'Taze soğan',
    'red onion': 'Kırmızı soğan',
    'chicken': 'Tavuk',
    'beef': 'Dana eti',
    'lamb': 'Kuzu eti',
    'pork': 'Domuz eti',
    'salmon': 'Somon',
    'shrimp': 'Karides',
    'prawns': 'Karides',
    'tuna': 'Ton balığı',
    'egg': 'Yumurta',
    'eggs': 'Yumurta',
    'egg yolk': 'Yumurta sarısı',
    'egg white': 'Yumurta beyazı',
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
    'noodles': 'Erişte / Noodle',
    'bread': 'Ekmek',
    'lemon': 'Limon',
    'lime': 'Misket limonu',
    'orange': 'Portakal',
    'chocolate': 'Çikolata',
    'honey': 'Bal',
    'cream': 'Krema',
    'yogurt': 'Yoğurt',
    'parsley': 'Maydanoz',
    'coriander': 'Kişniş',
    'basil': 'Fesleğen',
    'thyme': 'Kekik',
    'oregano': 'Kekik',
    'rosemary': 'Biberiye',
    'mint': 'Nane',
    'cumin': 'Kimyon',
    'paprika': 'Toz biber',
    'cinnamon': 'Tarçın',
    'water': 'Su',
    'mushroom': 'Mantar',
    'mushrooms': 'Mantar',
    'spinach': 'Ispanak',
    'lettuce': 'Marul',
    'banana': 'Muz',
    'apple': 'Elma',
    'apples': 'Elma',
    'strawberry': 'Çilek',
    'strawberries': 'Çilek',
    'almonds': 'Badem',
    'almond': 'Badem',
    'walnuts': 'Ceviz',
    'walnut': 'Ceviz',
    'hazelnuts': 'Fındık',
    'hazelnut': 'Fındık',
    'oats': 'Yulaf',
    'lentils': 'Mercimek',
    'chickpeas': 'Nohut',
    'beans': 'Fasulye',
  };

  static const Map<String, String> _yemekKalipMap = {
    'apple pie': 'Elmalı Turta',
    'banana bread': 'Muzlu Kek',
    'chocolate cake': 'Çikolatalı Kek',
    'cheese omelette': 'Peynirli Omlet',
    'fried rice': 'Kavrulmuş Pilav',
    'mashed potatoes': 'Patates Püresi',
    'french fries': 'Patates Kızartması',
    'chicken soup': 'Tavuk Çorbası',
    'tomato soup': 'Domates Çorbası',
    'caesar salad': 'Sezar Salata',
    'greek salad': 'Akdeniz / Yunan Salatası',
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

  static const Map<String, String> _olcuMap = {
    'tablespoons': 'yemek kaşığı',
    'tablespoon': 'yemek kaşığı',
    'tbsp': 'yemek kaşığı',
    'teaspoons': 'tatlı kaşığı',
    'teaspoon': 'tatlı kaşığı',
    'tsp': 'tatlı kaşığı',
    'cups': 'su bardağı',
    'cup': 'su bardağı',
    'ounces': 'ons',
    'ounce': 'ons',
    'oz': 'ons',
    'pounds': 'libre',
    'pound': 'libre',
    'lb': 'libre',
    'lbs': 'libre',
    'grams': 'gr',
    'gram': 'gr',
    'kilograms': 'kg',
    'kilogram': 'kg',
    'milliliters': 'ml',
    'milliliter': 'ml',
    'liters': 'litre',
    'liter': 'litre',
    'cloves': 'diş',
    'clove': 'diş',
    'slices': 'dilim',
    'slice': 'dilim',
    'pinch': 'çimdik',
    'handful': 'avuç',
    'bunch': 'demet',
    'can': 'kutu',
    'cans': 'kutu',
    'to taste': 'damak tadına göre',
    'as needed': 'gerektiği kadar',
  };

  static const Map<String, String> _adimKalipMap = {
    'preheat the oven': 'fırını önceden ısıtın',
    'heat oil in a pan': 'tavada yağı ısıtın',
    'heat oil in a large pan': 'geniş bir tavada yağı ısıtın',
    'heat butter in a pan': 'tavada tereyağını eritin',
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
    'baked': 'pişirilmiş',
    'boil': 'kaynatın',
    'simmer': 'kısık ateşte kaynatın',
    'fry': 'kızartın',
    'fried': 'kızarmış',
    'saute': 'soteleyin',
    'chop': 'doğrayın',
    'chopped': 'doğranmış',
    'dice': 'küp doğrayın',
    'diced': 'küp doğranmış',
    'slice': 'dilimleyin',
    'sliced': 'dilimlenmiş',
    'mince': 'ince kıyın',
    'minced': 'kıyılmış',
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
    'hours': 'saat',
    'hour': 'saat',
    'until': 'kadar',
    'brown': 'kahverengi',
    'pan': 'tava',
    'pot': 'tencere',
    'bowl': 'kase',
    'cool': 'soğumaya bırakın',
    'drain': 'süzün',
  };

  static String _sozlukleDegistir(
    String metin,
    Map<String, String> sozluk, {
    bool artikelleriTemizle = false,
  }) {
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

    if (artikelleriTemizle) {
      sonuc = sonuc.replaceAll(
        RegExp(r'\b(the|a|an)\b', caseSensitive: false),
        ' ',
      );
    }

    return sonuc.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String kategoriCevir(String kategori) {
    final anahtar = kategori.trim().toLowerCase();
    return _kategoriMap[anahtar] ?? kategori;
  }

  static String malzemeCevir(String malzeme) {
    final temiz = malzeme.trim();
    if (temiz.isEmpty) return temiz;

    final kucuk = temiz.toLowerCase();
    if (_malzemeMap.containsKey(kucuk)) {
      final ceviri = _malzemeMap[kucuk]!;
      return ceviri[0].toUpperCase() + ceviri.substring(1);
    }

    final sonuc = _sozlukleDegistir(
      temiz,
      _malzemeMap,
      artikelleriTemizle: true,
    );
    if (sonuc.isEmpty) return temiz;
    return sonuc[0].toUpperCase() + sonuc.substring(1);
  }

  static String miktarCevir(String miktar) {
    final temiz = miktar.trim();
    if (temiz.isEmpty) return 'Yeterince';

    final sonuc = _sozlukleDegistir(temiz, _olcuMap);
    if (sonuc.isEmpty) return 'Yeterince';
    return sonuc[0].toUpperCase() + sonuc.substring(1);
  }

  static String yemekAdiCevir(String baslik) {
    final orijinal = baslik.trim();
    if (orijinal.isEmpty) return orijinal;

    final kucuk = orijinal.toLowerCase();
    if (_yemekKalipMap.containsKey(kucuk)) {
      return '${_yemekKalipMap[kucuk]!} ($orijinal)';
    }

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
    final birlesik = cevrilenKelimeler
        .join(' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return '$birlesik ($orijinal)';
  }

  static String yapilisAdimiCevir(String adim) {
    final temiz = adim.trim();
    if (temiz.isEmpty) return temiz;

    final sonuc = _sozlukleDegistir(
      temiz,
      _adimKalipMap,
      artikelleriTemizle: true,
    );
    if (sonuc.isEmpty) return sonuc;
    return sonuc[0].toUpperCase() + sonuc.substring(1);
  }
}