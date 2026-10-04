import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class WasteType {
  final String id;
  final String name;
  final String category;
  final String description;
  final String instruction;
  final List<String> disposalTips;
  final String icon;

  const WasteType({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.instruction,
    required this.disposalTips,
    required this.icon,
  });

  bool get isDry =>
      category.toLowerCase().contains('dry') ||
      category.toLowerCase().contains('plastic') ||
      category.toLowerCase().contains('paper');

  Color get categoryColor {
    final lower = (category.isNotEmpty ? category : name).toLowerCase();
    if (lower.contains('plastic')) return AppColors.wastePlastic;
    if (lower.contains('organic') || lower.contains('bio')) return AppColors.wasteOrganic;
    if (lower.contains('paper')) return AppColors.wastePaper;
    if (lower.contains('glass')) return AppColors.wasteGlass;
    if (lower.contains('metal')) return AppColors.wasteMetal;
    if (lower.contains('hazardous')) return AppColors.wasteHazardous;
    if (lower.contains('e-waste') || lower.contains('electronic')) return AppColors.wasteEwaste;
    return AppColors.emeraldBrand;
  }

  factory WasteType.fromFirestore(String id, Map<String, dynamic> data) {
    final name = (data['name'] ??
            data['wasteType'] ??
            data['waste type'] ??
            data['type'] ??
            data['title'] ??
            id)
        .toString();

    final cat = (data['category'] ?? data['type'] ?? name).toString();
    final desc = (data['description'] ?? data['details'] ?? '').toString();
    final instr = (data['instruction'] ??
            data['instructions'] ??
            data['collectionInstruction'] ??
            data['note'] ??
            '')
        .toString();

    final rawTips = data['disposalTips'] ?? data['tips'] ?? data['items'];
    final tips = <String>[];
    if (rawTips is List) {
      for (final t in rawTips) {
        if (t != null && t.toString().trim().isNotEmpty) {
          tips.add(t.toString().trim());
        }
      }
    } else if (rawTips is String && rawTips.trim().isNotEmpty) {
      tips.addAll(rawTips.split(RegExp(r'[,;\n]')).map((s) => s.trim()).where((s) => s.isNotEmpty));
    }

    final icon = (data['icon'] ?? data['emoji'] ?? _defaultIconFor(cat)).toString();

    return WasteType(
      id: id,
      name: name,
      category: cat,
      description: desc,
      instruction: instr,
      disposalTips: tips,
      icon: icon,
    );
  }

  static String _defaultIconFor(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('plastic')) return '🥤';
    if (lower.contains('organic') || lower.contains('bio')) return '🌿';
    if (lower.contains('paper')) return '📄';
    if (lower.contains('glass')) return '🍾';
    if (lower.contains('metal')) return '🥫';
    if (lower.contains('hazardous')) return '⚠️';
    if (lower.contains('e-waste') || lower.contains('electronic')) return '💻';
    return '♻️';
  }
}
