import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../services/local_db_service.dart';
import 'ob_order_booking_screen.dart';

class OBRoutesScreen extends StatefulWidget {
  final ValueNotifier<int>? reloadNotifier;
  const OBRoutesScreen({super.key, this.reloadNotifier});
  @override
  State<OBRoutesScreen> createState() => _OBRoutesScreenState();
}

class _OBRoutesScreenState extends State<OBRoutesScreen> {
  List<LocalRoute> _routes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    widget.reloadNotifier?.addListener(_load);
  }

  @override
  void dispose() {
    widget.reloadNotifier?.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final routes = await LocalDbService.getRoutes();
    if (mounted) {
      setState(() {
        _routes = routes;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('My Routes'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent))
          : _routes.isEmpty
              ? const _EmptyState(
                  icon: Icons.map_outlined,
                  title: 'No Routes Assigned',
                  subtitle: 'Do a morning sync to download today\'s routes.',
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _routes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _RouteCard(
                      route: _routes[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => _ShopsScreen(route: _routes[i])),
                      ),
                    ),
                  ),
                ),
    );
  }
}

class _RouteCard extends StatefulWidget {
  final LocalRoute route;
  final VoidCallback onTap;
  const _RouteCard({required this.route, required this.onTap});
  @override
  State<_RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<_RouteCard> {
  int _shopCount = 0;
  int _recoveryCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final shops = await LocalDbService.getShopsByRoute(widget.route.id);
    final rec = shops.where((s) => s.hasRecoveryBill).length;
    if (mounted) {
      setState(() {
        _shopCount = shops.length;
        _recoveryCount = rec;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.accent.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.map_rounded,
                  color: AppTheme.accent, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.route.name,
                      style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _Chip(label: '$_shopCount shops', color: AppTheme.accent),
                      if (_recoveryCount > 0) ...[
                        const SizedBox(width: 6),
                        _Chip(
                            label: '$_recoveryCount recovery',
                            color: AppTheme.warning),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

// ── Shop filter enum ──────────────────────────────────────────────────────────
enum _ShopFilter { all, remaining, orderBooked }

class _ShopsScreen extends StatefulWidget {
  final LocalRoute route;
  const _ShopsScreen({required this.route});
  @override
  State<_ShopsScreen> createState() => _ShopsScreenState();
}

class _ShopsScreenState extends State<_ShopsScreen> {
  List<LocalShop> _shops = [];
  List<LocalShop> _filtered = [];
  Set<int> _bookedShopIds = {};
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  _ShopFilter _activeFilter = _ShopFilter.all;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final shops = await LocalDbService.getShopsByRoute(widget.route.id);
    final bookedIds =
        await LocalDbService.getBookedShopIds(widget.route.id, today);
    if (mounted) {
      setState(() {
        _shops = shops;
        _bookedShopIds = bookedIds;
        _loading = false;
      });
      _applyFilter();
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    List<LocalShop> result = q.isEmpty
        ? List.of(_shops)
        : _shops
            .where((s) =>
                s.name.toLowerCase().contains(q) ||
                (s.ownerName?.toLowerCase().contains(q) ?? false))
            .toList();

    switch (_activeFilter) {
      case _ShopFilter.remaining:
        result = result.where((s) => !_bookedShopIds.contains(s.id)).toList();
        break;
      case _ShopFilter.orderBooked:
        result = result.where((s) => _bookedShopIds.contains(s.id)).toList();
        break;
      case _ShopFilter.all:
        break;
    }

    setState(() => _filtered = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(widget.route.name),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search shops...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // Filter toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _activeFilter == _ShopFilter.all,
                  color: AppTheme.accent,
                  onTap: () {
                    setState(() => _activeFilter = _ShopFilter.all);
                    _applyFilter();
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Remaining',
                  selected: _activeFilter == _ShopFilter.remaining,
                  color: Colors.red.shade400,
                  onTap: () {
                    setState(() => _activeFilter = _ShopFilter.remaining);
                    _applyFilter();
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Order Booked',
                  selected: _activeFilter == _ShopFilter.orderBooked,
                  color: Colors.green.shade500,
                  onTap: () {
                    setState(() => _activeFilter = _ShopFilter.orderBooked);
                    _applyFilter();
                  },
                ),
              ],
            ),
          ),
          // Shop list
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent))
                : _filtered.isEmpty
                    ? const _EmptyState(
                        icon: Icons.store_outlined,
                        title: 'No Shops',
                        subtitle: 'No shops found in this route.')
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final shop = _filtered[i];
                          return _ShopTile(
                            shop: shop,
                            isBooked: _bookedShopIds.contains(shop.id),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        OBOrderBookingScreen(shop: shop)),
                              );
                              // Refresh booked status after returning
                              _load();
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : color.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: selected ? 0 : 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class _ShopTile extends StatelessWidget {
  final LocalShop shop;
  final bool isBooked;
  final VoidCallback onTap;
  const _ShopTile(
      {required this.shop, required this.isBooked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isWholesale = shop.shopType == 'wholesale';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isBooked ? Colors.green.shade400 : Colors.red.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isBooked ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isBooked ? Icons.check_circle_rounded : Icons.store_rounded,
                color:
                    isBooked ? Colors.green.shade500 : AppTheme.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.name,
                      style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.textPrimary)),
                  if (shop.ownerName != null)
                    Text(shop.ownerName!,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
            ),
            // Shop type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: isWholesale
                    ? AppTheme.accent.withAlpha(25)
                    : Colors.blueGrey.withAlpha(25),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isWholesale
                      ? AppTheme.accent.withAlpha(80)
                      : Colors.blueGrey.withAlpha(80),
                ),
              ),
              child: Text(
                isWholesale ? 'Wholesale' : 'Retail',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isWholesale ? AppTheme.accent : Colors.blueGrey,
                ),
              ),
            ),
            if (shop.hasRecoveryBill) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.warning.withAlpha(80)),
                ),
                child: Text('Recovery',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warning)),
              ),
            ],
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text(title,
                style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style:
                    GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
