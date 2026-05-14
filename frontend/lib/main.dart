import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/config/app_config.dart';
import 'src/services/care_plan_task_service.dart';
import 'src/services/carer_auth_service.dart';
import 'src/services/client_directory_service.dart';
import 'src/services/family_access_service.dart';
import 'src/services/visit_schedule_service.dart';
import 'src/services/visit_workflow_service.dart';

void main() {
  runApp(
    VitaSyncCarerApp(
      authService: CarerAuthService(baseUrl: AppConfig.backendBaseUrl),
      clientDirectory: ClientDirectoryService(
        baseUrl: AppConfig.backendBaseUrl,
      ),
      carePlanTasks: CarePlanTaskService(baseUrl: AppConfig.backendBaseUrl),
      visitSchedule: VisitScheduleService(baseUrl: AppConfig.backendBaseUrl),
      visitWorkflow: VisitWorkflowService(baseUrl: AppConfig.backendBaseUrl),
      familyAccess: FamilyAccessService(baseUrl: AppConfig.backendBaseUrl),
    ),
  );
}
