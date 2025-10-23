import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class BiometricSyncStatus extends StatefulWidget {
  final VoidCallback? onRefresh;
  final bool showRefreshButton;

  const BiometricSyncStatus({
    super.key,
    this.onRefresh,
    this.showRefreshButton = true,
  });

  @override
  State<BiometricSyncStatus> createState() => _BiometricSyncStatusState();
}

class _BiometricSyncStatusState extends State<BiometricSyncStatus>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isSyncing = false;
  DateTime? _lastSync;
  Map<String, SyncDataPoint> _syncData = {};

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _initializeSyncData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeSyncData() {
    // Mock sync data - in a real app this would come from the biometric service
    _syncData = {
      'Heart Rate': SyncDataPoint(
        lastSync: DateTime.now().subtract(const Duration(minutes: 15)),
        dataPoints: 48,
        status: SyncStatus.success,
        source: 'Apple Watch',
      ),
      'Sleep': SyncDataPoint(
        lastSync: DateTime.now().subtract(const Duration(hours: 2)),
        dataPoints: 1,
        status: SyncStatus.success,
        source: 'iPhone Health',
      ),
      'Temperature': SyncDataPoint(
        lastSync: DateTime.now().subtract(const Duration(minutes: 30)),
        dataPoints: 12,
        status: SyncStatus.warning,
        source: 'Apple Watch',
      ),
      'HRV': SyncDataPoint(
        lastSync: DateTime.now().subtract(const Duration(hours: 1)),
        dataPoints: 8,
        status: SyncStatus.success,
        source: 'Apple Watch',
      ),
      'Activity': SyncDataPoint(
        lastSync: DateTime.now().subtract(const Duration(minutes: 5)),
        dataPoints: 144,
        status: SyncStatus.success,
        source: 'iPhone Health',
      ),
    };
    _lastSync = DateTime.now().subtract(const Duration(minutes: 5));
  }

  Future<void> _performSync() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    _pulseController.repeat();

    // Simulate sync process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSyncing = false;
      _lastSync = DateTime.now();
      // Update some data points to show sync worked
      _syncData['Heart Rate'] = _syncData['Heart Rate']!.copyWith(
        lastSync: DateTime.now(),
        dataPoints: _syncData['Heart Rate']!.dataPoints + 2,
      );
      _syncData['Activity'] = _syncData['Activity']!.copyWith(
        lastSync: DateTime.now(),
        dataPoints: _syncData['Activity']!.dataPoints + 12,
      );
    });

    _pulseController.stop();
    _pulseController.reset();

    if (widget.onRefresh != null) {
      widget.onRefresh!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final overallStatus = _getOverallSyncStatus();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(overallStatus),
          const SizedBox(height: 20),
          _buildOverallStatus(overallStatus),
          const SizedBox(height: 20),
          _buildSyncDataList(),
          if (widget.showRefreshButton) ...[
            const SizedBox(height: 16),
            _buildSyncButton(),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3, end: 0);
  }

  Widget _buildHeader(SyncStatus overallStatus) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusColor(overallStatus).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              if (_isSyncing) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.1),
                  child: Icon(
                    Icons.sync,
                    color: _getStatusColor(overallStatus),
                    size: 20,
                  ),
                );
              }
              return Icon(
                _getStatusIcon(overallStatus),
                color: _getStatusColor(overallStatus),
                size: 20,
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sync Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
              ),
              Text(
                _isSyncing ? 'Syncing...' : _getStatusDescription(overallStatus),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.mediumGrey,
                ),
              ),
            ],
          ),
        ),
        if (_lastSync != null)
          Text(
            'Updated ${_formatLastSync(_lastSync!)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.mediumGrey,
              fontSize: 10,
            ),
          ),
      ],
    );
  }

  Widget _buildOverallStatus(SyncStatus overallStatus) {
    final theme = Theme.of(context);
    final totalDataPoints = _syncData.values
        .map((data) => data.dataPoints)
        .fold<int>(0, (sum, points) => sum + points);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(overallStatus).withValues(alpha: 0.1),
            _getStatusColor(overallStatus).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getStatusColor(overallStatus).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Data Points Synced',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.mediumGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalDataPoints.toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getStatusColor(overallStatus),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(overallStatus),
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncDataList() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Sources',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGrey,
          ),
        ),
        const SizedBox(height: 12),
        ..._syncData.entries.map((entry) => _buildSyncDataItem(
          entry.key,
          entry.value,
        )),
      ],
    );
  }

  Widget _buildSyncDataItem(String dataType, SyncDataPoint data) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(data.status).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(data.status).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getStatusColor(data.status),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(data.status),
              color: Colors.white,
              size: 12,
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
                      dataType,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.mediumGrey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data.source,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.mediumGrey,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${data.dataPoints} points • Last: ${_formatLastSync(data.lastSync)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          
          // Sync status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(data.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getStatusText(data.status),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(data.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSyncing ? null : _performSync,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isSyncing ? AppTheme.lightGrey : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Container(
          decoration: _isSyncing
              ? null
              : BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSyncing) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.mediumGrey,
                      ),
                    ),
                  ).animate().rotate(),
                  const SizedBox(width: 12),
                ],
                if (!_isSyncing) ...[
                  const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  _isSyncing ? 'Syncing Data...' : 'Sync Now',
                  style: TextStyle(
                    color: _isSyncing ? AppTheme.mediumGrey : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SyncStatus _getOverallSyncStatus() {
    final statuses = _syncData.values.map((data) => data.status).toList();
    
    if (statuses.any((status) => status == SyncStatus.error)) {
      return SyncStatus.error;
    } else if (statuses.any((status) => status == SyncStatus.warning)) {
      return SyncStatus.warning;
    } else {
      return SyncStatus.success;
    }
  }

  Color _getStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.success:
        return AppTheme.successGreen;
      case SyncStatus.warning:
        return AppTheme.warningOrange;
      case SyncStatus.error:
        return AppTheme.primaryRose;
      case SyncStatus.syncing:
        return AppTheme.secondaryBlue;
    }
  }

  IconData _getStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.success:
        return Icons.check_circle;
      case SyncStatus.warning:
        return Icons.warning;
      case SyncStatus.error:
        return Icons.error;
      case SyncStatus.syncing:
        return Icons.sync;
    }
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.success:
        return 'OK';
      case SyncStatus.warning:
        return 'WARN';
      case SyncStatus.error:
        return 'ERROR';
      case SyncStatus.syncing:
        return 'SYNC';
    }
  }

  String _getStatusDescription(SyncStatus status) {
    switch (status) {
      case SyncStatus.success:
        return 'All data sources synchronized';
      case SyncStatus.warning:
        return 'Some data sources have issues';
      case SyncStatus.error:
        return 'Sync errors detected';
      case SyncStatus.syncing:
        return 'Synchronizing data...';
    }
  }

  String _formatLastSync(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

enum SyncStatus {
  success,
  warning,
  error,
  syncing,
}

class SyncDataPoint {
  final DateTime lastSync;
  final int dataPoints;
  final SyncStatus status;
  final String source;

  const SyncDataPoint({
    required this.lastSync,
    required this.dataPoints,
    required this.status,
    required this.source,
  });

  SyncDataPoint copyWith({
    DateTime? lastSync,
    int? dataPoints,
    SyncStatus? status,
    String? source,
  }) {
    return SyncDataPoint(
      lastSync: lastSync ?? this.lastSync,
      dataPoints: dataPoints ?? this.dataPoints,
      status: status ?? this.status,
      source: source ?? this.source,
    );
  }
}
