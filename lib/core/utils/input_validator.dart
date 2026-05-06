import 'package:fpdart/fpdart.dart';

/// Utilitários de validação de entrada para prevenir injeções e garantir dados válidos
class InputValidator {
  InputValidator._();

  /// Valida email
  static Either<String, String> validateEmail(String email) {
    if (email.isEmpty) {
      return const Left('Email não pode estar vazio');
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(email)) {
      return const Left('Email inválido');
    }
    
    // Previne emails muito longos (DoS)
    if (email.length > 254) {
      return const Left('Email muito longo');
    }
    
    return Right(email.toLowerCase().trim());
  }

  /// Valida número de telefone angolano (+244)
  static Either<String, String> validatePhoneNumber(String phone) {
    if (phone.isEmpty) {
      return const Left('Número de telefone não pode estar vazio');
    }
    
    // Remove espaços e caracteres especiais
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Formato: +244 9XX XXX XXX (9 dígitos após código do país)
    final phoneRegex = RegExp(r'^\+244[9][0-9]{8}$');
    
    if (!phoneRegex.hasMatch(cleaned)) {
      return const Left('Número deve estar no formato +244 9XX XXX XXX');
    }
    
    return Right(cleaned);
  }

  /// Valida preço
  static Either<String, double> validatePrice(String priceStr) {
    if (priceStr.isEmpty) {
      return const Left('Preço não pode estar vazio');
    }
    
    final price = double.tryParse(priceStr.replaceAll(',', '.'));
    
    if (price == null) {
      return const Left('Preço inválido');
    }
    
    if (price < 0) {
      return const Left('Preço não pode ser negativo');
    }
    
    // Máximo razoável para imóveis em Angola (em Kz)
    if (price > 10000000000) {
      return const Left('Preço excede o limite máximo');
    }
    
    return Right(price);
  }

  /// Valida texto livre (previne XSS básico)
  static Either<String, String> validateText(
    String text, {
    int minLength = 0,
    int maxLength = 5000,
    String? fieldName,
  }) {
    final field = fieldName ?? 'Texto';
    
    if (text.isEmpty && minLength > 0) {
      return Left('$field não pode estar vazio');
    }
    
    if (text.length < minLength) {
      return Left('$field deve ter no mínimo $minLength caracteres');
    }
    
    if (text.length > maxLength) {
      return Left('$field não pode exceder $maxLength caracteres');
    }
    
    // Remove tags HTML básicas para prevenir XSS
    final sanitized = _sanitizeHtml(text);
    
    return Right(sanitized);
  }

  /// Valida coordenadas geográficas
  static Either<String, (double lat, double lng)> validateCoordinates(
    double? latitude,
    double? longitude,
  ) {
    if (latitude == null || longitude == null) {
      return const Left('Coordenadas não podem estar vazias');
    }
    
    // Angola está aproximadamente entre:
    // Latitude: -18.0 a -4.4
    // Longitude: 11.7 a 24.1
    if (latitude < -18.5 || latitude > -4.0) {
      return const Left('Latitude fora dos limites de Angola');
    }
    
    if (longitude < 11.0 || longitude > 24.5) {
      return const Left('Longitude fora dos limites de Angola');
    }
    
    return Right((latitude, longitude));
  }

  /// Valida URL de imagem
  static Either<String, String> validateImageUrl(String url) {
    if (url.isEmpty) {
      return const Left('URL não pode estar vazia');
    }
    
    final uri = Uri.tryParse(url);
    
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return const Left('URL inválida');
    }
    
    // Apenas HTTPS para segurança
    if (uri.scheme != 'https') {
      return const Left('Apenas URLs HTTPS são permitidas');
    }
    
    // Verifica extensões de imagem comuns
    final validExtensions = ['.jpg', '.jpeg', '.png', '.webp', '.gif'];
    final hasValidExtension = validExtensions.any(
      (ext) => url.toLowerCase().endsWith(ext),
    );
    
    if (!hasValidExtension) {
      return const Left('URL deve apontar para uma imagem válida');
    }
    
    return Right(url);
  }

  /// Remove HTML básico para prevenir XSS
  static String _sanitizeHtml(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '')
        .trim();
  }

  /// Valida ID (UUID v4)
  static Either<String, String> validateId(String id) {
    if (id.isEmpty) {
      return const Left('ID não pode estar vazio');
    }
    
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    
    if (!uuidRegex.hasMatch(id)) {
      return const Left('ID inválido');
    }
    
    return Right(id.toLowerCase());
  }

  /// Valida área em m²
  static Either<String, double> validateArea(String areaStr) {
    if (areaStr.isEmpty) {
      return const Left('Área não pode estar vazia');
    }
    
    final area = double.tryParse(areaStr.replaceAll(',', '.'));
    
    if (area == null) {
      return const Left('Área inválida');
    }
    
    if (area <= 0) {
      return const Left('Área deve ser maior que zero');
    }
    
    // Máximo razoável (100.000 m² = 10 hectares)
    if (area > 100000) {
      return const Left('Área excede o limite máximo');
    }
    
    return Right(area);
  }

  /// Valida número de quartos/banheiros
  static Either<String, int> validateRoomCount(String countStr) {
    if (countStr.isEmpty) {
      return const Left('Número não pode estar vazio');
    }
    
    final count = int.tryParse(countStr);
    
    if (count == null) {
      return const Left('Número inválido');
    }
    
    if (count < 0) {
      return const Left('Número não pode ser negativo');
    }
    
    if (count > 50) {
      return const Left('Número excede o limite máximo');
    }
    
    return Right(count);
  }
}
