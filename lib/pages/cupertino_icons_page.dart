import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ygking_to_model/data.dart';

class CupertinoIconsPage extends StatefulWidget {
  const CupertinoIconsPage({super.key});

  @override
  State<CupertinoIconsPage> createState() => _CupertinoIconsPageState();
}

class _CupertinoIconsPageState extends State<CupertinoIconsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late List<MapEntry<String, IconData>> _filteredIcons;

  @override
  void initState() {
    super.initState();
    _filteredIcons = IconsData.cupertinoIcons.entries.toList();
  }

  void _filterIcons(String query) {
    if (query.isEmpty) {
      _filteredIcons = IconsData.cupertinoIcons.entries.toList();
    } else {
      _filteredIcons = IconsData.cupertinoIcons.entries
          .where((icon) => icon.key.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cupertino Icons'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '搜索图标',
                prefixIcon: const Icon(CupertinoIcons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(CupertinoIcons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                            _filterIcons('');
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterIcons(value);
                });
              },
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = (constraints.maxWidth / 100).floor();
                return GridView.builder(
                  cacheExtent: 500,
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _filteredIcons.length,
                  itemBuilder: (context, index) {
                    final entry = _filteredIcons[index];
                    return RepaintBoundary(
                      child: _IconCard(
                        key: ValueKey(entry.key),
                        entry: entry,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _IconCard extends StatelessWidget {
  const _IconCard({
    super.key,
    required this.entry,
  });

  final MapEntry<String, IconData> entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Clipboard.setData(
            ClipboardData(text: 'CupertinoIcons.${entry.key}'),
          ).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('图标代码已复制到剪贴板')),
            );
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(entry.value, size: 32),
            const SizedBox(height: 4),
            Text(
              entry.key,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
