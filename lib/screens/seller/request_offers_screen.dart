import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/scrap_request.dart';
import '../../models/offer_model.dart';
import '../../models/waste_category.dart';
import '../../services/app_data_service.dart';

class RequestOffersScreen extends StatefulWidget {
  final ScrapRequest request;
  const RequestOffersScreen({super.key, required this.request});
  @override
  State<RequestOffersScreen> createState() => _RequestOffersScreenState();
}

class _RequestOffersScreenState extends State<RequestOffersScreen> {
  final _ds = AppDataService();

  @override
  Widget build(BuildContext context) {
    final offers = _ds.getRequestOffers(widget.request.id);
    final cat = WasteCategory.getById(widget.request.wasteType);

    return Scaffold(
      appBar: AppBar(title: const Text('پیشنهادها')),
      body: Column(children: [
        // Request info header
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.backgroundGreen,
          child: Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: Icon(cat.icon, color: cat.color, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${widget.request.quantity} | ${widget.request.address}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            if (widget.request.estimatedPrice != null)
              Column(children: [
                const Text('قیمت تخمینی', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                Text('${(widget.request.estimatedPrice! / 1000).toStringAsFixed(0)} هزار', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              ]),
          ]),
        ),
        // Offers list
        Expanded(
          child: offers.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.hourglass_empty, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text('هنوز پیشنهادی دریافت نشده', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                const Text('صبر کنید تا جمع\u200cآوری\u200cکنندگان پیشنهاد بدهند', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: offers.length,
                itemBuilder: (_, i) => _offerCard(offers[i]),
              ),
        ),
      ]),
    );
  }

  Widget _offerCard(OfferModel offer) {
    final isAccepted = offer.status == OfferStatus.accepted;
    final isRejected = offer.status == OfferStatus.rejected;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isAccepted ? const BorderSide(color: AppColors.primaryGreen, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(backgroundColor: AppColors.backgroundGreen, child: Icon(Icons.person, color: AppColors.primaryGreen)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(offer.buyerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Row(children: [
                const Icon(Icons.star, size: 14, color: AppColors.gold),
                Text(' ${offer.buyerRating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                Icon(Icons.shopping_bag_outlined, size: 14, color: AppColors.textSecondary),
                Text(' ${offer.buyerCompletedOrders} سفارش', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${(offer.offeredPrice / 1000).toStringAsFixed(0)} هزار تومان', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryGreen)),
              Row(children: [
                const Icon(Icons.location_on, size: 13, color: AppColors.textSecondary),
                Text(' ${offer.distance.toStringAsFixed(1)} کیلومتر', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
            ]),
          ]),
          if (offer.message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.backgroundGreen, borderRadius: BorderRadius.circular(10)),
              child: Text(offer.message, style: const TextStyle(fontSize: 13)),
            ),
          ],
          const SizedBox(height: 12),
          if (isAccepted)
            Container(
              width: double.infinity, padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20),
                SizedBox(width: 8),
                Text('پذیرفته شده', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
              ]),
            )
          else if (isRejected)
            const Center(child: Text('رد شده', style: TextStyle(color: AppColors.textSecondary)))
          else
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: () => _acceptOffer(offer),
              icon: const Icon(Icons.check, size: 20),
              label: const Text('انتخاب این پیشنهاد'),
            )),
        ]),
      ),
    );
  }

  void _acceptOffer(OfferModel offer) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('تأیید انتخاب', textAlign: TextAlign.center),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('پیشنهاد ${offer.buyerName} با مبلغ ${(offer.offeredPrice / 1000).toStringAsFixed(0)} هزار تومان', textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('آیا مطمئن هستید؟', style: TextStyle(color: AppColors.textSecondary)),
      ]),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
        ElevatedButton(onPressed: () {
          _ds.acceptOffer(offer.id, widget.request.id);
          Navigator.pop(ctx);
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('پیشنهاد پذیرفته شد! سفارش ایجاد شد.', textDirection: TextDirection.rtl), backgroundColor: AppColors.primaryGreen, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          );
        }, child: const Text('تأیید')),
      ],
    ));
  }
}
