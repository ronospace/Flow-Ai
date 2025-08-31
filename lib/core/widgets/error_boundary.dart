import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/app_enhancement_service.dart';
import '../utils/app_logger.dart';

/// Enhanced error boundary widget with beautiful error UI and recovery options
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final String? fallbackTitle;
  final String? fallbackMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onReport;
  final bool showDetails;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallbackTitle,
    this.fallbackMessage,
    this.onRetry,
    this.onReport,
    this.showDetails = false,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  Object? _error;
  StackTrace? _stackTrace;
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorUI(context);
    }

    return ErrorWidget.builder = (FlutterErrorDetails details) {
      _captureError(details.exception, details.stack);
      return _buildErrorUI(context);
    };

    // This won't actually be reached in normal flow, but keeps the analyzer happy
    return widget.child;
  }

  void _captureError(Object error, StackTrace? stackTrace) {
    setState(() {
      _hasError = true;
      _error = error;
      _stackTrace = stackTrace;
    });

    // Log to enhancement service
    try {
      final enhancementService = AppEnhancementService();
      // This would record the error for analytics/reporting
      AppLogger.error('🚨 Error captured by ErrorBoundary: $error', stackTrace);
    } catch (e) {
      AppLogger.warning('Failed to log error to enhancement service: $e');
    }
  }

  Widget _buildErrorUI(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon with animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryRose.withOpacity(0.2),
                      AppTheme.primaryPurple.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: AppTheme.primaryRose,
                ),
              ).animate()
                .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(),

              const SizedBox(height: 32),

              // Error Title
              Text(
                widget.fallbackTitle ?? 'Something went wrong',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.darkGrey,
                ),
                textAlign: TextAlign.center,
              ).animate()
                .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 600.ms)
                .fadeIn(),

              const SizedBox(height: 16),

              // Error Message
              Text(
                widget.fallbackMessage ?? 
                'We\'re sorry, but something unexpected happened. Don\'t worry, your data is safe.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white70 : AppTheme.mediumGrey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate()
                .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 600.ms)
                .fadeIn(),

              const SizedBox(height: 40),

              // Action Buttons
              Column(
                children: [
                  // Retry Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _handleRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh_rounded, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Try Again',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).animate()
                    .slideY(begin: 0.3, end: 0, delay: 800.ms, duration: 600.ms)
                    .fadeIn(),

                  const SizedBox(height: 16),

                  // Report Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _handleReport,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppTheme.primaryRose.withOpacity(0.3),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bug_report_outlined,
                            color: AppTheme.primaryRose,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Report Issue',
                            style: TextStyle(
                              color: AppTheme.primaryRose,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate()
                    .slideY(begin: 0.3, end: 0, delay: 1000.ms, duration: 600.ms)
                    .fadeIn(),

                  const SizedBox(height: 16),

                  // Show Details Button (for developers)
                  if (widget.showDetails || _error != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showDetails = !_showDetails;
                        });
                        HapticFeedback.selectionClick();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showDetails 
                              ? Icons.expand_less_rounded 
                              : Icons.expand_more_rounded,
                            color: AppTheme.mediumGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showDetails ? 'Hide Details' : 'Show Details',
                            style: TextStyle(
                              color: AppTheme.mediumGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                      .slideY(begin: 0.3, end: 0, delay: 1200.ms, duration: 600.ms)
                      .fadeIn(),
                ],
              ),

              // Error Details (expandable)
              if (_showDetails && _error != null)
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark 
                      ? Colors.grey[900]?.withOpacity(0.5)
                      : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryRose.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppTheme.mediumGrey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Technical Details',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.mediumGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        _error.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: AppTheme.mediumGrey,
                          fontSize: 12,
                        ),
                      ),
                      if (_stackTrace != null) ...[
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'Stack Trace:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.mediumGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _stackTrace.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                                color: AppTheme.mediumGrey,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ).animate()
                  .slideY(begin: 0.3, end: 0, duration: 400.ms)
                  .fadeIn(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRetry() {
    HapticFeedback.lightImpact();
    
    if (widget.onRetry != null) {
      widget.onRetry!();
    } else {
      // Default retry behavior - reset error state
      setState(() {
        _hasError = false;
        _error = null;
        _stackTrace = null;
        _showDetails = false;
      });
    }

    AppLogger.info('🔄 User triggered error recovery');
  }

  void _handleReport() async {
    HapticFeedback.selectionClick();

    if (widget.onReport != null) {
      widget.onReport!();
    } else {
      // Default report behavior - copy error to clipboard
      if (_error != null) {
        final errorReport = '''
Error Report:
Time: ${DateTime.now().toIso8601String()}
Error: ${_error.toString()}
${_stackTrace != null ? '\nStack Trace:\n${_stackTrace.toString()}' : ''}
''';

        await Clipboard.setData(ClipboardData(text: errorReport));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.copy_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Error details copied to clipboard'),
                ],
              ),
              backgroundColor: AppTheme.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }

    AppLogger.info('📋 User reported error');
  }
}

/// Wrapper widget that automatically adds error boundary
class SafeWidget extends StatelessWidget {
  final Widget child;
  final String? fallbackTitle;
  final String? fallbackMessage;

  const SafeWidget({
    super.key,
    required this.child,
    this.fallbackTitle,
    this.fallbackMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      fallbackTitle: fallbackTitle,
      fallbackMessage: fallbackMessage,
      child: child,
    );
  }
}
