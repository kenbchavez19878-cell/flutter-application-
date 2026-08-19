import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storeNameController = TextEditingController();
  final _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _storeNameController.text = state.appSettings.storeName;
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.appBg,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.headerBg,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBusinessDetailsCard(state),
                const SizedBox(height: 20),
                _buildCategoryCard(state),
                const SizedBox(height: 20),
                _buildDatabaseSyncCard(state),
                const SizedBox(height: 20),
                _buildAboutCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBusinessDetailsCard(AppState state) {
    return _buildCard(
      title: 'Business Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _storeNameController,
            decoration: const InputDecoration(labelText: 'Store Name'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                state.updateStoreName(_storeNameController.text.trim());
                await state.saveToStorage();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Store details updated successfully!'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
              ),
              child: const Text('Update Details'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(AppState state) {
    return _buildCard(
      title: 'Manage Categories',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newCategoryController,
                  decoration: const InputDecoration(
                    hintText: 'New category name...',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  final name = _newCategoryController.text.trim();
                  if (name.isNotEmpty && !state.categories.contains(name)) {
                    state.addCategory(name);
                    _newCategoryController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                ),
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                state.clearAllCategories();
                await state.saveToStorage();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All categories cleared!')),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.danger,
                side: const BorderSide(color: AppTheme.danger),
              ),
              child: const Text('Clear All Categories'),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppTheme.inputBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: ListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final cat = state.categories[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: index < state.categories.length - 1
                        ? Border(bottom: BorderSide(color: AppTheme.border))
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cat,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      GestureDetector(
                        onTap: () => _deleteCategory(cat, state),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.dangerBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Remove',
                            style: TextStyle(
                              color: AppTheme.danger,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(String cat, AppState state) {
    if (state.inventory.any((p) => p.category == cat)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot remove "$cat" because it is assigned to products in your inventory.',
          ),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Category'),
        content: Text('Are you sure you want to remove the category "$cat"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              state.deleteCategory(cat);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseSyncCard(AppState state) {
    return _buildCard(
      title: 'Local Database Sync',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Save your inventory and sales data directly to this browser.',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await state.saveToStorage();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Success! Your data has been saved to your browser.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('💾 Save Data to Browser'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _clearData(state),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.danger,
                side: const BorderSide(color: AppTheme.danger),
              ),
              child: const Text('🗑️ Delete Saved Data'),
            ),
          ),
        ],
      ),
    );
  }

  void _clearData(AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to wipe all saved data from the browser? This will reset the app back to factory defaults.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              await state.clearStorage();
              navigator.pop();
              _storeNameController.text = state.appSettings.storeName;
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('All saved data has been wiped.')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return _buildCard(
      title: 'About System',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.appBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System: EPC Inventory Management',
              style: TextStyle(fontSize: 14, color: AppTheme.textMain),
            ),
            SizedBox(height: 8),
            Text(
              'Client: EP Chavez Enterprises',
              style: TextStyle(fontSize: 14, color: AppTheme.textMain),
            ),
            SizedBox(height: 8),
            Text(
              'Version: 1.0 (Flutter)',
              style: TextStyle(fontSize: 14, color: AppTheme.textMain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
