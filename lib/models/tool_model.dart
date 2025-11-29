class Tool {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String icon;
  final List<String> tags;
  final bool isFavorite;

  const Tool({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.icon,
    this.tags = const [],
    this.isFavorite = false,
  });

  Tool copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? icon,
    bool? isFavorite,
  }) {
    return Tool(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      icon: icon ?? this.icon,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

// Available Tools
final List<Tool> availableTools = [
  // Encoders/Decoders (5 tools)
  const Tool(
    id: 'base64',
    name: 'Base64 Encoder/Decoder',
    description: 'Encode and decode Base64 strings',
    categoryId: 'encoders',
    icon: '🔤',
    tags: ['encode', 'decode', 'string', 'text'],
  ),
  const Tool(
    id: 'url_encoder',
    name: 'URL Encoder/Decoder',
    description: 'Encode and decode URLs',
    categoryId: 'encoders',
    icon: '🌐',
  ),
  const Tool(
    id: 'html_encoder',
    name: 'HTML Entity Encoder',
    description: 'Encode/decode HTML entities',
    categoryId: 'encoders',
    icon: '📄',
  ),
  const Tool(
    id: 'jwt_decoder',
    name: 'JWT Decoder',
    description: 'Decode JWT tokens',
    categoryId: 'encoders',
    icon: '🎫',
  ),
  const Tool(
    id: 'unicode',
    name: 'Unicode Converter',
    description: 'Convert text to Unicode',
    categoryId: 'encoders',
    icon: '🔤',
  ),

  // Generators (5 tools)
  const Tool(
    id: 'uuid',
    name: 'UUID Generator',
    description: 'Generate unique identifiers',
    categoryId: 'generators',
    icon: '🆔',
    tags: ['guid', 'id', 'random'],
  ),
  const Tool(
    id: 'password',
    name: 'Password Generator',
    description: 'Generate secure passwords',
    categoryId: 'generators',
    icon: '🔒',
  ),
  const Tool(
    id: 'hash',
    name: 'Hash Generator',
    description: 'Generate MD5, SHA hashes',
    categoryId: 'generators',
    icon: '#️⃣',
  ),
  const Tool(
    id: 'lorem',
    name: 'Lorem Ipsum Generator',
    description: 'Generate placeholder text',
    categoryId: 'generators',
    icon: '📝',
  ),
  const Tool(
    id: 'random_data',
    name: 'Random Data Generator',
    description: 'Generate random numbers, strings',
    categoryId: 'generators',
    icon: '🎲',
  ),

  // Formatters (4 tools)
  const Tool(
    id: 'json',
    name: 'JSON Formatter',
    description: 'Format and validate JSON',
    categoryId: 'formatters',
    icon: '{}',
    tags: ['prettify', 'minify', 'validate', 'lint'],
  ),
  const Tool(
    id: 'xml',
    name: 'XML Formatter',
    description: 'Format and validate XML',
    categoryId: 'formatters',
    icon: '📰',
  ),
  const Tool(
    id: 'css',
    name: 'CSS Formatter',
    description: 'Format and beautify CSS',
    categoryId: 'formatters',
    icon: '🎨',
  ),
  const Tool(
    id: 'sql',
    name: 'SQL Formatter',
    description: 'Format SQL queries',
    categoryId: 'formatters',
    icon: '🗄️',
  ),

  // Converters (5 tools)
  const Tool(
    id: 'color',
    name: 'Color Converter',
    description: 'Convert HEX, RGB, HSL colors',
    categoryId: 'converters',
    icon: '🎨',
    tags: ['hex', 'rgb', 'hsl', 'cmyk', 'picker'],
  ),
  const Tool(
    id: 'number_base',
    name: 'Number Base Converter',
    description: 'Convert binary, decimal, hex',
    categoryId: 'converters',
    icon: '🔢',
  ),
  const Tool(
    id: 'timestamp',
    name: 'Timestamp Converter',
    description: 'Convert Unix timestamps',
    categoryId: 'converters',
    icon: '⏰',
  ),
  const Tool(
    id: 'css_units',
    name: 'CSS Unit Converter',
    description: 'Convert px, em, rem, %',
    categoryId: 'converters',
    icon: '📏',
  ),
  const Tool(
    id: 'case_converter',
    name: 'Case Converter',
    description: 'camelCase, snake_case, etc.',
    categoryId: 'converters',
    icon: '🔠',
  ),
  const Tool(
    id: 'font_pair_finder',
    name: 'Font Pair Finder',
    description: 'Curated Google Font pairings',
    categoryId: 'design', // Assuming 'design' is a valid categoryId
    icon:
        '🅰️', // Using a generic icon as Icons.font_download_outlined is not a String
  ),
  const Tool(
    id: 'image_color_extractor',
    name: 'Image Color Extractor',
    description: 'Extract colors from any image',
    categoryId: 'converters',
    icon:
        '🖼️', // Using a generic icon as Icons.add_photo_alternate_outlined is not a String
  ),
  const Tool(
    id: 'color_extractor',
    name: 'Website Color Extractor',
    description: 'Extract colors from any website',
    categoryId: 'converters',
    icon: '🌈',
    tags: ['web', 'css', 'hex', 'rgb', 'palette'],
  ),
  const Tool(
    id: 'mock_data',
    name: 'Mock Data Studio',
    description: 'Generate random JSON/CSV data for testing',
    categoryId: 'generators',
    icon: '📊', // Using a generic icon as Icons.data_object is not a String
  ),

  // Text Tools (5 tools)
  const Tool(
    id: 'regex',
    name: 'Regex Tester',
    description: 'Test regular expressions',
    categoryId: 'text_tools',
    icon: '🔍',
  ),
  const Tool(
    id: 'word_counter',
    name: 'Word Counter',
    description: 'Count words and characters',
    categoryId: 'text_tools',
    icon: '📊',
  ),
  const Tool(
    id: 'text_diff',
    name: 'Text Diff Checker',
    description: 'Compare two texts',
    categoryId: 'text_tools',
    icon: '⚖️',
  ),
  const Tool(
    id: 'string_reverser',
    name: 'String Reverser',
    description: 'Reverse text or words',
    categoryId: 'text_tools',
    icon: '🔄',
  ),
  const Tool(
    id: 'duplicate_remover',
    name: 'Duplicate Line Remover',
    description: 'Remove duplicate lines',
    categoryId: 'text_tools',
    icon: '🧹',
  ),

  // Validators (2 tools)
  const Tool(
    id: 'email_validator',
    name: 'Email Validator',
    description: 'Validate email addresses',
    categoryId: 'formatters',
    icon: '📧',
  ),
  const Tool(
    id: 'url_validator',
    name: 'URL Validator',
    description: 'Validate and parse URLs',
    categoryId: 'formatters',
    icon: '🔗',
  ),

  // Additional Tools (5 tools)
  const Tool(
    id: 'gradient_generator',
    name: 'Gradient Generator',
    description: 'Create CSS/Flutter gradients',
    categoryId: 'generators',
    icon: '🌈',
  ),
  const Tool(
    id: 'screen_size',
    name: 'Screen Size Reference',
    description: 'Device dimensions & breakpoints',
    categoryId: 'converters',
    icon: '📱',
  ),
  const Tool(
    id: 'material_palette',
    name: 'Material Palette',
    description: 'Material Design colors',
    categoryId: 'generators',
    icon: '🎨',
  ),
  const Tool(
    id: 'aspect_ratio',
    name: 'Aspect Ratio Calculator',
    description: 'Calculate dimensions',
    categoryId: 'converters',
    icon: '📐',
  ),
  const Tool(
    id: 'ip_info',
    name: 'IP Address Info',
    description: 'Local IP & validation',
    categoryId: 'text_tools',
    icon: '🌐',
  ),
];
