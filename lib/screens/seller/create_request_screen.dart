import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/scrap_request.dart';
import '../../models/waste_category.dart';
import '../../services/app_data_service.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});
  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _ds = AppDataService();
  String _selectedType = 'paper';
  String _quantity = 'حدود ۱۰ کیلو';
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  PaymentType _paymentType = PaymentType.cash;
  UrgencyType _urgency = UrgencyType.normal;
  WasteCondition _condition = WasteCondition.mixed;
  int _selectedTimeIndex = 0;
  final List<String> _images = [];
  bool _isSubmitting = false;

  final _quantities = ['حدود ۵ کیلو', 'حدود ۱۰ کیلو', 'حدود ۲۰ کیلو', 'حدود ۵۰ کیلو', '۱ کیسه', '۲ کیسه', '۳ جعبه'];

  @override
  void initState() {
    super.initState();
    _addressController.text = _ds.currentUser?.address ?? '';
  }

  @override
  void dispose() { _descController.dispose(); _addressController.dispose(); super.dispose(); }

  void _submit() {
    if (_addressController.text.isEmpty) {
      _showSnack('لطفا آدرس خود را وارد کنید');
      return;
    }
    setState(() => _isSubmitting = true);
    final user = _ds.currentUser!;
    final cat = WasteCategory.getById(_selectedType);
    final req = ScrapRequest(
      sellerId: user.id, sellerName: user.name,
      wasteType: _selectedType, wasteTypes: [_selectedType],
      quantity: _quantity, description: _descController.text.isNotEmpty ? _descController.text : cat.name,
      images: _images,
      latitude: user.latitude, longitude: user.longitude,
      address: _addressController.text,
      requestedTime: DateTime.now().add(Duration(hours: _selectedTimeIndex == 0 ? 2 : (_selectedTimeIndex == 1 ? 24 : 4))),
      paymentType: _paymentType, urgency: _urgency, condition: _condition,
      status: RequestStatus.pending,
      estimatedPrice: cat.basePricePerKg * 10,
    );
    _ds.addRequest(req);
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() => _isSubmitting = false);
      _showSnack('درخواست با موفقیت ثبت شد!');
      Navigator.pop(context);
    });
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg, textDirection: TextDirection.rtl), backgroundColor: AppColors.primaryGreen, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ثبت درخواست جدید')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Waste type
          const Text('نوع ضایعات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: WasteCategory.categories.length,
              itemBuilder: (_, i) {
                final cat = WasteCategory.categories[i];
                final selected = cat.id == _selectedType;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = cat.id),
                  child: Container(
                    width: 80, margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: selected ? cat.color.withValues(alpha: 0.2) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: selected ? cat.color : AppColors.divider, width: selected ? 2 : 1),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(cat.icon, color: cat.color, size: 28),
                      const SizedBox(height: 6),
                      Text(cat.name, style: TextStyle(fontSize: 10, fontWeight: selected ? FontWeight.bold : FontWeight.normal), textAlign: TextAlign.center, maxLines: 2),
                    ]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Quantity
          const Text('مقدار تقریبی', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _quantities.map((q) => ChoiceChip(
              label: Text(q),
              selected: _quantity == q,
              selectedColor: AppColors.primaryGreen,
              labelStyle: TextStyle(color: _quantity == q ? Colors.white : AppColors.textPrimary, fontSize: 12),
              onSelected: (_) => setState(() => _quantity = q),
            )).toList(),
          ),
          const SizedBox(height: 20),
          // Condition
          const Text('وضعیت ضایعات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _conditionChip('تمیز و تفکیک', WasteCondition.clean, Icons.check_circle),
              _conditionChip('پرس شده', WasteCondition.compressed, Icons.compress),
              _conditionChip('مخلوط', WasteCondition.mixed, Icons.blender),
              _conditionChip('تفکیک شده', WasteCondition.separated, Icons.sort),
              _conditionChip('نیاز به جمع\u200cآوری', WasteCondition.needsPickup, Icons.local_shipping),
            ],
          ),
          const SizedBox(height: 20),
          // Photos
          const Text('تصاویر (اختیاری)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Row(children: [
            GestureDetector(
              onTap: () {
                if (_images.length < 3) {
                  setState(() => _images.add('https://picsum.photos/200?random=${_images.length}'));
                  _showSnack('تصویر اضافه شد (شبیه\u200cسازی)');
                }
              },
              child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(color: AppColors.backgroundGreen, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
                child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.camera_alt, color: AppColors.primaryGreen),
                  Text('عکس', style: TextStyle(fontSize: 10, color: AppColors.primaryGreen)),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            ..._images.asMap().entries.map((e) => Container(
              width: 70, height: 70, margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(color: AppColors.lightGreen.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
              child: Stack(children: [
                const Center(child: Icon(Icons.image, color: AppColors.primaryGreen, size: 32)),
                Positioned(top: 2, left: 2, child: GestureDetector(
                  onTap: () => setState(() => _images.removeAt(e.key)),
                  child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                )),
              ]),
            )),
          ]),
          const SizedBox(height: 20),
          // Address
          TextField(controller: _addressController, textDirection: TextDirection.rtl, maxLines: 2, decoration: InputDecoration(
            labelText: 'آدرس محل', prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: IconButton(icon: const Icon(Icons.my_location, color: AppColors.primaryGreen), onPressed: () { _addressController.text = _ds.currentUser?.address ?? 'تهران'; _showSnack('موقعیت GPS دریافت شد (شبیه\u200cسازی)'); }),
          )),
          const SizedBox(height: 16),
          TextField(controller: _descController, textDirection: TextDirection.rtl, maxLines: 2, decoration: const InputDecoration(labelText: 'توضیحات (اختیاری)', prefixIcon: Icon(Icons.description_outlined))),
          const SizedBox(height: 20),
          // Time
          const Text('زمان جمع\u200cآوری', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Row(children: [
            _timeChip('امروز', 0, Icons.today),
            const SizedBox(width: 8),
            _timeChip('فردا', 1, Icons.event),
            const SizedBox(width: 8),
            _timeChip('ساعت مشخص', 2, Icons.schedule),
          ]),
          const SizedBox(height: 20),
          // Urgency
          const Text('اولویت', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _urgencyChip('عادی', UrgencyType.normal, Icons.schedule)),
            const SizedBox(width: 10),
            Expanded(child: _urgencyChip('فوری', UrgencyType.urgent, Icons.flash_on)),
          ]),
          const SizedBox(height: 20),
          // Payment
          const Text('روش پرداخت', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _payChip('نقدی', PaymentType.cash, Icons.money)),
            const SizedBox(width: 8),
            Expanded(child: _payChip('آنلاین', PaymentType.online, Icons.payment)),
            const SizedBox(width: 8),
            Expanded(child: _payChip('هر دو', PaymentType.both, Icons.swap_horiz)),
          ]),
          const SizedBox(height: 28),
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send),
            label: Text(_isSubmitting ? 'در حال ثبت...' : 'ثبت درخواست'),
          )),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _conditionChip(String label, WasteCondition cond, IconData icon) {
    final selected = _condition == cond;
    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: selected ? Colors.white : AppColors.textSecondary),
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primaryGreen,
      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontSize: 12),
      onSelected: (_) => setState(() => _condition = cond),
    );
  }

  Widget _timeChip(String label, int idx, IconData icon) {
    final selected = _selectedTimeIndex == idx;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _selectedTimeIndex = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: selected ? AppColors.primaryGreen : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? AppColors.primaryGreen : AppColors.divider)),
        child: Column(children: [
          Icon(icon, color: selected ? Colors.white : AppColors.textSecondary, size: 20),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
      ),
    ));
  }

  Widget _urgencyChip(String label, UrgencyType type, IconData icon) {
    final selected = _urgency == type;
    final color = type == UrgencyType.urgent ? AppColors.red : AppColors.blue;
    return GestureDetector(
      onTap: () => setState(() => _urgency = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: selected ? color.withValues(alpha: 0.15) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? color : AppColors.divider, width: selected ? 2 : 1)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: selected ? color : AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _payChip(String label, PaymentType type, IconData icon) {
    final selected = _paymentType == type;
    return GestureDetector(
      onTap: () => setState(() => _paymentType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: selected ? AppColors.primaryGreen : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? AppColors.primaryGreen : AppColors.divider)),
        child: Column(children: [
          Icon(icon, color: selected ? Colors.white : AppColors.textSecondary, size: 20),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}
