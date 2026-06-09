import 'package:flutter/material.dart';

enum SourceActionVariant { compact, outlined, filled }

class SourceActionButton extends StatelessWidget {
  final bool plural;
  final VoidCallback? onPressed;
  final SourceActionVariant variant;
  final Color? color;
  final IconData icon;
  final bool expand;

  const SourceActionButton.sources({
    super.key,
    required this.onPressed,
    this.variant = SourceActionVariant.compact,
    this.color,
    this.icon = Icons.menu_book_rounded,
    this.expand = false,
  }) : plural = true;

  const SourceActionButton.source({
    super.key,
    required this.onPressed,
    this.variant = SourceActionVariant.compact,
    this.color,
    this.icon = Icons.open_in_new_rounded,
    this.expand = false,
  }) : plural = false;

  String get _label => plural ? 'View sources' : 'View source';

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? Theme.of(context).colorScheme.primary;

    final Widget control = switch (variant) {
      SourceActionVariant.compact => _buildCompact(resolvedColor),
      SourceActionVariant.outlined => _buildOutlined(resolvedColor),
      SourceActionVariant.filled => _buildFilled(resolvedColor),
    };

    return expand ? SizedBox(width: double.infinity, child: control) : control;
  }

  Widget _buildCompact(Color resolvedColor) {
    return Semantics(
      button: true,
      label: _label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(999),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: resolvedColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: resolvedColor.withValues(alpha: 0.24),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 13, color: resolvedColor),
                    const SizedBox(width: 6),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        _label,
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: resolvedColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlined(Color resolvedColor) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(_label, textAlign: TextAlign.center),
      style: OutlinedButton.styleFrom(
        foregroundColor: resolvedColor,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        side: BorderSide(color: resolvedColor.withValues(alpha: 0.72)),
        shape: const StadiumBorder(),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }

  Widget _buildFilled(Color resolvedColor) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(_label, textAlign: TextAlign.center),
      style: ElevatedButton.styleFrom(
        backgroundColor: resolvedColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0,
        shape: const StadiumBorder(),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }
}
