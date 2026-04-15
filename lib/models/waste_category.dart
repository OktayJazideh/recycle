import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WasteCategory {
  final String id;
  final String name;
  final String nameEn;
  final IconData icon;
  final Color color;
  final double basePricePerKg;

  const WasteCategory({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.color,
    required this.basePricePerKg,
  });

  static List<WasteCategory> get categories => [
    WasteCategory(id: 'paper', name: 'کاغذ و کارتن', nameEn: 'کاغذ', icon: Icons.description, color: AppColors.orange, basePricePerKg: 15000),
    WasteCategory(id: 'plastic', name: 'پلاستیک', nameEn: 'پلاستیک', icon: Icons.local_drink, color: AppColors.blue, basePricePerKg: 20000),
    WasteCategory(id: 'metal', name: 'فلز و آهن', nameEn: 'فلز', icon: Icons.settings, color: Color(0xFF78909C), basePricePerKg: 45000),
    WasteCategory(id: 'copper', name: 'مس و برنج', nameEn: 'مس', icon: Icons.electrical_services, color: Color(0xFFD84315), basePricePerKg: 350000),
    WasteCategory(id: 'aluminum', name: 'آلومینیوم', nameEn: 'آلومینیوم', icon: Icons.layers, color: Color(0xFF546E7A), basePricePerKg: 80000),
    WasteCategory(id: 'glass', name: 'شیشه', nameEn: 'شیشه', icon: Icons.wine_bar, color: AppColors.lightGreen, basePricePerKg: 5000),
    WasteCategory(id: 'electronics', name: 'الکترونیک', nameEn: 'الکترونیک', icon: Icons.devices, color: AppColors.purple, basePricePerKg: 30000),
    WasteCategory(id: 'battery', name: 'باتری', nameEn: 'باتری', icon: Icons.battery_full, color: Color(0xFFE65100), basePricePerKg: 25000),
    WasteCategory(id: 'textile', name: 'پارچه و لباس', nameEn: 'پارچه', icon: Icons.checkroom, color: Color(0xFF6A1B9A), basePricePerKg: 10000),
    WasteCategory(id: 'mixed', name: 'ضایعات مخلوط', nameEn: 'مخلوط', icon: Icons.inventory_2, color: AppColors.textSecondary, basePricePerKg: 8000),
  ];

  static WasteCategory getById(String id) =>
    categories.firstWhere((c) => c.id == id, orElse: () => categories.last);
}
