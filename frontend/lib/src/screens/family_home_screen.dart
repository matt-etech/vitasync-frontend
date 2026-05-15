import 'package:flutter/material.dart';

import '../models/family_portal_summary.dart';
import '../models/family_session.dart';
import '../services/family_access_contract.dart';

class FamilyHomeScreen extends StatefulWidget {
  const FamilyHomeScreen({
    required this.session,
    required this.familyAccess,
    required this.onLogout,
    super.key,
  });

  final FamilySession session;
  final FamilyAccessPort familyAccess;
  final VoidCallback onLogout;

  @override
  State<FamilyHomeScreen> createState() => _FamilyHomeScreenState();
}

class _FamilyHomeScreenState extends State<FamilyHomeScreen> {
  late Future<FamilyPortalSummary> _summary;
  late int _selectedClientId;
  var _selectedTabIndex = 0;

  static const _tabs = [
    _FamilyTab(label: 'Overview', icon: Icons.home_outlined),
    _FamilyTab(label: 'Care', icon: Icons.volunteer_activism_outlined),
    _FamilyTab(label: 'Visits', icon: Icons.event_note_outlined),
    _FamilyTab(label: 'Alerts', icon: Icons.notifications_none_outlined),
    _FamilyTab(label: 'My Profile', icon: Icons.person_outline),
  ];

  @override
  void initState() {
    super.initState();
    _selectedClientId = widget.session.clientId;
    _summary = _loadSummary();
  }

  Future<FamilyPortalSummary> _loadSummary() {
    return widget.familyAccess.portalSummary(
      widget.session,
      clientId: _selectedClientId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = _tabs[_selectedTabIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedTab.label),
        actions: [
          TextButton.icon(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
      body: FutureBuilder<FamilyPortalSummary>(
        future: _summary,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _FamilyPanel(
              title: 'Family portal unavailable',
              child: Text(
                snapshot.error is FamilyAccessException
                    ? (snapshot.error! as FamilyAccessException).message
                    : 'Check the backend connection and try again.',
              ),
            );
          }

          final summary = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (widget.session.clients.length > 1) ...[
                _ClientSelector(
                  clients: widget.session.clients,
                  selectedClientId: _selectedClientId,
                  onChanged: (clientId) {
                    setState(() {
                      _selectedClientId = clientId;
                      _summary = _loadSummary();
                    });
                  },
                ),
                const SizedBox(height: 12),
              ],
              ..._buildTabContent(summary, selectedTab),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFDDF6E3),
          border: Border(top: BorderSide(color: Color(0xFFB7DEC3))),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _selectedTabIndex,
            onTap: (index) {
              setState(() => _selectedTabIndex = index);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: const Color(0xFF0F766E),
            unselectedItemColor: const Color(0xFF40525A),
            items: [
              for (final tab in _tabs)
                BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  label: '',
                  tooltip: tab.label,
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTabContent(
    FamilyPortalSummary summary,
    _FamilyTab selectedTab,
  ) {
    switch (selectedTab.label) {
      case 'Care':
        return [
          _MedicationPanel(summary: summary),
          if (summary.carePlanSummary != null)
            _FamilyPanel(
              title: 'Care plan summary',
              child: Text(
                [
                  summary.carePlanSummary!['title'],
                  summary.carePlanSummary!['care_goals'],
                ].whereType<String>().join('\n'),
              ),
            )
          else
            const _FamilyPanel(
              title: 'Care plan summary',
              child: Text('No care plan summary shared.'),
            ),
        ];
      case 'Visits':
        return [
          _FamilyVisitCalendar(
            visits: [...summary.upcomingVisits, ...summary.pastVisits],
          ),
          _FamilyVisitListPanel(
            title: 'Upcoming visits',
            emptyText: 'No upcoming visits shared.',
            visits: summary.upcomingVisits,
          ),
          _FamilyVisitListPanel(
            title: 'Past visits',
            emptyText: 'No past visits shared.',
            visits: summary.pastVisits,
            showAttendance: true,
          ),
        ];
      case 'Alerts':
        return [
          _FamilyListPanel(
            title: 'Incident notifications',
            emptyText: 'No approved incident notifications.',
            rows: summary.incidentNotifications,
            labelFor: (row) =>
                '${row['category'] ?? 'Incident'} - ${row['severity'] ?? 'info'}',
          ),
        ];
      case 'My Profile':
        return [
          _FamilyProfilePanel(
            session: widget.session,
            selectedClient: summary.client,
            familyAccess: widget.familyAccess,
          ),
        ];
      default:
        return [
          _FamilyPanel(
            title: summary.client.name,
            subtitle: summary.client.homeName,
            child: Text('Status: ${summary.client.status}'),
          ),
          _NextVisitPanel(visits: summary.upcomingVisits),
          _MedicationPanel(summary: summary),
          _FamilyVisitListPanel(
            title: 'Upcoming visits',
            emptyText: 'No upcoming visits shared.',
            visits: summary.upcomingVisits,
          ),
        ];
    }
  }
}

class _ClientSelector extends StatelessWidget {
  const _ClientSelector({
    required this.clients,
    required this.selectedClientId,
    required this.onChanged,
  });

  final List<FamilySessionClient> clients;
  final int selectedClientId;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return _FamilyPanel(
      title: 'Selected client',
      child: DropdownButtonFormField<int>(
        value: selectedClientId,
        decoration: const InputDecoration(
          labelText: 'Client',
          prefixIcon: Icon(Icons.person_search_outlined),
        ),
        items: [
          for (final client in clients)
            DropdownMenuItem<int>(
              value: client.id,
              child: Text(
                client.homeName == null
                    ? client.name
                    : '${client.name} - ${client.homeName}',
              ),
            ),
        ],
        onChanged: (value) {
          if (value != null && value != selectedClientId) {
            onChanged(value);
          }
        },
      ),
    );
  }
}

class _NextVisitPanel extends StatelessWidget {
  const _NextVisitPanel({required this.visits});

  final List<Map<String, dynamic>> visits;

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return const _FamilyPanel(
        title: 'Next carer visit',
        child: Text('No upcoming visit is currently shared.'),
      );
    }

    final visit = visits.first;

    return _FamilyPanel(
      title: 'Next carer visit',
      child: _VisitDetail(visit: visit),
    );
  }
}

class _MedicationPanel extends StatelessWidget {
  const _MedicationPanel({required this.summary});

  final FamilyPortalSummary summary;

  @override
  Widget build(BuildContext context) {
    final medication = summary.medicationSummary;
    final latestRecord = summary.medicationRecords.isEmpty
        ? null
        : summary.medicationRecords.first;

    return _FamilyPanel(
      title: 'Medication support',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (medication == null)
            const Text('No medication support summary is shared.')
          else ...[
            _InfoLine(
              label: 'Upcoming support',
              value:
                  medication['support_level'] as String? ??
                  (medication['support_needed'] == true
                      ? 'Medication support needed'
                      : 'No medication support required'),
            ),
            if (medication['care_plan_instructions'] != null)
              _InfoLine(
                label: 'Instructions',
                value: medication['care_plan_instructions'] as String,
              ),
            if (medication['support_summary'] != null)
              _InfoLine(
                label: 'Medication',
                value: medication['support_summary'] as String,
              ),
            if (medication['allergies'] != null)
              _InfoLine(label: 'Allergies', value: medication['allergies'] as String),
          ],
          const SizedBox(height: 12),
          if (latestRecord == null)
            const Text('No medication administration record has been shared yet.')
          else ...[
            Text(
              'Latest medication record',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            _InfoLine(
              label: 'Status',
              value: latestRecord['status'] as String? ?? 'Recorded',
            ),
            _InfoLine(
              label: 'Given at',
              value: _dateTimeLabel(latestRecord['completed_at']),
            ),
            _InfoLine(
              label: 'Carer',
              value: latestRecord['carer_name'] as String? ?? 'Not recorded',
            ),
            if (latestRecord['detail'] != null)
              _InfoLine(label: 'Notes', value: latestRecord['detail'] as String),
          ],
        ],
      ),
    );
  }
}

class _FamilyVisitCalendar extends StatefulWidget {
  const _FamilyVisitCalendar({required this.visits});

  final List<Map<String, dynamic>> visits;

  @override
  State<_FamilyVisitCalendar> createState() => _FamilyVisitCalendarState();
}

class _FamilyVisitCalendarState extends State<_FamilyVisitCalendar> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _setInitialDate();
  }

  @override
  void didUpdateWidget(covariant _FamilyVisitCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visits != widget.visits) {
      _setInitialDate();
    }
  }

  void _setInitialDate() {
    final firstVisitDate = widget.visits
        .map((visit) => _parseDate(visit['scheduled_start_at']))
        .whereType<DateTime>()
        .toList()
      ..sort();
    final now = DateTime.now();
    _selectedDate = firstVisitDate.isEmpty ? now : firstVisitDate.first;
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final visibleDates = _visibleCalendarDates(_displayedMonth);
    final selectedVisits = widget.visits
        .where((visit) {
          final date = _parseDate(visit['scheduled_start_at']);
          return date != null && _sameDate(date, _selectedDate);
        })
        .toList();

    return _FamilyPanel(
      title: 'Visit calendar',
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month - 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  _monthLabel(_displayedMonth),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month + 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            childAspectRatio: 1.15,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final dayName in const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'])
                Center(child: Text(dayName, style: Theme.of(context).textTheme.labelMedium)),
              for (final date in visibleDates)
                _FamilyCalendarDayCell(
                  date: date,
                  isCurrentMonth: date.month == _displayedMonth.month,
                  isSelected: _sameDate(date, _selectedDate),
                  visits: widget.visits.where((visit) {
                    final visitDate = _parseDate(visit['scheduled_start_at']);
                    return visitDate != null && _sameDate(visitDate, date);
                  }).toList(),
                  onTap: () => setState(() => _selectedDate = date),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Visits on ${_dateLabel(_selectedDate.toIso8601String())}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(height: 8),
          if (selectedVisits.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('No visits scheduled.'),
            )
          else
            for (final visit in selectedVisits)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _VisitDetail(visit: visit, compact: true),
              ),
        ],
      ),
    );
  }
}

class _FamilyCalendarDayCell extends StatelessWidget {
  const _FamilyCalendarDayCell({
    required this.date,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.visits,
    required this.onTap,
  });

  final DateTime date;
  final bool isCurrentMonth;
  final bool isSelected;
  final List<Map<String, dynamic>> visits;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasVisits = visits.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFDDF6E3)
              : hasVisits
              ? const Color(0xFFE0F2F1)
              : const Color(0xFFF7F9FA),
          border: Border.all(
            color: isSelected || hasVisits
                ? const Color(0xFF0F766E)
                : const Color(0xFFE5EAEE),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                color: isCurrentMonth
                    ? const Color(0xFF17252F)
                    : const Color(0xFF8A98A3),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (hasVisits)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Row(
                  children: [
                    for (final visit in visits.take(3))
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.only(right: 2),
                        decoration: BoxDecoration(
                          color: _visitStatusColor(visit['status'] as String?),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FamilyVisitListPanel extends StatelessWidget {
  const _FamilyVisitListPanel({
    required this.title,
    required this.emptyText,
    required this.visits,
    this.showAttendance = false,
  });

  final String title;
  final String emptyText;
  final List<Map<String, dynamic>> visits;
  final bool showAttendance;

  @override
  Widget build(BuildContext context) {
    return _FamilyPanel(
      title: title,
      child: visits.isEmpty
          ? Text(emptyText)
          : Column(
              children: [
                for (final visit in visits)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _VisitDetail(
                      visit: visit,
                      showAttendance: showAttendance,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _VisitDetail extends StatelessWidget {
  const _VisitDetail({
    required this.visit,
    this.compact = false,
    this.showAttendance = false,
  });

  final Map<String, dynamic> visit;
  final bool compact;
  final bool showAttendance;

  @override
  Widget build(BuildContext context) {
    final carerName = visit['assigned_worker_name'] as String?;
    final attended = visit['did_carer_attend'] == true;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FDF9),
        border: Border.all(color: const Color(0xFFCDEBD6)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.event_available_outlined, color: _visitStatusColor(visit['status'] as String?)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  visit['title'] as String? ?? 'Care visit',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              _StatusPill(label: visit['status'] as String? ?? 'scheduled'),
            ],
          ),
          const SizedBox(height: 8),
          _InfoLine(label: 'When', value: _visitTimeRange(visit)),
          _InfoLine(label: 'Carer', value: carerName ?? 'Not assigned yet'),
          if (!compact || showAttendance) ...[
            _InfoLine(label: 'Did carer come?', value: attended ? 'Yes' : 'Not recorded yet'),
            _InfoLine(label: 'Arrived', value: _dateTimeLabel(visit['check_in_at'])),
            _InfoLine(label: 'Departed', value: _dateTimeLabel(visit['check_out_at'])),
          ],
          if (visit['notes'] != null && '${visit['notes']}'.trim().isNotEmpty)
            _InfoLine(label: 'Notes', value: visit['notes'] as String),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _visitStatusColor(label).withOpacity(.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.replaceAll('_', ' '),
        style: TextStyle(
          color: _visitStatusColor(label),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FamilyTab {
  const _FamilyTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _FamilyProfilePanel extends StatefulWidget {
  const _FamilyProfilePanel({
    required this.session,
    required this.selectedClient,
    required this.familyAccess,
  });

  final FamilySession session;
  final FamilyClientProfile selectedClient;
  final FamilyAccessPort familyAccess;

  @override
  State<_FamilyProfilePanel> createState() => _FamilyProfilePanelState();
}

class _FamilyProfilePanelState extends State<_FamilyProfilePanel> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  var _isSaving = false;
  String? _statusMessage;
  bool _isError = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _statusMessage = null;
      _isError = false;
    });

    try {
      await widget.familyAccess.changePassword(
        session: widget.session,
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        newPasswordConfirmation: _confirmPasswordController.text,
      );

      if (!mounted) {
        return;
      }

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() {
        _statusMessage = 'Password changed.';
        _isError = false;
      });
    } on FamilyAccessException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = error.message;
        _isError = true;
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;

    return Column(
      children: [
        _FamilyPanel(
          title: 'Member information',
          child: Column(
            children: [
              _ProfileRow(label: 'Name', value: session.name),
              _ProfileRow(label: 'Email', value: session.email),
              _ProfileRow(
                label: 'Relationship',
                value: session.relationship ?? 'Not recorded',
              ),
              _ProfileRow(label: 'Client', value: widget.selectedClient.name),
              _ProfileRow(
                label: 'Home',
                value: widget.selectedClient.homeName ?? 'Not recorded',
              ),
            ],
          ),
        ),
        _FamilyPanel(
          title: 'Change password',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_statusMessage != null) ...[
                  _InlineStatus(message: _statusMessage!, isError: _isError),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Current password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if ((value ?? '').isEmpty) {
                      return 'Enter your current password.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'New password',
                    prefixIcon: Icon(Icons.password_outlined),
                  ),
                  validator: (value) {
                    final password = value ?? '';
                    if (password.length < 8) {
                      return 'Use at least 8 characters.';
                    }
                    if (!RegExp(r'[A-Z]').hasMatch(password) ||
                        !RegExp(r'[a-z]').hasMatch(password) ||
                        !RegExp(r'\d').hasMatch(password)) {
                      return 'Use upper, lower, and number characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _changePassword(),
                  decoration: const InputDecoration(
                    labelText: 'Confirm new password',
                    prefixIcon: Icon(Icons.verified_user_outlined),
                  ),
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _changePassword,
                  icon: _isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? 'Saving password' : 'Save password'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _InlineStatus extends StatelessWidget {
  const _InlineStatus({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isError ? const Color(0xFFFFF4E5) : const Color(0xFFE8F8EE),
          border: Border.all(
            color: isError ? const Color(0xFFB45309) : const Color(0xFF86CDA0),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(message),
      ),
    );
  }
}

class _FamilyPanel extends StatelessWidget {
  const _FamilyPanel({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA7F3D0),
            Color(0xFFE8F8EE),
            Color(0xFFFFFFFF),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFEFC),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

DateTime? _parseDate(Object? value) {
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(value.toString())?.toLocal();
}

bool _sameDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

List<DateTime> _visibleCalendarDates(DateTime displayedMonth) {
  final firstDay = DateTime(displayedMonth.year, displayedMonth.month);
  final startOffset = firstDay.weekday - DateTime.monday;
  final start = firstDay.subtract(Duration(days: startOffset));

  return [for (var index = 0; index < 42; index++) start.add(Duration(days: index))];
}

String _monthLabel(DateTime date) {
  return '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _dateLabel(Object? value) {
  final date = value is DateTime ? value : _parseDate(value);

  if (date == null) {
    return 'Not scheduled';
  }

  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _timeLabel(Object? value) {
  final date = _parseDate(value);

  if (date == null) {
    return 'Not recorded';
  }

  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String _dateTimeLabel(Object? value) {
  final date = _parseDate(value);

  if (date == null) {
    return 'Not recorded';
  }

  return '${_dateLabel(date)} ${_timeLabel(date.toIso8601String())}';
}

String _visitTimeRange(Map<String, dynamic> visit) {
  final start = visit['scheduled_start_at'];
  final end = visit['scheduled_end_at'];

  return '${_dateLabel(start)} ${_timeLabel(start)} - ${_timeLabel(end)}';
}

Color _visitStatusColor(String? status) {
  switch (status) {
    case 'completed':
      return const Color(0xFF0F766E);
    case 'in_progress':
      return const Color(0xFFB45309);
    case 'missed':
    case 'cancelled':
      return const Color(0xFFB42318);
    default:
      return const Color(0xFF40525A);
  }
}

class _FamilyListPanel extends StatelessWidget {
  const _FamilyListPanel({
    required this.title,
    required this.emptyText,
    required this.rows,
    required this.labelFor,
  });

  final String title;
  final String emptyText;
  final List<Map<String, dynamic>> rows;
  final String Function(Map<String, dynamic> row) labelFor;

  @override
  Widget build(BuildContext context) {
    return _FamilyPanel(
      title: title,
      child: rows.isEmpty
          ? Text(emptyText)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final row in rows.take(5))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(labelFor(row)),
                  ),
              ],
            ),
    );
  }
}
