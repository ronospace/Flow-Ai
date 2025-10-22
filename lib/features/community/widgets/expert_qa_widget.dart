import 'package:flutter/material.dart';
import '../../../core/models/community_models.dart';

/// Expert Q&A Widget for professional health advice
class ExpertQAWidget extends StatefulWidget {
  final List<ExpertQuestion> questions;
  final Function(String, String) onAskQuestion;
  final Function(String) onLikeQuestion;
  final Function(String) onBookmarkQuestion;

  const ExpertQAWidget({
    Key? key,
    required this.questions,
    required this.onAskQuestion,
    required this.onLikeQuestion,
    required this.onBookmarkQuestion,
  }) : super(key: key);

  @override
  State<ExpertQAWidget> createState() => _ExpertQAWidgetState();
}

class _ExpertQAWidgetState extends State<ExpertQAWidget> {
  final TextEditingController _questionController = TextEditingController();
  String _selectedCategory = 'General';
  
  final List<String> _categories = [
    'General',
    'Menstrual Health',
    'Hormones',
    'Pregnancy',
    'PCOS',
    'Endometriosis',
    'Mental Health',
    'Nutrition',
  ];

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAskQuestionSection(),
        const SizedBox(height: 16),
        _buildCategoryFilter(),
        const SizedBox(height: 16),
        Expanded(
          child: _buildQuestionsList(),
        ),
      ],
    );
  }

  Widget _buildAskQuestionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Ask a Healthcare Expert',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe your question in detail...',
                border: OutlineInputBorder(),
                helperText: 'Your question will be answered by certified healthcare professionals',
                helperMaxLines: 2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    '🔒 Your privacy is protected. Questions are anonymous.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _submitQuestion(),
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Ask Question'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(category),
              selected: _selectedCategory == category,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionsList() {
    final filteredQuestions = widget.questions
        .where((q) => _selectedCategory == 'General' || q.category == _selectedCategory)
        .toList();

    if (filteredQuestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No questions in $_selectedCategory yet',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Text(
              'Be the first to ask a question!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredQuestions.length,
      itemBuilder: (context, index) {
        return _buildQuestionItem(filteredQuestions[index]);
      },
    );
  }

  Widget _buildQuestionItem(ExpertQuestion question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCategoryChip(question.category),
                const Spacer(),
                _buildStatusChip(question.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              question.description,
              style: const TextStyle(color: Colors.grey),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            if (question.answer != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.green,
                          child: const Icon(Icons.verified, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          question.expertName ?? 'Healthcare Expert',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const Spacer(),
                        Text(
                          _formatTimestamp(question.answeredAt!),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.answer!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Text(
                  'Asked ${_formatTimestamp(question.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                _buildActionButton(
                  icon: question.isLikedByUser ? Icons.favorite : Icons.favorite_border,
                  label: question.likesCount.toString(),
                  color: question.isLikedByUser ? Colors.red : Colors.grey,
                  onPressed: () => widget.onLikeQuestion(question.id),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: question.isBookmarkedByUser ? Icons.bookmark : Icons.bookmark_border,
                  label: 'Save',
                  color: question.isBookmarkedByUser ? Colors.orange : Colors.grey,
                  onPressed: () => widget.onBookmarkQuestion(question.id),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onPressed: () => _shareQuestion(question),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 10,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusChip(QuestionStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case QuestionStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        icon = Icons.schedule;
        break;
      case QuestionStatus.answered:
        color = Colors.green;
        text = 'Answered';
        icon = Icons.check_circle;
        break;
      case QuestionStatus.reviewed:
        color = Colors.blue;
        text = 'Under Review';
        icon = Icons.visibility;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color ?? Colors.grey),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color ?? Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _submitQuestion() {
    if (_questionController.text.trim().isNotEmpty) {
      widget.onAskQuestion(_selectedCategory, _questionController.text.trim());
      _questionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question submitted! You\'ll be notified when answered.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _shareQuestion(ExpertQuestion question) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon!')),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 30).floor()}mo ago';
    }
  }
}
