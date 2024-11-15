import 'dart:convert';

class JsonConverter {
  String convertJsonToDart(String jsonString, String className) {
    try {
      // 解析JSON字符串
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      // 生成字段定义
      final StringBuffer fields = StringBuffer();
      final StringBuffer constructor = StringBuffer();
      final StringBuffer fromJson = StringBuffer();
      final StringBuffer toJson = StringBuffer();

      // 处理每个字段
      jsonMap.forEach((key, value) {
        // 确定字段类型
        String type = _getFieldType(value);

        // 添加字段定义
        fields.writeln('  $type? $key;');

        // 添加构造函数参数
        if (constructor.isEmpty) {
          constructor.write('this.$key');
        } else {
          constructor.write(', this.$key');
        }

        // 添加fromJson转换
        fromJson.writeln('    $key = json[\'$key\'];');

        // 添加toJson转换
        toJson.writeln('    data[\'$key\'] = $key;');
      });

      // 生成完整的类代码
      return '''
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
''';
    } catch (e) {
      return '转换错误: $e\n\n请确保输入的是有效的JSON格式。\n例如：\n{\n  "id": 1,\n  "name": "测试"\n}';
    }
  }

  String _getFieldType(dynamic value) {
    if (value == null) return 'dynamic';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is String) return 'String';
    if (value is List) return 'List<${_getListType(value)}>';
    if (value is Map) return 'Map<String, dynamic>';
    return 'dynamic';
  }

  String _getListType(List list) {
    if (list.isEmpty) return 'dynamic';
    var firstItem = list[0];
    return _getFieldType(firstItem);
  }
}
