import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/app_data_service.dart';
import '../../models/scrap_request.dart';
import '../../models/waste_category.dart';

class NearbyRequestsScreen extends StatefulWidget {
  const NearbyRequestsScreen({super.key});
  @override
  State<NearbyRequestsScreen> createState() => _NearbyRequestsScreenState();
}

class _NearbyRequestsScreenState extends State<NearbyRequestsScreen> {
  final _ds = AppDataService();
  String _filterType = 'all';
  bool _showMap = false;

  @override
  Widget build(BuildContext context) {
    final user = _ds.currentUser!;
    var nearby = _ds.getNearbyRequests(user.latitude, user.longitude);
    if (_filterType != 'all') {
      nearby = nearby.where((r) => r.wasteType == _filterType).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('درخواست\u200cهای نزدیک'),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
        ],
      ),
      body: Column(children: [
        // Filter chips
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _filterChip('همه', 'all'),
              ...WasteCategory.categories.take(6).map((c) => _filterChip(c.name, c.id)),
            ],
          ),
        ),
        Expanded(
          child: _showMap ? _buildMapView(nearby) : _buildListView(nearby),
        ),
      ]),
    );
  }

  Widget _filterChip(String label, String type) {
    final selected = _filterType == type;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.orange,
        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontSize: 12),
        onSelected: (_) => setState(() => _filterType = type),
      ),
    );
  }

  Widget _buildMapView(List<ScrapRequest> requests) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Stack(children: [
        const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.map, size: 80, color: AppColors.lightGreen),
          SizedBox(height: 12),
          Text('نقشه (شبیه\u200cسازی)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          Text('موقعیت درخواست\u200cها در نسخه نهایی روی نقشه نمایش داده می\u200cشود', style: TextStyle(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ])),
        ...requests.asMap().entries.map((e) {
          final i = e.key;
          final r = e.value;
          final cat = WasteCategory.getById(r.wasteType);
          return Positioned(
            left: 30.0 + (i * 40 % 250),
            top: 30.0 + (i * 50 % 300),
            child: Tooltip(
              message: '${cat.name} - ${r.quantity}',
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: cat.color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: cat.color.withValues(alpha: 0.4), blurRadius: 8)]),
                child: Icon(cat.icon, color: Colors.white, size: 18),
              ),
            ),
          );
        }),
      ]),
    );
  }

  Widget _buildListView(List<ScrapRequest> requests) {
    if (requests.isEmpty) {
      return const Center(child: Text('درخواستی یافت نشد', style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (_, i) {
        final r = requests[i];
        final cat = WasteCategory.getById(r.wasteType);
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(cat.icon, color: cat.color, size: 22),
            ),
            title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${r.quantity} | ${r.address}', style: const TextStyle(fontSize: 12)),
            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (r.urgency == UrgencyType.urgent) const Icon(Icons.flash_on, color: AppColors.red, size: 18),
              if (r.estimatedPrice != null) Text('~${(r.estimatedPrice! / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.orange)),
            ]),
          ),
        );
      },
    );
  }
}
