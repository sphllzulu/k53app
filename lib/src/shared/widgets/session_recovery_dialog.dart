import 'package:flutter/material.dart';
import '../../core/services/session_persistence_service.dart';

class SessionRecoveryDialog extends StatelessWidget {
  final SessionState session;
  final VoidCallback onContinue;
  final VoidCallback onStartNew;

  const SessionRecoveryDialog({
    super.key,
    required this.session,
    required this.onContinue,
    required this.onStartNew,
  });

  @override
  Widget build(BuildContext context) {
    final metadata = SessionPersistenceService.getSessionMetadata(session);
    final sessionTypeEnum = metadata['type'] as SessionType;
    final sessionType = sessionTypeEnum == SessionType.study ? 'Study' : 'Exam';
    final progress = '${metadata['progress']}/${metadata['totalQuestions']}';
    final category = metadata['category'] ?? 'All Categories';

    return AlertDialog(
      title: const Text('Continue Previous Session?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have an unfinished $sessionType session:',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _buildSessionInfo('Type', sessionType),
          _buildSessionInfo('Progress', progress),
          _buildSessionInfo('Category', category),
          if (metadata['score'] != null) _buildSessionInfo('Score', metadata['score']),
          const SizedBox(height: 8),
          Text(
            'Would you like to continue where you left off or start a new session?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onStartNew,
          child: const Text('Start New'),
        ),
        ElevatedButton(
          onPressed: onContinue,
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildSessionInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}