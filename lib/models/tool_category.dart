class ToolCategory {
  final String id;
  final String name;
  final String icon;
  final String description;

  const ToolCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });
}

// Tool Categories
const List<ToolCategory> toolCategories = [
  ToolCategory(
    id: 'encoders',
    name: 'Encoders/Decoders',
    icon: '🔐',
    description: 'Encode and decode various formats',
  ),
  ToolCategory(
    id: 'generators',
    name: 'Generators',
    icon: '🎲',
    description: 'Generate UUIDs, passwords, and more',
  ),
  ToolCategory(
    id: 'formatters',
    name: 'Formatters',
    icon: '📊',
    description: 'Format and validate code',
  ),
  ToolCategory(
    id: 'converters',
    name: 'Converters',
    icon: '🔄',
    description: 'Convert between different formats',
  ),
  ToolCategory(
    id: 'text_tools',
    name: 'Text Tools',
    icon: '📝',
    description: 'Text manipulation utilities',
  ),
];
