abstract final class LabelNormalizer {
  static const String otherLetter = '#';

  static const Map<String, String> _accents = <String, String>{
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
    'ç': 'c',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ñ': 'n',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ý': 'y', 'ÿ': 'y',
    'œ': 'oe', 'æ': 'ae',
  };

  static String normalize(String value) {
    final StringBuffer buffer = StringBuffer();
    for (final String character in value.toLowerCase().trim().split('')) {
      buffer.write(_accents[character] ?? character);
    }
    return buffer.toString();
  }

  static String letterOf(String normalized) {
    if (normalized.isEmpty) {
      return otherLetter;
    }
    final int code = normalized.codeUnitAt(0);
    final bool isLatinLetter = code >= 0x61 && code <= 0x7A;
    return isLatinLetter ? normalized[0].toUpperCase() : otherLetter;
  }
}
