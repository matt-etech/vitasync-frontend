import 'package:flutter/material.dart';

import 'models/carer_session.dart';
import 'models/family_session.dart';
import 'screens/carer_home_screen.dart';
import 'screens/carer_login_screen.dart';
import 'screens/family_home_screen.dart';
import 'services/care_plan_task_contract.dart';
import 'services/carer_auth_contract.dart';
import 'services/client_directory_contract.dart';
import 'services/family_access_contract.dart';
import 'services/visit_schedule_contract.dart';
import 'services/visit_workflow_contract.dart';
import 'theme/vitasync_theme.dart';

class VitaSyncCarerApp extends StatefulWidget {
  const VitaSyncCarerApp({
    required this.authService,
    required this.clientDirectory,
    required this.carePlanTasks,
    required this.visitSchedule,
    required this.visitWorkflow,
    required this.familyAccess,
    super.key,
  });

  final CarerAuthPort authService;
  final ClientDirectoryPort clientDirectory;
  final CarePlanTaskPort carePlanTasks;
  final VisitSchedulePort visitSchedule;
  final VisitWorkflowPort visitWorkflow;
  final FamilyAccessPort familyAccess;

  @override
  State<VitaSyncCarerApp> createState() => _VitaSyncCarerAppState();
}

class _VitaSyncCarerAppState extends State<VitaSyncCarerApp> {
  CarerSession? _session;
  FamilySession? _familySession;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitaSync Carer',
      debugShowCheckedModeBanner: false,
      theme: buildVitaSyncTheme(),
      home: _session == null && _familySession == null
          ? CarerLoginScreen(
              authService: widget.authService,
              familyAccess: widget.familyAccess,
              onAuthenticated: (session) {
                setState(() => _session = session);
              },
              onFamilyAuthenticated: (session) {
                setState(() => _familySession = session);
              },
            )
          : _session != null
          ? CarerHomeScreen(
              session: _session!,
              authService: widget.authService,
              clientDirectory: widget.clientDirectory,
              carePlanTasks: widget.carePlanTasks,
              visitSchedule: widget.visitSchedule,
              visitWorkflow: widget.visitWorkflow,
              onLogout: () {
                setState(() => _session = null);
              },
            )
          : FamilyHomeScreen(
              session: _familySession!,
              familyAccess: widget.familyAccess,
              onLogout: () {
                setState(() => _familySession = null);
              },
            ),
    );
  }
}
