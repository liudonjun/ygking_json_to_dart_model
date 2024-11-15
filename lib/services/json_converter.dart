import 'dart:convert';

class JsonConverter {
  final Set<String> _generatedClasses = {};
  final StringBuffer _allClasses = StringBuffer();

  String convertJsonToDart(String jsonString, String className) {
    try {
      _generatedClasses.clear();
      _allClasses.clear();

      // 解析JSON字符串
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      // 生成主类和所有嵌套类
      _generateClass(jsonMap, className);

      return _allClasses.toString();
    } catch (e) {
      return '转换错误: $e\n\n请确保输入的是有效的JSON格式。\n例如：\n{\n  "id": 1,\n  "name": "测试"\n}';
    }
  }

  void _generateClass(Map<String, dynamic> jsonMap, String className) {
    if (_generatedClasses.contains(className)) return;
    _generatedClasses.add(className);

    final StringBuffer fields = StringBuffer();
    final StringBuffer constructor = StringBuffer();
    final StringBuffer fromJson = StringBuffer();
    final StringBuffer toJson = StringBuffer();

    jsonMap.forEach((key, value) {
      String type = _getFieldType(value, key);

      // 如果是对象，生成新的类
      if (value is Map) {
        String subClassName = '${key.capitalize()}';
        _generateClass(value as Map<String, dynamic>, subClassName);
        type = subClassName;
      }

      // 添加字段定义
      fields.writeln('  $type? $key;');

      // 添加构造函数参数
      if (constructor.isEmpty) {
        constructor.write('this.$key');
      } else {
        constructor.write(', this.$key');
      }

      // 添加fromJson转换
      if (value is Map) {
        String subClassName = '${className}${key.capitalize()}';
        fromJson.writeln(
            '    $key = json[\'$key\'] != null ? $subClassName.fromJson(json[\'$key\']) : null;');
      } else {
        fromJson.writeln('    $key = json[\'$key\'];');
      }

      // 添加toJson转换
      if (value is Map) {
        toJson.writeln('    if ($key != null) {');
        toJson.writeln('      data[\'$key\'] = $key!.toJson();');
        toJson.writeln('    }');
      } else {
        toJson.writeln('    data[\'$key\'] = $key;');
      }
    });

    // 生成类定义
    _allClasses.write('''
class $className {
$fields
  $className({$constructor});

  $className.fromJson(Map<String, dynamic> json) {
$fromJson
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
$toJson
    return data;
  }
}

''');
  }

  String _getFieldType(dynamic value, String key) {
    if (value == null) return 'dynamic';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is String) return 'String';
    if (value is List) return 'List<${_getListType(value)}>';
    if (value is Map) return '${key.capitalize()}';
    return 'dynamic';
  }

  String _getListType(List list) {
    if (list.isEmpty) return 'dynamic';
    var firstItem = list[0];
    return _getFieldType(firstItem, '');
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
