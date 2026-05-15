import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitasync_health/src/app.dart';
import 'package:vitasync_health/src/models/care_client.dart';
import 'package:vitasync_health/src/models/care_plan_task.dart';
import 'package:vitasync_health/src/models/carer_session.dart';
import 'package:vitasync_health/src/models/family_portal_summary.dart';
import 'package:vitasync_health/src/models/family_session.dart';
import 'package:vitasync_health/src/models/scheduled_visit.dart';
import 'package:vitasync_health/src/models/visit_workflow.dart';
import 'package:vitasync_health/src/services/care_plan_task_contract.dart';
import 'package:vitasync_health/src/services/carer_auth_contract.dart';
import 'package:vitasync_health/src/services/client_directory_contract.dart';
import 'package:vitasync_health/src/services/family_access_contract.dart';
import 'package:vitasync_health/src/services/visit_schedule_contract.dart';
import 'package:vitasync_health/src/services/visit_workflow_contract.dart';

void main() {
  testWidgets('carer can sign in and see their access state', (tester) async {
    final authService = _SuccessfulCarerAuthService();
    await tester.pumpWidget(
      VitaSyncCarerApp(
        authService: authService,
        clientDirectory: _SuccessfulClientDirectory(),
        carePlanTasks: _SuccessfulCarePlanTasks(),
        visitSchedule: _SuccessfulVisitSchedule(),
        visitWorkflow: _SuccessfulVisitWorkflow(),
        familyAccess: _SuccessfulFamilyAccess(),
      ),
    );

    expect(find.text('VitaSync Login'), findsOneWidget);
    expect(find.text('Carer'), findsOneWidget);
    expect(find.text('Family'), findsOneWidget);
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
    expect(find.text('Sync status: synced'), findsOneWidget);
    expect(find.textContaining('Last synced'), findsOneWidget);
    expect(find.text('scheduled'), findsOneWidget);
    expect(find.text('Check In'), findsOneWidget);
    expect(find.text('Observations'), findsOneWidget);
    expect(find.text('Vitals input'), findsNothing);
    expect(find.text('Record current vitals'), findsOneWidget);
    expect(find.text('Upload photo'), findsOneWidget);
    expect(find.text('Care plan'), findsNothing);
    expect(find.text('Medication'), findsNothing);
    expect(find.text('Audit evidence'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Notes'),
      'Client settled and breakfast prompt completed.',
    );
    await tester.ensureVisible(find.text('Save notes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save notes'));
    await tester.pump();
    expect(find.text('Visit notes saved.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));

    await tester.ensureVisible(find.text('Check In'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Check In'));
    await tester.pumpAndSettle();
    expect(find.text('in_progress'), findsOneWidget);
    expect(find.text('Check In recorded'), findsOneWidget);
    expect(find.text('09:28 - pending_sync'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -260));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Upload photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload photo'));
    await tester.pumpAndSettle();
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Choose from library'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Capture signature'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Capture signature'));
    await tester.pumpAndSettle();
    expect(find.text('Sign inside this box'), findsOneWidget);
    await tester.drag(find.text('Sign inside this box'), const Offset(120, 40));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save signature'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Signature captured'), findsWidgets);
    await tester.pump(const Duration(seconds: 4));

    expect(find.text('Alerts'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Report issue'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report issue'));
    await tester.pumpAndSettle();
    expect(find.text('Issue type'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Notes'),
      'Client was not home at arrival.',
    );
    await tester.tap(find.text('Queue issue report'));
    await tester.pump();
    expect(find.textContaining('issue sent to admin'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));

    expect(find.text('Default Carer'), findsNothing);
    expect(find.text('Oak House'), findsNothing);

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Default Carer'), findsOneWidget);
    expect(find.text('Oak House'), findsOneWidget);

    await tester.tap(find.text('Change password'));
    await tester.pumpAndSettle();
    expect(find.text('Current password'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Current password'),
      'password',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'New password'),
      'Newpass1',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm new password'),
      'Newpass1',
    );
    tester.testTextInput.hide();
    await tester.ensureVisible(find.text('Save new password'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save new password'));
    await tester.pump();
    expect(authService.passwordChanged, isTrue);
  });

  testWidgets('today vitals panel only accepts required numeric readings', (
    tester,
  ) async {
    await tester.pumpWidget(
      VitaSyncCarerApp(
        authService: _SuccessfulCarerAuthService(),
        clientDirectory: _SuccessfulClientDirectory(),
        carePlanTasks: _SuccessfulCarePlanTasks(),
        visitSchedule: _SuccessfulVisitSchedule(),
        visitWorkflow: _SuccessfulVisitWorkflow(),
        familyAccess: _SuccessfulFamilyAccess(),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'carer@vitasync.local',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.byIcon(Icons.login));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Vitals'), findsNothing);
    await tester.ensureVisible(find.text('Record current vitals'));
    await tester.pumpAndSettle();

    expect(find.text('Record current vitals'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'BP systolic'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'BP diastolic'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Pulse'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Temperature'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Blood oxygen'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'BP systolic'),
      'abc120',
    );
    expect(find.text('120'), findsOneWidget);
    expect(find.text('abc120'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'BP diastolic'),
      '80x',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Pulse'), '72b');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Temperature'),
      '36.7c',
    );
    expect(find.text('36.7'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Blood oxygen'),
      '98%',
    );
    tester.testTextInput.hide();
    await tester.ensureVisible(find.text('Save vitals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save vitals'));
    await tester.pump();

    expect(find.textContaining('Vitals recorded at'), findsWidgets);
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
        familyAccess: _SuccessfulFamilyAccess(),
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
    expect(find.text('05/2026'), findsOneWidget);
    expect(find.text('Agenda'), findsWidgets);
    expect(find.text('Visits on 07/05/2026'), findsOneWidget);
    expect(find.text('Default Carer'), findsWidgets);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('04/2026'), findsOneWidget);

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('06/2026'), findsOneWidget);

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
        familyAccess: _SuccessfulFamilyAccess(),
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

    await tester.tap(find.text('Open client'));
    await tester.pumpAndSettle();

    expect(find.text('Client details'), findsOneWidget);
    expect(find.text('Back to clients'), findsOneWidget);

    await tester.tap(find.text('Back to clients'));
    await tester.pumpAndSettle();
    expect(find.text('Client directory'), findsOneWidget);
  });

  testWidgets('tasks tab records basic carer tasks and extra notes', (
    tester,
  ) async {
    await tester.pumpWidget(
      VitaSyncCarerApp(
        authService: _SuccessfulCarerAuthService(),
        clientDirectory: _SuccessfulClientDirectory(),
        carePlanTasks: _SuccessfulCarePlanTasks(),
        visitSchedule: _SuccessfulVisitSchedule(),
        visitWorkflow: _SuccessfulVisitWorkflow(),
        familyAccess: _SuccessfulFamilyAccess(),
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

    expect(find.text('Carer tasks'), findsOneWidget);
    expect(find.text('Confirm client identity and consent'), findsOneWidget);
    expect(find.text('Review allergies and critical notes'), findsOneWidget);
    expect(find.text('Medication support completed'), findsOneWidget);

    await tester.tap(find.text('Mark done').first);
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);
    expect(find.textContaining('Done at'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -520));
    await tester.pumpAndSettle();

    expect(find.text('Notes'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Add extra task'),
      'Changed bedding and recorded skin concern',
    );
    await tester.ensureVisible(find.text('Add task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();
    expect(
      find.text('Changed bedding and recorded skin concern'),
      findsOneWidget,
    );

    await tester.drag(find.byType(ListView), const Offset(0, -520));
    await tester.pumpAndSettle();

    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Allergies - Margaret Lewis'), findsOneWidget);
    expect(find.text('Latex allergy. Use latex-free gloves.'), findsOneWidget);
    expect(find.text('Critical notes - Margaret Lewis'), findsOneWidget);
    expect(
      find.text('High falls risk. Use walking frame and keep route clear.'),
      findsOneWidget,
    );
    expect(find.text('Report missed medication'), findsOneWidget);
    expect(find.text('Client not home'), findsOneWidget);
    expect(find.text('Emergency escalation'), findsOneWidget);
  });

  testWidgets('incorrect login errors are shown near the form', (tester) async {
    await tester.pumpWidget(
      VitaSyncCarerApp(
        authService: _FailingCarerAuthService(),
        clientDirectory: _SuccessfulClientDirectory(),
        carePlanTasks: _SuccessfulCarePlanTasks(),
        visitSchedule: _SuccessfulVisitSchedule(),
        visitWorkflow: _SuccessfulVisitWorkflow(),
        familyAccess: _SuccessfulFamilyAccess(),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'manager@vitasync.local',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.byIcon(Icons.login));
    await tester.pumpAndSettle();

    expect(find.text('incorrect user or password'), findsOneWidget);
  });

  testWidgets('family member can sign in and see shared portal', (
    tester,
  ) async {
    await tester.pumpWidget(
      VitaSyncCarerApp(
        authService: _UnexpectedCarerAuthService(),
        clientDirectory: _SuccessfulClientDirectory(),
        carePlanTasks: _SuccessfulCarePlanTasks(),
        visitSchedule: _SuccessfulVisitSchedule(),
        visitWorkflow: _SuccessfulVisitWorkflow(),
        familyAccess: _SuccessfulFamilyAccess(),
      ),
    );

    await tester.tap(find.text('Family'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in as family'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'father@vitasync.local',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.byIcon(Icons.login));
    await tester.pumpAndSettle();

    expect(find.text('Overview'), findsWidgets);
    expect(find.text('Care'), findsOneWidget);
    expect(find.text('Visits'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('My Profile'), findsNothing);
    expect(find.text('Selected client'), findsOneWidget);
    expect(find.text('Thabisile Mahlanza - Default Home'), findsOneWidget);
    expect(find.text('Thabisile Mahlanza'), findsOneWidget);

    await tester.tap(find.text('Thabisile Mahlanza - Default Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Asha Patel - Oak House').last);
    await tester.pumpAndSettle();
    expect(find.text('Asha Patel'), findsOneWidget);
    expect(find.text('Status: active'), findsOneWidget);

    await tester.tap(find.byTooltip('Care'));
    await tester.pumpAndSettle();
    expect(find.text('Medication support'), findsOneWidget);
    expect(find.text('Latest medication record'), findsOneWidget);
    expect(find.text('Care plan summary'), findsOneWidget);

    await tester.tap(find.byTooltip('Visits'));
    await tester.pumpAndSettle();
    expect(find.text('Visit calendar'), findsOneWidget);
    expect(find.text('Upcoming visits'), findsOneWidget);
    expect(find.text('Past visits'), findsOneWidget);
    expect(find.text('Carer'), findsWidgets);

    await tester.tap(find.byTooltip('Alerts'));
    await tester.pumpAndSettle();
    expect(find.text('Incident notifications'), findsOneWidget);

    await tester.tap(find.byTooltip('My Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Member information'), findsOneWidget);
    expect(find.text('Bokang Mahlanza'), findsOneWidget);
    expect(find.text('father@vitasync.local'), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Current password'),
      'password',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'New password'),
      'Newpass1',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm new password'),
      'Newpass1',
    );
    tester.testTextInput.hide();
    await tester.ensureVisible(find.text('Save password'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save password'));
    await tester.pump();
    expect(find.text('Password changed.'), findsOneWidget);
  });
}

class _SuccessfulCarerAuthService implements CarerAuthPort {
  bool passwordChanged = false;

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

  @override
  Future<void> changePassword({
    required CarerSession session,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    passwordChanged = true;
  }
}

class _FailingCarerAuthService implements CarerAuthPort {
  @override
  Future<CarerSession> login({
    required String email,
    required String password,
  }) async {
    throw const CarerAuthException('incorrect user or password');
  }

  @override
  Future<void> changePassword({
    required CarerSession session,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    throw const CarerAuthException('Password could not be changed.');
  }
}

class _UnexpectedCarerAuthService implements CarerAuthPort {
  @override
  Future<CarerSession> login({
    required String email,
    required String password,
  }) async {
    throw const CarerAuthException('Carer login should not be used.');
  }

  @override
  Future<void> changePassword({
    required CarerSession session,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {}
}

class _SuccessfulFamilyAccess implements FamilyAccessPort {
  bool passwordChanged = false;

  @override
  Future<FamilySession> login({
    required String email,
    required String password,
  }) async {
    return const FamilySession(
      id: 2,
      name: 'Bokang Mahlanza',
      email: 'father@vitasync.local',
      clientId: 1,
      clientName: 'Thabisile Mahlanza',
      homeName: 'Default Home',
      clients: [
        FamilySessionClient(
          id: 1,
          name: 'Thabisile Mahlanza',
          homeName: 'Default Home',
        ),
        FamilySessionClient(id: 10, name: 'Asha Patel', homeName: 'Oak House'),
      ],
      permissions: FamilyAccessPermissions(
        canViewCareUpdates: true,
        canViewMedication: true,
        canViewInvoices: false,
        canReceiveIncidentAlerts: false,
        canViewAppointments: true,
        canViewVisits: true,
        canUploadDocuments: false,
        canViewStaffMessages: false,
        canViewSharedDocuments: false,
        canViewSensitiveDocuments: false,
        canViewSafeguarding: false,
      ),
    );
  }

  @override
  Future<FamilyPortalSummary> portalSummary(
    FamilySession session, {
    int? clientId,
  }) async {
    final selectedClient = clientId == 10
        ? const FamilyClientProfile(
            id: 10,
            name: 'Asha Patel',
            status: 'active',
            homeName: 'Oak House',
          )
        : const FamilyClientProfile(
            id: 1,
            name: 'Thabisile Mahlanza',
            status: 'active',
            homeName: 'Default Home',
          );

    return FamilyPortalSummary(
      client: selectedClient,
      permissions: {'can_view_care_updates': true},
      carePlanSummary: const {
        'title': 'Morning support plan',
        'care_goals': 'Stay safe at home.',
      },
      upcomingVisits: const [
        {
          'visit_id': 41,
          'title': 'Evening medication visit',
          'scheduled_start_at': '2026-05-20T18:00:00',
          'scheduled_end_at': '2026-05-20T18:30:00',
          'status': 'scheduled',
          'assigned_worker_name': 'Default Carer',
          'did_carer_attend': false,
        },
      ],
      pastVisits: const [
        {
          'visit_id': 40,
          'title': 'Morning medication visit',
          'scheduled_start_at': '2026-05-14T08:00:00',
          'scheduled_end_at': '2026-05-14T08:30:00',
          'status': 'completed',
          'assigned_worker_name': 'Default Carer',
          'check_in_at': '2026-05-14T07:58:00',
          'check_out_at': '2026-05-14T08:28:00',
          'did_carer_attend': true,
          'notes': 'Settled and supported with breakfast.',
        },
      ],
      visitNotesSummary: const [
        {'summary': 'Settled and supported with breakfast.'},
      ],
      medicationSummary: const {
        'support_needed': true,
        'support_level': 'Administered by staff',
        'care_plan_instructions': 'Follow MAR chart.',
        'support_summary': 'Morning tablets.',
      },
      medicationRecords: const [
        {
          'visit_id': 40,
          'title': 'Medication support',
          'status': 'completed',
          'completed_at': '2026-05-14T08:10:00',
          'carer_name': 'Default Carer',
          'detail': 'Medication given as planned.',
        },
      ],
      incidentNotifications: const [],
      appointments: const [
        {'title': 'Morning visit'},
      ],
    );
  }

  @override
  Future<void> changePassword({
    required FamilySession session,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    passwordChanged = true;
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
    String? notes,
  }) {
    return VisitWorkflow(
      id: 20,
      clientName: 'Margaret Lewis',
      address: '12 Willow Lane, Windhoek',
      timeWindow: '09:30 - 10:15',
      status: status,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      allergies: 'Latex allergy. Use latex-free gloves.',
      criticalInformation:
          'High falls risk. Use walking frame and keep route clear.',
      notes: notes,
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

  @override
  Future<VisitWorkflow> recordVisitNotes({
    required CarerSession session,
    required int visitId,
    required String notes,
  }) async {
    return _visit(notes: notes);
  }

  @override
  Future<VisitWorkflow> recordVisitTask({
    required CarerSession session,
    required int visitId,
    required VisitTaskRecord task,
  }) async {
    return _visit();
  }

  @override
  Future<VisitWorkflow> recordVisitVitals({
    required CarerSession session,
    required int visitId,
    required VisitVitalsRecord vitals,
  }) async {
    return _visit();
  }

  @override
  Future<VisitWorkflow> recordVisitEvidence({
    required CarerSession session,
    required int visitId,
    required VisitEvidenceRecord evidence,
  }) async {
    return _visit();
  }

  @override
  Future<VisitWorkflow> recordLocationEvent({
    required CarerSession session,
    required int visitId,
    required VisitLocationEvent event,
  }) async {
    return event.type == 'arrived'
        ? _visit(status: 'in_progress', checkInTime: '09:28')
        : _visit(
            status: 'completed',
            checkInTime: '09:28',
            checkOutTime: '10:12',
          );
  }

  @override
  Future<IssueReportReceipt> reportIssue({
    required CarerSession session,
    required IssueReport issue,
  }) async {
    return const IssueReportReceipt(
      status: 'queued',
      syncStatus: 'synced',
      reportedAt: '08/05/2026 09:35',
    );
  }
}
