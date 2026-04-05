// lib/shared/widgets/loading_overlay.dart
//
// Kelimelik — loading, error, and empty state widgets.

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_strings.dart';

// ─── Full-screen loading ──────────────────────────────────────────────────────

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.primary),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message!, style: AppTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Inline loading indicator ─────────────────────────────────────────────────

class InlineLoader extends StatelessWidget {
  const InlineLoader({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size, height: size,
        child: const CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 48),
            const SizedBox(height: 16),
            Text(message, style: AppTheme.bodyMedium, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(S.of(context).commonRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.action,
    this.actionLabel,
  });

  final String emoji;
  final String title;
  final String? subtitle;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(title, style: AppTheme.headlineMedium, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, style: AppTheme.bodyMedium, textAlign: TextAlign.center),
            ],
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: action, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
