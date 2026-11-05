import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/colors.dart';
import '../constants/app_spacing.dart';
import '../models/printer.dart';
import '../services/printer_service.dart';
import 'printer_details.dart';
import 'login_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String searchQuery = '';
  Set<String> selectedBrands = {};
  Set<String> selectedTypes = {};

  RangeValues? selectedPriceRange;

  late Future<List<Printer>> printersFuture;

  @override
  void initState() {
    super.initState();
    printersFuture = PrinterService().getPrinters();
  }

  Future<void> showPrinterFilters(List<Printer> allPrinters) async {
    // Get unique brands and printer types.
    final brands = allPrinters
        .map((printer) => printer.brand)
        .toSet()
        .toList()
      ..sort();

    final types = allPrinters
        .map((printer) => printer.category)
        .toSet()
        .toList()
      ..sort();

    // Determine the available price range.
    final prices = allPrinters.map((printer) => printer.price).toList();

    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);

    final sliderMax = maxPrice > minPrice ? maxPrice : minPrice + 1;

    // Temporary selections used while the panel is open.
    Set<String> tempBrands = Set.from(selectedBrands);
    Set<String> tempTypes = Set.from(selectedTypes);

    RangeValues tempPriceRange = selectedPriceRange ??
        RangeValues(minPrice, sliderMax);

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Filter title
                    const Text(
                      'Filter Printers',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.medium),

                    // Brand section
                    const Text(
                      'Brands',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),

                    ...brands.map((brand) {
                      return CheckboxListTile(
                        title: Text(
                          brand,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                          ),
                        ),
                        value: tempBrands.contains(brand),
                        activeColor: AppColors.tertiary,
                        checkColor: AppColors.textBlack,
                        side: const BorderSide(
                          color: AppColors.quaternary,
                        ),
                        onChanged: (checked) {
                          setModalState(() {
                            if (checked == true) {
                              tempBrands.add(brand);
                            } else {
                              tempBrands.remove(brand);
                            }
                          });
                        },
                      );
                    }),

                    const SizedBox(height: AppSpacing.medium),

                    // Printer type section
                    const Text(
                      'Printer Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),

                    ...types.map((type) {
                      return CheckboxListTile(
                        title: Text(
                          type,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                          ),
                        ),
                        value: tempTypes.contains(type),
                        activeColor: AppColors.tertiary,
                        checkColor: AppColors.textBlack,
                        side: const BorderSide(
                          color: AppColors.quaternary,
                        ),
                        onChanged: (checked) {
                          setModalState(() {
                            if (checked == true) {
                              tempTypes.add(type);
                            } else {
                              tempTypes.remove(type);
                            }
                          });
                        },
                      );
                    }),

                    const SizedBox(height: AppSpacing.medium),

                    const Text(
                      'Price Range',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.small),

                    RangeSlider(
                      values: tempPriceRange,
                      min: minPrice,
                      max: sliderMax,
                      activeColor: AppColors.tertiary,
                      inactiveColor: AppColors.quaternary,
                      labels: RangeLabels(
                        '\$${tempPriceRange.start.toStringAsFixed(2)}',
                        '\$${tempPriceRange.end.toStringAsFixed(2)}',
                      ),
                      onChanged: (values) {
                        setModalState(() {
                          tempPriceRange = values;
                        });
                      },
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${tempPriceRange.start.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.textWhite),
                        ),
                        Text(
                          '\$${tempPriceRange.end.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.textWhite),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.large),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            'brands': tempBrands,
                            'types': tempTypes,
                            'priceRange': tempPriceRange,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tertiary,
                          foregroundColor: AppColors.textBlack,
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          tempBrands.clear();
                          tempTypes.clear();
                          tempPriceRange = RangeValues(minPrice, sliderMax);
                        });
                      },
                      child: const Text(
                        'Clear Filters',
                        style: TextStyle(color: AppColors.textWhite),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedBrands = result['brands'] as Set<String>;
        selectedTypes = result['types'] as Set<String>;
        selectedPriceRange = result['priceRange'] as RangeValues;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Print-ish'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        actions: [
          StreamBuilder<AuthState>(
            stream: Supabase.instance.client.auth.onAuthStateChange,
            builder: (context, snapshot) {
              final user = Supabase.instance.client.auth.currentUser;
              return IconButton(
                icon: Icon(user != null ? Icons.person : Icons.login),
                tooltip: user != null ? 'Profile & Account' : 'Sign In',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase().trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search printers...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.textWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.small,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.small),

                IconButton(
                  onPressed: () async {
                    final allPrinters = await printersFuture;

                    if (!context.mounted) return;

                    showPrinterFilters(allPrinters);
                  },
                  icon: const Icon(Icons.filter_list),
                  color: AppColors.tertiary,
                  iconSize: 28,
                  tooltip: 'Filter printers',
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_cart),
                  color: AppColors.secondary,
                  iconSize: 28,
                  tooltip: 'Shopping cart',
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.medium),

            Expanded(
              child: FutureBuilder<List<Printer>>(
                future: printersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Unable to load printers. Please try again later.',
                        style: TextStyle(color: AppColors.textWhite),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final allPrinters = snapshot.data ?? [];

                  final printers = allPrinters.where((printer) {
                    final matchesSearch =
                        printer.category.toLowerCase().contains(searchQuery) ||
                            printer.specs.toLowerCase().contains(searchQuery) ||
                            printer.brand.toLowerCase().contains(searchQuery) ||
                            printer.model.toLowerCase().contains(searchQuery);

                    final matchesBrand = selectedBrands.isEmpty ||
                        selectedBrands.contains(printer.brand);

                    final matchesType = selectedTypes.isEmpty ||
                        selectedTypes.contains(printer.category);

                    final matchesPrice = selectedPriceRange == null ||
                        (printer.price >= selectedPriceRange!.start &&
                            printer.price <= selectedPriceRange!.end);

                    return matchesSearch && matchesBrand && matchesType && matchesPrice;
                  }).toList();

                  if (printers.isEmpty) {
                    return Center(
                      child: Text(
                        searchQuery.isEmpty
                            ? 'No printers available'
                            : 'No printers match your search',
                        style: const TextStyle(color: AppColors.textWhite),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: printers.length,
                    itemBuilder: (context, index) {
                      final printer = printers[index];

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.print),
                          title: Text('${printer.brand} ${printer.model}'),
                          subtitle: Text(
                            '${printer.category}\n${printer.specs}',
                          ),
                          isThreeLine: true,
                          trailing: Text(
                            '\$${printer.price.toStringAsFixed(2)}',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrinterDetails(
                                  printer: printer,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
