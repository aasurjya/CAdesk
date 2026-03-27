import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum ApiCallStatus { success, failed, timeout }

extension ApiCallStatusX on ApiCallStatus {
  Color get color => switch (this) {
    ApiCallStatus.success => AppColors.success,
    ApiCallStatus.failed => AppColors.error,
    ApiCallStatus.timeout => AppColors.warning,
  };

  String get label => switch (this) {
    ApiCallStatus.success => 'Success',
    ApiCallStatus.failed => 'Failed',
    ApiCallStatus.timeout => 'Timeout',
  };
}

class ApiCallRecord {
  const ApiCallRecord({
    required this.endpoint,
    required this.method,
    required this.status,
    required this.responseTime,
    required this.timestamp,
    required this.httpCode,
  });

  final String endpoint;
  final String method;
  final ApiCallStatus status;
  final int responseTime;
  final DateTime timestamp;
  final int httpCode;
}

class GstrFlowStatus {
  const GstrFlowStatus({
    required this.returnType,
    required this.period,
    required this.stage,
    required this.stageColor,
  });

  final String returnType;
  final String period;
  final String stage;
  final Color stageColor;
}

class RateLimit {
  const RateLimit({
    required this.label,
    required this.used,
    required this.total,
  });

  final String label;
  final int used;
  final int total;

  double get usagePercent => total == 0 ? 0 : used / total;
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final _apiStatusProvider = Provider<bool>((ref) => true);

final _recentCallsProvider = Provider<List<ApiCallRecord>>((ref) {
  return [
    ApiCallRecord(
      endpoint: '/taxpayer/gstin',
      method: 'GET',
      status: ApiCallStatus.success,
      responseTime: 234,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      httpCode: 200,
    ),
    ApiCallRecord(
      endpoint: '/returns/gstr1',
      method: 'POST',
      status: ApiCallStatus.success,
      responseTime: 1120,
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      httpCode: 200,
    ),
    ApiCallRecord(
      endpoint: '/returns/gstr3b',
      method: 'POST',
      status: ApiCallStatus.failed,
      responseTime: 5000,
      timestamp: DateTime.now().subtract(const Duration(minutes: 42)),
      httpCode: 500,
    ),
    ApiCallRecord(
      endpoint: '/ewaybill/generate',
      method: 'POST',
      status: ApiCallStatus.success,
      responseTime: 890,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      httpCode: 200,
    ),
    ApiCallRecord(
      endpoint: '/returns/gstr2b',
      method: 'GET',
      status: ApiCallStatus.timeout,
      responseTime: 30000,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      httpCode: 408,
    ),
  ];
});

final _gstrFlowProvider = Provider<List<GstrFlowStatus>>((ref) {
  return [
    const GstrFlowStatus(
      returnType: 'GSTR-1',
      period: 'Feb 2026',
      stage: 'Filed',
      stageColor: AppColors.success,
    ),
    const GstrFlowStatus(
      returnType: 'GSTR-3B',
      period: 'Feb 2026',
      stage: 'Draft Saved',
      stageColor: AppColors.secondary,
    ),
    const GstrFlowStatus(
      returnType: 'GSTR-1',
      period: 'Mar 2026',
      stage: 'Not Started',
      stageColor: AppColors.neutral400,
    ),
  ];
});

final _rateLimitsProvider = Provider<List<RateLimit>>((ref) {
  return const [
    RateLimit(label: 'GSTIN Lookup', used: 142, total: 500),
    RateLimit(label: 'Returns API', used: 38, total: 100),
    RateLimit(label: 'E-Way Bill', used: 12, total: 200),
  ];
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class GstnApiDashboardScreen extends ConsumerWidget {
  const GstnApiDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isApiUp = ref.watch(_apiStatusProvider);
    final calls = ref.watch(_recentCallsProvider);
    final flows = ref.watch(_gstrFlowProvider);
    final limits = ref.watch(_rateLimitsProvider);
    final theme = Theme.of(context);

    final successCount = calls
        .where((c) => c.status == ApiCallStatus.success)
        .length;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GSTN API Dashboard',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'API integration & monitoring',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // API status banner
          _ApiStatusBanner(isUp: isApiUp),
          const SizedBox(height: 16),

          // Stats
          Row(
            children: [
              _StatCard(
                label: 'Total Calls',
                value: '${calls.length}',
                icon: Icons.api_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Success',
                value: '$successCount',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Failed',
                value: '${calls.length - successCount}',
                icon: Icons.error_outline_rounded,
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Rate limits
          const _SectionHeader(
            title: 'Rate Limit Usage',
            icon: Icons.speed_rounded,
          ),
          const SizedBox(height: 10),
          ...limits.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _RateLimitBar(limit: l),
            ),
          ),
          const SizedBox(height: 16),

          // GSTR flow
          const _SectionHeader(
            title: 'GSTR Filing Status',
            icon: Icons.receipt_long_rounded,
          ),
          const SizedBox(height: 10),
          ...flows.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _GstrFlowTile(flow: f),
            ),
          ),
          const SizedBox(height: 16),

          // Recent API calls
          const _SectionHeader(
            title: 'Recent API Calls',
            icon: Icons.history_rounded,
          ),
          const SizedBox(height: 10),
          ...calls.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ApiCallTile(call: c),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// API status banner
// ---------------------------------------------------------------------------

class _ApiStatusBanner extends StatelessWidget {
  const _ApiStatusBanner({required this.isUp});

  final bool isUp;

  @override
  Widget build(BuildContext context) {
    final color = isUp ? AppColors.success : AppColors.error;
    final label = isUp ? 'GSTN API is operational' : 'GSTN API is down';
    final icon = isUp ? Icons.check_circle_rounded : Icons.error_rounded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rate limit bar
// ---------------------------------------------------------------------------

class _RateLimitBar extends StatelessWidget {
  const _RateLimitBar({required this.limit});

  final RateLimit limit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = limit.usagePercent;
    final barColor = pct > 0.8
        ? AppColors.error
        : pct > 0.5
        ? AppColors.warning
        : AppColors.success;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  limit.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${limit.used} / ${limit.total}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: AppColors.neutral200,
                color: barColor,
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GSTR flow tile
// ---------------------------------------------------------------------------

class _GstrFlowTile extends StatelessWidget {
  const _GstrFlowTile({required this.flow});

  final GstrFlowStatus flow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: flow.stageColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            size: 18,
            color: flow.stageColor,
          ),
        ),
        title: Text(
          '${flow.returnType} - ${flow.period}',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: flow.stageColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            flow.stage,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: flow.stageColor,
            ),
          ),
        ),
        dense: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// API call tile
// ---------------------------------------------------------------------------

class _ApiCallTile extends StatelessWidget {
  const _ApiCallTile({required this.call});

  final ApiCallRecord call;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                call.method,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    call.endpoint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${_timeAgo(call.timestamp)} - ${call.responseTime}ms - HTTP ${call.httpCode}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              call.status == ApiCallStatus.success
                  ? Icons.check_circle_rounded
                  : call.status == ApiCallStatus.failed
                  ? Icons.cancel_rounded
                  : Icons.timer_off_rounded,
              size: 18,
              color: call.status.color,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}
