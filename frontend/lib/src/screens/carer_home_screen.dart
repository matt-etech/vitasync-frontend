import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../models/care_client.dart';
import '../models/carer_session.dart';
import '../models/scheduled_visit.dart';
import '../models/visit_workflow.dart';
import '../services/care_plan_task_contract.dart';
import '../services/carer_auth_contract.dart';
import '../services/client_directory_contract.dart';
import '../services/visit_schedule_contract.dart';
import '../services/visit_workflow_contract.dart';

class CarerHomeScreen extends StatefulWidget {
  const CarerHomeScreen({
    required this.session,
    required this.authService,
    required this.clientDirectory,
    required this.carePlanTasks,
    required this.visitSchedule,
    required this.visitWorkflow,
    required this.onLogout,
    super.key,
  });

  final CarerSession session;
  final CarerAuthPort authService;
  final ClientDirectoryPort clientDirectory;
  final CarePlanTaskPort carePlanTasks;
  final VisitSchedulePort visitSchedule;
  final VisitWorkflowPort visitWorkflow;
  final VoidCallback onLogout;

  @override
  State<CarerHomeScreen> createState() => _CarerHomeScreenState();
}

class _CarerHomeScreenState extends State<CarerHomeScreen> {
  int _selectedTabIndex = 0;
  _ScheduleMode _selectedScheduleMode = _ScheduleMode.agenda;
  final List<_AuditEvidence> _auditEvidence = const [
    _AuditEvidence(
      action: 'Visit loaded for carer',
      timestamp: '09:20',
      syncState: _SyncState.synced,
    ),
  ];

  static const _tabs = [
    _HomeTab(label: 'Today', icon: Icons.today_outlined),
    _HomeTab(label: 'Schedule', icon: Icons.calendar_month_outlined),
    _HomeTab(label: 'Clients', icon: Icons.people_alt_outlined),
    _HomeTab(label: 'Tasks', icon: Icons.checklist_outlined),
    _HomeTab(label: 'Profile', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final status =
        widget.session.accountStatus ??
        widget.session.profileStatus ??
        'signed in';
    final selectedTab = _tabs[_selectedTabIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carer Access'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: _buildTabContent(
            context: context,
            selectedTab: selectedTab,
            status: status,
          ),
        ),
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

  List<Widget> _buildTabContent({
    required BuildContext context,
    required _HomeTab selectedTab,
    required String status,
  }) {
    switch (selectedTab.label) {
      case 'Today':
        return [
          Text('Today', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(
            'Visit execution',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _TodayVisitWorkflow(
            session: widget.session,
            visitWorkflow: widget.visitWorkflow,
            auditEvidence: _auditEvidence,
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Timeline'),
          const SizedBox(height: 12),
          _TodayTimelineWorkflow(
            session: widget.session,
            visitSchedule: widget.visitSchedule,
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Quick actions'),
          const SizedBox(height: 12),
          _QuickActions(
            session: widget.session,
            visitWorkflow: widget.visitWorkflow,
          ),
        ];
      case 'Schedule':
        return [
          Text('Schedule', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Text('Visits', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          _ScheduleWorkflow(
            session: widget.session,
            visitSchedule: widget.visitSchedule,
            selectedMode: _selectedScheduleMode,
            onModeSelected: (mode) {
              setState(() => _selectedScheduleMode = mode);
            },
          ),
        ];
      case 'Profile':
        return [
          Text('Profile', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(
            'Carer information',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _StatusPanel(
            carerName: widget.session.name,
            email: widget.session.email,
            homeName: widget.session.homeName,
            jobTitle: widget.session.jobTitle,
            status: status,
            onChangePassword: () => _showChangePasswordSheet(context),
          ),
        ];
      case 'Clients':
        return [
          Text('Clients', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(
            'Client directory',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _ClientsWorkflow(
            session: widget.session,
            clientDirectory: widget.clientDirectory,
          ),
        ];
      case 'Tasks':
        return [
          Text('Tasks', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(
            'Carer tasks',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _CarerTasksWorkflow(
            session: widget.session,
            visitWorkflow: widget.visitWorkflow,
          ),
        ];
      default:
        return [
          Text(
            selectedTab.label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(
            selectedTab.label,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _EmptyTabPanel(
            icon: selectedTab.icon,
            title: '${selectedTab.label} workflow',
            message:
                'This area is ready for the ${selectedTab.label.toLowerCase()} care workflow.',
          ),
        ];
    }
  }

  Future<void> _showChangePasswordSheet(BuildContext context) async {
    final request = await showModalBottomSheet<_PasswordChangeRequest>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _ChangePasswordSheet(),
    );

    if (!context.mounted || request == null) {
      return;
    }

    try {
      await widget.authService.changePassword(
        session: widget.session,
        currentPassword: request.currentPassword,
        newPassword: request.newPassword,
        newPasswordConfirmation: request.newPasswordConfirmation,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully.')),
      );
    } on CarerAuthException catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _EmptyTabPanel extends StatelessWidget {
  const _EmptyTabPanel({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: const Color(0xFF0F766E)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF17252F),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(message, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientsWorkflow extends StatefulWidget {
  const _ClientsWorkflow({
    required this.session,
    required this.clientDirectory,
  });

  final CarerSession session;
  final ClientDirectoryPort clientDirectory;

  @override
  State<_ClientsWorkflow> createState() => _ClientsWorkflowState();
}

class _ClientsWorkflowState extends State<_ClientsWorkflow> {
  late Future<List<CareClient>> _clients;
  CareClient? _selectedClient;

  @override
  void initState() {
    super.initState();
    _clients = widget.clientDirectory.clientsForCarer(widget.session);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CareClient>>(
      future: _clients,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingPanel(message: 'Loading assigned clients');
        }

        if (snapshot.hasError) {
          return _ClientLoadErrorPanel(
            onRetry: () {
              setState(() {
                _clients = widget.clientDirectory.clientsForCarer(
                  widget.session,
                );
              });
            },
          );
        }

        final clients = snapshot.data ?? const [];

        if (clients.isEmpty) {
          return const _EmptyClientPanel();
        }

        final selectedClient = _selectedClient;
        if (selectedClient != null) {
          return _ClientDetailPanel(
            client: selectedClient,
            onBack: () {
              setState(() {
                _selectedClient = null;
              });
            },
          );
        }

        return Column(
          children: [
            for (final client in clients)
              _ClientDirectoryCard(
                client: client,
                onOpen: () {
                  setState(() {
                    _selectedClient = client;
                  });
                },
              ),
          ],
        );
      },
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _ClientLoadErrorPanel extends StatelessWidget {
  const _ClientLoadErrorPanel({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        border: Border.all(color: const Color(0xFF991B1B)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clients could not be loaded',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text('Check the backend connection and try again.'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyClientPanel extends StatelessWidget {
  const _EmptyClientPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('No active clients are assigned to this care home.'),
    );
  }
}

class _ClientDirectoryCard extends StatelessWidget {
  const _ClientDirectoryCard({required this.client, required this.onOpen});

  final CareClient client;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  client.name,
                  style: const TextStyle(
                    color: Color(0xFF17252F),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _ClientStatusBadge(status: client.status),
            ],
          ),
          const SizedBox(height: 12),
          if (client.address != null)
            _ClientMeta(icon: Icons.map_outlined, text: client.address!),
          if (client.phone != null)
            _ClientMeta(icon: Icons.phone_outlined, text: client.phone!),
          if (client.homeName != null)
            _ClientMeta(icon: Icons.home_work_outlined, text: client.homeName!),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Open client'),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              foregroundColor: const Color(0xFF17252F),
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: Color(0xFFB7C2CA)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientDetailPanel extends StatelessWidget {
  const _ClientDetailPanel({required this.client, required this.onBack});

  final CareClient client;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to clients'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0F766E),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Client details',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF17252F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _ClientStatusBadge(status: client.status),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            client.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF17252F),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (client.address != null)
            _ClientMeta(icon: Icons.map_outlined, text: client.address!),
          if (client.phone != null)
            _ClientMeta(icon: Icons.phone_outlined, text: client.phone!),
          if (client.email != null)
            _ClientMeta(icon: Icons.mail_outline, text: client.email!),
          if (client.latitude != null && client.longitude != null)
            _ClientMeta(
              icon: Icons.location_searching,
              text:
                  'EVV location: ${client.latitude}, ${client.longitude} (${client.geofenceRadiusMeters ?? 100}m)',
            )
          else
            const _ClientMeta(
              icon: Icons.location_disabled_outlined,
              text: 'EVV location not configured',
            ),
          if (client.homeName != null)
            _ClientMeta(icon: Icons.home_work_outlined, text: client.homeName!),
          if (client.onboardingStatus != null)
            _ClientMeta(
              icon: Icons.verified_user_outlined,
              text: 'Onboarding: ${client.onboardingStatus}',
            ),
          const SizedBox(height: 16),
          const _InfoBanner(
            icon: Icons.assignment_ind_outlined,
            title: 'Assigned client',
            message:
                'Use this view to confirm contact, address, home, and current status before care delivery.',
          ),
        ],
      ),
    );
  }
}

class _ClientStatusBadge extends StatelessWidget {
  const _ClientStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFE5EAEE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isActive ? const Color(0xFF166534) : const Color(0xFF40525A),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ClientMeta extends StatelessWidget {
  const _ClientMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF5E6C76)),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _CarerTasksWorkflow extends StatefulWidget {
  const _CarerTasksWorkflow({
    required this.session,
    required this.visitWorkflow,
  });

  final CarerSession session;
  final VisitWorkflowPort visitWorkflow;

  @override
  State<_CarerTasksWorkflow> createState() => _CarerTasksWorkflowState();
}

class _CarerTasksWorkflowState extends State<_CarerTasksWorkflow> {
  final _additionalTaskController = TextEditingController();
  final List<_BasicCarerTask> _tasks = [
    _BasicCarerTask(
      id: 'identity-consent',
      title: 'Confirm client identity and consent',
      detail: 'Confirm the client and gain consent before care starts.',
      icon: Icons.verified_user_outlined,
    ),
    _BasicCarerTask(
      id: 'safety-alerts',
      title: 'Review allergies and critical notes',
      detail: 'Check the alerts below before medication or personal care.',
      icon: Icons.health_and_safety_outlined,
    ),
    _BasicCarerTask(
      id: 'medication',
      title: 'Medication support completed',
      detail: 'Follow the MAR and record any concern immediately.',
      icon: Icons.medication_liquid_outlined,
    ),
    _BasicCarerTask(
      id: 'personal-care',
      title: 'Personal care support completed',
      detail: 'Complete agreed personal care with dignity and privacy.',
      icon: Icons.volunteer_activism_outlined,
    ),
    _BasicCarerTask(
      id: 'nutrition-hydration',
      title: 'Nutrition and hydration offered',
      detail: 'Offer food, fluids, and record concerns in notes.',
      icon: Icons.local_drink_outlined,
    ),
    _BasicCarerTask(
      id: 'safe-environment',
      title: 'Environment left safe',
      detail: 'Check access, trip risks, call bell, and essentials.',
      icon: Icons.home_outlined,
    ),
  ];

  @override
  void dispose() {
    _additionalTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final task in _tasks)
          _BasicCarerTaskCard(
            task: task,
            onChanged: (isDone) => _setTaskDone(task.id, isDone),
          ),
        _AdditionalTaskPanel(
          controller: _additionalTaskController,
          onAddTask: _addAdditionalTask,
        ),
        _VisitAlerts(
          session: widget.session,
          visitWorkflow: widget.visitWorkflow,
        ),
      ],
    );
  }

  void _setTaskDone(String taskId, bool isDone) {
    setState(() {
      final index = _tasks.indexWhere((task) => task.id == taskId);
      if (index == -1) {
        return;
      }

      _tasks[index] = _tasks[index].copyWith(
        completedAt: isDone ? DateTime.now() : null,
        clearCompletedAt: !isDone,
      );
    });
  }

  void _addAdditionalTask() {
    final note = _additionalTaskController.text.trim();
    if (note.isEmpty) {
      return;
    }

    setState(() {
      _tasks.add(
        _BasicCarerTask(
          id: 'additional-${DateTime.now().microsecondsSinceEpoch}',
          title: note,
          detail: 'Additional task added during this visit.',
          icon: Icons.note_add_outlined,
          isAdditional: true,
        ),
      );
      _additionalTaskController.clear();
    });
  }
}

class _TodayVisitWorkflow extends StatefulWidget {
  const _TodayVisitWorkflow({
    required this.session,
    required this.visitWorkflow,
    required this.auditEvidence,
  });

  final CarerSession session;
  final VisitWorkflowPort visitWorkflow;
  final List<_AuditEvidence> auditEvidence;

  @override
  State<_TodayVisitWorkflow> createState() => _TodayVisitWorkflowState();
}

class _TodayVisitWorkflowState extends State<_TodayVisitWorkflow> {
  late Future<VisitWorkflow?> _visit;
  Timer? _visitRefreshTimer;
  StreamSubscription<Position>? _positionSubscription;
  int? _monitoredVisitId;
  bool _locationMonitorStarting = false;
  bool _arrivalLogged = false;
  bool _departureLogged = false;
  _SyncState _syncState = _SyncState.pendingSync;
  DateTime? _lastSyncAt;
  String? _locationMonitorMessage;

  @override
  void initState() {
    super.initState();
    _visit = _loadTodayVisit();
    _visitRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _refreshTodayVisit();
    });
  }

  @override
  void dispose() {
    _visitRefreshTimer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VisitWorkflow?>(
      future: _visit,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingPanel(message: 'Loading today visit');
        }

        if (snapshot.hasError) {
          return _VisitLoadErrorPanel(
            onRetry: () {
              setState(() {
                _syncState = _SyncState.pendingSync;
                _visit = _loadTodayVisit();
              });
            },
          );
        }

        final visit = snapshot.data;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _markSynced();
        });

        if (visit == null) {
          return const _EmptyVisitPanel();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _ensureLocationMonitoring(visit);
          }
        });

        return _VisitExecutionPanel(
          visit: visit,
          auditEvidence: widget.auditEvidence,
          syncState: _syncState,
          lastSyncAt: _lastSyncAt,
          locationMonitorMessage: _locationMonitorMessage,
          hasConfiguredLocation: _hasConfiguredLocation(visit),
          onCheckIn: () async {
            final updated = await widget.visitWorkflow.checkIn(
              session: widget.session,
              visitId: visit.id,
            );
            setState(() {
              _visit = Future.value(updated);
              _syncState = _SyncState.synced;
              _lastSyncAt = DateTime.now();
            });
          },
          onCheckOut: () async {
            final updated = await widget.visitWorkflow.checkOut(
              session: widget.session,
              visitId: visit.id,
            );
            setState(() {
              _visit = Future.value(updated);
              _syncState = _SyncState.synced;
              _lastSyncAt = DateTime.now();
            });
          },
        );
      },
    );
  }

  Future<VisitWorkflow?> _loadTodayVisit() async {
    final visit = await widget.visitWorkflow.todayVisitForCarer(widget.session);

    if (mounted) {
      _syncState = _SyncState.synced;
      _lastSyncAt = DateTime.now();
    }

    return visit;
  }

  void _refreshTodayVisit() {
    if (!mounted) {
      return;
    }

    setState(() {
      _syncState = _SyncState.pendingSync;
      _visit = _loadTodayVisit();
    });
  }

  void _markSynced() {
    if (!mounted || _syncState == _SyncState.synced) {
      return;
    }

    setState(() {
      _syncState = _SyncState.synced;
      _lastSyncAt = DateTime.now();
    });
  }

  Future<void> _ensureLocationMonitoring(VisitWorkflow visit) async {
    if (visit.checkInTime != null) {
      _arrivalLogged = true;
    }

    if (visit.checkOutTime != null) {
      _departureLogged = true;
      await _positionSubscription?.cancel();
      _positionSubscription = null;
      _setLocationMonitorMessage(
        'Departure has been recorded. Admin alert evidence is available in the audit trail.',
      );
      return;
    }

    if (_monitoredVisitId == visit.id || _locationMonitorStarting) {
      return;
    }

    _monitoredVisitId = visit.id;
    _arrivalLogged = visit.checkInTime != null;
    _departureLogged = visit.checkOutTime != null;

    if (!_hasConfiguredLocation(visit)) {
      _setLocationMonitorMessage(
        'Client geofence is not configured yet. Add client latitude and longitude to enable auto arrival and departure logs.',
      );
      return;
    }

    _locationMonitorStarting = true;
    _setLocationMonitorMessage('Checking device location for this visit.');

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) {
      return;
    }

    if (!serviceEnabled) {
      _locationMonitorStarting = false;
      _setLocationMonitorMessage(
        'Location services are off. Turn them on so arrival and departure can be logged automatically.',
      );
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (!mounted) {
      return;
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _locationMonitorStarting = false;
      _setLocationMonitorMessage(
        'Location permission is required for automatic arrival and departure logging.',
      );
      return;
    }

    final radius = visit.geofenceRadiusMeters ?? 100;
    await _positionSubscription?.cancel();
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: (radius / 4).clamp(10, 50).round(),
          ),
        ).listen((position) {
          _handlePosition(visit: visit, position: position);
        });

    _locationMonitorStarting = false;
    _setLocationMonitorMessage(
      'Monitoring geofence. Arrival and departure will log automatically.',
    );
  }

  Future<void> _handlePosition({
    required VisitWorkflow visit,
    required Position position,
  }) async {
    if (!mounted || !_hasConfiguredLocation(visit)) {
      return;
    }

    final radius = visit.geofenceRadiusMeters ?? 100;
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      visit.clientLatitude!,
      visit.clientLongitude!,
    );

    if (distance <= radius && !_arrivalLogged) {
      _arrivalLogged = true;
      _setLocationMonitorMessage('Inside client geofence. Logging arrival.');
      await _recordLocationEvent(
        visit: visit,
        position: position,
        distance: distance,
        radius: radius,
        type: 'arrived',
      );
      return;
    }

    final canLogDeparture = _arrivalLogged || visit.checkInTime != null;
    if (distance > radius && canLogDeparture && !_departureLogged) {
      _departureLogged = true;
      _setLocationMonitorMessage(
        'Outside client geofence. Logging departure and alerting admin.',
      );
      await _recordLocationEvent(
        visit: visit,
        position: position,
        distance: distance,
        radius: radius,
        type: 'departed',
      );
    }
  }

  Future<void> _recordLocationEvent({
    required VisitWorkflow visit,
    required Position position,
    required double distance,
    required int radius,
    required String type,
  }) async {
    try {
      final updated = await widget.visitWorkflow.recordLocationEvent(
        session: widget.session,
        visitId: visit.id,
        event: VisitLocationEvent(
          type: type,
          latitude: position.latitude,
          longitude: position.longitude,
          accuracyMeters: position.accuracy,
          distanceMeters: distance,
          geofenceRadiusMeters: radius,
          recordedAt: DateTime.now(),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _visit = Future.value(updated);
        _syncState = _SyncState.synced;
        _lastSyncAt = DateTime.now();
        _locationMonitorMessage = type == 'arrived'
            ? 'Arrival logged automatically from device location.'
            : 'Departure logged automatically and admin alert recorded.';
      });
    } on VisitWorkflowException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        if (type == 'arrived') {
          _arrivalLogged = false;
        } else {
          _departureLogged = false;
        }
        _locationMonitorMessage = error.message;
      });
    }
  }

  bool _hasConfiguredLocation(VisitWorkflow visit) {
    return visit.clientLatitude != null && visit.clientLongitude != null;
  }

  void _setLocationMonitorMessage(String message) {
    if (!mounted || _locationMonitorMessage == message) {
      return;
    }

    setState(() {
      _locationMonitorMessage = message;
    });
  }
}

class _VisitLoadErrorPanel extends StatelessWidget {
  const _VisitLoadErrorPanel({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        border: Border.all(color: const Color(0xFF991B1B)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today visit could not be loaded',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text('Check the backend connection and try again.'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyVisitPanel extends StatelessWidget {
  const _EmptyVisitPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('No visit is assigned for today.'),
    );
  }
}

class _BasicCarerTask {
  const _BasicCarerTask({
    required this.id,
    required this.title,
    required this.detail,
    required this.icon,
    this.completedAt,
    this.isAdditional = false,
  });

  final String id;
  final String title;
  final String detail;
  final IconData icon;
  final DateTime? completedAt;
  final bool isAdditional;

  _BasicCarerTask copyWith({
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return _BasicCarerTask(
      id: id,
      title: title,
      detail: detail,
      icon: icon,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      isAdditional: isAdditional,
    );
  }
}

class _BasicCarerTaskCard extends StatelessWidget {
  const _BasicCarerTaskCard({required this.task, required this.onChanged});

  final _BasicCarerTask task;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDone = task.completedAt != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(task.icon, color: const Color(0xFF0F766E)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    color: Color(0xFF17252F),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _TaskStateChip(
                progress: _CareTaskProgress(
                  state: isDone ? _CareTaskState.done : _CareTaskState.pending,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(task.detail),
          const SizedBox(height: 12),
          if (isDone)
            _ClientMeta(
              icon: Icons.schedule_outlined,
              text: 'Done at ${_timeLabel(task.completedAt!)}',
            ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: isDone,
            onChanged: (value) => onChanged(value ?? false),
            title: Text(isDone ? 'Completed' : 'Mark done'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}

class _AdditionalTaskPanel extends StatelessWidget {
  const _AdditionalTaskPanel({
    required this.controller,
    required this.onAddTask,
  });

  final TextEditingController controller;
  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.note_add_outlined, color: Color(0xFF0F766E)),
              const SizedBox(width: 8),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF17252F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Add extra task',
              hintText: 'Task completed or required during this visit',
              prefixIcon: Icon(Icons.edit_note_outlined),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onAddTask(),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onAddTask,
            icon: const Icon(Icons.add_task),
            label: const Text('Add task'),
          ),
        ],
      ),
    );
  }
}

class _HomeTab {
  const _HomeTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _VisitSummary {
  const _VisitSummary({
    required this.clientName,
    required this.timeWindow,
    required this.status,
  });

  factory _VisitSummary.fromScheduledVisit(ScheduledVisit visit) {
    return _VisitSummary(
      clientName: visit.clientName,
      timeWindow: visit.timeWindow,
      status: _effectiveScheduledVisitState(visit, DateTime.now()),
    );
  }

  final String clientName;
  final String timeWindow;
  final _VisitState status;
}

enum _VisitState { scheduled, inProgress, completed, missed }

enum _CareTaskState { pending, done, skipped }

enum _SyncState { synced, pendingSync }

class _CareTaskProgress {
  const _CareTaskProgress({required this.state});

  final _CareTaskState state;
}

class _AuditEvidence {
  const _AuditEvidence({
    required this.action,
    required this.timestamp,
    required this.syncState,
  });

  final String action;
  final String timestamp;
  final _SyncState syncState;
}

extension _SyncStatePresentation on _SyncState {
  String get label {
    switch (this) {
      case _SyncState.synced:
        return 'synced';
      case _SyncState.pendingSync:
        return 'pending_sync';
    }
  }
}

enum _ScheduleMode { agenda, week, month }

extension _ScheduleModePresentation on _ScheduleMode {
  String get label {
    switch (this) {
      case _ScheduleMode.agenda:
        return 'Agenda';
      case _ScheduleMode.week:
        return 'Week';
      case _ScheduleMode.month:
        return 'Month';
    }
  }

  IconData get icon {
    switch (this) {
      case _ScheduleMode.agenda:
        return Icons.table_rows_outlined;
      case _ScheduleMode.week:
        return Icons.view_week_outlined;
      case _ScheduleMode.month:
        return Icons.calendar_month_outlined;
    }
  }
}

extension _VisitStatePresentation on _VisitState {
  String get label {
    switch (this) {
      case _VisitState.scheduled:
        return 'scheduled';
      case _VisitState.inProgress:
        return 'in_progress';
      case _VisitState.completed:
        return 'completed';
      case _VisitState.missed:
        return 'missed';
    }
  }

  Color get foregroundColor {
    switch (this) {
      case _VisitState.completed:
        return const Color(0xFF166534);
      case _VisitState.inProgress:
        return const Color(0xFF854D0E);
      case _VisitState.missed:
        return const Color(0xFF991B1B);
      case _VisitState.scheduled:
        return const Color(0xFF0F766E);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case _VisitState.completed:
        return const Color(0xFFDCFCE7);
      case _VisitState.inProgress:
        return const Color(0xFFFEF3C7);
      case _VisitState.missed:
        return const Color(0xFFFEE2E2);
      case _VisitState.scheduled:
        return const Color(0xFFE0F2F1);
    }
  }

  IconData get icon {
    switch (this) {
      case _VisitState.completed:
        return Icons.check_circle_outline;
      case _VisitState.inProgress:
        return Icons.timelapse_outlined;
      case _VisitState.missed:
        return Icons.error_outline;
      case _VisitState.scheduled:
        return Icons.schedule_outlined;
    }
  }
}

_VisitState _visitStateFromApi(String status) {
  switch (status) {
    case 'in_progress':
      return _VisitState.inProgress;
    case 'completed':
      return _VisitState.completed;
    case 'missed':
      return _VisitState.missed;
    case 'scheduled':
    default:
      return _VisitState.scheduled;
  }
}

_VisitState _effectiveVisitState(VisitWorkflow visit, DateTime now) {
  if (visit.checkOutTime != null) {
    return _VisitState.completed;
  }

  if (visit.checkInTime != null) {
    return _VisitState.inProgress;
  }

  return _effectiveStateFromSchedule(
    status: visit.status,
    scheduledEndAt: visit.scheduledEndAt,
    now: now,
  );
}

_VisitState _effectiveScheduledVisitState(ScheduledVisit visit, DateTime now) {
  return _effectiveStateFromSchedule(
    status: visit.status,
    scheduledEndAt: visit.scheduledEndAt,
    now: now,
  );
}

_VisitState _effectiveStateFromSchedule({
  required String status,
  required DateTime? scheduledEndAt,
  required DateTime now,
}) {
  final apiState = _visitStateFromApi(status);

  if (apiState == _VisitState.scheduled &&
      scheduledEndAt != null &&
      now.isAfter(scheduledEndAt)) {
    return _VisitState.missed;
  }

  return apiState;
}

bool _sameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

List<DateTime> _visibleCalendarDates(DateTime displayedMonth) {
  final firstDay = DateTime(displayedMonth.year, displayedMonth.month);
  final startOffset = firstDay.weekday - DateTime.monday;
  final firstVisibleDay = firstDay.subtract(Duration(days: startOffset));

  return [
    for (var index = 0; index < 42; index++)
      firstVisibleDay.add(Duration(days: index)),
  ];
}

String _monthLabel(DateTime date) {
  return '${_twoDigits(date.month)}/${date.year}';
}

String _shortDateLabel(DateTime date) {
  return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';
}

String _dateTimeLabel(DateTime date) {
  return '${_shortDateLabel(date)} ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
}

String _timeLabel(DateTime date) {
  return '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
}

String _twoDigits(int value) {
  return value.toString().padLeft(2, '0');
}

extension _CareTaskStatePresentation on _CareTaskState {
  String get label {
    switch (this) {
      case _CareTaskState.pending:
        return 'pending';
      case _CareTaskState.done:
        return 'done';
      case _CareTaskState.skipped:
        return 'skipped';
    }
  }
}

class _ScheduleModeSelector extends StatelessWidget {
  const _ScheduleModeSelector({
    required this.selectedMode,
    required this.onModeSelected,
  });

  final _ScheduleMode selectedMode;
  final ValueChanged<_ScheduleMode> onModeSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_ScheduleMode>(
      segments: [
        for (final mode in _ScheduleMode.values)
          ButtonSegment<_ScheduleMode>(
            value: mode,
            icon: Icon(mode.icon),
            label: Text(mode.label),
          ),
      ],
      selected: {selectedMode},
      onSelectionChanged: (selection) {
        onModeSelected(selection.first);
      },
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF0F766E);
          }
          return const Color(0xFF40525A);
        }),
        side: WidgetStateProperty.all(
          const BorderSide(color: Color(0xFFB7C2CA)),
        ),
      ),
    );
  }
}

class _ScheduleWorkflow extends StatefulWidget {
  const _ScheduleWorkflow({
    required this.session,
    required this.visitSchedule,
    required this.selectedMode,
    required this.onModeSelected,
  });

  final CarerSession session;
  final VisitSchedulePort visitSchedule;
  final _ScheduleMode selectedMode;
  final ValueChanged<_ScheduleMode> onModeSelected;

  @override
  State<_ScheduleWorkflow> createState() => _ScheduleWorkflowState();
}

class _ScheduleWorkflowState extends State<_ScheduleWorkflow> {
  late Future<List<ScheduledVisit>> _visits;
  DateTime _displayedMonth = DateTime(2026, 5);
  DateTime _selectedDate = DateTime(2026, 5, 7);
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _visits = widget.visitSchedule.visitsForCarer(widget.session);
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _visits = widget.visitSchedule.visitsForCarer(widget.session);
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ScheduledVisit>>(
      future: _visits,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingPanel(message: 'Loading scheduled visits');
        }

        if (snapshot.hasError) {
          return _VisitScheduleErrorPanel(
            onRetry: () {
              setState(() {
                _visits = widget.visitSchedule.visitsForCarer(widget.session);
              });
            },
          );
        }

        final visits = snapshot.data ?? const [];

        return Column(
          children: [
            _ScheduleCalendar(
              visits: visits,
              displayedMonth: _displayedMonth,
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                  _displayedMonth = DateTime(date.year, date.month);
                });
              },
              onPreviousMonth: () {
                setState(() {
                  _displayedMonth = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month - 1,
                  );
                });
              },
              onNextMonth: () {
                setState(() {
                  _displayedMonth = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month + 1,
                  );
                });
              },
            ),
            const SizedBox(height: 16),
            _SelectedDateVisits(
              date: _selectedDate,
              visits: visits
                  .where((visit) => _sameDate(visit.date, _selectedDate))
                  .toList(),
            ),
            const SizedBox(height: 16),
            _ScheduleModeSelector(
              selectedMode: widget.selectedMode,
              onModeSelected: widget.onModeSelected,
            ),
            const SizedBox(height: 16),
            _ScheduleView(mode: widget.selectedMode, visits: visits),
          ],
        );
      },
    );
  }
}

class _VisitScheduleErrorPanel extends StatelessWidget {
  const _VisitScheduleErrorPanel({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        border: Border.all(color: const Color(0xFF991B1B)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visits could not be loaded',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text('Check the backend connection and try again.'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleView extends StatelessWidget {
  const _ScheduleView({required this.mode, required this.visits});

  final _ScheduleMode mode;
  final List<ScheduledVisit> visits;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case _ScheduleMode.agenda:
        return _AgendaSchedule(visits: visits);
      case _ScheduleMode.week:
        return _CalendarSchedule(
          title: 'Weekly calendar',
          columns: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
          visits: visits,
        );
      case _ScheduleMode.month:
        return _CalendarSchedule(
          title: 'Monthly calendar',
          columns: const ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
          visits: visits,
        );
    }
  }
}

class _ScheduleCalendar extends StatelessWidget {
  const _ScheduleCalendar({
    required this.visits,
    required this.displayedMonth,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  static const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final List<ScheduledVisit> visits;
  final DateTime displayedMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final visibleDates = _visibleCalendarDates(displayedMonth);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  _monthLabel(displayedMonth),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF17252F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: onNextMonth,
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
              for (final dayName in _weekDays)
                Center(
                  child: Text(
                    dayName,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              for (final date in visibleDates)
                _CalendarDayCell(
                  date: date,
                  isCurrentMonth: date.month == displayedMonth.month,
                  isSelected: _sameDate(date, selectedDate),
                  visits: visits
                      .where((visit) => _sameDate(visit.date, date))
                      .toList(),
                  onTap: () => onDateSelected(date),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.date,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.visits,
    required this.onTap,
  });

  final DateTime date;
  final bool isCurrentMonth;
  final bool isSelected;
  final List<ScheduledVisit> visits;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasVisits = visits.isNotEmpty;

    return Semantics(
      label: hasVisits
          ? '${date.day}, ${visits.length} scheduled visits'
          : '${date.day}',
      button: true,
      child: InkWell(
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
              color: isSelected
                  ? const Color(0xFF0F766E)
                  : hasVisits
                  ? const Color(0xFF0F766E)
                  : const Color(0xFFE5EAEE),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 2),
              for (final visit in visits.take(1))
                Flexible(
                  child: Text(
                    visit.clientName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 8, height: 1),
                  ),
                ),
              if (hasVisits)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      for (final visit in visits.take(3))
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(right: 2),
                          decoration: BoxDecoration(
                            color: _effectiveScheduledVisitState(
                              visit,
                              DateTime.now(),
                            ).foregroundColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedDateVisits extends StatelessWidget {
  const _SelectedDateVisits({required this.date, required this.visits});

  final DateTime date;
  final List<ScheduledVisit> visits;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visits on ${_shortDateLabel(date)}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          if (visits.isEmpty)
            const Text('No visits scheduled.')
          else
            for (final visit in visits)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ScheduledVisitSummary(visit: visit),
              ),
        ],
      ),
    );
  }
}

class _AgendaSchedule extends StatelessWidget {
  const _AgendaSchedule({required this.visits});

  final List<ScheduledVisit> visits;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const _AgendaHeader(),
          for (final visit in visits) _AgendaRow(visit: visit),
        ],
      ),
    );
  }
}

class _AgendaHeader extends StatelessWidget {
  const _AgendaHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F9FA),
        border: Border(bottom: BorderSide(color: Color(0xFFD7DEE3))),
      ),
      child: Row(
        children: const [
          Expanded(flex: 2, child: _TableHeaderText('Day')),
          Expanded(flex: 2, child: _TableHeaderText('Time')),
          Expanded(flex: 3, child: _TableHeaderText('Client')),
        ],
      ),
    );
  }
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.visit});

  final ScheduledVisit visit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5EAEE))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(_shortDateLabel(visit.date))),
          Expanded(flex: 2, child: Text(visit.timeWindow)),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.clientName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                _StatusBadge(
                  status: _effectiveScheduledVisitState(visit, DateTime.now()),
                ),
                if (visit.assignedWorkerName != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    visit.assignedWorkerName!,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduledVisitSummary extends StatelessWidget {
  const _ScheduledVisitSummary({required this.visit});

  final ScheduledVisit visit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.event_available_outlined,
          color: _effectiveScheduledVisitState(
            visit,
            DateTime.now(),
          ).foregroundColor,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${visit.timeWindow} - ${visit.clientName}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (visit.assignedWorkerName != null)
                Text(
                  'Carer: ${visit.assignedWorkerName}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
            ],
          ),
        ),
        _StatusBadge(
          status: _effectiveScheduledVisitState(visit, DateTime.now()),
        ),
      ],
    );
  }
}

class _TableHeaderText extends StatelessWidget {
  const _TableHeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.labelMedium);
  }
}

class _CalendarSchedule extends StatelessWidget {
  const _CalendarSchedule({
    required this.title,
    required this.columns,
    required this.visits,
  });

  final String title;
  final List<String> columns;
  final List<ScheduledVisit> visits;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.35,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (var index = 0; index < columns.length; index++)
                _CalendarCell(
                  label: columns[index],
                  visits: visits
                      .where(
                        (visit) =>
                            index == visits.indexOf(visit) % columns.length,
                      )
                      .toList(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({required this.label, required this.visits});

  final String label;
  final List<ScheduledVisit> visits;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FA),
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          for (final visit in visits.take(2))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${visit.timeWindow} ${visit.clientName}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _TodayTimelineWorkflow extends StatefulWidget {
  const _TodayTimelineWorkflow({
    required this.session,
    required this.visitSchedule,
  });

  final CarerSession session;
  final VisitSchedulePort visitSchedule;

  @override
  State<_TodayTimelineWorkflow> createState() => _TodayTimelineWorkflowState();
}

class _TodayTimelineWorkflowState extends State<_TodayTimelineWorkflow> {
  late Future<List<ScheduledVisit>> _visits;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _visits = widget.visitSchedule.visitsForCarer(widget.session);
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _visits = widget.visitSchedule.visitsForCarer(widget.session);
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ScheduledVisit>>(
      future: _visits,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingPanel(message: 'Loading visit timeline');
        }

        if (snapshot.hasError) {
          return _VisitScheduleErrorPanel(
            onRetry: () {
              setState(() {
                _visits = widget.visitSchedule.visitsForCarer(widget.session);
              });
            },
          );
        }

        final today = DateTime.now();
        final visits = (snapshot.data ?? const <ScheduledVisit>[])
            .where((visit) => _sameDate(visit.date, today))
            .map(_VisitSummary.fromScheduledVisit)
            .toList();

        if (visits.isEmpty) {
          return const _EmptyTabPanel(
            icon: Icons.timeline_outlined,
            title: 'No visits today',
            message: 'Today has no assigned visit timeline yet.',
          );
        }

        return _VisitTimeline(visits: visits);
      },
    );
  }
}

class _VisitExecutionPanel extends StatelessWidget {
  const _VisitExecutionPanel({
    required this.visit,
    required this.auditEvidence,
    required this.syncState,
    required this.lastSyncAt,
    required this.locationMonitorMessage,
    required this.hasConfiguredLocation,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  final VisitWorkflow visit;
  final List<_AuditEvidence> auditEvidence;
  final _SyncState syncState;
  final DateTime? lastSyncAt;
  final String? locationMonitorMessage;
  final bool hasConfiguredLocation;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  @override
  Widget build(BuildContext context) {
    final checkInTime = visit.checkInTime;
    final checkOutTime = visit.checkOutTime;
    final currentVisitState = _effectiveVisitState(visit, DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB7C2CA)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OfflineSyncBanner(syncState: syncState, lastSyncAt: lastSyncAt),
          const Divider(height: 1, color: Color(0xFFD7DEE3)),
          _LocationAutomationBanner(
            hasConfiguredLocation: hasConfiguredLocation,
            message: locationMonitorMessage,
          ),
          const Divider(height: 1, color: Color(0xFFD7DEE3)),
          _VisitHeader(visit: visit, status: currentVisitState),
          const Divider(height: 1, color: Color(0xFFD7DEE3)),
          _VisitActions(
            checkInTime: checkInTime,
            checkOutTime: checkOutTime,
            isMissed: currentVisitState == _VisitState.missed,
            onCheckIn: onCheckIn,
            onCheckOut: onCheckOut,
          ),
          const Divider(height: 1, color: Color(0xFFD7DEE3)),
          const _VisitObservationPanel(),
          const Divider(height: 1, color: Color(0xFFD7DEE3)),
          const _VisitVitalsPanel(),
          const Divider(height: 1, color: Color(0xFFD7DEE3)),
          _AuditEvidencePanel(
            checkInTime: checkInTime,
            checkOutTime: checkOutTime,
            auditEvidence: auditEvidence,
          ),
        ],
      ),
    );
  }
}

class _VisitHeader extends StatelessWidget {
  const _VisitHeader({required this.visit, required this.status});

  final VisitWorkflow visit;
  final _VisitState status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  visit.clientName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF17252F),
                  ),
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 12),
          if (visit.address != null)
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _VisitMeta(
                  icon: Icons.map_outlined,
                  text: visit.address!,
                ),
              ),
            ),
          if (visit.address != null) const SizedBox(height: 8),
          _VisitMeta(icon: Icons.access_time, text: visit.timeWindow),
        ],
      ),
    );
  }
}

class _OfflineSyncBanner extends StatelessWidget {
  const _OfflineSyncBanner({required this.syncState, required this.lastSyncAt});

  final _SyncState syncState;
  final DateTime? lastSyncAt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _InfoBanner(
        icon: syncState == _SyncState.synced
            ? Icons.cloud_done_outlined
            : Icons.cloud_sync_outlined,
        title: 'Sync status: ${syncState.label}',
        message: lastSyncAt == null
            ? 'Waiting for first backend sync. Actions are queued locally if internet drops.'
            : 'Last synced ${_dateTimeLabel(lastSyncAt!)}. Actions are queued locally if internet drops.',
      ),
    );
  }
}

class _LocationAutomationBanner extends StatelessWidget {
  const _LocationAutomationBanner({
    required this.hasConfiguredLocation,
    required this.message,
  });

  final bool hasConfiguredLocation;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final toneColor = hasConfiguredLocation
        ? const Color(0xFF0F766E)
        : const Color(0xFFB45309);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasConfiguredLocation
              ? const Color(0xFFEFFCF8)
              : const Color(0xFFFFFBEB),
          border: Border.all(
            color: hasConfiguredLocation
                ? const Color(0xFF99D6C8)
                : const Color(0xFFFCD34D),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              hasConfiguredLocation
                  ? Icons.location_searching
                  : Icons.location_disabled_outlined,
              color: toneColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Automatic location logs',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF17252F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message ??
                        'The app will auto-log arrival and departure when the configured client geofence is available.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF425466),
                      height: 1.35,
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

class _VisitActions extends StatelessWidget {
  const _VisitActions({
    required this.checkInTime,
    required this.checkOutTime,
    required this.isMissed,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  final String? checkInTime;
  final String? checkOutTime;
  final bool isMissed;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Visit actions'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: checkInTime == null && !isMissed ? onCheckIn : null,
            icon: const Icon(Icons.login),
            label: Text(
              checkInTime == null ? 'Check In' : 'Checked in $checkInTime',
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: isMissed || checkInTime == null || checkOutTime != null
                ? null
                : onCheckOut,
            icon: const Icon(Icons.logout),
            label: Text(
              checkOutTime == null ? 'Check Out' : 'Checked out $checkOutTime',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF17252F),
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: Color(0xFFB7C2CA)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isMissed
                ? 'Visit window has passed. The backend will log this visit as missed and alert admin.'
                : 'Timestamp recorded. GPS can be attached when device location is available.',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _VisitObservationPanel extends StatelessWidget {
  const _VisitObservationPanel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: _ObservationsSection(),
    );
  }
}

class _VisitVitalsPanel extends StatelessWidget {
  const _VisitVitalsPanel();

  @override
  Widget build(BuildContext context) {
    return const Padding(padding: EdgeInsets.all(16), child: _VitalsWorkflow());
  }
}

class _VitalsWorkflow extends StatefulWidget {
  const _VitalsWorkflow();

  @override
  State<_VitalsWorkflow> createState() => _VitalsWorkflowState();
}

class _VitalsWorkflowState extends State<_VitalsWorkflow> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _pulseController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _oxygenController = TextEditingController();
  DateTime? _recordedAt;

  static final _wholeNumberFormatter = FilteringTextInputFormatter.digitsOnly;
  static final _decimalFormatter = _OneDecimalTextInputFormatter();

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    _temperatureController.dispose();
    _oxygenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _InfoBanner(
              icon: Icons.monitor_heart_outlined,
              title: 'Record current vitals',
              message:
                  'Enter numeric readings only. Save after checking the values against the client condition.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _VitalNumberField(
                    controller: _systolicController,
                    label: 'BP systolic',
                    suffix: 'mmHg',
                    icon: Icons.favorite_border,
                    inputFormatters: [_wholeNumberFormatter],
                    validator: (value) => _rangeValidator(
                      value,
                      label: 'BP systolic',
                      min: 70,
                      max: 250,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '/',
                    style: TextStyle(
                      color: Color(0xFF17252F),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: _VitalNumberField(
                    controller: _diastolicController,
                    label: 'BP diastolic',
                    suffix: 'mmHg',
                    icon: Icons.favorite_border,
                    inputFormatters: [_wholeNumberFormatter],
                    validator: (value) => _rangeValidator(
                      value,
                      label: 'BP diastolic',
                      min: 40,
                      max: 150,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _VitalNumberField(
              controller: _pulseController,
              label: 'Pulse',
              suffix: 'bpm',
              icon: Icons.monitor_heart_outlined,
              inputFormatters: [_wholeNumberFormatter],
              validator: (value) =>
                  _rangeValidator(value, label: 'Pulse', min: 30, max: 220),
            ),
            const SizedBox(height: 12),
            _VitalNumberField(
              controller: _temperatureController,
              label: 'Temperature',
              suffix: 'C',
              icon: Icons.thermostat_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [_decimalFormatter],
              validator: (value) => _rangeValidator(
                value,
                label: 'Temperature',
                min: 30,
                max: 45,
              ),
            ),
            const SizedBox(height: 12),
            _VitalNumberField(
              controller: _oxygenController,
              label: 'Blood oxygen',
              suffix: '%',
              icon: Icons.air_outlined,
              inputFormatters: [_wholeNumberFormatter],
              validator: (value) => _rangeValidator(
                value,
                label: 'Blood oxygen',
                min: 50,
                max: 100,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _saveVitals,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save vitals'),
            ),
            if (_recordedAt != null) ...[
              const SizedBox(height: 12),
              _ClientMeta(
                icon: Icons.schedule_outlined,
                text: 'Vitals recorded at ${_timeLabel(_recordedAt!)}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _rangeValidator(
    String? value, {
    required String label,
    required num min,
    required num max,
  }) {
    final reading = num.tryParse(value ?? '');
    if (reading == null) {
      return 'Enter $label.';
    }

    if (reading < min || reading > max) {
      return '$label must be $min-$max.';
    }

    return null;
  }

  void _saveVitals() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _recordedAt = DateTime.now());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vitals recorded at ${_timeLabel(_recordedAt!)}')),
    );
  }
}

class _VitalNumberField extends StatelessWidget {
  const _VitalNumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.icon,
    required this.inputFormatters,
    required this.validator,
    this.keyboardType = TextInputType.number,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}

class _OneDecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final buffer = StringBuffer();
    var hasDecimal = false;
    var decimalPlaces = 0;

    for (final rune in newValue.text.runes) {
      final character = String.fromCharCode(rune);
      if (_isDigit(character)) {
        if (hasDecimal) {
          if (decimalPlaces >= 1) {
            continue;
          }
          decimalPlaces++;
        }
        buffer.write(character);
      } else if (character == '.' && !hasDecimal && buffer.isNotEmpty) {
        hasDecimal = true;
        buffer.write(character);
      }
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  bool _isDigit(String value) {
    return value.codeUnitAt(0) >= 48 && value.codeUnitAt(0) <= 57;
  }
}

class _CareSection extends StatelessWidget {
  const _CareSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FA),
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _TaskStateChip extends StatelessWidget {
  const _TaskStateChip({required this.progress});

  final _CareTaskProgress progress;

  @override
  Widget build(BuildContext context) {
    final isDone = progress.state == _CareTaskState.done;
    final isSkipped = progress.state == _CareTaskState.skipped;
    final color = isDone
        ? const Color(0xFF166534)
        : isSkipped
        ? const Color(0xFF854D0E)
        : const Color(0xFF40525A);
    final background = isDone
        ? const Color(0xFFDCFCE7)
        : isSkipped
        ? const Color(0xFFFEF3C7)
        : const Color(0xFFE5EAEE);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        progress.state.label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ObservationsSection extends StatefulWidget {
  const _ObservationsSection();

  @override
  State<_ObservationsSection> createState() => _ObservationsSectionState();
}

class _ObservationsSectionState extends State<_ObservationsSection> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedPhoto;

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final photo = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (!mounted || photo == null) {
        return;
      }

      setState(() => _selectedPhoto = photo);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Photo attached: ${photo.name}')));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Photo could not be attached. Check device permissions.',
          ),
        ),
      );
    }
  }

  Future<void> _showPhotoOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Take photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickPhoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from library'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickPhoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _CareSection(
      title: 'Observations',
      children: [
        TextField(
          minLines: 3,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Notes',
            hintText: 'Record visit notes',
            prefixIcon: const Icon(Icons.notes_outlined),
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedPhoto != null) ...[
          _AttachedPhotoSummary(photo: _selectedPhoto!),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: _showPhotoOptions,
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(
            _selectedPhoto == null ? 'Upload photo' : 'Replace photo',
          ),
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            foregroundColor: const Color(0xFF17252F),
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: Color(0xFFB7C2CA)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _AttachedPhotoSummary extends StatelessWidget {
  const _AttachedPhotoSummary({required this.photo});

  final XFile photo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        border: Border.all(color: const Color(0xFF0F766E)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file, color: Color(0xFF0F766E)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              photo.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditEvidencePanel extends StatelessWidget {
  const _AuditEvidencePanel({
    required this.checkInTime,
    required this.checkOutTime,
    required this.auditEvidence,
  });

  final String? checkInTime;
  final String? checkOutTime;
  final List<_AuditEvidence> auditEvidence;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ...auditEvidence,
      if (checkInTime != null)
        _AuditEvidence(
          action: 'Check In recorded',
          timestamp: checkInTime!,
          syncState: _SyncState.pendingSync,
        ),
      if (checkOutTime != null)
        _AuditEvidence(
          action: 'Check Out recorded',
          timestamp: checkOutTime!,
          syncState: _SyncState.pendingSync,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Audit evidence'),
          const SizedBox(height: 12),
          for (final row in rows) _AuditEvidenceRow(evidence: row),
          const SizedBox(height: 12),
          const _SignaturePrompt(),
        ],
      ),
    );
  }
}

class _AuditEvidenceRow extends StatelessWidget {
  const _AuditEvidenceRow({required this.evidence});

  final _AuditEvidence evidence;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.fact_check_outlined, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evidence.action,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${evidence.timestamp} - ${evidence.syncState.label}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignaturePrompt extends StatefulWidget {
  const _SignaturePrompt();

  @override
  State<_SignaturePrompt> createState() => _SignaturePromptState();
}

class _SignaturePromptState extends State<_SignaturePrompt> {
  String? _capturedAt;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _captureSignature,
      icon: Icon(_capturedAt == null ? Icons.draw_outlined : Icons.verified),
      label: Text(
        _capturedAt == null
            ? 'Capture signature'
            : 'Signature captured $_capturedAt',
      ),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        foregroundColor: const Color(0xFF17252F),
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: Color(0xFFB7C2CA)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _captureSignature() async {
    final captured = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _SignatureCaptureSheet(),
    );

    if (!mounted || captured != true) {
      return;
    }

    final now = DateTime.now();
    setState(() {
      _capturedAt = '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signature captured at $_capturedAt')),
    );
  }
}

class _SignatureCaptureSheet extends StatefulWidget {
  const _SignatureCaptureSheet();

  @override
  State<_SignatureCaptureSheet> createState() => _SignatureCaptureSheetState();
}

class _SignatureCaptureSheetState extends State<_SignatureCaptureSheet> {
  final List<List<Offset>> _strokes = [];

  bool get _hasSignature => _strokes.any((stroke) => stroke.length > 1);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capture signature',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF17252F),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FA),
                border: Border.all(color: const Color(0xFFB7C2CA)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _strokes.add([details.localPosition]);
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      if (_strokes.isEmpty) {
                        _strokes.add([]);
                      }
                      _strokes.last.add(details.localPosition);
                    });
                  },
                  child: CustomPaint(
                    painter: _SignaturePainter(strokes: _strokes),
                    child: const SizedBox.expand(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text('Sign inside this box'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _strokes.isEmpty
                        ? null
                        : () {
                            setState(_strokes.clear);
                          },
                    icon: const Icon(Icons.backspace_outlined),
                    label: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _hasSignature
                        ? () => Navigator.of(context).pop(true)
                        : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Save signature'),
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

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter({required this.strokes});

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF17252F)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3;

    for (final stroke in strokes) {
      for (var index = 0; index < stroke.length - 1; index++) {
        canvas.drawLine(stroke[index], stroke[index + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.strokes != strokes;
  }
}

class _VisitAlerts extends StatefulWidget {
  const _VisitAlerts({required this.session, required this.visitWorkflow});

  final CarerSession session;
  final VisitWorkflowPort visitWorkflow;

  @override
  State<_VisitAlerts> createState() => _VisitAlertsState();
}

class _VisitAlertsState extends State<_VisitAlerts> {
  late Future<VisitWorkflow?> _todayVisit;

  @override
  void initState() {
    super.initState();
    _todayVisit = widget.visitWorkflow.todayVisitForCarer(widget.session);
  }

  @override
  void didUpdateWidget(covariant _VisitAlerts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session != widget.session ||
        oldWidget.visitWorkflow != widget.visitWorkflow) {
      _todayVisit = widget.visitWorkflow.todayVisitForCarer(widget.session);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Alerts'),
          const SizedBox(height: 12),
          FutureBuilder<VisitWorkflow?>(
            future: _todayVisit,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const _InfoBanner(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Client safety details',
                  message:
                      'Loading client-specific allergies and critical information.',
                );
              }

              if (snapshot.hasError) {
                return const _AlertBanner(
                  icon: Icons.warning_amber_outlined,
                  title: 'Client safety details unavailable',
                  message:
                      'Client-specific allergies and critical information could not be loaded. Confirm the current care plan before care delivery.',
                );
              }

              final visit = snapshot.data;
              if (visit == null) {
                return const _InfoBanner(
                  icon: Icons.event_available_outlined,
                  title: 'No assigned visit',
                  message:
                      'Client-specific alerts will appear when a current assigned visit is available.',
                );
              }

              return Column(
                children: [
                  _AlertBanner(
                    icon: Icons.warning_amber_outlined,
                    title: 'Allergies - ${visit.clientName}',
                    message:
                        visit.allergies ??
                        'No allergy information was returned for ${visit.clientName}. Confirm the current care plan before medication support.',
                  ),
                  const SizedBox(height: 8),
                  _AlertBanner(
                    icon: Icons.priority_high_outlined,
                    title: 'Critical notes - ${visit.clientName}',
                    message:
                        visit.criticalInformation ??
                        'No critical information was returned for ${visit.clientName}. Review the care plan and escalate uncertainty before proceeding.',
                    isCritical: true,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          const _SectionHeader(title: 'Exception actions'),
          const SizedBox(height: 12),
          _ExceptionActionButton(
            icon: Icons.access_time_filled_outlined,
            label: 'Mark visit late',
            onPressed: () => _submitExceptionReport(
              context,
              category: 'Late visit',
              severity: 'Warning',
              defaultNotes: 'Visit is running late. Admin follow-up required.',
            ),
          ),
          const SizedBox(height: 8),
          _ExceptionActionButton(
            icon: Icons.medication_liquid_outlined,
            label: 'Report missed medication',
            onPressed: () => _submitExceptionReport(
              context,
              category: 'Medication concern',
              severity: 'Critical',
              defaultNotes:
                  'Medication was not administered. Review MAR and escalate.',
            ),
          ),
          const SizedBox(height: 8),
          _ExceptionActionButton(
            icon: Icons.home_outlined,
            label: 'Client not home',
            onPressed: () => _submitExceptionReport(
              context,
              category: 'Client not home',
              severity: 'Warning',
              defaultNotes: 'Client was not home at the scheduled visit time.',
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => _submitExceptionReport(
              context,
              category: 'Emergency escalation',
              severity: 'Critical',
              defaultNotes:
                  'Emergency escalation started. Immediate admin response required.',
            ),
            icon: const Icon(Icons.emergency_outlined),
            label: const Text('Emergency escalation'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitExceptionReport(
    BuildContext context, {
    required String category,
    required String severity,
    required String defaultNotes,
  }) async {
    final report = await showModalBottomSheet<IssueReport>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ReportIssueSheet(
        initialCategory: category,
        initialSeverity: severity,
        initialNotes: defaultNotes,
      ),
    );

    if (!context.mounted || report == null) {
      return;
    }

    try {
      final receipt = await widget.visitWorkflow.reportIssue(
        session: widget.session,
        issue: report,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${report.category} sent to admin at ${receipt.reportedAt}',
          ),
        ),
      );
    } on VisitWorkflowException catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({
    required this.icon,
    required this.title,
    required this.message,
    this.isCritical = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool isCritical;

  @override
  Widget build(BuildContext context) {
    final background = isCritical
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFFEF3C7);
    final borderColor = isCritical
        ? const Color(0xFFDC2626)
        : const Color(0xFFF59E0B);
    final iconColor = isCritical
        ? const Color(0xFF991B1B)
        : const Color(0xFF854D0E);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF17252F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExceptionActionButton extends StatelessWidget {
  const _ExceptionActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        foregroundColor: const Color(0xFF17252F),
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: Color(0xFFB7C2CA)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        border: Border.all(color: const Color(0xFF0F766E)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0F766E)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF17252F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitTimeline extends StatelessWidget {
  const _VisitTimeline({required this.visits});

  final List<_VisitSummary> visits;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          for (var index = 0; index < visits.length; index++)
            _TimelineVisitRow(
              visit: visits[index],
              isLast: index == visits.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineVisitRow extends StatelessWidget {
  const _TimelineVisitRow({required this.visit, required this.isLast});

  final _VisitSummary visit;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final statusColor = visit.status.foregroundColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: const Color(0xFFD7DEE3)),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.timeWindow,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      visit.clientName,
                      style: const TextStyle(
                        color: Color(0xFF17252F),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _StatusBadge(status: visit.status),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.session, required this.visitWorkflow});

  final CarerSession session;
  final VisitWorkflowPort visitWorkflow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _QuickActionButton(
          icon: Icons.report_problem_outlined,
          label: 'Report issue',
          onPressed: () => _showReportIssueSheet(context),
        ),
      ],
    );
  }

  Future<void> _showReportIssueSheet(BuildContext context) async {
    final result = await showModalBottomSheet<IssueReport>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _ReportIssueSheet(),
    );

    if (!context.mounted || result == null) {
      return;
    }

    try {
      final receipt = await visitWorkflow.reportIssue(
        session: session,
        issue: result,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result.severity} issue sent to admin at ${receipt.reportedAt}',
          ),
        ),
      );
    } on VisitWorkflowException catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        foregroundColor: const Color(0xFF17252F),
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: Color(0xFFB7C2CA)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _ReportIssueSheet extends StatefulWidget {
  const _ReportIssueSheet({
    this.initialCategory = 'Client not home',
    this.initialSeverity = 'Warning',
    this.initialNotes,
  });

  final String initialCategory;
  final String initialSeverity;
  final String? initialNotes;

  @override
  State<_ReportIssueSheet> createState() => _ReportIssueSheetState();
}

class _ReportIssueSheetState extends State<_ReportIssueSheet> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  late String _category;
  late String _severity;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _severity = widget.initialSeverity;
    _notesController.text = widget.initialNotes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report issue',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF17252F),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Issue type'),
                items: const [
                  DropdownMenuItem(
                    value: 'Late visit',
                    child: Text('Late visit'),
                  ),
                  DropdownMenuItem(
                    value: 'Client not home',
                    child: Text('Client not home'),
                  ),
                  DropdownMenuItem(
                    value: 'Medication concern',
                    child: Text('Medication concern'),
                  ),
                  DropdownMenuItem(
                    value: 'Safeguarding concern',
                    child: Text('Safeguarding concern'),
                  ),
                  DropdownMenuItem(
                    value: 'Emergency escalation',
                    child: Text('Emergency escalation'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _severity,
                decoration: const InputDecoration(labelText: 'Severity'),
                items: const [
                  DropdownMenuItem(value: 'Info', child: Text('Info')),
                  DropdownMenuItem(value: 'Warning', child: Text('Warning')),
                  DropdownMenuItem(value: 'Critical', child: Text('Critical')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _severity = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'What happened and what action is needed?',
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 6) {
                    return 'Add a short issue note.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  Navigator.of(context).pop(
                    IssueReport(
                      category: _category,
                      severity: _severity,
                      notes: _notesController.text.trim(),
                      reportedAt: DateTime.now(),
                    ),
                  );
                },
                icon: const Icon(Icons.outgoing_mail),
                label: const Text('Queue issue report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: const Color(0xFF17252F),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final _VisitState status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 16, color: status.foregroundColor),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: status.foregroundColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitMeta extends StatelessWidget {
  const _VisitMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF5E6C76)),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.carerName,
    required this.email,
    required this.homeName,
    required this.jobTitle,
    required this.status,
    required this.onChangePassword,
  });

  final String carerName;
  final String email;
  final String? homeName;
  final String? jobTitle;
  final String status;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusRow(
            icon: Icons.person_outline,
            label: 'Carer',
            value: carerName,
          ),
          _StatusRow(
            icon: Icons.verified_user_outlined,
            label: 'Access state',
            value: status,
          ),
          _StatusRow(icon: Icons.alternate_email, label: 'Email', value: email),
          _StatusRow(
            icon: Icons.home_work_outlined,
            label: 'Home',
            value: homeName ?? 'Not assigned',
          ),
          _StatusRow(
            icon: Icons.badge_outlined,
            label: 'Role',
            value: jobTitle ?? 'Carer',
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onChangePassword,
            icon: const Icon(Icons.lock_reset),
            label: const Text('Change password'),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              foregroundColor: const Color(0xFF17252F),
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: Color(0xFFB7C2CA)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordChangeRequest {
  const _PasswordChangeRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _obscurePasswords = true;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change password',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF17252F),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _currentPassword,
                obscureText: _obscurePasswords,
                decoration: const InputDecoration(
                  labelText: 'Current password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: _requiredPassword,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newPassword,
                obscureText: _obscurePasswords,
                decoration: const InputDecoration(
                  labelText: 'New password',
                  prefixIcon: Icon(Icons.password),
                ),
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Use at least 8 characters.';
                  }

                  if (!RegExp(r'[A-Z]').hasMatch(value) ||
                      !RegExp(r'[a-z]').hasMatch(value) ||
                      !RegExp(r'\d').hasMatch(value)) {
                    return 'Use upper, lower case letters and a number.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPassword,
                obscureText: _obscurePasswords,
                decoration: const InputDecoration(
                  labelText: 'Confirm new password',
                  prefixIcon: Icon(Icons.lock_reset),
                ),
                validator: (value) {
                  if (value != _newPassword.text) {
                    return 'Passwords do not match.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: !_obscurePasswords,
                onChanged: (value) {
                  setState(() => _obscurePasswords = !(value ?? false));
                },
                title: const Text('Show passwords'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  Navigator.of(context).pop(
                    _PasswordChangeRequest(
                      currentPassword: _currentPassword.text,
                      newPassword: _newPassword.text,
                      newPasswordConfirmation: _confirmPassword.text,
                    ),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Save new password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your current password.';
    }

    return null;
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
