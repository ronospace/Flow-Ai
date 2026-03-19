import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/medical_citation.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Medical Citations Section for Settings
/// Displays all medical sources and citations used in the app
/// Required by App Store Guideline 1.4.1 - Medical Citations
class MedicalCitationsSection extends StatefulWidget {
  const MedicalCitationsSection({super.key});

  @override
  State<MedicalCitationsSection> createState() =>
      _MedicalCitationsSectionState();
}

class _MedicalCitationsSectionState extends State<MedicalCitationsSection> {
  String _searchQuery = '';
  String? _selectedCategory;

  final Map<String, String> _categoryLabels = {
    'cycle_length': 'Cycle Tracking',
    'cycle_regularity': 'Cycle Regularity',
    'fertility_window': 'Fertility & Ovulation',
    'pcos_detection': 'PCOS Detection',
    'endometriosis_detection': 'Endometriosis',
    'menstrual_symptoms': 'Menstrual Symptoms',
    'hormone_tracking': 'Hormone Tracking',
    'health_tracking': 'General Health Tracking',
    'lifestyle_recommendations': 'Lifestyle & Wellness',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.medical_information,
                    color: AppTheme.secondaryBlue,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sources',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.secondaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.warningOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppTheme.warningOrange,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'For awareness only. Not medical advice.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.warningOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search sources',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),

        // Category filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                
                const SizedBox(width: 4),
                ..._categoryLabels.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildCategoryChip(context, entry.key, entry.value),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Citations list
        Expanded(child: _buildCitationsList(context)),
      ],
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String? category,
    String label,
  ) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
      selectedColor: AppTheme.secondaryBlue.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.secondaryBlue,
    );
  }

  Widget _buildCitationsList(BuildContext context) {
    final theme = Theme.of(context);
    final allCitations = MedicalCitationsDatabase.getAllCitations();

    // Filter by category
    final filteredByCategory = _selectedCategory == null
        ? allCitations
        : MedicalCitationsDatabase.getCitationsForInsightType(
            _selectedCategory!,
          );

    // Filter by search query
    final filtered = _searchQuery.isEmpty
        ? filteredByCategory
        : filteredByCategory.where((citation) {
            return citation.title.toLowerCase().contains(_searchQuery) ||
                citation.source.toLowerCase().contains(_searchQuery) ||
                citation.description.toLowerCase().contains(_searchQuery) ||
                (citation.authors.isNotEmpty &&
                    citation.authors
                        .join(' ')
                        .toLowerCase()
                        .contains(_searchQuery));
          }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No citations found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    // Group by category for better organization
    final grouped = <String, List<MedicalCitation>>{};
    for (final citation in filtered) {
      // Find which category this citation belongs to
      String? category;
      for (final cat in _categoryLabels.keys) {
        final catCitations =
            MedicalCitationsDatabase.getCitationsForInsightType(cat);
        if (catCitations.any((c) => c.id == citation.id)) {
          category = cat;
          break;
        }
      }
      final categoryKey = category ?? 'other';
      grouped.putIfAbsent(categoryKey, () => []).add(citation);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final categoryKey = grouped.keys.elementAt(index);
        final citations = grouped[categoryKey]!;
        final categoryLabel = _categoryLabels[categoryKey] ?? 'Other Sources';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: 24),
            Text(
              categoryLabel,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.secondaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            ...citations.map(
              (citation) => _buildCitationCard(context, citation),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCitationCard(BuildContext context, MedicalCitation citation) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.secondaryBlue.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source organization badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                citation.source,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.secondaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              citation.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            // Authors and year
            if (citation.authors.isNotEmpty || citation.year != null) ...[
              Row(
                children: [
                  if (citation.authors.isNotEmpty) ...[
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        citation.authors.join(', '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (citation.year != null) ...[
                    Text(
                      ' (${citation.year})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Description
            Text(
              citation.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // DOI if available
            if (citation.doi != null) ...[
              Text(
                'DOI: ${citation.doi}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // View Source button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(citation.url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('View Source'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.secondaryBlue,
                  side: BorderSide(color: AppTheme.secondaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}
