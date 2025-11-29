import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/action_button.dart';
import '../../widgets/input_field.dart';

enum MockDataType {
  uuid,
  id,
  firstName,
  lastName,
  fullName,
  email,
  username,
  phone,
  date,
  boolean,
  integer,
  price,
  city,
  country,
}

class FieldDefinition {
  String name;
  MockDataType type;

  FieldDefinition({required this.name, required this.type});
}

class MockDataTool extends StatefulWidget {
  final Tool tool;

  const MockDataTool({super.key, required this.tool});

  @override
  State<MockDataTool> createState() => _MockDataToolState();
}

class _MockDataToolState extends State<MockDataTool> {
  final List<FieldDefinition> _fields = [
    FieldDefinition(name: 'id', type: MockDataType.uuid),
    FieldDefinition(name: 'name', type: MockDataType.fullName),
    FieldDefinition(name: 'email', type: MockDataType.email),
    FieldDefinition(name: 'isActive', type: MockDataType.boolean),
  ];

  int _count = 10;
  String _result = '';
  bool _isCsv = false;

  final Random _random = Random();

  void _addField() {
    setState(() {
      _fields.add(
        FieldDefinition(
          name: 'field_${_fields.length + 1}',
          type: MockDataType.fullName,
        ),
      );
    });
  }

  void _removeField(int index) {
    setState(() {
      _fields.removeAt(index);
    });
  }

  void _generate() {
    final List<Map<String, dynamic>> data = [];

    for (int i = 0; i < _count; i++) {
      final Map<String, dynamic> row = {};
      for (final field in _fields) {
        row[field.name] = _generateValue(field.type, i);
      }
      data.add(row);
    }

    setState(() {
      if (_isCsv) {
        _result = _toCsv(data);
      } else {
        _result = const JsonEncoder.withIndent('  ').convert(data);
      }
    });
  }

  dynamic _generateValue(MockDataType type, int index) {
    switch (type) {
      case MockDataType.uuid:
        return _generateUuid();
      case MockDataType.id:
        return index + 1;
      case MockDataType.firstName:
        return _randomItem([
          'James',
          'Mary',
          'John',
          'Patricia',
          'Robert',
          'Jennifer',
          'Michael',
          'Linda',
          'William',
          'Elizabeth',
        ]);
      case MockDataType.lastName:
        return _randomItem([
          'Smith',
          'Johnson',
          'Williams',
          'Brown',
          'Jones',
          'Garcia',
          'Miller',
          'Davis',
          'Rodriguez',
          'Martinez',
        ]);
      case MockDataType.fullName:
        return '${_generateValue(MockDataType.firstName, index)} ${_generateValue(MockDataType.lastName, index)}';
      case MockDataType.email:
        final name = _generateValue(
          MockDataType.firstName,
          index,
        ).toString().toLowerCase();
        return '$name${_random.nextInt(99)}@example.com';
      case MockDataType.username:
        final name = _generateValue(
          MockDataType.firstName,
          index,
        ).toString().toLowerCase();
        return '$name${_random.nextInt(999)}';
      case MockDataType.phone:
        return '+1 (${_random.nextInt(800) + 200}) ${_random.nextInt(800) + 200}-${_random.nextInt(9000) + 1000}';
      case MockDataType.date:
        return DateTime.now()
            .subtract(Duration(days: _random.nextInt(365 * 5)))
            .toIso8601String()
            .split('T')[0];
      case MockDataType.boolean:
        return _random.nextBool();
      case MockDataType.integer:
        return _random.nextInt(1000);
      case MockDataType.price:
        return double.parse((_random.nextDouble() * 1000).toStringAsFixed(2));
      case MockDataType.city:
        return _randomItem([
          'New York',
          'London',
          'Tokyo',
          'Paris',
          'Berlin',
          'Sydney',
          'Mumbai',
          'Toronto',
          'Dubai',
          'Singapore',
        ]);
      case MockDataType.country:
        return _randomItem([
          'USA',
          'UK',
          'Japan',
          'France',
          'Germany',
          'Australia',
          'India',
          'Canada',
          'UAE',
          'Singapore',
        ]);
    }
  }

  String _generateUuid() {
    // Simple UUID v4 implementation
    final bytes = List<int>.generate(16, (_) => _random.nextInt(255));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  T _randomItem<T>(List<T> items) {
    return items[_random.nextInt(items.length)];
  }

  String _toCsv(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return '';
    final headers = data.first.keys.join(',');
    final rows = data
        .map((row) => row.values.map((v) => '"$v"').join(','))
        .join('\n');
    return '$headers\n$rows';
  }

  @override
  Widget build(BuildContext context) {
    return ToolDetailScreen(
      tool: widget.tool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Schema Builder
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Schema',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      onPressed: _addField,
                      icon: const Icon(Icons.add),
                      tooltip: 'Add Field',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _fields.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = _fields.removeAt(oldIndex);
                      _fields.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final field = _fields[index];
                    return Container(
                      key: ValueKey(field),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.drag_handle, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: field.name,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Field Name',
                              ),
                              onChanged: (v) => field.name = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<MockDataType>(
                                value: field.type,
                                isExpanded: true,
                                items: MockDataType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(
                                      type.name.toUpperCase(),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => field.type = v);
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => _removeField(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Controls
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Count: $_count'),
                    Slider(
                      value: _count.toDouble(),
                      min: 1,
                      max: 100,
                      divisions: 99,
                      label: _count.toString(),
                      onChanged: (v) => setState(() => _count = v.toInt()),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ToggleButtons(
                isSelected: [_isCsv == false, _isCsv == true],
                onPressed: (index) {
                  setState(() {
                    _isCsv = index == 1;
                    if (_result.isNotEmpty) _generate(); // Regenerate format
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('JSON'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('CSV'),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          ActionButton(
            label: 'Generate Data',
            icon: Icons.auto_awesome,
            onPressed: _generate,
            isPrimary: true,
          ),

          const SizedBox(height: 24),

          // Result
          if (_result.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Result',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _result));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy',
                      ),
                    ],
                  ),
                  const Divider(),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _result,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
