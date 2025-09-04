import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/services/enhanced_ai_chat_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';

/// FAQ Browser Screen for comprehensive FAQ browsing
class FAQBrowserScreen extends StatefulWidget {
  const FAQBrowserScreen({super.key});

  @override
  State<FAQBrowserScreen> createState() => _FAQBrowserScreenState();
}

class _FAQBrowserScreenState extends State<FAQBrowserScreen>
    with TickerProviderStateMixin {
  final EnhancedAIChatService _chatService = EnhancedAIChatService();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  
  String? _selectedCategory;
  List<FAQItem> _filteredFAQs = [];
  List<FAQItem> _searchResults = [];
  bool _isSearching = false;
  
  final Map<String, IconData> _categoryIcons = {
    'health': Icons.favorite,
    'general': Icons.lightbulb,
    'technology': Icons.computer,
    'science': Icons.science,
    'lifestyle': Icons.self_improvement,
  };

  final Map<String, Color> _categoryColors = {
    'health': AppTheme.primaryRose,
    'general': AppTheme.primaryPurple,
    'technology': AppTheme.secondaryBlue,
    'science': AppTheme.accentMint,
    'lifestyle': AppTheme.warningOrange,
  };

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Load all FAQs initially
    _loadAllFAQs();
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadAllFAQs() {
    final allFAQs = <FAQItem>[];
    for (final category in _chatService.getFAQCategories()) {
      allFAQs.addAll(_chatService.getFAQsByCategory(category));
    }
    
    setState(() {
      _filteredFAQs = allFAQs;
    });
  }

  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      _isSearching = false;
      _searchController.clear();
      
      if (category == null) {
        _loadAllFAQs();
      } else {
        _filteredFAQs = _chatService.getFAQsByCategory(category);
      }
    });
  }

  void _searchFAQs(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        if (_selectedCategory == null) {
          _loadAllFAQs();
        } else {
          _filteredFAQs = _chatService.getFAQsByCategory(_selectedCategory!);
        }
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _chatService.searchFAQs(
        query,
        category: _selectedCategory,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryPurple,
                      AppTheme.primaryRose,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: const Icon(
                            Icons.help_center,
                            color: Colors.white,
                            size: 35,
                          ),
                        ).animate().scale(delay: 200.ms),
                        const SizedBox(height: 12),
                        Text(
                          localizations.faqAndKnowledgeBase,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                        const SizedBox(height: 6),
                        Text(
                          localizations.findAnswersToCommonQuestions,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 600.ms),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: localizations.searchFAQs,
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppTheme.primaryPurple,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchFAQs('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  onChanged: _searchFAQs,
                ),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
            ),
          ),

          // Category Filter Chips
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              constraints: const BoxConstraints(minHeight: 60, maxHeight: 80),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: _chatService.getFAQCategories().length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // All categories chip
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(localizations.allCategories),
                        selected: _selectedCategory == null,
                        onSelected: (_) => _filterByCategory(null),
                        backgroundColor: theme.cardColor,
                        selectedColor: AppTheme.primaryPurple.withValues(alpha: 0.2),
                        checkmarkColor: AppTheme.primaryPurple,
                        labelStyle: TextStyle(
                          color: _selectedCategory == null 
                              ? AppTheme.primaryPurple 
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: _selectedCategory == null 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }

                  final category = _chatService.getFAQCategories()[index - 1];
                  final isSelected = _selectedCategory == category;
                  final color = _categoryColors[category] ?? AppTheme.primaryPurple;
                  final icon = _categoryIcons[category] ?? Icons.help;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(
                        icon,
                        size: 18,
                        color: isSelected ? color : theme.textTheme.bodyMedium?.color,
                      ),
                      label: Text(category.toUpperCase()),
                      selected: isSelected,
                      onSelected: (_) => _filterByCategory(category),
                      backgroundColor: theme.cardColor,
                      selectedColor: color.withValues(alpha: 0.2),
                      checkmarkColor: color,
                      labelStyle: TextStyle(
                        color: isSelected ? color : theme.textTheme.bodyMedium?.color,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(delay: 1000.ms).slideX(begin: -0.2),
          ),

          // FAQ Results Counter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                _isSearching
                    ? '${_searchResults.length} search results'
                    : _selectedCategory != null
                        ? '${_filteredFAQs.length} FAQs in ${_selectedCategory}'
                        : '${_filteredFAQs.length} total FAQs',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.mediumGrey,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 1200.ms),
            ),
          ),

          // FAQ List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final faqs = _isSearching ? _searchResults : _filteredFAQs;
                if (index >= faqs.length) return null;

                final faq = faqs[index];
                return _buildFAQCard(faq, index);
              },
            ),
          ),

          // Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),

      // Floating Action Button for AI Chat
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAIChatDialog(context);
        },
        backgroundColor: AppTheme.primaryRose,
        icon: const Icon(Icons.psychology, color: Colors.white),
        label: const Text(
          'Ask Mira',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ).animate().scale(delay: 1500.ms),
    );
  }

  Widget _buildFAQCard(FAQItem faq, int index) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryPurple.withValues(alpha: 0.2),
                AppTheme.primaryRose.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.quiz,
            color: AppTheme.primaryPurple,
            size: 20,
          ),
        ),
        title: Text(
          faq.question,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGrey,
          ),
        ),
        subtitle: Text(
          faq.answer.length > 100
              ? '${faq.answer.substring(0, 100)}...'
              : faq.answer,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.mediumGrey,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faq.answer,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: AppTheme.darkGrey,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _askRelatedQuestion(faq.question);
                      },
                      icon: Icon(
                        Icons.psychology,
                        color: AppTheme.primaryPurple,
                        size: 16,
                      ),
                      label: Text(
                        'Ask related question',
                        style: TextStyle(
                          color: AppTheme.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.verified,
                      color: AppTheme.successGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: AppTheme.successGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 200 + (index * 100)))
      .fadeIn()
      .slideX(begin: 0.3);
  }

  void _askRelatedQuestion(String question) {
    _showAIChatDialog(context, initialMessage: "Tell me more about: $question");
  }

  void _showAIChatDialog(BuildContext context, {String? initialMessage}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.mediumGrey,
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
                            colors: [AppTheme.primaryPurple, AppTheme.primaryRose],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ask Mira AI',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Get personalized answers to your questions',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.mediumGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                
                // Quick Message Input
                if (initialMessage != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            initialMessage,
                            style: TextStyle(
                              color: AppTheme.primaryPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.send,
                          color: AppTheme.primaryPurple,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                
                // Navigation to full chat
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppTheme.mediumGrey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Full chat experience coming soon!',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.mediumGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'For now, use the floating chat in the insights screen',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.mediumGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/insights');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text(
                            'Go to AI Chat',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
