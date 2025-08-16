import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../models/user_preferences.dart';
import '../providers/settings_provider.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppLanguage> get _filteredLanguages {
    if (_searchQuery.isEmpty) {
      return AppLanguage.values;
    }
    
    return AppLanguage.values.where((language) {
      return language.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             language.code.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.accentMint, AppTheme.secondaryBlue],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  AppLocalizations.of(context)!.chooseLanguage,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ),
              ],
            ),
          ).animate().slideY(begin: -0.3, end: 0).fadeIn(),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchLanguages,
                  prefixIcon: const Icon(Icons.search, color: AppTheme.mediumGrey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ).animate().slideY(begin: 0.3, end: 0).fadeIn(delay: 100.ms),

          const SizedBox(height: 20),

          // Language List
          Expanded(
            child: Consumer<SettingsProvider>(
              builder: (context, settings, child) {
                final currentLanguage = settings.preferences.language;
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filteredLanguages.length,
                  itemBuilder: (context, index) {
                    final language = _filteredLanguages[index];
                    final isSelected = language == currentLanguage;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppTheme.accentMint.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected 
                            ? Border.all(color: AppTheme.accentMint, width: 2)
                            : null,
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppTheme.accentMint
                                : AppTheme.lightGrey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              language.code.toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.mediumGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          language.displayName,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppTheme.accentMint : AppTheme.darkGrey,
                          ),
                        ),
                        subtitle: Text(
                          language.code,
                          style: const TextStyle(
                            color: AppTheme.mediumGrey,
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected 
                            ? const Icon(
                                Icons.check_circle,
                                color: AppTheme.accentMint,
                              )
                            : const Icon(
                                Icons.circle_outlined,
                                color: AppTheme.lightGrey,
                              ),
                        onTap: () async {
                          if (!isSelected) {
                            HapticFeedback.mediumImpact();
                            await settings.updateLanguage(language);
                            
                            if (mounted) {
                              // Show confirmation
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${AppLocalizations.of(context)!.languageChangedTo} ${language.displayName}'
                                  ),
                                  backgroundColor: AppTheme.accentMint,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              
                              Navigator.pop(context);
                            }
                          }
                        },
                      ),
                    ).animate(delay: Duration(milliseconds: index * 50))
                      .slideX(begin: 0.3, end: 0)
                      .fadeIn();
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
