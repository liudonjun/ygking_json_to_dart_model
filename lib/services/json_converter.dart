import 'dart:convert';

class JsonConverter {
  String convertJsonToDart(String jsonStr, String className) {
    try {
      final dynamic jsonData = json.decode(jsonStr);
      final StringBuffer buffer = StringBuffer();

      if (jsonData is Map<String, dynamic>) {
        _generateClass(jsonData, className, buffer, className);
      } else if (jsonData is List &&
          jsonData.isNotEmpty &&
          jsonData[0] is Map<String, dynamic>) {
        // 如果是数组，使用第一个元素作为模板
        _generateClass(jsonData[0], className, buffer, className);
      } else {
        return '// 错误: JSON格式无效\n// 输入必须是对象或对象数组';
      }

      return buffer.toString();
    } catch (e) {
      return '// 错误: JSON格式无效\n// $e';
    }
  }

  void _generateClass(
    Map<String, dynamic> map,
    String className,
    StringBuffer buffer,
    String parentClassName,
  ) {
    // 生成类声明
    buffer.writeln('class $className {');

    // 生成字段声明
    map.forEach((key, value) {
      final type = _getFieldType(value, key);
      buffer.writeln('  $type? $key;');
    });
    buffer.writeln();

    // 生成构造函数
    buffer.writeln('  $className({');
    map.forEach((key, _) {
      buffer.writeln('    this.$key,');
    });
    buffer.writeln('  });');
    buffer.writeln();

    // 生成 fromJson
    buffer.writeln('  $className.fromJson(Map<String, dynamic> json) {');
    map.forEach((key, value) {
      if (value is List && value.isNotEmpty && value[0] is Map) {
        // 处理对象数组
        buffer.writeln('''    if (json['$key'] != null) {
      $key = <${key.capitalize()}>[];
      json['$key'].forEach((v) {
        $key!.add(${key.capitalize()}.fromJson(v));
      });
    }''');
      } else if (value is Map) {
        // 处理嵌套对象
        buffer.writeln('''    if (json['$key'] != null) {
      $key = ${key.capitalize()}.fromJson(json['$key']);
    }''');
      } else {
        buffer.writeln('    $key = json[\'$key\'];');
      }
    });
    buffer.writeln('  }');
    buffer.writeln();

    // 生成 toJson
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer
        .writeln('    final Map<String, dynamic> data = <String, dynamic>{};');
    map.forEach((key, value) {
      if (value is List && value.isNotEmpty && value[0] is Map) {
        // 处理对象数组
        buffer.writeln('''    if ($key != null) {
      data['$key'] = $key!.map((v) => v.toJson()).toList();
    }''');
      } else if (value is Map) {
        // 处理嵌套对象
        buffer.writeln('''    if ($key != null) {
      data['$key'] = $key!.toJson();
    }''');
      } else {
        buffer.writeln('    data[\'$key\'] = $key;');
      }
    });
    buffer.writeln('    return data;');
    buffer.writeln('  }');

    buffer.writeln('}');
    buffer.writeln();

    // 生成嵌套类
    map.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        _generateClass(
          value,
          key.capitalize(),
          buffer,
          className,
        );
      } else if (value is List &&
          value.isNotEmpty &&
          value[0] is Map<String, dynamic>) {
        _generateClass(
          value[0] as Map<String, dynamic>,
          key.capitalize(),
          buffer,
          className,
        );
      }
    });
  }

  String _getFieldType(dynamic value, String key) {
    if (value == null) return 'dynamic';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is String) return 'String';
    if (value is List) {
      if (value.isEmpty) return 'List<dynamic>';
      if (value[0] is Map) {
        return 'List<${key.capitalize()}>';
      }
      return 'List<${_getFieldType(value[0], key)}>';
    }
    if (value is Map) return key.capitalize();
    return 'dynamic';
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
