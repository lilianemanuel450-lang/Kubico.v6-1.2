class AppConstants {
  AppConstants._();

  // Brand
  static const String appName = 'Kubico';
  static const String appTagline = 'O Melhor Imobiliário de Angola';

  // Supabase — configura aqui os teus valores
  // Podes usar variáveis de ambiente no Codemagic ou colocar directamente
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://homvogeaihfakcfxhqol.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'SUA_ANON_KEY_AQUI',
  );

  // Angola / Luanda
  static const double luandaLatitude = -8.8390;
  static const double luandaLongitude = 13.2894;
  static const double defaultRadiusKm = 10.0;

  // Cache
  static const Duration cacheMaxAge = Duration(days: 3);
  static const int maxCachedProperties = 500;

  // Paginação
  static const int pageSize = 20;

  // Debounce busca
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // Preços (Kz)
  static const double minPriceKz = 0;
  static const double maxPriceKz = 5000000;
}

class AppStrings {
  AppStrings._();

  static const String serverError = 'Erro no servidor. Tenta novamente.';
  static const String networkError = 'Sem conexão à internet.';
  static const String cacheError = 'Erro ao carregar dados locais.';
  static const String locationError = 'Não foi possível obter a localização.';
  static const String authError = 'Erro de autenticação.';
  static const String noPropertiesFound = 'Nenhum imóvel encontrado.';
  static const String noPropertiesCache = 'Nenhum imóvel em cache.';

  static const String forRent = 'Arrendamento';
  static const String forSale = 'Venda';
  static const String house = 'Casa';
  static const String apartment = 'Apartamento';
  static const String land = 'Terreno';
  static const String commercial = 'Comercial';

  static const String callAgent = 'Ligar ao Agente';
  static const String whatsappAgent = 'WhatsApp';
  static const String shareProperty = 'Partilhar';
  static const String saveProperty = 'Guardar';
  static const String publishProperty = 'Publicar Imóvel';
}
