import 'dart:math';
import '../models/user_model.dart';
import '../models/scrap_request.dart';
import '../models/offer_model.dart';
import '../models/order_model.dart';
import '../models/rating_model.dart';
import '../models/ticket_model.dart';

class AppDataService {
  static final AppDataService _instance = AppDataService._internal();
  factory AppDataService() => _instance;
  AppDataService._internal() {
    _initSampleData();
  }

  UserModel? currentUser;
  final List<UserModel> users = [];
  final List<ScrapRequest> requests = [];
  final List<OfferModel> offers = [];
  final List<OrderModel> orders = [];
  final List<RatingModel> ratings = [];
  final List<ArticleModel> articles = [];
  final List<TicketModel> tickets = [];
  final List<Map<String, dynamic>> notifications = [];
  final List<Map<String, dynamic>> violations = [];

  // Admin settings
  double maxDistanceKm = 10.0;
  double commissionPercent = 0.0;
  bool demoModeEnabled = true;

  final _rng = Random();

  void _initSampleData() {
    _createSampleUsers();
    _createSampleRequests();
    _createSampleOffers();
    _createSampleOrders();
    _createSampleRatings();
    _createSampleArticles();
    _createSampleTickets();
  }

  void _createSampleUsers() {
    final sellerNames = ['علی رضایی', 'سارا محمدی', 'رضا کریمی', 'مریم حسینی', 'حسن احمدی'];
    final buyerNames = ['مهدی (وانت سیار)', 'عباس ضایعاتی', 'فاطمه بازیافت', 'حمید جمع\u200cآوری', 'زهرا مواد'];
    final addresses = ['میدان ونک، تهران', 'خ انقلاب، تهران', 'میدان تجریش، تهران', 'صادقیه، تهران', 'میدان آزادی، تهران'];

    for (int i = 0; i < 5; i++) {
      users.add(UserModel(
        id: 'seller_$i', name: sellerNames[i], phone: '0912${1000000 + _rng.nextInt(9000000)}',
        role: UserRole.seller, ratingAvg: 3.5 + _rng.nextDouble() * 1.5,
        ratingCount: 5 + _rng.nextInt(50), address: addresses[i],
        latitude: 35.68 + _rng.nextDouble() * 0.06,
        longitude: 51.35 + _rng.nextDouble() * 0.08,
        isVerified: true, completedOrders: 3 + _rng.nextInt(30),
      ));
    }

    for (int i = 0; i < 5; i++) {
      users.add(UserModel(
        id: 'buyer_$i', name: buyerNames[i], phone: '0912${2000000 + _rng.nextInt(9000000)}',
        role: UserRole.buyer, ratingAvg: 3.8 + _rng.nextDouble() * 1.2,
        ratingCount: 10 + _rng.nextInt(80), address: addresses[i],
        latitude: 35.69 + _rng.nextDouble() * 0.04,
        longitude: 51.37 + _rng.nextDouble() * 0.06,
        isVerified: true, vehicleInfo: i < 3 ? 'وانت زامیاد - سفید' : 'مغازه محلی',
        wasteTypes: ['paper', 'plastic', 'metal', 'glass'].sublist(0, 2 + _rng.nextInt(3)),
        workingHours: '۸:۰۰ - ۲۰:۰۰',
        completedOrders: 20 + _rng.nextInt(100),
      ));
    }

    users.add(UserModel(
      id: 'admin_0', name: 'مدیر سیستم', phone: '09120000000',
      role: UserRole.admin, ratingAvg: 5.0, isVerified: true,
    ));
  }

  void _createSampleRequests() {
    final wasteTypes = ['paper', 'plastic', 'metal', 'copper', 'glass', 'electronics', 'mixed'];
    final quantities = ['حدود ۵ کیلو', 'حدود ۱۰ کیلو', 'حدود ۲۰ کیلو', 'حدود ۵۰ کیلو', '۲ کیسه', '۱ صندوق عقب', '۳ جعبه'];
    final descs = [
      'روزنامه و مجله قدیمی', 'بطری و ظرف پلاستیکی',
      'ضایعات فلزی از بازسازی', 'سیم\u200cهای برق قدیمی',
      'مجموعه بطری\u200cهای شیشه\u200cای', 'گوشی و لپ\u200cتاپ قدیمی', 'ضایعات مخلوط خانگی',
    ];

    for (int i = 0; i < 12; i++) {
      final idx = i % wasteTypes.length;
      final seller = users.where((u) => u.role == UserRole.seller).toList()[i % 5];
      requests.add(ScrapRequest(
        id: 'req_$i', sellerId: seller.id, sellerName: seller.name,
        wasteType: wasteTypes[idx], wasteTypes: [wasteTypes[idx]],
        quantity: quantities[idx], description: descs[idx],
        images: [],
        latitude: seller.latitude + (_rng.nextDouble() - 0.5) * 0.01,
        longitude: seller.longitude + (_rng.nextDouble() - 0.5) * 0.01,
        address: seller.address,
        requestedTime: DateTime.now().add(Duration(hours: 2 + _rng.nextInt(48))),
        paymentType: PaymentType.values[_rng.nextInt(3)],
        urgency: i < 4 ? UrgencyType.urgent : UrgencyType.normal,
        condition: WasteCondition.values[_rng.nextInt(5)],
        status: i < 3 ? RequestStatus.pending : (i < 6 ? RequestStatus.active : (i < 9 ? RequestStatus.accepted : RequestStatus.completed)),
        estimatedPrice: (50 + _rng.nextInt(500)) * 1000.0,
        createdAt: DateTime.now().subtract(Duration(hours: _rng.nextInt(72))),
      ));
    }
  }

  void _createSampleOffers() {
    final buyers = users.where((u) => u.role == UserRole.buyer).toList();
    for (int i = 0; i < 6; i++) {
      final req = requests[i];
      for (int j = 0; j < 2 + _rng.nextInt(3); j++) {
        final buyer = buyers[_rng.nextInt(buyers.length)];
        offers.add(OfferModel(
          id: 'offer_${i}_$j', requestId: req.id,
          buyerId: buyer.id, buyerName: buyer.name,
          offeredPrice: (req.estimatedPrice ?? 100000) * (0.8 + _rng.nextDouble() * 0.4),
          message: j == 0 ? 'امروز میتونم جمع\u200cآوری کنم' : 'بهترین قیمت تضمینی!',
          status: i < 3 ? OfferStatus.pending : (j == 0 ? OfferStatus.accepted : OfferStatus.rejected),
          buyerRating: buyer.ratingAvg,
          buyerCompletedOrders: buyer.completedOrders,
          distance: 0.5 + _rng.nextDouble() * 5,
          createdAt: DateTime.now().subtract(Duration(hours: _rng.nextInt(24))),
        ));
      }
    }
  }

  void _createSampleOrders() {
    for (int i = 6; i < 10; i++) {
      final req = requests[i];
      final buyer = users.firstWhere((u) => u.role == UserRole.buyer);
      orders.add(OrderModel(
        id: 'order_$i', requestId: req.id,
        sellerId: req.sellerId, sellerName: req.sellerName,
        buyerId: buyer.id, buyerName: buyer.name,
        wasteType: req.wasteType, quantity: req.quantity,
        finalPrice: req.estimatedPrice ?? 150000,
        paymentType: req.paymentType.name,
        paymentStatus: i > 8 ? PaymentStatus.paid : PaymentStatus.pending,
        orderStatus: i == 6 ? OrderStatus.confirmed : (i == 7 ? OrderStatus.buyerOnWay : (i == 8 ? OrderStatus.arrived : OrderStatus.completed)),
        address: req.address,
        scheduledTime: req.requestedTime,
        completedAt: i == 9 ? DateTime.now().subtract(const Duration(hours: 2)) : null,
      ));
    }
  }

  void _createSampleRatings() {
    for (int i = 0; i < 8; i++) {
      final fromUser = users[_rng.nextInt(users.length - 1)];
      final toUser = users[_rng.nextInt(users.length - 1)];
      final comments = ['تجربه عالی بود', 'زمان\u200cبندی بهتر میشد', 'خیلی خوب و منصف', 'راضی بودم', 'کیفیت خوبی داشت', 'قیمت مناسب بود', 'وقت\u200cشناس بود', 'برخورد خوبی داشت'];
      ratings.add(RatingModel(
        orderId: 'order_9',
        fromUserId: fromUser.id, fromUserName: fromUser.name,
        toUserId: toUser.id, toUserName: toUser.name,
        score: 3.0 + _rng.nextDouble() * 2.0,
        accuracyScore: 3.0 + _rng.nextDouble() * 2.0,
        punctualityScore: 3.0 + _rng.nextDouble() * 2.0,
        behaviorScore: 3.0 + _rng.nextDouble() * 2.0,
        hiddenComment: comments[i],
      ));
    }
  }

  void _createSampleArticles() {
    final articleData = [
      {'title': 'کدام ضایعات بیشترین ارزش را دارند؟', 'category': 'pricing', 'content': 'مس و برنج جزو باارزش\u200cترین مواد بازیافتی هستند. هر کیلوگرم سیم مسی تمیز تا ۳۵۰ هزار تومان ارزش دارد. قوطی\u200cهای آلومینیومی نیز ارزشمند هستند و معمولاً کیلویی حدود ۸۰ هزار تومان قیمت\u200cگذاری می\u200cشوند.\n\nراهنمای قیمت کلی:\n\n- مس: ۳۰۰ تا ۴۰۰ هزار تومان/کیلو\n- آلومینیوم: ۷۰ تا ۹۰ هزار تومان/کیلو\n- آهن/فولاد: ۳۰ تا ۵۰ هزار تومان/کیلو\n- پلاستیک (تمیز): ۱۵ تا ۲۵ هزار تومان/کیلو\n- کاغذ/کارتن: ۱۰ تا ۲۰ هزار تومان/کیلو\n- شیشه: ۳ تا ۸ هزار تومان/کیلو'},
      {'title': 'چگونه ضایعات را درست تفکیک کنیم؟', 'category': 'education', 'content': 'تفکیک صحیح مواد زباله می\u200cتواند ارزش آن\u200cها را به طور قابل توجهی افزایش دهد:\n\n۱. فلزات را بر اساس نوع جدا کنید\n۲. کاغذ را خشک و تمیز نگه دارید\n۳. برچسب بطری\u200cهای پلاستیکی را بردارید\n۴. ظروف شیشه\u200cای را بشویید\n۵. باتری\u200cها را از لوازم الکترونیکی جدا کنید'},
      {'title': 'نکات ایمنی برای جمع\u200cآوری ضایعات', 'category': 'safety', 'content': 'چه فروشنده باشید چه جمع\u200cآوری\u200cکننده، ایمنی اولویت اول است:\n\n۱. هنگام کار با فلزات تیز دستکش بپوشید\n۲. با شیشه شکسته احتیاط کنید\n۳. هرگز مواد شیمیایی را با زباله عادی مخلوط نکنید\n۴. از تکنیک\u200cهای بلند کردن صحیح استفاده کنید\n۵. ضایعات را در مکان\u200cهای هوادار نگه دارید'},
      {'title': 'اقتصاد بازیافت', 'category': 'economics', 'content': 'بازیافت نه تنها برای محیط زیست خوب است بلکه یک صنعت میلیاردی است. تنها در ایران، بازار بازیافت هزاران شغل ایجاد کرده.\n\nبا فروش ضایعات از طریق بازار بازیافت:\n- از اقلامی که دور می\u200cریختید درآمد کسب کنید\n- از جمع\u200cآوری\u200cکنندگان محلی حمایت کنید\n- زباله\u200cهای دفنی را کاهش دهید\n- به اقتصاد چرخشی کمک کنید'},
      {'title': 'بهترین زمان فروش ضایعات', 'category': 'tips', 'content': 'زمان\u200cبندی می\u200cتواند بر قیمت تأثیر بگذارد:\n\n- قیمت فلزات در بهار و پاییز بالاتر است\n- مقدار کافی جمع کنید تا ارزش جمع\u200cآوری داشته باشد\n- درخواست\u200cهای صبح زود پاسخ سریع\u200cتری می\u200cگیرند'},
      {'title': 'تأثیر وضعیت ضایعات بر قیمت', 'category': 'pricing', 'content': 'وضعیت ضایعات مستقیماً بر ارزش آن تأثیر می\u200cگذارد:\n\nتمیز و تفکیک\u200cشده: قیمت پرمیوم (۱۰۰٪)\nمخلوط: قیمت متوسط (۷۰-۸۰٪)\nتفکیک\u200cنشده/کثیف: قیمت پایین (۵۰-۶۰٪)'},
    ];

    for (int i = 0; i < articleData.length; i++) {
      articles.add(ArticleModel(
        id: 'article_$i',
        title: articleData[i]['title']!,
        content: articleData[i]['content']!,
        category: articleData[i]['category']!,
        author: 'تیم بازار بازیافت',
        views: 50 + _rng.nextInt(500),
        likes: 10 + _rng.nextInt(100),
        createdAt: DateTime.now().subtract(Duration(days: i * 3)),
      ));
    }
  }

  void _createSampleTickets() {
    final seller = users.firstWhere((u) => u.role == UserRole.seller);
    tickets.add(TicketModel(
      id: 'ticket_0', userId: seller.id, userName: seller.name,
      title: 'مشکل در تحویل سفارش',
      description: 'جمع\u200cآوری\u200cکننده در زمان مقرر حاضر نشد.',
      priority: TicketPriority.urgent, status: TicketStatus.open,
      orderId: 'order_7',
      messages: [
        TicketMessage(
          senderId: seller.id, senderName: seller.name,
          message: 'جمع\u200cآوری\u200cکننده در زمان مقرر حاضر نشد. لطفاً پیگیری کنید.',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        TicketMessage(
          senderId: 'admin_0', senderName: 'پشتیبانی', isAdmin: true,
          message: 'سلام. پیگیری شد. جمع\u200cآوری\u200cکننده تماس گرفته و اعلام کرده با تأخیر خواهد آمد.',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ));

    final buyer = users.firstWhere((u) => u.role == UserRole.buyer);
    tickets.add(TicketModel(
      id: 'ticket_1', userId: buyer.id, userName: buyer.name,
      title: 'وزن ضایعات کمتر از اعلام شده',
      description: 'فروشنده ۲۰ کیلو اعلام کرده ولی ۱۰ کیلو بود.',
      priority: TicketPriority.normal, status: TicketStatus.inProgress,
      orderId: 'order_8',
      messages: [
        TicketMessage(
          senderId: buyer.id, senderName: buyer.name,
          message: 'فروشنده ۲۰ کیلو اعلام کرده ولی ۱۰ کیلو بود.',
          createdAt: DateTime.now().subtract(const Duration(hours: 10)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ));
  }

  // CRUD Operations
  List<ScrapRequest> getSellerRequests(String sellerId) =>
    requests.where((r) => r.sellerId == sellerId).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<ScrapRequest> getNearbyRequests(double lat, double lng, {double? radiusKm}) {
    final radius = radiusKm ?? maxDistanceKm;
    return requests
      .where((r) => (r.status == RequestStatus.pending || r.status == RequestStatus.active) && _distance(r.latitude, r.longitude, lat, lng) <= radius)
      .toList()
      ..sort((a, b) => _distance(a.latitude, a.longitude, lat, lng).compareTo(_distance(b.latitude, b.longitude, lat, lng)));
  }

  List<OfferModel> getRequestOffers(String requestId) =>
    offers.where((o) => o.requestId == requestId).toList()..sort((a, b) => b.offeredPrice.compareTo(a.offeredPrice));

  List<OrderModel> getUserOrders(String userId) =>
    orders.where((o) => o.sellerId == userId || o.buyerId == userId).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<TicketModel> getUserTickets(String userId) =>
    tickets.where((t) => t.userId == userId).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<RatingModel> getUserRatings(String userId) =>
    ratings.where((r) => r.toUserId == userId).toList();

  List<RatingModel> getRatingsAboutUser(String userId) =>
    ratings.where((r) => r.toUserId == userId).toList();

  List<RatingModel> getRatingsByUser(String userId) =>
    ratings.where((r) => r.fromUserId == userId).toList();

  void addRequest(ScrapRequest request) {
    requests.insert(0, request);
    _addNotification(request.sellerId, 'درخواست شما با موفقیت ثبت شد', 'request');
    // Notify nearby collectors
    final nearbyBuyers = users.where((u) => u.role == UserRole.buyer && u.isActive && _distance(u.latitude, u.longitude, request.latitude, request.longitude) <= maxDistanceKm).toList();
    for (final buyer in nearbyBuyers) {
      _addNotification(buyer.id, 'درخواست جدید در نزدیکی شما: ${request.description}', 'new_request');
    }
  }

  void addOffer(OfferModel offer) {
    offers.add(offer);
    final req = requests.firstWhere((r) => r.id == offer.requestId);
    _addNotification(req.sellerId, 'پیشنهاد جدید از ${offer.buyerName} دریافت شد', 'offer');
  }

  void acceptOffer(String offerId, String requestId) {
    final offerIdx = offers.indexWhere((o) => o.id == offerId);
    if (offerIdx >= 0) {
      final offer = offers[offerIdx];
      offers[offerIdx] = offer.copyWith(status: OfferStatus.accepted);
      for (int i = 0; i < offers.length; i++) {
        if (offers[i].requestId == requestId && offers[i].id != offerId) {
          offers[i] = offers[i].copyWith(status: OfferStatus.rejected);
        }
      }
      final reqIdx = requests.indexWhere((r) => r.id == requestId);
      if (reqIdx >= 0) {
        requests[reqIdx] = requests[reqIdx].copyWith(status: RequestStatus.accepted, acceptedBuyerId: offer.buyerId);
      }
      final req = requests[reqIdx];
      orders.add(OrderModel(
        requestId: requestId, sellerId: req.sellerId, sellerName: req.sellerName,
        buyerId: offer.buyerId, buyerName: offer.buyerName,
        wasteType: req.wasteType, quantity: req.quantity,
        finalPrice: offer.offeredPrice, paymentType: req.paymentType.name,
        address: req.address, scheduledTime: req.requestedTime,
        orderStatus: OrderStatus.confirmed,
      ));
      _addNotification(offer.buyerId, 'پیشنهاد شما برای درخواست ${req.sellerName} پذیرفته شد!', 'offer_accepted');
    }
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      orders[idx] = orders[idx].copyWith(orderStatus: status);
      if (status == OrderStatus.completed) {
        orders[idx] = orders[idx].copyWith(completedAt: DateTime.now(), paymentStatus: PaymentStatus.paid);
        final reqIdx = requests.indexWhere((r) => r.id == orders[idx].requestId);
        if (reqIdx >= 0) {
          requests[reqIdx] = requests[reqIdx].copyWith(status: RequestStatus.completed);
        }
      }
      _addNotification(orders[idx].sellerId, 'وضعیت سفارش به "${_statusLabel(status)}" تغییر کرد', 'order_status');
      _addNotification(orders[idx].buyerId, 'وضعیت سفارش به "${_statusLabel(status)}" تغییر کرد', 'order_status');
    }
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.confirmed: return 'تأیید شده';
      case OrderStatus.buyerOnWay: return 'در مسیر';
      case OrderStatus.arrived: return 'رسیدم';
      case OrderStatus.weighing: return 'در حال توزین';
      case OrderStatus.completed: return 'تکمیل شده';
      case OrderStatus.disputed: return 'اختلاف';
      case OrderStatus.cancelled: return 'لغو شده';
      default: return 'در انتظار';
    }
  }

  void confirmCashPayment(String orderId) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      orders[idx] = orders[idx].copyWith(paymentStatus: PaymentStatus.paid);
    }
  }

  void addRating(RatingModel rating) {
    ratings.add(rating);
    final userRatings = ratings.where((r) => r.toUserId == rating.toUserId).toList();
    final avg = userRatings.map((r) => r.score).reduce((a, b) => a + b) / userRatings.length;
    final userIdx = users.indexWhere((u) => u.id == rating.toUserId);
    if (userIdx >= 0) {
      users[userIdx] = users[userIdx].copyWith(ratingAvg: avg, ratingCount: userRatings.length);
    }
  }

  bool hasRated(String orderId, String fromUserId) {
    return ratings.any((r) => r.orderId == orderId && r.fromUserId == fromUserId);
  }

  // Ticket operations
  void addTicket(TicketModel ticket) {
    tickets.insert(0, ticket);
    _addNotification(ticket.userId, 'تیکت "${ticket.title}" با موفقیت ثبت شد', 'ticket');
  }

  void addTicketMessage(String ticketId, TicketMessage message) {
    final idx = tickets.indexWhere((t) => t.id == ticketId);
    if (idx >= 0) {
      final updated = List<TicketMessage>.from(tickets[idx].messages)..add(message);
      tickets[idx] = tickets[idx].copyWith(messages: updated, updatedAt: DateTime.now());
      if (message.isAdmin) {
        tickets[idx] = tickets[idx].copyWith(status: TicketStatus.inProgress);
        _addNotification(tickets[idx].userId, 'پاسخ جدید برای تیکت "${tickets[idx].title}"', 'ticket_reply');
      }
    }
  }

  void updateTicketStatus(String ticketId, TicketStatus status) {
    final idx = tickets.indexWhere((t) => t.id == ticketId);
    if (idx >= 0) {
      tickets[idx] = tickets[idx].copyWith(status: status, updatedAt: DateTime.now());
      _addNotification(tickets[idx].userId, 'وضعیت تیکت "${tickets[idx].title}" تغییر کرد', 'ticket_status');
    }
  }

  // Violation reports
  void addViolation(Map<String, dynamic> violation) {
    violations.add(violation);
  }

  // User management
  void toggleUserActive(String userId) {
    final idx = users.indexWhere((u) => u.id == userId);
    if (idx >= 0) {
      users[idx] = users[idx].copyWith(isActive: !users[idx].isActive);
    }
  }

  void deleteRating(String ratingId) {
    ratings.removeWhere((r) => r.id == ratingId);
  }

  // Notification management
  void _addNotification(String userId, String message, String type) {
    notifications.insert(0, {
      'id': 'notif_${notifications.length}',
      'userId': userId,
      'message': message, 'type': type,
      'isRead': false, 'createdAt': DateTime.now().toIso8601String(),
    });
  }

  List<Map<String, dynamic>> getUserNotifications(String userId) {
    return notifications.where((n) => n['userId'] == userId).toList();
  }

  void markNotificationRead(String notifId) {
    final idx = notifications.indexWhere((n) => n['id'] == notifId);
    if (idx >= 0) {
      notifications[idx]['isRead'] = true;
    }
  }

  int getUnreadCount(String userId) {
    return notifications.where((n) => n['userId'] == userId && n['isRead'] == false).length;
  }

  // Statistics for admin
  Map<String, dynamic> getStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = today.subtract(const Duration(days: 30));

    return {
      'totalSellers': users.where((u) => u.role == UserRole.seller).length,
      'totalBuyers': users.where((u) => u.role == UserRole.buyer).length,
      'ordersToday': orders.where((o) => o.createdAt.isAfter(today)).length,
      'ordersWeek': orders.where((o) => o.createdAt.isAfter(weekAgo)).length,
      'ordersMonth': orders.where((o) => o.createdAt.isAfter(monthAgo)).length,
      'totalTransactions': orders.where((o) => o.paymentStatus == PaymentStatus.paid).fold<double>(0, (sum, o) => sum + o.finalPrice),
      'openTickets': tickets.where((t) => t.status != TicketStatus.closed).length,
      'totalRequests': requests.length,
      'completedOrders': orders.where((o) => o.orderStatus == OrderStatus.completed).length,
      'pendingRequests': requests.where((r) => r.status == RequestStatus.pending || r.status == RequestStatus.active).length,
    };
  }

  double _distance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // CSV export
  String exportUsersCSV() {
    final sb = StringBuffer();
    sb.writeln('ID,Name,Phone,Role,Rating,Orders,Active,Verified');
    for (final u in users.where((u) => u.role != UserRole.admin)) {
      sb.writeln('${u.id},${u.name},${u.phone},${u.role.name},${u.ratingAvg.toStringAsFixed(1)},${u.completedOrders},${u.isActive},${u.isVerified}');
    }
    return sb.toString();
  }

  String exportOrdersCSV() {
    final sb = StringBuffer();
    sb.writeln('ID,Seller,Buyer,WasteType,Price,PaymentStatus,OrderStatus,Date');
    for (final o in orders) {
      sb.writeln('${o.id},${o.sellerName},${o.buyerName},${o.wasteType},${o.finalPrice},${o.paymentStatus.name},${o.orderStatus.name},${o.createdAt}');
    }
    return sb.toString();
  }

  String exportTicketsCSV() {
    final sb = StringBuffer();
    sb.writeln('ID,User,Title,Priority,Status,Date');
    for (final t in tickets) {
      sb.writeln('${t.id},${t.userName},${t.title},${t.priority.name},${t.status.name},${t.createdAt}');
    }
    return sb.toString();
  }
}
