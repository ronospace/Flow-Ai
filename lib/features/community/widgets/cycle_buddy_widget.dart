import 'package:flutter/material.dart';
import '../../../core/models/community_models.dart';

/// Cycle Buddy Widget for matching with cycle partners
class CycleBuddyWidget extends StatefulWidget {
  final List<CycleBuddy> availableBuddies;
  final List<BuddyRequest> pendingRequests;
  final List<CycleBuddy> currentBuddies;
  final Function(String) onSendBuddyRequest;
  final Function(String, bool) onRespondToBuddyRequest;
  final Function(String) onRemoveBuddy;

  const CycleBuddyWidget({
    Key? key,
    required this.availableBuddies,
    required this.pendingRequests,
    required this.currentBuddies,
    required this.onSendBuddyRequest,
    required this.onRespondToBuddyRequest,
    required this.onRemoveBuddy,
  }) : super(key: key);

  @override
  State<CycleBuddyWidget> createState() => _CycleBuddyWidgetState();
}

class _CycleBuddyWidgetState extends State<CycleBuddyWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInfoHeader(),
        const SizedBox(height: 16),
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.people_outline),
              text: 'Find Buddies',
              child: widget.availableBuddies.isNotEmpty
                  ? Badge(
                      label: Text('${widget.availableBuddies.length}'),
                      child: const Tab(icon: Icon(Icons.people_outline), text: 'Find Buddies'),
                    )
                  : null,
            ),
            Tab(
              icon: const Icon(Icons.schedule),
              text: 'Requests',
              child: widget.pendingRequests.isNotEmpty
                  ? Badge(
                      label: Text('${widget.pendingRequests.length}'),
                      child: const Tab(icon: Icon(Icons.schedule), text: 'Requests'),
                    )
                  : null,
            ),
            Tab(
              icon: const Icon(Icons.favorite),
              text: 'My Buddies',
              child: widget.currentBuddies.isNotEmpty
                  ? Badge(
                      label: Text('${widget.currentBuddies.length}'),
                      child: const Tab(icon: Icon(Icons.favorite), text: 'My Buddies'),
                    )
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFindBuddiesTab(),
              _buildRequestsTab(),
              _buildMyBuddiesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoHeader() {
    return Card(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.people,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cycle Buddies',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Connect with others who share similar cycles for support and motivation.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFindBuddiesTab() {
    if (widget.availableBuddies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No cycle buddies available right now',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              'Check back later for new matches!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.availableBuddies.length,
      itemBuilder: (context, index) {
        return _buildBuddyCard(widget.availableBuddies[index], isAvailable: true);
      },
    );
  }

  Widget _buildRequestsTab() {
    if (widget.pendingRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No pending requests',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              'Buddy requests will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.pendingRequests.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(widget.pendingRequests[index]);
      },
    );
  }

  Widget _buildMyBuddiesTab() {
    if (widget.currentBuddies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No cycle buddies yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              'Start connecting with others!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.currentBuddies.length,
      itemBuilder: (context, index) {
        return _buildBuddyCard(widget.currentBuddies[index], isConnected: true);
      },
    );
  }

  Widget _buildBuddyCard(CycleBuddy buddy, {bool isAvailable = false, bool isConnected = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    buddy.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            buddy.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          if (buddy.isOnline)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        'Age ${buddy.age} • ${_formatLocation(buddy.location)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _buildCompatibilityScore(buddy.compatibilityScore),
              ],
            ),
            const SizedBox(height: 12),
            _buildCycleInfo(buddy),
            const SizedBox(height: 12),
            if (buddy.interests.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: buddy.interests.take(3).map((interest) {
                  return Chip(
                    label: Text(interest),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
            if (isAvailable)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => widget.onSendBuddyRequest(buddy.id),
                  icon: const Icon(Icons.person_add, size: 16),
                  label: const Text('Send Request'),
                ),
              ),
            if (isConnected)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _chatWithBuddy(buddy),
                      icon: const Icon(Icons.chat, size: 16),
                      label: const Text('Chat'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRemoveBuddyDialog(buddy),
                      icon: const Icon(Icons.person_remove, size: 16),
                      label: const Text('Remove'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuddyRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    request.senderName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.senderName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Sent ${_formatTimestamp(request.createdAt)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (request.message?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.message!,
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onRespondToBuddyRequest(request.id, true),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => widget.onRespondToBuddyRequest(request.id, false),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityScore(double score) {
    Color color;
    if (score >= 0.8) {
      color = Colors.green;
    } else if (score >= 0.6) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Text(
        '${(score * 100).toInt()}% match',
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCycleInfo(CycleBuddy buddy) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          _buildCycleInfoItem('Cycle Length', '${buddy.averageCycleLength} days'),
          const SizedBox(width: 16),
          _buildCycleInfoItem('Phase', buddy.currentPhase),
          const SizedBox(width: 16),
          _buildCycleInfoItem('Day', 'Day ${buddy.currentCycleDay}'),
        ],
      ),
    );
  }

  Widget _buildCycleInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  void _chatWithBuddy(CycleBuddy buddy) {
    // Implement chat functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chat with ${buddy.name} coming soon!')),
    );
  }

  void _showRemoveBuddyDialog(CycleBuddy buddy) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Buddy'),
          content: Text('Are you sure you want to remove ${buddy.name} as your cycle buddy?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onRemoveBuddy(buddy.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  String _formatLocation(String location) {
    // Format location to show city/country
    return location.length > 20 ? '${location.substring(0, 17)}...' : location;
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
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
