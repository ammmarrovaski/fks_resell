import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../shop/data/shop_repository.dart';
import '../../shop/domain/product.dart';
import '../../shop/presentation/product_detail_screen.dart';
import '../data/auth_repository.dart';
import 'users_search_screen.dart';

class _HomeColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color bordoLight = Color(0xFF8B3A42);
  static const Color bordoDark = Color(0xFF5A2129);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color cardBg = Color(0xFF262626);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color divider = Color(0xFF333333);
  static const Color accent = Color(0xFFD4A574);
}

enum SortOption {
  newest,
  oldest,
  priceLow,
  priceHigh,
}

enum ConditionFilter {
  all,
  novo,
  koristeno,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _shopRepo = ShopRepository();
  final _searchController = TextEditingController();
  String _selectedCategory = 'Sve';
  String _searchQuery = '';
  bool _isSearching = false;

  // Filter & sort state
  SortOption _sortOption = SortOption.newest;
  ConditionFilter _conditionFilter = ConditionFilter.all;
  double? _minPrice;
  double? _maxPrice;
  bool _hideSold = false;

  // Price controllers
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  bool get _hasActiveFilters =>
      _conditionFilter != ConditionFilter.all ||
      _minPrice != null ||
      _maxPrice != null ||
      _hideSold ||
      _sortOption != SortOption.newest;

  final List<String> _categories = [
    'Sve',
    'Dresovi',
    'Duksevi',
    'Salovi',
    'Aksesoari'
  ];

  final Map<String, IconData> _categoryIcons = {
    'Sve': Icons.apps_rounded,
    'Dresovi': Icons.sports_soccer,
    'Duksevi': Icons.checkroom,
    'Salovi': Icons.dry_cleaning,
    'Aksesoari': Icons.watch,
  };

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  List<Product> _filterAndSort(List<Product> products) {
    var filtered = products;

    // Category
    if (_selectedCategory != 'Sve') {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((p) =>
              p.title.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q))
          .toList();
    }

    // Condition
    if (_conditionFilter == ConditionFilter.novo) {
      filtered = filtered.where((p) => p.condition == 'Novo').toList();
    } else if (_conditionFilter == ConditionFilter.koristeno) {
      filtered = filtered.where((p) => p.condition != 'Novo').toList();
    }

    // Price range
    if (_minPrice != null) {
      filtered = filtered.where((p) => p.price >= _minPrice!).toList();
    }
    if (_maxPrice != null) {
      filtered = filtered.where((p) => p.price <= _maxPrice!).toList();
    }

    // Hide sold
    if (_hideSold) {
      filtered = filtered.where((p) => !p.isSold).toList();
    }

    // Sort
    switch (_sortOption) {
      case SortOption.newest:
        filtered.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        break;
      case SortOption.oldest:
        filtered.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return a.createdAt!.compareTo(b.createdAt!);
        });
        break;
      case SortOption.priceLow:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHigh:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
    }

    return filtered;
  }

  void _openProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }

  void _showFilterSheet() {
    // temp state inside sheet
    SortOption tempSort = _sortOption;
    ConditionFilter tempCondition = _conditionFilter;
    bool tempHideSold = _hideSold;
    final tempMin = TextEditingController(text: _minPriceController.text);
    final tempMax = TextEditingController(text: _maxPriceController.text);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _HomeColors.textMuted.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filteri i sortiranje',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _HomeColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setSheetState(() {
                          tempSort = SortOption.newest;
                          tempCondition = ConditionFilter.all;
                          tempHideSold = false;
                          tempMin.clear();
                          tempMax.clear();
                        });
                      },
                      child: const Text(
                        'Resetuj',
                        style: TextStyle(
                          color: _HomeColors.bordo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Sort section
                _sheetSectionLabel('SORTIRANJE'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _sortChip('Najnoviji', SortOption.newest, tempSort,
                        (v) => setSheetState(() => tempSort = v)),
                    _sortChip('Najstariji', SortOption.oldest, tempSort,
                        (v) => setSheetState(() => tempSort = v)),
                    _sortChip('Cijena ↑', SortOption.priceLow, tempSort,
                        (v) => setSheetState(() => tempSort = v)),
                    _sortChip('Cijena ↓', SortOption.priceHigh, tempSort,
                        (v) => setSheetState(() => tempSort = v)),
                  ],
                ),

                const SizedBox(height: 20),

                // Condition section
                _sheetSectionLabel('STANJE'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    _conditionChip('Sve', ConditionFilter.all, tempCondition,
                        (v) => setSheetState(() => tempCondition = v)),
                    _conditionChip('Novo', ConditionFilter.novo, tempCondition,
                        (v) => setSheetState(() => tempCondition = v)),
                    _conditionChip('Korišteno', ConditionFilter.koristeno,
                        tempCondition,
                        (v) => setSheetState(() => tempCondition = v)),
                  ],
                ),

                const SizedBox(height: 20),

                // Price range
                _sheetSectionLabel('RASPON CIJENE (KM)'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _priceField(
                        controller: tempMin,
                        hint: 'Min',
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('—',
                          style: TextStyle(color: _HomeColors.textMuted)),
                    ),
                    Expanded(
                      child: _priceField(
                        controller: tempMax,
                        hint: 'Max',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Hide sold toggle
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _HomeColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _HomeColors.divider.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sakrij prodane artikle',
                        style: TextStyle(
                          fontSize: 14,
                          color: _HomeColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: tempHideSold,
                        onChanged: (v) =>
                            setSheetState(() => tempHideSold = v),
                        activeColor: _HomeColors.bordo,
                        activeTrackColor:
                            _HomeColors.bordo.withOpacity(0.3),
                        inactiveThumbColor: _HomeColors.textMuted,
                        inactiveTrackColor:
                            _HomeColors.textMuted.withOpacity(0.2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Apply button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _sortOption = tempSort;
                        _conditionFilter = tempCondition;
                        _hideSold = tempHideSold;
                        _minPriceController.text = tempMin.text;
                        _maxPriceController.text = tempMax.text;
                        _minPrice = double.tryParse(tempMin.text);
                        _maxPrice = double.tryParse(tempMax.text);
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _HomeColors.bordo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'PRIMIJENI FILTERE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _HomeColors.textMuted,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _sortChip(String label, SortOption value, SortOption current,
      ValueChanged<SortOption> onTap) {
    final selected = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? _HomeColors.bordo
              : _HomeColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? _HomeColors.bordo
                : _HomeColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _HomeColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _conditionChip(String label, ConditionFilter value,
      ConditionFilter current, ValueChanged<ConditionFilter> onTap) {
    final selected = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _HomeColors.bordo : _HomeColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _HomeColors.bordo : _HomeColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _HomeColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _priceField(
      {required TextEditingController controller, required String hint}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: _HomeColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: _HomeColors.textMuted, fontSize: 14),
        filled: true,
        fillColor: _HomeColors.cardBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _HomeColors.divider.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: _HomeColors.bordo, width: 1.5),
        ),
      ),
    );
  }

  int _activeFilterCount() {
    int count = 0;
    if (_sortOption != SortOption.newest) count++;
    if (_conditionFilter != ConditionFilter.all) count++;
    if (_minPrice != null) count++;
    if (_maxPrice != null) count++;
    if (_hideSold) count++;
    return count;
  }

  String _sortLabel() {
    switch (_sortOption) {
      case SortOption.newest:
        return 'Najnoviji';
      case SortOption.oldest:
        return 'Najstariji';
      case SortOption.priceLow:
        return 'Cijena ↑';
      case SortOption.priceHigh:
        return 'Cijena ↓';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _HomeColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: _isSearching
                    ? _buildSearchBar(key: const ValueKey('search'))
                    : _buildHeader(key: const ValueKey('header')),
              ),
            ),

            const SizedBox(height: 14),

            // Category chips + filter chip (all in one list)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Category chips
                  ..._categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _HomeColors.bordo
                                : _HomeColors.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isSelected
                                  ? _HomeColors.bordo
                                  : _HomeColors.divider,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color:
                                          _HomeColors.bordo.withOpacity(0.25),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _categoryIcons[cat] ?? Icons.category,
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : _HomeColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? Colors.white
                                      : _HomeColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  // Filter chip — isti stil kao kategorije
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: _hasActiveFilters
                            ? _HomeColors.bordo
                            : _HomeColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: _hasActiveFilters
                              ? _HomeColors.bordo
                              : _HomeColors.divider,
                        ),
                        boxShadow: _hasActiveFilters
                            ? [
                                BoxShadow(
                                  color: _HomeColors.bordo.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 16,
                            color: _hasActiveFilters
                                ? Colors.white
                                : _HomeColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _hasActiveFilters
                                ? 'Filteri (${_activeFilterCount()})'
                                : 'Filteri',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _hasActiveFilters
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: _hasActiveFilters
                                  ? Colors.white
                                  : _HomeColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Active filter chips summary
            if (_hasActiveFilters)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (_sortOption != SortOption.newest)
                        _activeFilterBadge('${_sortLabel()}', onRemove: () {
                          setState(() => _sortOption = SortOption.newest);
                        }),
                      if (_conditionFilter != ConditionFilter.all)
                        _activeFilterBadge(
                          _conditionFilter == ConditionFilter.novo
                              ? 'Novo'
                              : 'Korišteno',
                          onRemove: () {
                            setState(
                                () => _conditionFilter = ConditionFilter.all);
                          },
                        ),
                      if (_minPrice != null)
                        _activeFilterBadge('Min: ${_minPrice!.toInt()} KM',
                            onRemove: () {
                          setState(() {
                            _minPrice = null;
                            _minPriceController.clear();
                          });
                        }),
                      if (_maxPrice != null)
                        _activeFilterBadge('Max: ${_maxPrice!.toInt()} KM',
                            onRemove: () {
                          setState(() {
                            _maxPrice = null;
                            _maxPriceController.clear();
                          });
                        }),
                      if (_hideSold)
                        _activeFilterBadge('Bez prodanih', onRemove: () {
                          setState(() => _hideSold = false);
                        }),
                      // Clear all
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _sortOption = SortOption.newest;
                            _conditionFilter = ConditionFilter.all;
                            _hideSold = false;
                            _minPrice = null;
                            _maxPrice = null;
                            _minPriceController.clear();
                            _maxPriceController.clear();
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.red.withOpacity(0.3)),
                          ),
                          child: const Text(
                            'Resetuj sve',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 14),

            // Products grid
            Expanded(
              child: StreamBuilder<List<Product>>(
                stream: _shopRepo.getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: _HomeColors.bordo,
                        strokeWidth: 2.5,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: _HomeColors.surface,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.wifi_off_rounded,
                                size: 28, color: _HomeColors.textMuted),
                          ),
                          const SizedBox(height: 16),
                          const Text('Greška pri učitavanju',
                              style: TextStyle(
                                  color: _HomeColors.textSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          const Text('Provjerite internet konekciju',
                              style: TextStyle(
                                  color: _HomeColors.textMuted, fontSize: 13)),
                        ],
                      ),
                    );
                  }

                  final allProducts = snapshot.data ?? [];
                  final products = _filterAndSort(allProducts);

                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: _HomeColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: _HomeColors.divider),
                            ),
                            child: const Icon(Icons.storefront_outlined,
                                size: 40, color: _HomeColors.textMuted),
                          ),
                          const SizedBox(height: 20),
                          const Text('Nema artikala',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: _HomeColors.textSecondary)),
                          const SizedBox(height: 8),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              _hasActiveFilters || _searchQuery.isNotEmpty
                                  ? 'Nema rezultata za odabrane filtere.\nPokušajte promijeniti kriterije.'
                                  : _selectedCategory == 'Sve'
                                      ? 'Budi prvi koji objavi artikal!'
                                      : 'Nema artikala u kategoriji $_selectedCategory',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: _HomeColors.textMuted,
                                  height: 1.4),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (_hasActiveFilters) ...[
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _sortOption = SortOption.newest;
                                  _conditionFilter = ConditionFilter.all;
                                  _hideSold = false;
                                  _minPrice = null;
                                  _maxPrice = null;
                                  _minPriceController.clear();
                                  _maxPriceController.clear();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _HomeColors.bordo.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color:
                                          _HomeColors.bordo.withOpacity(0.3)),
                                ),
                                child: const Text(
                                  'Resetuj filtere',
                                  style: TextStyle(
                                    color: _HomeColors.bordo,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Results count
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: Row(
                          children: [
                            Text(
                              '${products.length} ${products.length == 1 ? 'artikal' : 'artikala'}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: _HomeColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            if (_sortOption != SortOption.newest)
                              Text(
                                _sortLabel(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _HomeColors.bordo,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(products[index]);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activeFilterBadge(String label, {required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.only(left: 10, right: 6, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: _HomeColors.bordo.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _HomeColors.bordo.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: _HomeColors.bordo,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 14, color: _HomeColors.bordo),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({Key? key}) {
    return Row(
      key: key,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: _HomeColors.bordo.withOpacity(0.15),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/hz.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.sports_soccer,
                    size: 24, color: _HomeColors.bordo);
              },
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FKS Fan Shop',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _HomeColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'BORDO PORODICA',
                style: TextStyle(
                  fontSize: 11,
                  color: _HomeColors.bordo,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UsersSearchScreen()),
              ),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _HomeColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _HomeColors.divider),
                ),
                child: const Icon(Icons.people_outline_rounded,
                    color: _HomeColors.textSecondary, size: 22),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _toggleSearch,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _HomeColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _HomeColors.divider),
                ),
                child: const Icon(Icons.search_rounded,
                    color: _HomeColors.textSecondary, size: 22),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar({Key? key}) {
    return Row(
      key: key,
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: _HomeColors.surface,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: _HomeColors.bordo.withOpacity(0.4)),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(
                  color: _HomeColors.textPrimary, fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Pretraži artikle...',
                hintStyle:
                    TextStyle(color: _HomeColors.textMuted, fontSize: 15),
                prefixIcon: Icon(Icons.search_rounded,
                    color: _HomeColors.bordo, size: 22),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.trim());
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _toggleSearch,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _HomeColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _HomeColors.divider),
            ),
            child: const Icon(Icons.close_rounded,
                color: _HomeColors.textSecondary, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    final hasImage = product.imageUrls.isNotEmpty;

    return GestureDetector(
      onTap: () => _openProductDetail(product),
      child: Container(
        decoration: BoxDecoration(
          color: _HomeColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _HomeColors.divider.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                    child: SizedBox(
                      width: double.infinity,
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrls.first,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: _HomeColors.surface,
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: _HomeColors.bordo,
                                        strokeWidth: 2),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: _HomeColors.surface,
                                child: Icon(
                                  _categoryIcons[product.category] ??
                                      Icons.shopping_bag,
                                  size: 36,
                                  color: _HomeColors.bordo.withOpacity(0.4),
                                ),
                              ),
                            )
                          : Container(
                              color: _HomeColors.surface,
                              child: Center(
                                child: Icon(
                                  _categoryIcons[product.category] ??
                                      Icons.shopping_bag,
                                  size: 36,
                                  color: _HomeColors.bordo.withOpacity(0.4),
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (product.isSold)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18)),
                      child: Container(
                        color: Colors.black.withOpacity(0.55),
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PRODANO',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!product.isSold && product.condition == 'Novo')
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'NOVO',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _HomeColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(0)} KM',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: product.isSold
                                ? _HomeColors.textMuted
                                : _HomeColors.bordo,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: _HomeColors.bordo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _HomeColors.bordoLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}