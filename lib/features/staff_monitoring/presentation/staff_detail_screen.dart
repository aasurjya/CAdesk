import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Mock data model for staff detail
// ---------------------------------------------------------------------------

class _StaffDetail {
  const _StaffDetail({
    required this.id,
    required this.name,
    required this.designation,
    required this.email,
    required this.phone,
    required this.department,
    required this.skills,
    required this.assignments,
    required this.capacityPercent,
    required this.hoursThisWeek,
    required this.hoursThisMonth,
    required this.billableHoursMonth,
    required this.tasksCompleted,
    required this.onTimePercent,
    required this.leaveBalance,
    required this.joinDate,
  });

  final String id;
  final String name;
  final String designation;
  final String email;
  final String phone;
  final String department;
  final List<String> skills;
  final List<_Assignment> assignments;
  final int capacityPercent;
  final double hoursThisWeek;
  final double hoursThisMonth;
  final double billableHoursMonth;
  final int tasksCompleted;
  final int onTimePercent;
  final int leaveBalance;
  final DateTime joinDate;
}

class _Assignment {
  const _Assignment({
    required this.clientName,
    required this.task,
    required this.dueDate,
    required this.status,
  });

  final String clientName;
  final String task;
  final String dueDate;
  final String status;
}

_StaffDetail _mockStaffDetail(String staffId) {
  return _StaffDetail(
    id: staffId,
    name: 'Ananya Desai',
    designation: 'Senior CA',
    email: 'ananya@firm.com',
    phone: '+91 98765 43210',
    department: 'Tax & Compliance',
    skills: ['ITR Filing', 'GST', 'Tax Planning', 'TDS', 'Audit'],
    assignments: const [
      _Assignment(
        clientName: 'Rajesh Sharma',
        task: 'ITR Filing AY 2025-26',
        dueDate: '31 Mar 2026',
        status: 'In Progress',
      ),
      _Assignment(
        clientName: 'Priya Patel',
        task: 'GST Return - Feb 2026',
        dueDate: '20 Mar 2026',
        status: 'Pending',
      ),
      _Assignment(
        clientName: 'Arjun Enterprises',
        task: 'Statutory Audit',
        dueDate: '15 Apr 2026',
        status: 'Not Started',
      ),
    ],
    capacityPercent: 78,
    hoursThisWeek: 32.5,
    hoursThisMonth: 142,
    billableHoursMonth: 118,
    tasksCompleted: 47,
    onTimePercent: 92,
    leaveBalance: 12,
    joinDate: DateTime(2021, 6, 1),
  );
}

/// Staff detail screen showing assignments, capacity, time logged, skills,
/// performance metrics, and leave balance for an individual staff member.
class StaffDetailScreen extends ConsumerWidget {
  const StaffDetailScreen({super.key, required this.staffId});

  final String staffId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = _mockStaffDetail(staffId);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _HeroHeader(staff: staff),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _CapacityCard(staff: staff),
                const SizedBox(height: 16),
                _TimeLoggedCard(staff: staff),
                const SizedBox(height: 16),
                _PerformanceCard(staff: staff),
                const SizedBox(height: 16),
                _SkillsSection(skills: staff.skills),
                const SizedBox(height: 16),
                _AssignmentsSection(assignments: staff.assignments),
                const SizedBox(height: 16),
                _LeaveSection(leaveBalance: staff.leaveBalance, theme: theme),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero header
// ---------------------------------------------------------------------------

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.staff});

  final _StaffDetail staff;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryVariant],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withAlpha(40),
                  child: Text(
                    staff.name.split(' ').map((w) => w[0]).take(2).join(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  staff.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${staff.designation} \u2022 ${staff.department}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Capacity card
// ---------------------------------------------------------------------------

class _CapacityCard extends StatelessWidget {
  const _CapacityCard({required this.staff});

  final _StaffDetail staff;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = staff.capacityPercent >= 90
        ? AppColors.error
        : staff.capacityPercent >= 70
        ? AppColors.warning
        : AppColors.success;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capacity Utilization',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: staff.capacityPercent / 100,
                      minHeight: 10,
                      backgroundColor: AppColors.neutral100,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${staff.capacityPercent}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Time logged card
// ---------------------------------------------------------------------------

class _TimeLoggedCard extends StatelessWidget {
  const _TimeLoggedCard({required this.staff});

  final _StaffDetail staff;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _MetricTile(
              label: 'This Week',
              value: '${staff.hoursThisWeek}h',
              icon: Icons.schedule_rounded,
              color: AppColors.primary,
            ),
            _MetricTile(
              label: 'This Month',
              value: '${staff.hoursThisMonth.toInt()}h',
              icon: Icons.calendar_month_rounded,
              color: AppColors.secondary,
            ),
            _MetricTile(
              label: 'Billable',
              value: '${staff.billableHoursMonth.toInt()}h',
              icon: Icons.attach_money_rounded,
              color: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Performance card
// ---------------------------------------------------------------------------

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.staff});

  final _StaffDetail staff;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MetricTile(
                  label: 'Tasks Done',
                  value: '${staff.tasksCompleted}',
                  icon: Icons.task_alt_rounded,
                  color: AppColors.primary,
                ),
                _MetricTile(
                  label: 'On-Time',
                  value: '${staff.onTimePercent}%',
                  icon: Icons.timer_rounded,
                  color: staff.onTimePercent >= 90
                      ? AppColors.success
                      : AppColors.warning,
                ),
                _MetricTile(
                  label: 'Billable Hrs',
                  value: '${staff.billableHoursMonth.toInt()}',
                  icon: Icons.receipt_rounded,
                  color: AppColors.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skills section
// ---------------------------------------------------------------------------

class _SkillsSection extends StatelessWidget {
  const _SkillsSection({required this.skills});

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skills & Expertise',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map(
                    (skill) => Chip(
                      label: Text(skill, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppColors.primary.withAlpha(15),
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Assignments section
// ---------------------------------------------------------------------------

class _AssignmentsSection extends StatelessWidget {
  const _AssignmentsSection({required this.assignments});

  final List<_Assignment> assignments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Assignments',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...assignments.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.neutral200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            a.clientName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          _StatusBadge(status: a.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a.task,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Due: ${a.dueDate}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Leave section
// ---------------------------------------------------------------------------

class _LeaveSection extends StatelessWidget {
  const _LeaveSection({required this.leaveBalance, required this.theme});

  final int leaveBalance;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.beach_access_rounded,
              color: AppColors.accent,
              size: 24,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leave Balance',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '$leaveBalance days remaining',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _MetricTile extends StatelessWidget {
  const _MetricTile({
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
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  Color get _color {
    switch (status) {
      case 'In Progress':
        return AppColors.primary;
      case 'Pending':
        return AppColors.warning;
      case 'Not Started':
        return AppColors.neutral400;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withAlpha(60)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}
