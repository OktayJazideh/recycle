import 'package:flutter/foundation.dart';

import '../models/domain_models.dart';
import '../repositories/marketplace_repository.dart';

class AppState extends ChangeNotifier {
  AppState(this._repository);

  final MarketplaceRepository _repository;

  bool isBootstrapping = true;
  bool isSavingSettings = false;
  bool isSubmittingRequest = false;
  String? bootstrapError;
  AppUser? currentUser;
  List<AppUser> users = <AppUser>[];
  List<WasteCategoryConfig> categories = <WasteCategoryConfig>[];
  List<QuantityOption> quantityOptions = <QuantityOption>[];
  List<RecycleRequest> requests = <RecycleRequest>[];
  List<SupportTicket> tickets = <SupportTicket>[];
  AdminSettings settings = AdminSettings(
    commissionPercent: 0,
    maxDistanceKm: 10,
    demoModeEnabled: true,
  );

  Future<void> bootstrap() async {
    isBootstrapping = true;
    bootstrapError = null;
    notifyListeners();

    try {
      final data = await _repository.loadBootstrapData();
      users = data.users;
      categories = data.categories;
      quantityOptions = data.quantityOptions..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      requests = data.requests;
      tickets = data.tickets;
      settings = data.settings;
    } catch (error) {
      bootstrapError = 'بارگذاری داده‌ها با خطا روبه‌رو شد.';
    } finally {
      isBootstrapping = false;
      notifyListeners();
    }
  }

  void loginAs(AppUserRole role) {
    currentUser = users.firstWhere((user) => user.role == role);
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  AppUser get sellerDemo => users.firstWhere((user) => user.role == AppUserRole.seller);
  AppUser get buyerDemo => users.firstWhere((user) => user.role == AppUserRole.buyer);
  AppUser get adminDemo => users.firstWhere((user) => user.role == AppUserRole.admin);

  WasteCategoryConfig categoryById(String id) {
    return categories.firstWhere(
      (category) => category.id == id,
      orElse: () => categories.isNotEmpty
          ? categories.first
          : WasteCategoryConfig(
              id: 'fallback',
              title: 'دسته‌بندی',
              iconName: 'description',
              colorHex: '#7D9B76',
              pricePerKg: 0,
              isProtected: false,
            ),
    );
  }

  List<RecycleRequest> get sellerRequests {
    final sellerId = sellerDemo.id;
    return requests.where((request) => request.sellerId == sellerId).toList();
  }

  List<RecycleRequest> get buyerNearbyRequests {
    return List<RecycleRequest>.from(requests)
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  }

  List<SupportTicket> get openTickets {
    return tickets.where((ticket) => ticket.status != SupportTicketStatus.closed).toList();
  }

  Map<String, String> get adminStats {
    return <String, String>{
      'کاربران فعال': '${users.length - 1}',
      'درخواست‌های فعال': '${requests.length}',
      'تیکت باز': '${openTickets.length}',
      'گردش مالی': '0.2M',
    };
  }

  Future<bool> saveAdminSettings({
    required double commissionPercent,
    required double maxDistanceKm,
    required bool demoModeEnabled,
    required Map<String, int> categoryPrices,
  }) async {
    isSavingSettings = true;
    notifyListeners();

    settings = settings.copyWith(
      commissionPercent: commissionPercent,
      maxDistanceKm: maxDistanceKm,
      demoModeEnabled: demoModeEnabled,
    );

    categories = categories
        .map(
          (category) => category.copyWith(
            pricePerKg: categoryPrices[category.id] ?? category.pricePerKg,
          ),
        )
        .toList();

    try {
      await _repository.persistAdminConfiguration(
        settings: settings,
        categories: categories,
        quantityOptions: quantityOptions,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      isSavingSettings = false;
      notifyListeners();
    }
  }

  Future<bool> submitRecycleRequest({
    required String categoryId,
    required String quantityId,
    required String address,
    required String description,
    required bool urgent,
  }) async {
    isSubmittingRequest = true;
    notifyListeners();

    final category = categoryById(categoryId);
    final quantity = quantityOptions.firstWhere(
      (item) => item.id == quantityId,
      orElse: () => quantityOptions.first,
    );

    final request = RecycleRequest(
      id: 'req-${DateTime.now().millisecondsSinceEpoch}',
      sellerId: sellerDemo.id,
      sellerName: sellerDemo.name,
      categoryId: category.id,
      quantityId: quantity.id,
      quantityLabel: quantity.label,
      address: address,
      description: description,
      estimatedPrice: category.pricePerKg * 5,
      urgent: urgent,
      statusLabel: 'در انتظار',
      distanceKm: 0.0,
    );

    try {
      requests = <RecycleRequest>[request, ...requests];
      await _repository.submitRequest(request);
      return true;
    } catch (_) {
      requests.removeWhere((item) => item.id == request.id);
      return false;
    } finally {
      isSubmittingRequest = false;
      notifyListeners();
    }
  }

  Future<void> sendTicketReply({
    required String ticketId,
    required String text,
    required bool isAdmin,
  }) async {
    final ticketIndex = tickets.indexWhere((ticket) => ticket.id == ticketId);
    if (ticketIndex == -1) {
      return;
    }

    final sender = isAdmin ? adminDemo.name : (currentUser?.name ?? sellerDemo.name);
    final message = TicketMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      senderName: sender,
      body: text,
      sentAt: DateTime.now(),
      isAdmin: isAdmin,
    );

    final ticket = tickets[ticketIndex];
    final updatedMessages = <TicketMessage>[...ticket.messages, message];
    tickets[ticketIndex] = ticket.copyWith(
      status: isAdmin ? SupportTicketStatus.inProgress : ticket.status,
      preview: text,
      messages: updatedMessages,
    );
    notifyListeners();

    await _repository.sendTicketMessage(ticketId: ticketId, message: message);
  }

  void updateCurrentUserProfile({
    required String name,
    required String phone,
    required String address,
  }) {
    if (currentUser == null) {
      return;
    }

    final updated = currentUser!.copyWith(name: name, phone: phone, address: address);
    final userIndex = users.indexWhere((user) => user.id == currentUser!.id);
    if (userIndex != -1) {
      users[userIndex] = updated;
    }
    currentUser = updated;
    notifyListeners();
  }
}
