import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

enum NotificationType {
  sosReceived,
  alertSent,
  safeCheckIn,
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status != AuthStatus.authenticated || state.user == null) return const SizedBox.shrink();
        return _NotificationsBody(uid: state.user!.uid, userName: state.user!.displayName);
      },
    );
  }
}

class _NotificationsBody extends StatefulWidget {
  final String uid;
  final String userName;

  const _NotificationsBody({required this.uid, required this.userName});

  @override
  State<_NotificationsBody> createState() => _NotificationsBodyState();
}

class _NotificationsBodyState extends State<_NotificationsBody> {
  bool _showDemoData = false;

  NotificationType _determineType(Map<String, dynamic> data, String currentUid) {
    final type = data['type'] as String?;
    if (type == 'sos' || type == 'emergency') return NotificationType.sosReceived;
    if (type == 'safe' || type == 'ok') return NotificationType.safeCheckIn;
    if (type == 'broadcast' || type == 'sent') return NotificationType.alertSent;

    final message = (data['message'] as String? ?? '').toLowerCase();
    final senderUid = data['senderUid'] as String?;
    if (senderUid == currentUid || message.contains('broadcast') || message.contains('sent to')) {
      return NotificationType.alertSent;
    }
    if (message.contains('yardım') || message.contains('sos') || message.contains('injured') || message.contains('help')) {
      return NotificationType.sosReceived;
    }
    return NotificationType.safeCheckIn; // Default fallback
  }

  List<Map<String, dynamic>> _getDemoNotifications() {
    return [
      {
        'id': 'demo_1',
        'senderName': 'Sarah Jenkins',
        'message': 'SOS Received',
        'type': 'sos',
        'location': 'Near Central Park, NY',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
        'read': false,
      },
      {
        'id': 'demo_2',
        'senderName': 'You (Main User)',
        'message': 'Emergency broadcast sent to 5 primary contacts.',
        'type': 'broadcast',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 16))),
        'read': true,
      },
      {
        'id': 'demo_3',
        'senderName': 'Marcus Thorne',
        'message': 'I\'m OK sent',
        'type': 'safe',
        'location': 'Financial District, Downtown',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 15))),
        'read': true,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService(FirebaseFirestore.instance);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leadingWidth: 56,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0F1E36)),
                onPressed: () => context.pop(),
              )
            : const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Icon(Icons.shield_outlined, color: Color(0xFF0F1E36), size: 28),
              ),
        title: const Text(
          'Safety Pulse',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F1E36),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF0F1E36)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF0F1E36)),
            onPressed: () {
              setState(() {
                _showDemoData = !_showDemoData;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_showDemoData ? 'Showing demo mockup history.' : 'Showing live Firestore history.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading titles
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alert History',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F1E36),
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 8),
                  const Text(
                    'Review all safety notifications and emergency status updates.',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF718096),
                    ),
                  ).animate().fadeIn(delay: 150.ms),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // History List
            Expanded(
              child: _showDemoData
                  ? _buildList(_getDemoNotifications(), firestoreService)
                  : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: firestoreService.notificationsStream(widget.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Failed to load alerts',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];

                        if (docs.isEmpty) {
                          // Standard fallback to show demo data for premium display
                          return _buildList(_getDemoNotifications(), firestoreService, isFallback: true);
                        }

                        final dataList = docs.map((doc) {
                          final data = doc.data();
                          data['id'] = doc.id;
                          return data;
                        }).toList();

                        return _buildList(dataList, firestoreService);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, FirestoreService firestoreService, {bool isFallback = false}) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: items.length + (isFallback ? 1 : 0),
      itemBuilder: (context, index) {
        if (isFallback && index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF0F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Color(0xFF718096)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No live alerts. Showing simulation history.',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF718096),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final actualIndex = isFallback ? index - 1 : index;
        final data = items[actualIndex];
        final id = data['id'] as String;
        final isRead = data['read'] as bool? ?? false;
        final senderName = data['senderName'] as String? ?? 'Contact';
        final timestamp = (data['createdAt'] as Timestamp?)?.toDate();
        final message = data['message'] as String? ?? '';
        final location = data['location'] as String?;

        final type = _determineType(data, widget.uid);

        return _NotificationCard(
          senderName: senderName,
          message: message,
          timestamp: timestamp,
          isRead: isRead,
          type: type,
          location: location,
          onCall: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Calling $senderName...')),
            );
          },
          onDismiss: () {
            if (!isFallback) {
              firestoreService.markNotificationRead(id);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Alert dismissed.')),
            );
          },
        ).animate().fadeIn(
              delay: Duration(milliseconds: 80 * index),
              duration: 300.ms,
            );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String senderName;
  final String message;
  final DateTime? timestamp;
  final bool isRead;
  final NotificationType type;
  final String? location;
  final VoidCallback onCall;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.senderName,
    required this.message,
    this.timestamp,
    required this.isRead,
    required this.type,
    this.location,
    required this.onCall,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Avatar + Name/Badge + Time
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderName,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF0F1E36),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(),
                    ],
                  ),
                ),
                if (timestamp != null)
                  Text(
                    DateFormatter.formatDateTime(timestamp!),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF718096),
                    ),
                  ),
              ],
            ),
            
            // Content based on NotificationType
            if (type == NotificationType.sosReceived) ...[
              const SizedBox(height: 16),
              _buildLocationSnippet(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: onCall,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066CC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Call Contact',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        onPressed: onDismiss,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0066CC), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: const Color(0xFF0066CC),
                        ),
                        child: const Text(
                          'Dismiss',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (type == NotificationType.alertSent) ...[
              const SizedBox(height: 16),
              _buildInfoBlock(),
            ] else if (type == NotificationType.safeCheckIn) ...[
              if (location != null && location!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF718096)),
                    const SizedBox(width: 6),
                    Text(
                      location!,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final bool isUser = type == NotificationType.alertSent;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF0B1B3D) : const Color(0xFFE5F0FF),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isUser
            ? const Icon(Icons.person, color: Colors.white, size: 22)
            : Text(
                senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Color(0xFF0066CC),
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  fontFamily: 'Nunito',
                ),
              ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    switch (type) {
      case NotificationType.sosReceived:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emergency_outlined, color: Color(0xFFEA4335), size: 14),
            SizedBox(width: 4),
            Text(
              'SOS Received',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Color(0xFFEA4335),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        );
      case NotificationType.alertSent:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.send_outlined, color: Color(0xFF0066CC), size: 14),
            SizedBox(width: 4),
            Text(
              'Alert Sent',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Color(0xFF0066CC),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        );
      case NotificationType.safeCheckIn:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, color: Color(0xFF34A853), size: 14),
            SizedBox(width: 4),
            Text(
              'I\'m OK sent',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Color(0xFF34A853),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildLocationSnippet() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Color(0xFF0066CC), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Location Snippet',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF718096),
                  ),
                ),
                Text(
                  location ?? 'Near Central Park, NY',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F1E36),
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'View Map',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0066CC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBlock() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF718096), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message.isNotEmpty ? message : 'Emergency broadcast sent to 5 primary contacts.',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A5568),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
