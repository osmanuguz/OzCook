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
    'sesame oil': 'Susam yağı',
    'chicken breast': 'Tavuk göğsü',
    'chicken breasts': 'Tavuk göğsü',
    'chicken thighs': 'Tavuk but',
    'chicken thigh': 'Tavuk but',
    'chicken wings': 'Tavuk kanat',
    'minced beef': 'Dana kıyma',
    'ground beef': 'Dana kıyma',
    'tomato paste': 'Domates salçası',
    'tomato sauce': 'Domates sosu',
    'tomato puree': 'Domates püresi',
    'brown sugar': 'Esmer şeker',
    'powdered sugar': 'Pudra şekeri',
    'icing sugar': 'Pudra şekeri',
    'black pepper': 'Karabiber',
    'white pepper': 'Beyaz biber',
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
    'feta': 'Beyaz peynir',
    'rocket': 'Roka',
    'harissa spice': 'Harissa baharatı',
    'pine nuts': 'Çam fıstığı',
    'cream cheese': 'Krem peynir',
    'chicken stock': 'Tavuk suyu',
    'beef stock': 'Et suyu',
    'vegetable stock': 'Sebze suyu',
    'lemon juice': 'Limon suyu',
    'lime juice': 'Misket limonu suyu',
    'soy sauce': 'Soya sosu',
    'worcestershire sauce': 'Worcestershire sosu',
    'chili powder': 'Acı biber tozu',
    'red chili': 'Kırmızı acı biber',
    'green chili': 'Yeşil acı biber',
    'green pepper': 'Yeşil biber',
    'red pepper': 'Kırmızı biber',
    'bell pepper': 'Dolmalık biber',
    'spring onion': 'Taze soğan',
    'spring onions': 'Taze soğan',
    'green onion': 'Taze soğan',
    'green onions': 'Taze soğan',
    'red onion': 'Kırmızı soğan',
    'bay leaf': 'Defne yaprağı',
    'bay leaves': 'Defne yaprağı',
    'chicken': 'Tavuk',
    'beef': 'Dana eti',
    'lamb': 'Kuzu eti',
    'pork': 'Domuz eti',
    'bacon': 'Pastırma / Bacon',
    'sausage': 'Sosis',
    'sausages': 'Sosis',
    'salmon': 'Somon',
    'shrimp': 'Karides',
    'prawns': 'Karides',
    'tuna': 'Ton balığı',
    'cod': 'Morina balığı',
    'egg': 'Yumurta',
    'eggs': 'Yumurta',
    'egg yolk': 'Yumurta sarısı',
    'egg white': 'Yumurta beyazı',
    'milk': 'Süt',
    'butter': 'Tereyağı',
    'oil': 'Sıvı yağ',
    'flour': 'Un',
    'plain flour': 'Çok amaçlı un',
    'self-raising flour': 'Kabartma tozlu un',
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
    'sweet potato': 'Tatlı patates',
    'carrot': 'Havuç',
    'carrots': 'Havuç',
    'zucchini': 'Kabak',
    'courgette': 'Kabak',
    'eggplant': 'Patlıcan',
    'aubergine': 'Patlıcan',
    'cheese': 'Peynir',
    'rice': 'Pirinç',
    'pasta': 'Makarna',
    'spaghetti': 'Spagetti',
    'noodles': 'Erişte / Noodle',
    'bread': 'Ekmek',
    'breadcrumbs': 'Galeta unu',
    'lemon': 'Limon',
    'lime': 'Misket limonu',
    'orange': 'Portakal',
    'chocolate': 'Çikolata',
    'honey': 'Bal',
    'maple syrup': 'Akçaağaç şurubu',
    'cream': 'Krema',
    'yogurt': 'Yoğurt',
    'yoghurt': 'Yoğurt',
    'parsley': 'Maydanoz',
    'coriander': 'Kişniş',
    'cilantro': 'Kişniş',
    'dill': 'Dereotu',
    'chives': 'Frenk soğanı',
    'basil': 'Fesleğen',
    'thyme': 'Kekik',
    'oregano': 'Kekik',
    'rosemary': 'Biberiye',
    'mint': 'Nane',
    'cumin': 'Kimyon',
    'paprika': 'Toz biber',
    'turmeric': 'Zerdeçal',
    'ginger': 'Zencefil',
    'cinnamon': 'Tarçın',
    'nutmeg': 'Muskat',
    'water': 'Su',
    'vinegar': 'Sirke',
    'mayonnaise': 'Mayonez',
    'mustard': 'Hardal',
    'ketchup': 'Ketçap',
    'mushroom': 'Mantar',
    'mushrooms': 'Mantar',
    'spinach': 'Ispanak',
    'lettuce': 'Marul',
    'cabbage': 'Lahana',
    'broccoli': 'Brokoli',
    'cauliflower': 'Karnabahar',
    'corn': 'Mısır',
    'sweetcorn': 'Tatlı mısır',
    'peas': 'Bezelye',
    'avocado': 'Avokado',
    'banana': 'Muz',
    'apple': 'Elma',
    'apples': 'Elma',
    'strawberry': 'Çilek',
    'strawberries': 'Çilek',
    'blueberry': 'Yaban mersini',
    'blueberries': 'Yaban mersini',
    'almonds': 'Badem',
    'almond': 'Badem',
    'walnuts': 'Ceviz',
    'walnut': 'Ceviz',
    'hazelnuts': 'Fındık',
    'hazelnut': 'Fındık',
    'peanuts': 'Yer fıstığı',
    'peanut butter': 'Fıstık ezmesi',
    'oats': 'Yulaf',
    'lentils': 'Mercimek',
    'chickpeas': 'Nohut',
    'beans': 'Fasulye',
    'black beans': 'Siyah fasulye',
    'kidney beans': 'Barbunya / Böbrek fasulyesi',
  };

  static const Map<String, String> _yemekKalipMap = {
    'apple pie': 'Elmalı Turta',
    'apple crumble': 'Elmalı Crumble',
    'banana bread': 'Muzlu Kek',
    'chocolate cake': 'Çikolatalı Kek',
    'chocolate mousse': 'Çikolatalı Mus',
    'cheese omelette': 'Peynirli Omlet',
    'fried rice': 'Kavrulmuş Pilav',
    'egg fried rice': 'Yumurtalı Kavrulmuş Pilav',
    'mashed potatoes': 'Patates Püresi',
    'baked potatoes': 'Fırın Patates',
    'roast potatoes': 'Fırınlanmış Patates',
    'french fries': 'Patates Kızartması',
    'chicken soup': 'Tavuk Çorbası',
    'tomato soup': 'Domates Çorbası',
    'caesar salad': 'Sezar Salata',
    'greek salad': 'Akdeniz / Yunan Salatası',
    'chicken curry': 'Körili Tavuk',
    'beef stroganoff': 'Dana Stroganof',
    'fish and chips': 'Balık ve Patates Kızartması',
    'mac and cheese': 'Peynirli Makarna',
    'macaroni and cheese': 'Peynirli Makarna',
    'chocolate chip cookies': 'Damla Çikolatalı Kurabiye',
    'garlic bread': 'Sarımsaklı Ekmek',
    'meatball soup': 'Köfte Çorbası',
    'lentil soup': 'Mercimek Çorbası',
    'stuffed peppers': 'Biber Dolması',
    'chicken noodle soup': 'Şehriyeli Tavuk Çorbası',
    'grilled cheese': 'Izgara Peynirli Sandviç',
    'chicken fajitas': 'Tavuklu Fajita',
    'beef tacos': 'Dana Etli Taco',
    'chicken tikka masala': 'Tavuk Tikka Masala',
    'pad thai': 'Pad Thai Eriştesi',
    'shepherds pie': 'Çoban Turta',
    'fish pie': 'Balıklı Turta',
    'lemon cake': 'Limonlu Kek',
    'carrot cake': 'Havuçlu Kek',
    'tiramisu': 'Tiramisu Tatlısı',
    'creme brulee': 'Krem Brüle',
    'panna cotta': 'Panna Cotta',
    'pancake stack': 'Katlı Pankek',
    'french toast': 'Fransız Tostu',
    'shakshuka': 'Şakşuka',
    'falafel': 'Falafel',
    'hummus': 'Humus',
    'guacamole': 'Guacamole Sos',
    'lasagna': 'Lazanya',
    'carbonara': 'Karbonara Makarna',
    'bolognese': 'Bolonez Soslu Makarna',
    'paella': 'Paella Pilavı',
    'ramen': 'Ramen Çorbası',
    'pho': 'Pho Çorbası',
    'spring rolls': 'Çıtır Börek / Rulolar',
    'dumplings': 'Mantı / Buhar Böreği',
    'meatballs': 'Köfte',
    'stuffed aubergine': 'Patlıcan Karnıyarık / Dolma',
    'ratatouille': 'Ratatuy Sebze Yemeği',
    'chili con carne': 'Acılı Kıymalı Yemek',
  };

  static const Map<String, String> _yemekKelimeMap = {
    'baked': 'Fırında',
    'roasted': 'Fırınlanmış',
    'roast': 'Fırın',
    'grilled': 'Izgara',
    'grill': 'Izgara',
    'fried': 'Kızarmış',
    'fry': 'Kızartma',
    'crispy': 'Çıtır',
    'spicy': 'Acılı',
    'sweet': 'Tatlı',
    'sour': 'Ekşi',
    'creamy': 'Kremalı',
    'cream': 'Kremalı',
    'cheesy': 'Peynirli',
    'stuffed': 'Dolgulu',
    'glazed': 'Soslu',
    'smoked': 'İsli / Füme',
    'steamed': 'Buharda',
    'boiled': 'Haşlanmış',
    'braised': 'Buharda / Ağır Pişmiş',
    'garlic': 'Sarımsaklı',
    'lemon': 'Limonlu',
    'lime': 'Limonlu',
    'chicken': 'Tavuklu',
    'beef': 'Dana Etli',
    'lamb': 'Kuzulu',
    'pork': 'Domuz Etli',
    'goat': 'Keçi Etli',
    'fish': 'Balıklı',
    'salmon': 'Somonlu',
    'tuna': 'Ton Balıklı',
    'cod': 'Morina Balıklı',
    'shrimp': 'Karidesli',
    'prawn': 'Karidesli',
    'prawns': 'Karidesli',
    'egg': 'Yumurtalı',
    'eggs': 'Yumurtalı',
    'cheese': 'Peynirli',
    'chocolate': 'Çikolatalı',
    'apple': 'Elmalı',
    'banana': 'Muzlu',
    'strawberry': 'Çilekli',
    'berry': 'Meyveli',
    'berries': 'Meyveli',
    'cake': 'Kek',
    'pie': 'Turta',
    'tart': 'Tart',
    'crumble': 'Crumble',
    'brownie': 'Browni',
    'cheesecake': 'Cheesecake',
    'cookie': 'Kurabiye',
    'cookies': 'Kurabiye',
    'biscuit': 'Bisküvi',
    'biscuits': 'Bisküvi',
    'pudding': 'Puding',
    'mousse': 'Mus',
    'soup': 'Çorbası',
    'stew': 'Yahni',
    'broth': 'Et Suyu',
    'salad': 'Salatası',
    'pasta': 'Makarnası',
    'spaghetti': 'Spagetti',
    'penne': 'Penne Makarna',
    'macaroni': 'Makarna',
    'noodle': 'Erişte',
    'noodles': 'Erişte',
    'rice': 'Pilavı',
    'risotto': 'Risotto',
    'curry': 'Körili Yemek',
    'pancake': 'Pankek',
    'pancakes': 'Pankek',
    'waffle': 'Waffle',
    'omelette': 'Omlet',
    'sandwich': 'Sandviç',
    'burger': 'Burger',
    'wrap': 'Dürüm',
    'taco': 'Taco',
    'tacos': 'Taco',
    'fajita': 'Fajita',
    'fajitas': 'Fajita',
    'bread': 'Ekmek',
    'roll': 'Rulo / Ekmek',
    'rolls': 'Rulo / Börek',
    'potato': 'Patatesli',
    'potatoes': 'Patatesli',
    'mushroom': 'Mantarlı',
    'mushrooms': 'Mantarlı',
    'spinach': 'Ispanaklı',
    'broccoli': 'Brokolili',
    'cauliflower': 'Karnabaharlı',
    'tomato': 'Domatesli',
    'tomatoes': 'Domatesli',
    'onion': 'Soğanlı',
    'onions': 'Soğanlı',
    'pepper': 'Biberli',
    'peppers': 'Biberli',
    'carrot': 'Havuçlu',
    'carrots': 'Havuçlu',
    'aubergine': 'Patlıcanlı',
    'eggplant': 'Patlıcanlı',
    'courgette': 'Kabaklı',
    'zucchini': 'Kabaklı',
    'bean': 'Fasulyeli',
    'beans': 'Fasulyeli',
    'lentil': 'Mercimekli',
    'lentils': 'Mercimekli',
    'chickpea': 'Nohutlu',
    'chickpeas': 'Nohutlu',
    'honey': 'Ballı',
    'cinnamon': 'Tarçınlı',
    'ginger': 'Zencefilli',
    'almond': 'Bademli',
    'almonds': 'Bademli',
    'walnut': 'Cevizli',
    'walnuts': 'Cevizli',
    'hazelnut': 'Fındıklı',
    'hazelnuts': 'Fındıklı',
    'peanut': 'Fıstıklı',
    'peanuts': 'Fıstıklı',
    'orange': 'Portakallı',
    'meatballs': 'Köfte',
    'meatball': 'Köfte',
    'sausage': 'Sosisli',
    'sausages': 'Sosisli',
    'bacon': 'Pastırmalı',
    'sauce': 'Soslu',
    'glaze': 'Soslu',
    'bowl': 'Kase',
    'skillet': 'Tavada',
    'pot': 'Tencerede',
    'classic': 'Klasik',
    'easy': 'Pratik',
    'quick': 'Hızlı',
    'homemade': 'Ev Yapımı',
    'style': 'Usulü',
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
    'medium': 'orta boy',
    'large': 'büyük boy',
    'small': 'küçük boy',
    'juice of half': 'Yarım limonun suyu',
    'chopped': 'doğranmış',
    'half': 'yarım',
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
    'until tender': 'yumuşayana kadar',
    'until golden': 'altın rengini alana kadar',
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
    'fold': 'nazikçe karıştırın',
    'add': 'ekleyin',
    'pour': 'dökün',
    'heat': 'ısıtın',
    'cook': 'pişirin',
    'serve': 'servis edin',
    'season': 'baharatlandırın',
    'cover': 'üzerini kapatın',
    'uncover': 'kapağını açın',
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
    'chill': 'soğutun',
    'refrigerate': 'buzdolabında bekletin',
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

  static String? _kelimeKarsiligiBul(String hamKelime) {
    final temiz = hamKelime
        .toLowerCase()
        .replaceAll(RegExp(r"['’]s\b"), '')
        .replaceAll(RegExp(r'[^a-z0-9\-]'), '');

    if (temiz.isEmpty) return null;
    if (_yemekKelimeMap.containsKey(temiz)) {
      return _yemekKelimeMap[temiz];
    }
    if (temiz.endsWith('ies') && temiz.length > 4) {
      final tekil = '${temiz.substring(0, temiz.length - 3)}y';
      if (_yemekKelimeMap.containsKey(tekil)) return _yemekKelimeMap[tekil];
    }
    if (temiz.endsWith('es') && temiz.length > 4) {
      final tekil = temiz.substring(0, temiz.length - 2);
      if (_yemekKelimeMap.containsKey(tekil)) return _yemekKelimeMap[tekil];
    }
    if (temiz.endsWith('s') && temiz.length > 3) {
      final tekil = temiz.substring(0, temiz.length - 1);
      if (_yemekKelimeMap.containsKey(tekil)) return _yemekKelimeMap[tekil];
    }
    return null;
  }

  static String yemekAdiCevir(String baslik) {
    final orijinal = baslik.trim();
    if (orijinal.isEmpty) return orijinal;

    // Zaten "(...)" ile çevrilmişse tekrar parantez ekleme
    if (orijinal.contains('(') && orijinal.endsWith(')')) {
      return orijinal;
    }

    final kucuk = orijinal.toLowerCase();
    if (_yemekKalipMap.containsKey(kucuk)) {
      return '${_yemekKalipMap[kucuk]!} ($orijinal)';
    }

    // Kalıp içinde geçiyor mu kontrol et
    final siraliKaliplar = _yemekKalipMap.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final kalip in siraliKaliplar) {
      if (RegExp('\\b${RegExp.escape(kalip)}\\b', caseSensitive: false)
          .hasMatch(kucuk)) {
        final trKalip = _yemekKalipMap[kalip]!;
        return '$trKalip ($orijinal)';
      }
    }

    final kelimeler = orijinal.split(RegExp(r'\s+'));
    final cevrilenKelimeler = <String>[];
    bool herhangiCevrildi = false;

    for (final kelime in kelimeler) {
      final karsilik = _kelimeKarsiligiBul(kelime);
      if (karsilik != null) {
        cevrilenKelimeler.add(karsilik);
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