class City {
  final String name;
  final String country;
  final String countryCode;
  final String imageUrl;
  final String description;
  final List<String> mustVisit;
  final double averageDailyCost;

  const City({
    required this.name,
    required this.country,
    required this.countryCode,
    required this.imageUrl,
    required this.description,
    required this.mustVisit,
    required this.averageDailyCost,
  });

  String get currencySymbol {
    switch (countryCode.toUpperCase()) {
      case 'IN': return '₹';
      case 'GB': return '£';
      case 'JP': return '¥';
      case 'AE': return 'AED ';
      case 'TH': return '฿';
      case 'ID': return 'Rp';
      case 'TR': return '₺';
      case 'BR': return r'R$';
      case 'KR': return '₩';
      case 'VN': return '₫';
      case 'TW': return r'NT$';
      case 'PH': return '₱';
      case 'CH': return 'CHF ';
      case 'EG': return 'E£';
      case 'MA': return 'MAD ';
      case 'RU': return '₽';
      case 'CN': return '¥';
      case 'ZA': return 'R';
      case 'DK':
      case 'SE':
      case 'NO':
      case 'IS': return 'kr';
      case 'FR':
      case 'IT':
      case 'ES':
      case 'NL':
      case 'GR':
      case 'AT':
      case 'DE':
      case 'PT':
      case 'IE':
      case 'FI': return '€';
      default: return r'$';
    }
  }

  double get convertedCost {
    // Basic approximate conversion rates
    switch (countryCode.toUpperCase()) {
      case 'IN': return averageDailyCost * 83.0;
      case 'JP': return averageDailyCost * 150.0;
      case 'AE': return averageDailyCost * 3.67;
      case 'TH': return averageDailyCost * 35.0;
      case 'ID': return averageDailyCost * 15600.0;
      case 'GB': return averageDailyCost * 0.79;
      case 'TR': return averageDailyCost * 31.0;
      case 'KR': return averageDailyCost * 1330.0;
      case 'VN': return averageDailyCost * 24500.0;
      case 'PH': return averageDailyCost * 56.0;
      case 'BR': return averageDailyCost * 5.0;
      case 'FR':
      case 'IT':
      case 'ES':
      case 'NL':
      case 'GR':
      case 'AT':
      case 'DE':
      case 'PT':
      case 'IE':
      case 'FI': return averageDailyCost * 0.92;
      default: return averageDailyCost;
    }
  }

  List<Map<String, String>> get mustVisitWithDescriptions {
    return mustVisit.map((place) => {
      'name': place,
      'description': CityData.getPlaceDescription(place),
    }).toList();
  }
}

class CityData {
  static List<City> get cities => [
    _city("Paris", "France", "FR", 180, "Experience the romance of the City of Light, from the iconic Eiffel Tower to world-class art at the Louvre.", ["Eiffel Tower", "Louvre Museum", "Notre Dame"]),
    _city("Dubai", "UAE", "AE", 250, "A futuristic city of luxury shopping, ultramodern architecture, and lively nightlife scene.", ["Burj Khalifa", "The Dubai Mall", "Palm Jumeirah"]),
    _city("Istanbul", "Turkey", "TR", 90, "A cultural bridge between East and West, rich in history, from the Hagia Sophia to the Grand Bazaar.", ["Hagia Sophia", "Blue Mosque", "Grand Bazaar"]),
    _city("London", "UK", "GB", 210, "A world-class city blending Roman history with modern culture, fashion, and royal heritage.", ["British Museum", "Tower of London", "Buckingham Palace"]),
    _city("Kyoto", "Japan", "JP", 150, "The heart of traditional Japan, famous for its classical Buddhist temples, gardens, and imperial palaces.", ["Fushimi Inari Taisha", "Kinkaku-ji", "Arashiyama"]),
    _city("Bangkok", "Thailand", "TH", 60, "A vibrant capital known for ornate shrines and vibrant street life.", ["Grand Palace", "Wat Arun", "Chatuchak Market"]),
    _city("New York", "USA", "US", 240, "The city that never sleeps, featuring iconic skyscrapers, Broadway shows, and Central Park.", ["Statue of Liberty", "Central Park", "Times Square"]),
    _city("Rome", "Italy", "IT", 160, "The Eternal City, showcasing nearly 3,000 years of globally influential art, architecture, and culture.", ["Colosseum", "Vatican City", "Pantheon"]),
    _city("Singapore", "Singapore", "SG", 180, "A melting pot of culture and history, and an extravaganza of culinary delights.", ["Marina Bay Sands", "Gardens by the Bay", "Sentosa"]),
    _city("Amsterdam", "Netherlands", "NL", 150, "Known for its artistic heritage, elaborate canal system, and narrow houses with gabled facades.", ["Rijksmuseum", "Van Gogh Museum", "Anne Frank House"]),
    _city("Barcelona", "Spain", "ES", 140, "Famous for the whimsical architecture of Antoni Gaudí, vibrant street life, and sandy beaches.", ["Sagrada Família", "Park Güell", "La Rambla"]),
    _city("Sydney", "Australia", "AU", 190, "Ideally situated around one of the world's largest natural harbors, known for its Opera House.", ["Sydney Opera House", "Bondi Beach", "Harbour Bridge"]),
    _city("Bali", "Indonesia", "ID", 70, "An island paradise known for its forested volcanic mountains, rice paddies, beaches and coral reefs.", ["Uluwatu Temple", "Monkey Forest", "Rice Terraces"]),
    _city("Cape Town", "South Africa", "ZA", 100, "A port city on South Africa’s southwest coast, on a peninsula beneath the imposing Table Mountain.", ["Table Mountain", "Robben Island", "V&A Waterfront"]),
    _city("Rio de Janeiro", "Brazil", "BR", 110, "Famed for its Copacabana and Ipanema beaches, 38m Christ the Redeemer statue atop Mount Corcovado.", ["Christ the Redeemer", "Sugarloaf Mountain", "Copacabana"]),
    _city("Prague", "Czech Republic", "CZ", 100, "The City of a Hundred Spires, known for its Old Town Square, colorful baroque buildings, and Gothic churches.", ["Charles Bridge", "Prague Castle", "Old Town Square"]),
    _city("Seoul", "South Korea", "KR", 130, "A huge metropolis where modern skyscrapers, high-tech subways and pop culture meet Buddhist temples.", ["Gyeongbokgung", "N Seoul Tower", "Bukchon Hanok"]),
    _city("Santorini", "Greece", "GR", 200, "Instantly recognizable for its whitewashed, cubiform houses clinging to cliffs above an underwater caldera.", ["Oia", "Fira", "Red Beach"]),
    _city("Machu Picchu", "Peru", "PE", 140, "A 15th-century Inca citadel, located in the Eastern Cordillera of southern Peru on a 2,430-meter mountain ridge.", ["Sun Gate", "Temple of the Sun", "Intihuatana"]),
    _city("Venice", "Italy", "IT", 190, "Built on more than 100 small islands in a lagoon in the Adriatic Sea, with no roads, just canals.", ["St. Mark's Basilica", "Rialto Bridge", "Grand Canal"]),
    _city("Florence", "Italy", "IT", 160, "Cradle of the Renaissance, romantic, enchanting and utterly irresistible.", ["Duomo", "Uffizi Gallery", "Ponte Vecchio"]),
    _city("Cairo", "Egypt", "EG", 60, "Set on the Nile River, Egypt's sprawling capital is famous for Giza Pyramids.", ["Pyramids of Giza", "Sphinx", "Egyptian Museum"]),
    _city("Marrakesh", "Morocco", "MA", 80, "A major commercial center with mosques, palaces and gardens and a maze-like medina.", ["Jemaa el-Fnaa", "Majorelle Garden", "Bahia Palace"]),
    _city("Lisbon", "Portugal", "PT", 110, "Portugal's hilly, coastal capital city known for its cafe culture and soulful Fado music.", ["Belém Tower", "Jerónimos Monastery", "Tram 28"]),
    _city("Vienna", "Austria", "AT", 150, "Austria's capital, lies in the country's east on the Danube River. Artistic and intellectual legacy.", ["Schönbrunn Palace", "St. Stephen's Cathedral", "Belvedere"]),
    _city("Budapest", "Hungary", "HU", 90, "Political, economic, and cultural centre of Hungary, bisected by the River Danube.", ["Parliament", "Fisherman's Bastion", "Széchenyi Baths"]),
    _city("Berlin", "Germany", "DE", 140, "Known for its art scene and modern landmarks like the gold-colored, swoop-roofed Berliner Philharmonie.", ["Brandenburg Gate", "Berlin Wall", "Reichstag"]),
    _city("Athens", "Greece", "GR", 110, "The heart of Ancient Greece, a powerful civilization and empire.", ["Acropolis", "Parthenon", "Plaka"]),
    _city("Dublin", "Ireland", "IE", 160, "The capital of the Republic of Ireland, is on Ireland’s east coast at the mouth of the River Liffey.", ["Guinness Storehouse", "Trinity College", "Temple Bar"]),
    _city("Edinburgh", "Scotland", "GB", 150, "Scotland's compact, hilly capital. It has a medieval Old Town and elegant Georgian New Town.", ["Edinburgh Castle", "Royal Mile", "Arthur's Seat"]),
    _city("Stockholm", "Sweden", "SE", 170, "14 islands and more than 50 bridges on an extensive Baltic Sea archipelago.", ["Vasa Museum", "Gamla Stan", "Skansen"]),
    _city("Oslo", "Norway", "NO", 180, "Known for its green spaces and museums, including the Edvard Munch Museum.", ["Vigeland Park", "Viking Ship Museum", "Opera House"]),
    _city("Copenhagen", "Denmark", "DK", 175, "Home to the Little Mermaid statue and Renaissance-era Rosenborg Castle.", ["Tivoli Gardens", "Nyhavn", "Little Mermaid"]),
    _city("Helsinki", "Finland", "FI", 160, "A vibrant seaside city of beautiful islands and great green parks.", ["Suomenlinna", "Helsinki Cathedral", "Market Square"]),
    _city("Reykjavik", "Iceland", "IS", 220, "Coast of Iceland, the country's capital and largest city.", ["Blue Lagoon", "Hallgrímskirkja", "Golden Circle"]),
    _city("Vancouver", "Canada", "CA", 180, "A bustling west coast seaport in British Columbia, is among Canada’s densest, most ethnically diverse cities.", ["Stanley Park", "Granville Island", "Capilano Bridge"]),
    _city("Toronto", "Canada", "CA", 170, "A major Canadian city along Lake Ontario’s northwestern shore.", ["CN Tower", "Royal Ontario Museum", "Ripley's Aquarium"]),
    _city("Montreal", "Canada", "CA", 150, "The largest city in Canada's Québec province. It’s set on an island in the Saint Lawrence River.", ["Old Montreal", "Mount Royal", "Notre-Dame Basilica"]),
    _city("Mexico City", "Mexico", "MX", 90, "Densely populated, high-altitude capital of Mexico, known for its Templo Mayor.", ["Zócalo", "Frida Kahlo Museum", "Chapultepec Park"]),
    _city("Buenos Aires", "Argentina", "AR", 80, "Argentina’s big, cosmopolitan capital city. Its center is the Plaza de Mayo.", ["La Boca", "Recoleta Cemetery", "Casa Rosada"]),
    _city("Santiago", "Chile", "CL", 100, "Stands within a valley surrounded by the snow-capped Andes and the Chilean Coast Range.", ["San Cristóbal Hill", "Plaza de Armas", "La Chascona"]),
    _city("Lima", "Peru", "PE", 90, "The capital of Peru, lies on the country's arid Pacific coast.", ["Miraflores", "Plaza Mayor", "Larco Museum"]),
    _city("Mumbai", "India", "IN", 70, "A densely populated city on India's west coast. A financial center, it's the largest city in India.", ["Gateway of India", "Marine Drive", "Elephanta Caves"]),
    _city("New Delhi", "India", "IN", 60, "Capital of India. Features colonial-era parliament buildings and war memorials.", ["India Gate", "Red Fort", "Qutub Minar"]),
    _city("Jaipur", "India", "IN", 55, "Capital of India’s Rajasthan state. It evokes the royal family that once ruled the region.", ["Hawa Mahal", "Amber Palace", "City Palace"]),
    _city("Kathmandu", "Nepal", "NP", 40, "Nepal's capital, set in a valley surrounded by the Himalayas.", ["Boudhanath Stupa", "Swayambhunath", "Pashupatinath"]),
    _city("Hanoi", "Vietnam", "VN", 50, "Known for its centuries-old architecture and a rich culture.", ["Ha Long Bay", "Old Quarter", "Hoan Kiem Lake"]),
    _city("Ho Chi Minh City", "Vietnam", "VN", 55, "A high-octane city of commerce and culture.", ["War Remnants Museum", "Cu Chi Tunnels", "Ben Thanh Market"]),
    _city("Taipei", "Taiwan", "TW", 110, "The capital of Taiwan, is a modern metropolis.", ["Taipei 101", "Ximending", "Shilin Night Market"]),
    _city("Manila", "Philippines", "PH", 70, "The capital of the Philippines, a densely populated bayside city.", ["Intramuros", "Rizal Park", "Fort Santiago"]),
  ];

  static String getPlaceDescription(String place) {
    final Map<String, String> descriptions = {
      // Paris
      "Eiffel Tower": "The iconic symbol of Paris, this iron lattice tower offers spectacular views of the city.",
      "Louvre Museum": "The world's largest and most visited art museum, housing thousands of works including the Mona Lisa.",
      "Notre Dame": "A masterpiece of French Gothic architecture, this cathedral is a historic heart of the city.",
      // Dubai
      "Burj Khalifa": "The world's tallest building, standing at 828 meters with observation decks offering panoramic views.",
      "The Dubai Mall": "A massive shopping and entertainment complex featuring an ice rink, aquarium, and over 1,200 shops.",
      "Palm Jumeirah": "A world-renowned man-made archipelago in the shape of a palm tree, home to luxury hotels and villas.",
      // Istanbul
      "Hagia Sophia": "A historic miracle of architecture, serving as a church, then a mosque, and now a cultural site.",
      "Blue Mosque": "An iconic landmark known for its blue tiles and six minarets, still an active place of worship.",
      "Grand Bazaar": "One of the largest and oldest covered markets in the world, with over 3,000 shops.",
      // London
      "British Museum": "Dedicated to human history, art, and culture, with a vast collection of world artifacts.",
      "Tower of London": "A historic castle on the north bank of the River Thames, home to the Crown Jewels.",
      "Buckingham Palace": "The London residence and administrative headquarters of the monarch of the United Kingdom.",
      // Kyoto
      "Fushimi Inari Taisha": "Famous for its thousands of vermilion torii gates that line a network of trails.",
      "Kinkaku-ji": "The Golden Pavilion, a Zen Buddhist temple where the top two floors are completely covered in gold leaf.",
      "Arashiyama": "A scenic area on the outskirts of Kyoto, famous for its Bamboo Grove and Togetsukyo Bridge.",
      // New York
      "Statue of Liberty": "A colossal neoclassical sculpture on Liberty Island, a symbol of freedom and democracy.",
      "Central Park": "A vast urban park in Manhattan, offering trails, lakes, and iconic landmarks like Bethesda Terrace.",
      "Times Square": "The vibrant heart of the city's theater district, famous for its bright lights and massive digital billboards.",
      // Rome
      "Colosseum": "The largest ancient amphitheater ever built, a testament to Roman engineering and history.",
      "Vatican City": "An independent city-state home to St. Peter's Basilica and the incredible Vatican Museums.",
      "Pantheon": "A former Roman temple, now a church, famous for its massive concrete dome and oculus.",
      // Bali
      "Uluwatu Temple": "A Balinese Hindu sea temple spectacularly perched on top of a steep cliff by the ocean.",
      "Monkey Forest": "A sanctuary and natural habitat for the Balinese long-tailed macaque, located in Ubud.",
      "Rice Terraces": "The Tegallalang Rice Terraces offer a scenic outlook over the terraced fields of the valley.",
      // Santorini
      "Oia": "A coastal town famous for its whitewashed houses and blue-domed churches with sunset views.",
      "Fira": "The capital of Santorini, a vibrant town perched on the edge of a high cliff with caldera views.",
      "Red Beach": "Known for its unique red-colored volcanic sand and towering red cliffs.",
      // Generic fallback
      "Landmarks": "Explore the historic monuments and famous sites that define this city's character.",
      "Shopping": "Discover local markets and luxury boutiques in the city's premier shopping districts.",
      "Food Street": "Taste the authentic local flavors and street food specialties of the region.",
    };

    return descriptions[place] ?? "Experience the unique history, stunning architecture, and local culture of this iconic location.";
  }

  static City _city(
      String name, String country, String code, double cost, String desc, List<String> places) {
    return City(
      name: name,
      country: country,
      countryCode: code,
      imageUrl: "https://picsum.photos/seed/$name/600/400",
      description: desc,
      mustVisit: places,
      averageDailyCost: cost,
    );
  }
}
