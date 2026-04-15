import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/scrap_request.dart';
import '../models/waste_category.dart';

class RequestCard extends StatelessWidget {
  final ScrapRequest request;
  final VoidCallback? onTap;

  const RequestCard({super.key, required this.request, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cat = WasteCategory.getById(request.wasteType);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(cat.icon, color: cat.color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text('${request.quantity} - ${request.description}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            if (request.estimatedPrice != null)
              Text('${(request.estimatedPrice! / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
          ]),
        ),
      ),
    );
  }
}
