import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/domain_models.dart';

abstract class MarketplaceRepository {
  Future<AppBootstrapData> loadBootstrapData();
  Future<void> persistAdminConfiguration({
    required AdminSettings settings,
    required List<WasteCategoryConfig> categories,
    required List<QuantityOption> quantityOptions,
  });

  Future<void> submitRequest(RecycleRequest request);
  Future<void> sendTicketMessage({
    required String ticketId,
    required TicketMessage message,
  });
}

class HybridMarketplaceRepository implements MarketplaceRepository {
  HybridMarketplaceRepository({required this.apiBaseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String apiBaseUrl;
  final http.Client _client;

  @override
  Future<AppBootstrapData> loadBootstrapData() async {
    try {
      final response = await _client
          .get(Uri.parse('$apiBaseUrl/api/bootstrap'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final raw = jsonDecode(utf8.decode(response.bodyBytes));
        if (raw is Map<String, dynamic>) {
          return AppBootstrapData.fromMap(raw);
        }
      }
    } catch (_) {
      // Silent fallback to local seed keeps the UI responsive during offline demos.
    }

    await Future<void>.delayed(const Duration(milliseconds: 900));
    return _mockData();
  }

  @override
  Future<void> persistAdminConfiguration({
    required AdminSettings settings,
    required List<WasteCategoryConfig> categories,
    required List<QuantityOption> quantityOptions,
  }) async {
    try {
      await _client
          .put(
            Uri.parse('$apiBaseUrl/api/settings'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'settings': settings.toMap(),
              'categories': categories.map((item) => item.toMap()).toList(),
              'quantityOptions':
                  quantityOptions.map((item) => item.toMap()).toList(),
            }),
          )
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
    }
  }

  @override
  Future<void> submitRequest(RecycleRequest request) async {
    try {
      await _client
          .post(
            Uri.parse('$apiBaseUrl/api/requests'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toMap()),
          )
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  Future<void> sendTicketMessage({
    required String ticketId,
    required TicketMessage message,
  }) async {
    try {
      await _client
          .post(
            Uri.parse('$apiBaseUrl/api/tickets/$ticketId/messages'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(message.toMap()),
          )
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
  }

  AppBootstrapData _mockData() {
    final users = <AppUser>[
      AppUser(
        id: 'seller-demo',
        name: 'علی رضایی',
        phone: '09121111111',
        role: AppUserRole.seller,
        address: 'میدان ونک، تهران',
        rating: 4.1,
        completedOrders: 28,
        preferredCategoryId: 'paper',
        points: 32,
      ),
      AppUser(
        id: 'buyer-demo',
        name: 'مهدی (وانت سیار)',
        phone: '09123334444',
        role: AppUserRole.buyer,
        address: 'میدان ونک، تهران',
        rating: 4.5,
        completedOrders: 118,
        preferredCategoryId: 'metal',
        vehicleInfo: 'وانت زامیاد - سفید',
        workingHours: '۸:۰۰ تا ۲۰:۰۰',
        portfolioImages: const [
          'assets/images/collector_before_after_1.png',
          'assets/images/collector_before_after_2.png',
        ],
        points: 84,
      ),
      AppUser(
        id: 'admin-demo',
        name: 'مدیر سیستم',
        phone: '09120000000',
        role: AppUserRole.admin,
        address: 'دفتر مرکزی',
        rating: 5,
        completedOrders: 0,
        preferredCategoryId: 'paper',
      ),
    ];

    final categories = <WasteCategoryConfig>[
      WasteCategoryConfig(
        id: 'paper',
        title: 'کاغذ و کارتن',
        iconName: 'description',
        colorHex: '#7D9B76',
        pricePerKg: 15000,
        isProtected: true,
      ),
      WasteCategoryConfig(
        id: 'plastic',
        title: 'پلاستیک',
        iconName: 'local_drink',
        colorHex: '#5C8D89',
        pricePerKg: 20000,
        isProtected: true,
      ),
      WasteCategoryConfig(
        id: 'metal',
        title: 'فلز و آهن',
        iconName: 'precision_manufacturing',
        colorHex: '#8A6A4A',
        pricePerKg: 45000,
        isProtected: true,
      ),
      WasteCategoryConfig(
        id: 'copper',
        title: 'مس و برنج',
        iconName: 'electrical_services',
        colorHex: '#B06F4F',
        pricePerKg: 350000,
        isProtected: true,
      ),
      WasteCategoryConfig(
        id: 'glass',
        title: 'شیشه',
        iconName: 'wine_bar',
        colorHex: '#86B8A5',
        pricePerKg: 5000,
        isProtected: false,
      ),
      WasteCategoryConfig(
        id: 'electronics',
        title: 'الکترونیک',
        iconName: 'devices',
        colorHex: '#7E8AA2',
        pricePerKg: 30000,
        isProtected: false,
      ),
    ];

    final quantityOptions = <QuantityOption>[
      QuantityOption(id: 'q1', label: 'حدود ۵ کیلو', sortOrder: 1),
      QuantityOption(id: 'q2', label: 'حدود ۱۰ کیلو', sortOrder: 2),
      QuantityOption(id: 'q3', label: 'حدود ۲۰ کیلو', sortOrder: 3),
      QuantityOption(id: 'q4', label: 'حدود ۵۰ کیلو', sortOrder: 4),
      QuantityOption(id: 'q5', label: '۱ کیسه', sortOrder: 5),
      QuantityOption(id: 'q6', label: '۲ کیسه', sortOrder: 6),
      QuantityOption(id: 'q7', label: '۳ جعبه', sortOrder: 7),
    ];

    final requests = <RecycleRequest>[
      RecycleRequest(
        id: 'req-1',
        sellerId: 'seller-demo',
        sellerName: 'علی رضایی',
        categoryId: 'plastic',
        quantityId: 'q2',
        quantityLabel: 'حدود ۱۰ کیلو',
        address: 'میدان تجریش، تهران',
        description: 'بطری و ظرف پلاستیکی تفکیک شده',
        estimatedPrice: 210000,
        urgent: true,
        statusLabel: 'در انتظار',
        distanceKm: 0.4,
      ),
      RecycleRequest(
        id: 'req-2',
        sellerId: 'seller-demo',
        sellerName: 'علی رضایی',
        categoryId: 'metal',
        quantityId: 'q4',
        quantityLabel: 'حدود ۵۰ کیلو',
        address: 'میدان ونک، تهران',
        description: 'ضایعات فلزی مربوط به بازسازی',
        estimatedPrice: 860000,
        urgent: true,
        statusLabel: 'در حال بررسی',
        distanceKm: 0.0,
      ),
      RecycleRequest(
        id: 'req-3',
        sellerId: 'seller-demo',
        sellerName: 'علی رضایی',
        categoryId: 'paper',
        quantityId: 'q1',
        quantityLabel: 'حدود ۵ کیلو',
        address: 'صادقیه، تهران',
        description: 'کارتن و روزنامه خشک',
        estimatedPrice: 95000,
        urgent: false,
        statusLabel: 'پیشنهاد دریافت شد',
        distanceKm: 2.7,
      ),
    ];

    final tickets = <SupportTicket>[
      SupportTicket(
        id: 'ticket-1',
        title: 'وزن ضایعات کمتر از اعلام اولیه بود',
        status: SupportTicketStatus.inProgress,
        preview: 'فروشنده ۲۰ کیلو اعلام کرده بود اما وزن واقعی کمتر بود.',
        messages: [
          TicketMessage(
            id: 'msg-1',
            senderName: 'مهدی (وانت سیار)',
            body: 'فروشنده ۲۰ کیلو اعلام کرده بود اما وزن واقعی ۱۰ کیلو شد.',
            sentAt: DateTime.now().subtract(const Duration(hours: 3)),
            isAdmin: false,
          ),
          TicketMessage(
            id: 'msg-2',
            senderName: 'پشتیبانی',
            body: 'مورد بررسی شد. لطفاً عکس باسکول را هم ارسال کنید.',
            sentAt: DateTime.now().subtract(const Duration(hours: 2)),
            isAdmin: true,
          ),
        ],
      ),
      SupportTicket(
        id: 'ticket-2',
        title: 'جمع‌آور با تأخیر رسیده است',
        status: SupportTicketStatus.open,
        preview: 'نیاز به هماهنگی مجدد برای زمان مراجعه وجود دارد.',
        messages: [
          TicketMessage(
            id: 'msg-3',
            senderName: 'علی رضایی',
            body: 'جمع‌آور با ۴۵ دقیقه تأخیر رسیده و نیاز به هماهنگی مجدد دارم.',
            sentAt: DateTime.now().subtract(const Duration(hours: 6)),
            isAdmin: false,
          ),
        ],
      ),
    ];

    return AppBootstrapData(
      users: users,
      categories: categories,
      quantityOptions: quantityOptions,
      settings: AdminSettings(
        commissionPercent: 8.5,
        maxDistanceKm: 10,
        demoModeEnabled: true,
      ),
      requests: requests,
      tickets: tickets,
    );
  }
}
