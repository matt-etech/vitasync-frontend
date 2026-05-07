import 'package:flutter/material.dart';

import '../models/care_client.dart';
import '../models/care_plan_task.dart';
import '../models/carer_session.dart';
import '../models/scheduled_visit.dart';
import '../models/visit_workflow.dart';
import '../services/care_plan_task_contract.dart';
import '../services/client_directory_contract.dart';
import '../services/visit_schedule_contract.dart';
import '../services/visit_workflow_contract.dart';

class CarerHomeScreen extends StatefulWidget {
  const CarerHomeScreen({
    required this.session,
    required this.clientDirectory,
    required this.carePlanTasks,
    required this.visitSchedule,
    required this.visitWorkflow,
    required this.onLogout,
    super.key,
  });

  final CarerSession session;
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
  final Map<String, _CareTaskProgress> _careTaskProgress = {};
  final List<_AuditEvidence> _auditEvidence = const [
    _AuditEvidence(
      action: 'Visit loaded for carer',
      timestamp: '09:20',
      syncState: _SyncState.synced,
    ),
  ];

  static const _timelineVisits = [
    _VisitSummary(
      clientName: 'Arthur Brown',
      timeWindow: '07:45 - 08:30',
      status: _VisitState.completed,
    ),
    _VisitSummary(
      clientName: 'Margaret Lewis',
      timeWindow: '09:30 - 10:15',
      status: _VisitState.inProgress,
    ),
    _VisitSummary(
      clientName: 'Nadia Patel',
      timeWindow: '10:30 - 11:00',
      status: _VisitState.missed,
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
            careTaskProgress: _careTaskProgress,
            auditEvidence: _auditEvidence,
            onCareTaskDoneChanged: (taskId, isDone) {
              setState(() {
                if (isDone) {
                  _careTaskProgress[taskId] = const _CareTaskProgress(
                    state: _CareTaskState.done,
                  );
                } else {
                  _careTaskProgress.remove(taskId);
                }
              });
            },
            onCareTaskSkipped: (taskId, reason) {
              setState(() {
                _careTaskProgress[taskId] = _CareTaskProgress(
                  state: _CareTaskState.skipped,
                  skippedReason: reason,
                );
              });
            },
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Timeline'),
          const SizedBox(height: 12),
          const _VisitTimeline(visits: _timelineVisits),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Quick actions'),
          const SizedBox(height: 12),
          const _QuickActions(),
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
            'Care plan tasks',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _CarePlanTasksWorkflow(
            session: widget.session,
            carePlanTasks: widget.carePlanTasks,
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

        return Column(
          children: [
            for (final client in clients) _ClientDirectoryCard(client: client),
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
  const _ClientDirectoryCard({required this.client});

  final CareClient client;

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
            onPressed: () {},
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

class _CarePlanTasksWorkflow extends StatefulWidget {
  const _CarePlanTasksWorkflow({
    required this.session,
    required this.carePlanTasks,
  });

  final CarerSession session;
  final CarePlanTaskPort carePlanTasks;

  @override
  State<_CarePlanTasksWorkflow> createState() => _CarePlanTasksWorkflowState();
}

class _CarePlanTasksWorkflowState extends State<_CarePlanTasksWorkflow> {
  late Future<List<CarePlanTask>> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = widget.carePlanTasks.tasksForCarer(widget.session);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CarePlanTask>>(
      future: _tasks,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingPanel(message: 'Loading care plan tasks');
        }

        if (snapshot.hasError) {
          return _TaskLoadErrorPanel(
            onRetry: () {
              setState(() {
                _tasks = widget.carePlanTasks.tasksForCarer(widget.session);
              });
            },
          );
        }

        final tasks = snapshot.data ?? const [];

        if (tasks.isEmpty) {
          return const _EmptyTaskPanel();
        }

        return Column(
          children: [
            for (final task in tasks) _CarePlanTaskCard(task: task),
            const _VisitAlerts(),
          ],
        );
      },
    );
  }
}

class _TodayVisitWorkflow extends StatefulWidget {
  const _TodayVisitWorkflow({
    required this.session,
    required this.visitWorkflow,
    required this.careTaskProgress,
    required this.auditEvidence,
    required this.onCareTaskDoneChanged,
    required this.onCareTaskSkipped,
  });

  final CarerSession session;
  final VisitWorkflowPort visitWorkflow;
  final Map<String, _CareTaskProgress> careTaskProgress;
  final List<_AuditEvidence> auditEvidence;
  final void Function(String taskId, bool isDone) onCareTaskDoneChanged;
  final void Function(String taskId, String reason) onCareTaskSkipped;

  @override
  State<_TodayVisitWorkflow> createState() => _TodayVisitWorkflowState();
}

class _TodayVisitWorkflowState extends State<_TodayVisitWorkflow> {
  late Future<VisitWorkflow?> _visit;

  @override
  void initState() {
    super.initState();
    _visit = widget.visitWorkflow.todayVisitForCarer(widget.session);
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
                _visit = widget.visitWorkflow.todayVisitForCarer(
                  widget.session,
                );
              });
            },
          );
        }

        final visit = snapshot.data;

        if (visit == null) {
          return const _EmptyVisitPanel();
        }

        return _VisitExecutionPanel(
          visit: visit,
          careTaskProgress: widget.careTaskProgress,
          auditEvidence: widget.auditEvidence,
          onCheckIn: () async {
            final updated = await widget.visitWorkflow.checkIn(
              session: widget.session,
              visitId: visit.id,
            );
            setState(() {
              _visit = Future.value(updated);
            });
          },
          onCheckOut: () async {
            final updated = await widget.visitWorkflow.checkOut(
              session: widget.session,
              visitId: visit.id,
            );
            setState(() {
              _visit = Future.value(updated);
            });
          },
          onCareTaskDoneChanged: widget.onCareTaskDoneChanged,
          onCareTaskSkipped: widget.onCareTaskSkipped,
        );
      },
    );
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

class _TaskLoadErrorPanel extends StatelessWidget {
  const _TaskLoadErrorPanel({required this.onRetry});

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
            'Care plan tasks could not be loaded',
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

class _EmptyTaskPanel extends StatelessWidget {
  const _EmptyTaskPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('No active care plan tasks are available.'),
    );
  }
}

class _CarePlanTaskCard extends StatelessWidget {
  const _CarePlanTaskCard({required this.task});

  final CarePlanTask task;

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
                  state: _careTaskStateFromApi(task.status),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(task.instructions),
          const SizedBox(height: 12),
          _ClientMeta(icon: Icons.person_outline, text: task.clientName),
          _ClientMeta(icon: Icons.article_outlined, text: task.carePlanTitle),
          _ClientMeta(icon: Icons.category_outlined, text: task.section),
          if (task.riskLevel != null)
            _ClientMeta(
              icon: Icons.warning_amber_outlined,
              text: 'Risk: ${task.riskLevel}',
            ),
        ],
      ),
    );
  }

  _CareTaskState _careTaskStateFromApi(String status) {
    switch (status) {
      case 'done':
        return _CareTaskState.done;
      case 'skipped':
        return _CareTaskState.skipped;
      case 'pending':
      default:
        return _CareTaskState.pending;
    }
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

  final String clientName;
  final String timeWindow;
  final _VisitState status;
}

enum _VisitState { scheduled, inProgress, completed, missed }

enum _CareTaskState { pending, done, skipped }

enum _SyncState { synced, pendingSync }

class _CareTaskProgress {
  const _CareTaskProgress({required this.state, this.skippedReason});

  final _CareTaskState state;
  final String? skippedReason;
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
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${months[date.month - 1]} ${date.year}';
}

String _shortDateLabel(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
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

  @override
  void initState() {
    super.initState();
    _visits = widget.visitSchedule.visitsForCarer(widget.session);
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
                Text(
                  visit.clientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9),
                ),
              const Spacer(),
              if (hasVisits)
                Row(
                  children: [
                    for (final visit in visits.take(3))
                      Container(
                        width: 6,
                        height: 5,
                        margin: const EdgeInsets.only(right: 2),
                        decoration: BoxDecoration(
                          color: _visitStateFromApi(
                            visit.status,
                          ).foregroundColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
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
          Expanded(flex: 2, child: Text(visit.dayLabel)),
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
                _StatusBadge(status: _visitStateFromApi(visit.status)),
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
          color: _visitStateFromApi(visit.status).foregroundColor,
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
        _StatusBadge(status: _visitStateFromApi(visit.status)),
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

class _VisitExecutionPanel extends StatelessWidget {
  const _VisitExecutionPanel({
    required this.visit,
    required this.careTaskProgress,
    required this.auditEvidence,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onCareTaskDoneChanged,
    required this.onCareTaskSkipped,
  });

  final VisitWorkflow visit;
  final Map<String, _CareTaskProgress> careTaskProgress;
  final List<_AuditEvidence> auditEvidence;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final void Function(String taskId, bool isDone) onCareTaskDoneChanged;
  final void Function(String taskId, String reason) onCareTaskSkipped;

  @override
  Widget build(BuildContext context) {
    final checkInTime = visit.checkInTime;
    final checkOutTime = visit.checkOutTime;
    final currentVisitState = checkOutTime != null
        ? _VisitState.completed
        : checkInTime != null
        ? _VisitState.inProgress
        : _visitStateFromApi(visit.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB7C2CA)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _OfflineSyncBanner(),
          const Divider(height: 1, color: Color(0xFFD7DEE3)),
          _VisitHeader(visit: visit, status: currentVisitState),
          const Divider(height: 1, color: Color(0xFFD7DEE3)),
          _VisitActions(
            checkInTime: checkInTime,
            checkOutTime: checkOutTime,
            onCheckIn: onCheckIn,
            onCheckOut: onCheckOut,
          ),
          const Divider(height: 1, color: Color(0xFFD7DEE3)),
          _CarePlanChecklist(
            carePlanTasks: visit.tasks,
            careTaskProgress: careTaskProgress,
            onCareTaskDoneChanged: onCareTaskDoneChanged,
            onCareTaskSkipped: onCareTaskSkipped,
          ),
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
  const _OfflineSyncBanner();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: _InfoBanner(
        icon: Icons.cloud_off_outlined,
        title: 'Offline ready',
        message:
            'Actions are saved locally and queued for sync if internet drops.',
      ),
    );
  }
}

class _VisitActions extends StatelessWidget {
  const _VisitActions({
    required this.checkInTime,
    required this.checkOutTime,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  final String? checkInTime;
  final String? checkOutTime;
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
            onPressed: checkInTime == null ? onCheckIn : null,
            icon: const Icon(Icons.login),
            label: Text(
              checkInTime == null ? 'Check In' : 'Checked in $checkInTime',
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: checkInTime == null || checkOutTime != null
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
            'Timestamp recorded. GPS can be attached when device location is available.',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _CarePlanChecklist extends StatelessWidget {
  const _CarePlanChecklist({
    required this.carePlanTasks,
    required this.careTaskProgress,
    required this.onCareTaskDoneChanged,
    required this.onCareTaskSkipped,
  });

  final List<CarePlanTask> carePlanTasks;
  final Map<String, _CareTaskProgress> careTaskProgress;
  final void Function(String taskId, bool isDone) onCareTaskDoneChanged;
  final void Function(String taskId, String reason) onCareTaskSkipped;

  _CareTaskProgress _progressFor(String taskId) {
    return careTaskProgress[taskId] ??
        const _CareTaskProgress(state: _CareTaskState.pending);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Care plan'),
          const SizedBox(height: 12),
          if (carePlanTasks.isNotEmpty) ...[
            _CareSection(
              title: 'Care plan tasks',
              children: [
                for (final task in carePlanTasks)
                  _CarePlanTaskCheckbox(
                    task: task,
                    progress: _progressFor(task.id),
                    onDoneChanged: onCareTaskDoneChanged,
                    onSkipped: onCareTaskSkipped,
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          _CareSection(
            title: 'Medication',
            children: [
              _MedicationTaskTile(
                id: 'medication-paracetamol',
                drugName: 'Paracetamol',
                dosage: '500mg',
                time: '09:45',
                progress: _progressFor('medication-paracetamol'),
                onDoneChanged: onCareTaskDoneChanged,
                onSkipped: onCareTaskSkipped,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CareSection(
            title: 'Procedures',
            children: [
              _CareTaskCheckbox(
                id: 'procedure-wound-care',
                label: 'Wound care',
                progress: _progressFor('procedure-wound-care'),
                onDoneChanged: onCareTaskDoneChanged,
                onSkipped: onCareTaskSkipped,
              ),
              _CareTaskCheckbox(
                id: 'procedure-feeding',
                label: 'Feeding',
                progress: _progressFor('procedure-feeding'),
                onDoneChanged: onCareTaskDoneChanged,
                onSkipped: onCareTaskSkipped,
              ),
              _CareTaskCheckbox(
                id: 'procedure-hygiene',
                label: 'Hygiene',
                progress: _progressFor('procedure-hygiene'),
                onDoneChanged: onCareTaskDoneChanged,
                onSkipped: onCareTaskSkipped,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _ObservationsSection(),
        ],
      ),
    );
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

class _MedicationTaskTile extends StatelessWidget {
  const _MedicationTaskTile({
    required this.id,
    required this.drugName,
    required this.dosage,
    required this.time,
    required this.progress,
    required this.onDoneChanged,
    required this.onSkipped,
  });

  final String id;
  final String drugName;
  final String dosage;
  final String time;
  final _CareTaskProgress progress;
  final void Function(String taskId, bool isDone) onDoneChanged;
  final void Function(String taskId, String reason) onSkipped;

  @override
  Widget build(BuildContext context) {
    return _CareTaskTileShell(
      id: id,
      progress: progress,
      onDoneChanged: onDoneChanged,
      onSkipped: onSkipped,
      title: drugName,
      subtitle: 'Dosage: $dosage  Time: $time',
      icon: Icons.medication_outlined,
    );
  }
}

class _CareTaskCheckbox extends StatelessWidget {
  const _CareTaskCheckbox({
    required this.id,
    required this.label,
    required this.progress,
    required this.onDoneChanged,
    required this.onSkipped,
  });

  final String id;
  final String label;
  final _CareTaskProgress progress;
  final void Function(String taskId, bool isDone) onDoneChanged;
  final void Function(String taskId, String reason) onSkipped;

  @override
  Widget build(BuildContext context) {
    return _CareTaskTileShell(
      id: id,
      progress: progress,
      onDoneChanged: onDoneChanged,
      onSkipped: onSkipped,
      title: label,
    );
  }
}

class _CarePlanTaskCheckbox extends StatelessWidget {
  const _CarePlanTaskCheckbox({
    required this.task,
    required this.progress,
    required this.onDoneChanged,
    required this.onSkipped,
  });

  final CarePlanTask task;
  final _CareTaskProgress progress;
  final void Function(String taskId, bool isDone) onDoneChanged;
  final void Function(String taskId, String reason) onSkipped;

  @override
  Widget build(BuildContext context) {
    return _CareTaskTileShell(
      id: task.id,
      progress: progress,
      onDoneChanged: onDoneChanged,
      onSkipped: onSkipped,
      title: task.title,
      subtitle: '${task.section}: ${task.instructions}',
      icon: Icons.assignment_turned_in_outlined,
    );
  }
}

class _CareTaskTileShell extends StatelessWidget {
  const _CareTaskTileShell({
    required this.id,
    required this.progress,
    required this.onDoneChanged,
    required this.onSkipped,
    required this.title,
    this.subtitle,
    this.icon,
  });

  final String id;
  final _CareTaskProgress progress;
  final void Function(String taskId, bool isDone) onDoneChanged;
  final void Function(String taskId, String reason) onSkipped;
  final String title;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDone = progress.state == _CareTaskState.done;
    final isSkipped = progress.state == _CareTaskState.skipped;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5EAEE))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: isDone,
            onChanged: (value) => onDoneChanged(id, value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: subtitle == null ? null : Text(subtitle!),
            secondary: icon == null ? null : Icon(icon),
          ),
          Row(
            children: [
              _TaskStateChip(progress: progress),
              const Spacer(),
              TextButton.icon(
                onPressed: isSkipped || isDone
                    ? null
                    : () => onSkipped(id, 'Client declined'),
                icon: const Icon(Icons.do_not_disturb_on_outlined),
                label: const Text('Skip'),
              ),
            ],
          ),
          if (isSkipped && progress.skippedReason != null) ...[
            const SizedBox(height: 4),
            Text(
              'Reason: ${progress.skippedReason}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
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

class _ObservationsSection extends StatelessWidget {
  const _ObservationsSection();

  @override
  Widget build(BuildContext context) {
    return _CareSection(
      title: 'Observations',
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Vitals input',
            hintText: 'BP, pulse, temperature',
            prefixIcon: const Icon(Icons.monitor_heart_outlined),
          ),
        ),
        const SizedBox(height: 12),
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
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text('Upload photo'),
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

class _SignaturePrompt extends StatelessWidget {
  const _SignaturePrompt();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.draw_outlined),
      label: const Text('Capture signature'),
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

class _VisitAlerts extends StatelessWidget {
  const _VisitAlerts();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Alerts'),
          const SizedBox(height: 12),
          const _AlertBanner(
            icon: Icons.warning_amber_outlined,
            title: 'Allergies',
            message:
                'Penicillin allergy recorded. Confirm medication before administration.',
          ),
          const SizedBox(height: 8),
          const _AlertBanner(
            icon: Icons.priority_high_outlined,
            title: 'Critical notes',
            message: 'High falls risk. Use walking frame and keep route clear.',
          ),
          const SizedBox(height: 12),
          const _SectionHeader(title: 'Exception actions'),
          const SizedBox(height: 12),
          const _ExceptionActionButton(
            icon: Icons.access_time_filled_outlined,
            label: 'Mark visit late',
          ),
          const SizedBox(height: 8),
          const _ExceptionActionButton(
            icon: Icons.medication_liquid_outlined,
            label: 'Report missed medication',
          ),
          const SizedBox(height: 8),
          const _ExceptionActionButton(
            icon: Icons.home_outlined,
            label: 'Client not home',
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.emergency_outlined),
            label: const Text('Emergency escalation'),
          ),
        ],
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({
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
        color: const Color(0xFFFEF3C7),
        border: Border.all(color: const Color(0xFFF59E0B)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF854D0E)),
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
  const _ExceptionActionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
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
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _QuickActionButton(icon: Icons.login, label: 'Check-in'),
        SizedBox(height: 8),
        _QuickActionButton(
          icon: Icons.report_problem_outlined,
          label: 'Report issue',
        ),
        SizedBox(height: 8),
        _QuickActionButton(icon: Icons.note_add_outlined, label: 'Add note'),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
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
  });

  final String carerName;
  final String email;
  final String? homeName;
  final String? jobTitle;
  final String status;

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
        ],
      ),
    );
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
