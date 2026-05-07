import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitasync_health/src/app.dart';
import 'package:vitasync_health/src/models/care_client.dart';
import 'package:vitasync_health/src/models/care_plan_task.dart';
import 'package:vitasync_health/src/models/carer_session.dart';
import 'package:vitasync_health/src/models/scheduled_visit.dart';
import 'package:vitasync_health/src/models/visit_workflow.dart';
import 'package:vitasync_health/src/services/care_plan_task_contract.dart';
import 'package:vitasync_health/src/services/carer_auth_contract.dart';
import 'package:vitasync_health/src/services/client_directory_contract.dart';
import 'package:vitasync_health/src/services/visit_schedule_contract.dart';
import 'package:vitasync_health/src/services/visit_workflow_contract.dart';

void main() {
  testWidgets('carer can sign in and see their access state', (tester) async {
    await tester.pumpWidget(
      VitaSyncCarerApp(
        authService: _SuccessfulCarerAuthService(),
        clientDirectory: _SuccessfulClientDirectory(),
        carePlanTasks: _SuccessfulCarePlanTasks(),
        visitSchedule: _SuccessfulVisitSchedule(),
        visitWorkflow: _SuccessfulVisitWorkflow(),
      ),
    );

    expect(find.text('VitaSync Carer Login'), findsOneWidget);
    expect(find.text('Sign in as carer'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'carer@vitasync.local',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.byIcon(Icons.login));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Visit execution'), findsOneWidget);
    expect(find.text('Offline ready'), findsOneWidget);
    expect(find.text('scheduled'), findsOneWidget);
    expect(find.text('Check In'), findsOneWidget);
    expect(find.text('Care plan'), findsOneWidget);
    expect(find.text('Medication'), findsOneWidget);
    expect(find.text('pending'), findsWidgets);
    expect(find.text('Audit evidence'), findsOneWidget);

    await tester.tap(find.text('Check In'));
    await tester.pumpAndSettle();
    expect(find.text('in_progress'), findsOneWidget);
    expect(find.text('Check In recorded'), findsOneWidget);
    expect(find.text('09:28 - pending_sync'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -360));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(find.text('done'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -220));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip').at(1));
    await tester.pumpAndSettle();
    expect(find.text('skipped'), findsOneWidget);
    expect(find.text('Reason: Client declined'), findsOneWidget);

    expect(find.text('Alerts'), findsNothing);

    expect(find.text('Default Carer'), findsNothing);
    expect(find.text('Oak House'), findsNothing);

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Default Carer'), findsOneWidget);
    expect(find.text('Oak House'), findsOneWidget);
  });

  testWidgets('schedule defaults to agenda and can switch calendar modes', (
    tester,
  ) async {
    await tester.pumpWidget(
      VitaSyncCarerApp(
        authService: _SuccessfulCarerAuthService(),
        clientDirectory: _SuccessfulClientDirectory(),
        carePlanTasks: _SuccessfulCarePlanTasks(),
        visitSchedule: _SuccessfulVisitSchedule(),
        visitWorkflow: _SuccessfulVisitWorkflow(),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'carer@vitasync.local',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.byIcon(Icons.login));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Schedule'));
    await tester.pumpAndSettle();

    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('May 2026'), findsOneWidget);
    expect(find.text('Agenda'), findsWidgets);
    expect(find.text('Visits on 7 May 2026'), findsOneWidget);
    expect(find.text('Default Carer'), findsWidgets);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('April 2026'), findsOneWidget);

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('June 2026'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -260));
    await tester.pumpAndSettle();

    expect(find.text('Week'), findsOneWidget);
    await tester.ensureVisible(find.text('Week'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();
    expect(find.text('Weekly calendar'), findsOneWidget);

    await tester.ensureVisible(find.text('Month'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();
    expect(find.text('Monthly calendar'), findsOneWidget);

    await tester.ensureVisible(find.text('Agenda').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agenda').last);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -640));
    await tester.pumpAndSettle();

    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Margaret Lewis'), findsOneWidget);
  });

  testWidgets('clients tab loads clients from the directory service', (
    tester,
  ) async {
    await tester.pumpWidget(
      VitaSyncCarerApp(
        authService: _SuccessfulCarerAuthService(),
        clientDirectory: _SuccessfulClientDirectory(),
        carePlanTasks: _SuccessfulCarePlanTasks(),
        visitSchedule: _SuccessfulVisitSchedule(),
        visitWorkflow: _SuccessfulVisitWorkflow(),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'carer@vitasync.local',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.byIcon(Icons.login));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Clients'));
    await tester.pumpAndSettle();

    expect(find.text('Client directory'), findsOneWidget);
    expect(find.text('Asha Patel'), findsOneWidget);
    expect(find.text('10 Client Road'), findsOneWidget);
    expect(find.text('Oak House'), findsOneWidget);
  });

  testWidgets('tasks tab loads tasks from care plans', (tester) async {
    await tester.pumpWidget(
      VitaSyncCarerApp(
        authService: _SuccessfulCarerAuthService(),
        clientDirectory: _SuccessfulClientDirectory(),
        carePlanTasks: _SuccessfulCarePlanTasks(),
        visitSchedule: _SuccessfulVisitSchedule(),
        visitWorkflow: _SuccessfulVisitWorkflow(),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'carer@vitasync.local',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.byIcon(Icons.login));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Tasks'));
    await tester.pumpAndSettle();

    expect(find.text('Care plan tasks'), findsOneWidget);
    expect(find.text('Administered by staff'), findsOneWidget);
    expect(find.text('Morning support plan'), findsOneWidget);
    expect(find.text('Follow MAR chart'), findsOneWidget);
    expect(find.text('Asha Patel'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -520));
    await tester.pumpAndSettle();

    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Report missed medication'), findsOneWidget);
    expect(find.text('Client not home'), findsOneWidget);
    expect(find.text('Emergency escalation'), findsOneWidget);
  });

  testWidgets('login errors are shown near the form', (tester) async {
    await tester.pumpWidget(
      VitaSyncCarerApp(
        authService: _FailingCarerAuthService(),
        clientDirectory: _SuccessfulClientDirectory(),
        carePlanTasks: _SuccessfulCarePlanTasks(),
        visitSchedule: _SuccessfulVisitSchedule(),
        visitWorkflow: _SuccessfulVisitWorkflow(),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'manager@vitasync.local',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.byIcon(Icons.login));
    await tester.pumpAndSettle();

    expect(
      find.text('This login is only available to active carers.'),
      findsOneWidget,
    );
  });
}

class _SuccessfulCarerAuthService implements CarerAuthPort {
  @override
  Future<CarerSession> login({
    required String email,
    required String password,
  }) async {
    return const CarerSession(
      id: 1,
      name: 'Default Carer',
      email: 'carer@vitasync.local',
      jobTitle: 'Carer',
      homeName: 'Oak House',
      accountStatus: 'active',
    );
  }
}

class _FailingCarerAuthService implements CarerAuthPort {
  @override
  Future<CarerSession> login({
    required String email,
    required String password,
  }) async {
    throw const CarerAuthException(
      'This login is only available to active carers.',
    );
  }
}

class _SuccessfulClientDirectory implements ClientDirectoryPort {
  @override
  Future<List<CareClient>> clientsForCarer(CarerSession session) async {
    return const [
      CareClient(
        id: 10,
        name: 'Asha Patel',
        status: 'active',
        address: '10 Client Road',
        phone: '07123456789',
        homeName: 'Oak House',
        onboardingStatus: 'approved',
      ),
    ];
  }
}

class _SuccessfulCarePlanTasks implements CarePlanTaskPort {
  @override
  Future<List<CarePlanTask>> tasksForCarer(CarerSession session) async {
    return const [
      CarePlanTask(
        id: '1:medication',
        clientName: 'Asha Patel',
        carePlanTitle: 'Morning support plan',
        section: 'Medication',
        title: 'Administered by staff',
        instructions: 'Follow MAR chart',
        status: 'pending',
        riskLevel: 'High',
      ),
    ];
  }
}

class _SuccessfulVisitSchedule implements VisitSchedulePort {
  @override
  Future<List<ScheduledVisit>> visitsForCarer(CarerSession session) async {
    return [
      ScheduledVisit(
        id: 20,
        date: DateTime(2026, 5, 7),
        dayLabel: 'Thu 7 May',
        clientName: 'Margaret Lewis',
        assignedWorkerName: 'Default Carer',
        timeWindow: '09:30 - 10:15',
        status: 'scheduled',
      ),
      ScheduledVisit(
        id: 21,
        date: DateTime(2026, 4, 30),
        dayLabel: 'Thu 30 Apr',
        clientName: 'Arthur Brown',
        assignedWorkerName: 'Default Carer',
        timeWindow: '07:45 - 08:30',
        status: 'completed',
      ),
      ScheduledVisit(
        id: 22,
        date: DateTime(2026, 6, 2),
        dayLabel: 'Tue 2 Jun',
        clientName: 'Nadia Patel',
        assignedWorkerName: 'Default Carer',
        timeWindow: '10:30 - 11:00',
        status: 'missed',
      ),
    ];
  }
}

class _SuccessfulVisitWorkflow implements VisitWorkflowPort {
  VisitWorkflow _visit({
    String status = 'scheduled',
    String? checkInTime,
    String? checkOutTime,
  }) {
    return VisitWorkflow(
      id: 20,
      clientName: 'Margaret Lewis',
      address: '12 Willow Lane, Windhoek',
      timeWindow: '09:30 - 10:15',
      status: status,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      tasks: const [
        CarePlanTask(
          id: '20:medication',
          clientName: 'Margaret Lewis',
          carePlanTitle: 'Morning care plan',
          section: 'Medication',
          title: 'Medication support',
          instructions: 'Follow MAR chart',
          status: 'pending',
          riskLevel: 'High',
        ),
      ],
    );
  }

  @override
  Future<VisitWorkflow?> todayVisitForCarer(CarerSession session) async {
    return _visit();
  }

  @override
  Future<VisitWorkflow> checkIn({
    required CarerSession session,
    required int visitId,
  }) async {
    return _visit(status: 'in_progress', checkInTime: '09:28');
  }

  @override
  Future<VisitWorkflow> checkOut({
    required CarerSession session,
    required int visitId,
  }) async {
    return _visit(
      status: 'completed',
      checkInTime: '09:28',
      checkOutTime: '10:12',
    );
  }
}
