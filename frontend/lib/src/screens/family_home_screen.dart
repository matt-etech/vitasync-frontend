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

  @override
  void initState() {
    super.initState();
    _summary = widget.familyAccess.portalSummary(widget.session);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family portal'),
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
              _FamilyPanel(
                title: summary.client.name,
                subtitle: summary.client.homeName,
                child: Text('Status: ${summary.client.status}'),
              ),
              if (summary.carePlanSummary != null)
                _FamilyPanel(
                  title: 'Care plan summary',
                  child: Text(
                    [
                      summary.carePlanSummary!['title'],
                      summary.carePlanSummary!['care_goals'],
                    ].whereType<String>().join('\n'),
                  ),
                ),
              if (summary.medicationSummary != null)
                _FamilyPanel(
                  title: 'Medication summary',
                  child: Text(
                    [
                      summary.medicationSummary!['support_summary'],
                      summary.medicationSummary!['allergies'],
                    ].whereType<String>().join('\n'),
                  ),
                ),
              _FamilyListPanel(
                title: 'Appointments',
                emptyText: 'No appointments shared.',
                rows: summary.appointments,
                labelFor: (row) => row['title'] as String? ?? 'Visit',
              ),
              _FamilyListPanel(
                title: 'Visit notes summary',
                emptyText: 'No visit notes shared.',
                rows: summary.visitNotesSummary,
                labelFor: (row) => row['summary'] as String? ?? 'Visit update',
              ),
              _FamilyListPanel(
                title: 'Incident notifications',
                emptyText: 'No approved incident notifications.',
                rows: summary.incidentNotifications,
                labelFor: (row) =>
                    '${row['category'] ?? 'Incident'} - ${row['severity'] ?? 'info'}',
              ),
            ],
          );
        },
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7DEE3)),
        borderRadius: BorderRadius.circular(8),
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
    );
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
