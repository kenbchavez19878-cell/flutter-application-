import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _searchTerm = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final filteredInventory = state.inventory.where((p) {
          return p.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
              p.category.toLowerCase().contains(_searchTerm.toLowerCase());
        }).toList();

        return Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: filteredInventory.isEmpty
                  ? _buildEmptyState()
                  : _buildCatalogGrid(filteredInventory),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      color: AppTheme.appBg,
      child: TextField(
        onChanged: (value) => setState(() => _searchTerm = value),
        decoration: InputDecoration(
          hintText: 'Search catalog...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
          filled: true,
          fillColor: AppTheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.border),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border, style: BorderStyle.solid),
        ),
        child: const Text(
          'No items match your search. Try another keyword.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCatalogGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildCatalogItem(products[index]),
    );
  }

  Widget _buildCatalogItem(Product product) {
    final pillClass = product.stock > 5
        ? 'ok'
        : (product.stock > 0 ? 'low' : 'out');
    final pillText = product.stock > 5
        ? '${product.stock} In Stock'
        : (product.stock > 0 ? 'Low: ${product.stock} Left' : 'Sold Out');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.appBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: product.img != null && product.img!.startsWith('http')
                  ? Image.network(product.img!, fit: BoxFit.contain)
                  : const Icon(
                      Icons.image,
                      size: 48,
                      color: AppTheme.textMuted,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₱${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: pillClass == 'ok'
                  ? AppTheme.successBg
                  : (pillClass == 'low'
                        ? AppTheme.warningBg
                        : AppTheme.dangerBg),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              pillText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: pillClass == 'ok'
                    ? AppTheme.successText
                    : (pillClass == 'low'
                          ? AppTheme.warningText
                          : AppTheme.dangerText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
