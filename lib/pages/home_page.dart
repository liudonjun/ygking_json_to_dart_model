import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ygking_to_model/pages/cupertino_icons_page.dart';
import 'package:ygking_to_model/pages/material_icons_page.dart';
import 'package:ygking_to_model/services/json_converter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _jsonController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();
  String _dartCode = '';

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _dartCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('代码已复制到剪贴板')),
    );
  }

  Widget _buildInputPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _classNameController,
          decoration: const InputDecoration(
            labelText: '输入类名',
            hintText: '例如: User',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TextField(
            controller: _jsonController,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: '输入JSON',
              border: OutlineInputBorder(),
              hintText: '请输入有效的JSON格式数据',
            ),
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final jsonConverter = JsonConverter();
                  setState(() {
                    _dartCode = jsonConverter.convertJsonToDart(
                      _jsonController.text,
                      _classNameController.text,
                    );
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('生成Dart Model'),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _jsonController.clear();
                  _classNameController.clear();
                  setState(() {
                    _dartCode = '';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[100],
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('清除'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOutputPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text(
              '生成的代码：',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _copyToClipboard,
              icon: const Text('复制'),
              label: const Icon(Icons.copy, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SelectableText(
              _dartCode,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为窄屏设备
    final isNarrowScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON 转 Dart Model'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MaterialIconsPage()),
              );
            },
            tooltip: 'Material Icons',
          ),
          IconButton(
            icon: const Icon(Icons.apple),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CupertinoIconsPage()),
              );
            },
            tooltip: 'Cupertino Icons',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isNarrowScreen
            ? Column(
                children: [
                  Expanded(child: _buildInputPanel()),
                  const SizedBox(height: 16),
                  Expanded(child: _buildOutputPanel()),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildInputPanel()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildOutputPanel()),
                ],
              ),
      ),
    );
  }
}
