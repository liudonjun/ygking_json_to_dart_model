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

  // 获取所有Cupertino图标

  @override
  Widget build(BuildContext context) {
    // 过滤图标
    final filteredIcons = IconsData.cupertinoIcons.entries.where((icon) {
      return icon.key.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

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
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final crossAxisCount = (constraints.maxWidth / 100).floor();
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: filteredIcons.length,
                itemBuilder: (context, index) {
                  final entry = filteredIcons[index];
                  return Card(
                    child: InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: 'CupertinoIcons.${entry.key}'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('图标代码已复制到剪贴板')),
                        );
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
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
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
