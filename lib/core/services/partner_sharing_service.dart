import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import '../models/cycle_data.dart';
import '../models/daily_tracking_data.dart';
import 'database_service.dart';
import 'user_preferences_service.dart';
import 'cloud_sync_service.dart';

class PartnerSharingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _databaseService = DatabaseService();
  final UserPreferencesService _preferencesService = UserPreferencesService();
  final CloudSyncService _cloudSyncService = CloudSyncService();

  // Encryption for shared data
  late final Encrypter _encrypter;
  late final IV _iv;

  PartnerSharingService() {
    _initializeEncryption();
  }

  void _initializeEncryption() {
    final key = Key.fromSecureRandom(32);
    _encrypter = Encrypter(AES(key));
    _iv = IV.fromSecureRandom(16);
  }

  // Create sharing invitation
  Future<SharingInvitation> createSharingInvitation({
    required String partnerEmail,
    required SharingPermissions permissions,
    required String invitationMessage,
    DateTime? expiresAt,
  }) async {
    if (!_cloudSyncService.isSignedIn) {
      throw Exception('User must be signed in to share data');
    }

    try {
      final currentUser = _auth.currentUser!;
      final invitationId = _generateInvitationCode();
      
      expiresAt ??= DateTime.now().add(const Duration(days: 7));

      final invitation = SharingInvitation(
        id: invitationId,
        ownerUserId: currentUser.uid,
        ownerEmail: currentUser.email!,
        partnerEmail: partnerEmail,
        permissions: permissions,
        status: SharingStatus.pending,
        invitationMessage: invitationMessage,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
      );

      // Save invitation to Firestore
      await _firestore
          .collection('sharing_invitations')
          .doc(invitationId)
          .set(invitation.toMap());

      // Send notification to partner (email or in-app)
      await _sendSharingNotification(invitation);

      return invitation;
    } catch (e) {
      debugPrint('Error creating sharing invitation: $e');
      rethrow;
    }
  }

  // Accept sharing invitation
  Future<SharedConnection> acceptSharingInvitation(String invitationCode) async {
    if (!_cloudSyncService.isSignedIn) {
      throw Exception('User must be signed in to accept invitation');
    }

    try {
      final currentUser = _auth.currentUser!;
      
      // Get invitation
      final invitationDoc = await _firestore
          .collection('sharing_invitations')
          .doc(invitationCode)
          .get();

      if (!invitationDoc.exists) {
        throw Exception('Invalid invitation code');
      }

      final invitation = SharingInvitation.fromMap(invitationDoc.data()!);
      
      // Validate invitation
      if (invitation.status != SharingStatus.pending) {
        throw Exception('Invitation has already been ${invitation.status.toString().split('.').last}');
      }

      if (invitation.expiresAt.isBefore(DateTime.now())) {
        throw Exception('Invitation has expired');
      }

      if (invitation.partnerEmail != currentUser.email) {
        throw Exception('This invitation is not for your email address');
      }

      // Create shared connection
      final connectionId = _generateConnectionId();
      final connection = SharedConnection(
        id: connectionId,
        ownerUserId: invitation.ownerUserId,
        ownerEmail: invitation.ownerEmail,
        partnerUserId: currentUser.uid,
        partnerEmail: currentUser.email!,
        permissions: invitation.permissions,
        status: ConnectionStatus.active,
        createdAt: DateTime.now(),
        lastAccessedAt: DateTime.now(),
      );

      // Save connection
      await _firestore
          .collection('shared_connections')
          .doc(connectionId)
          .set(connection.toMap());

      // Update invitation status
      await _firestore
          .collection('sharing_invitations')
          .doc(invitationCode)
          .update({
        'status': SharingStatus.accepted.toString().split('.').last,
        'acceptedAt': FieldValue.serverTimestamp(),
        'partnerUserId': currentUser.uid,
      });

      // Create shared data collection for this connection
      await _setupSharedDataCollection(connection);

      // Notify owner that invitation was accepted
      await _notifyOwnerOfAcceptance(invitation, currentUser);

      return connection;
    } catch (e) {
      debugPrint('Error accepting sharing invitation: $e');
      rethrow;
    }
  }

  // Decline sharing invitation
  Future<void> declineSharingInvitation(String invitationCode, String reason) async {
    try {
      await _firestore
          .collection('sharing_invitations')
          .doc(invitationCode)
          .update({
        'status': SharingStatus.declined.toString().split('.').last,
        'declinedAt': FieldValue.serverTimestamp(),
        'declineReason': reason,
      });
    } catch (e) {
      debugPrint('Error declining sharing invitation: $e');
      rethrow;
    }
  }

  // Get shared connections for current user
  Future<List<SharedConnection>> getSharedConnections() async {
    if (!_cloudSyncService.isSignedIn) {
      throw Exception('User must be signed in');
    }

    try {
      final currentUser = _auth.currentUser!;
      
      // Get connections where user is owner
      final ownerQuery = await _firestore
          .collection('shared_connections')
          .where('ownerUserId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: ConnectionStatus.active.toString().split('.').last)
          .get();

      // Get connections where user is partner
      final partnerQuery = await _firestore
          .collection('shared_connections')
          .where('partnerUserId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: ConnectionStatus.active.toString().split('.').last)
          .get();

      final connections = <SharedConnection>[];
      
      for (final doc in ownerQuery.docs) {
        connections.add(SharedConnection.fromMap(doc.data()));
      }
      
      for (final doc in partnerQuery.docs) {
        connections.add(SharedConnection.fromMap(doc.data()));
      }

      return connections;
    } catch (e) {
      debugPrint('Error getting shared connections: $e');
      rethrow;
    }
  }

  // Share specific data with partner
  Future<void> shareDataWithPartner(
    String connectionId,
    List<String> cycleIds,
    List<String> trackingDataIds, {
    String? note,
  }) async {
    try {
      final connection = await _getConnection(connectionId);
      if (connection == null) {
        throw Exception('Connection not found');
      }

      final currentUser = _auth.currentUser!;
      
      // Verify permissions
      if (connection.ownerUserId != currentUser.uid) {
        throw Exception('Only data owner can share data');
      }

      // Encrypt and share cycles
      for (final cycleId in cycleIds) {
        final cycle = await _databaseService.getCycleById(cycleId);
        if (cycle != null && _canShareCycle(connection.permissions)) {
          await _shareEncryptedData(connectionId, 'cycles', cycle.toMap());
        }
      }

      // Encrypt and share tracking data
      for (final trackingId in trackingDataIds) {
        final tracking = await _databaseService.getTrackingById(trackingId);
        if (tracking != null && _canShareTracking(connection.permissions)) {
          await _shareEncryptedData(connectionId, 'tracking', tracking.toMap());
        }
      }

      // Update connection with last shared timestamp
      await _firestore
          .collection('shared_connections')
          .doc(connectionId)
          .update({
        'lastSharedAt': FieldValue.serverTimestamp(),
        'lastSharedNote': note,
      });

      // Notify partner of new shared data
      await _notifyPartnerOfNewData(connection, cycleIds.length + trackingDataIds.length);
    } catch (e) {
      debugPrint('Error sharing data with partner: $e');
      rethrow;
    }
  }

  // Get shared data from connection
  Future<SharedData> getSharedData(String connectionId) async {
    try {
      final connection = await _getConnection(connectionId);
      if (connection == null) {
        throw Exception('Connection not found');
      }

      final currentUser = _auth.currentUser!;
      
      // Verify access
      if (connection.ownerUserId != currentUser.uid && 
          connection.partnerUserId != currentUser.uid) {
        throw Exception('No access to this connection');
      }

      // Get shared cycles
      final cyclesQuery = await _firestore
          .collection('shared_data')
          .doc(connectionId)
          .collection('cycles')
          .orderBy('sharedAt', descending: true)
          .get();

      // Get shared tracking data
      final trackingQuery = await _firestore
          .collection('shared_data')
          .doc(connectionId)
          .collection('tracking')
          .orderBy('sharedAt', descending: true)
          .get();

      final cycles = <CycleData>[];
      final trackingData = <DailyTrackingData>[];

      // Decrypt cycles
      for (final doc in cyclesQuery.docs) {
        try {
          final encryptedData = doc.data();
          final decryptedData = _decryptSharedData(encryptedData);
          cycles.add(CycleData.fromMap(decryptedData));
        } catch (e) {
          debugPrint('Error decrypting cycle data: $e');
        }
      }

      // Decrypt tracking data
      for (final doc in trackingQuery.docs) {
        try {
          final encryptedData = doc.data();
          final decryptedData = _decryptSharedData(encryptedData);
          trackingData.add(DailyTrackingData.fromMap(decryptedData));
        } catch (e) {
          debugPrint('Error decrypting tracking data: $e');
        }
      }

      // Update last accessed timestamp
      await _firestore
          .collection('shared_connections')
          .doc(connectionId)
          .update({
        'lastAccessedAt': FieldValue.serverTimestamp(),
      });

      return SharedData(
        connectionId: connectionId,
        cycles: cycles,
        trackingData: trackingData,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting shared data: $e');
      rethrow;
    }
  }

  // Update sharing permissions
  Future<void> updateSharingPermissions(String connectionId, SharingPermissions newPermissions) async {
    try {
      final connection = await _getConnection(connectionId);
      if (connection == null) {
        throw Exception('Connection not found');
      }

      final currentUser = _auth.currentUser!;
      
      // Only owner can update permissions
      if (connection.ownerUserId != currentUser.uid) {
        throw Exception('Only data owner can update permissions');
      }

      await _firestore
          .collection('shared_connections')
          .doc(connectionId)
          .update({
        'permissions': newPermissions.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notify partner of permission changes
      await _notifyPartnerOfPermissionChange(connection, newPermissions);
    } catch (e) {
      debugPrint('Error updating sharing permissions: $e');
      rethrow;
    }
  }

  // Revoke sharing access
  Future<void> revokeSharing(String connectionId, String reason) async {
    try {
      final connection = await _getConnection(connectionId);
      if (connection == null) {
        throw Exception('Connection not found');
      }

      final currentUser = _auth.currentUser!;
      
      // Only owner can revoke sharing
      if (connection.ownerUserId != currentUser.uid) {
        throw Exception('Only data owner can revoke sharing');
      }

      // Update connection status
      await _firestore
          .collection('shared_connections')
          .doc(connectionId)
          .update({
        'status': ConnectionStatus.revoked.toString().split('.').last,
        'revokedAt': FieldValue.serverTimestamp(),
        'revokeReason': reason,
      });

      // Delete shared data
      await _deleteSharedData(connectionId);

      // Notify partner of revocation
      await _notifyPartnerOfRevocation(connection, reason);
    } catch (e) {
      debugPrint('Error revoking sharing: $e');
      rethrow;
    }
  }

  // Emergency sharing for healthcare providers
  Future<EmergencyShare> createEmergencyShare({
    required String healthcareProviderEmail,
    required String urgencyLevel,
    required String medicalContext,
    DateTime? expiresAt,
  }) async {
    try {
      final currentUser = _auth.currentUser!;
      final shareId = _generateEmergencyShareId();
      
      expiresAt ??= DateTime.now().add(const Duration(hours: 24));

      // Get recent health data
      final recentCycles = await _databaseService.getCyclesInRange(
        DateTime.now().subtract(const Duration(days: 90)),
        DateTime.now(),
      );
      
      final recentTracking = await _databaseService.getTrackingDataInRange(
        DateTime.now().subtract(const Duration(days: 30)),
        DateTime.now(),
      );

      // Create emergency share with all necessary data
      final emergencyShare = EmergencyShare(
        id: shareId,
        ownerUserId: currentUser.uid,
        ownerEmail: currentUser.email!,
        healthcareProviderEmail: healthcareProviderEmail,
        urgencyLevel: urgencyLevel,
        medicalContext: medicalContext,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        accessCode: _generateEmergencyAccessCode(),
      );

      // Encrypt and store emergency data
      final emergencyData = {
        'cycles': recentCycles.map((c) => c.toMap()).toList(),
        'trackingData': recentTracking.map((t) => t.toMap()).toList(),
        'medicalContext': medicalContext,
        'urgencyLevel': urgencyLevel,
      };

      final encryptedData = _encryptEmergencyData(emergencyData);

      await _firestore
          .collection('emergency_shares')
          .doc(shareId)
          .set({
        ...emergencyShare.toMap(),
        'encryptedData': encryptedData,
      });

      // Send emergency notification with access code
      await _sendEmergencyNotification(emergencyShare);

      return emergencyShare;
    } catch (e) {
      debugPrint('Error creating emergency share: $e');
      rethrow;
    }
  }

  // Access emergency shared data
  Future<Map<String, dynamic>> accessEmergencyShare(String shareId, String accessCode) async {
    try {
      final shareDoc = await _firestore
          .collection('emergency_shares')
          .doc(shareId)
          .get();

      if (!shareDoc.exists) {
        throw Exception('Emergency share not found');
      }

      final shareData = shareDoc.data()!;
      final emergencyShare = EmergencyShare.fromMap(shareData);

      // Validate access code
      if (emergencyShare.accessCode != accessCode) {
        throw Exception('Invalid access code');
      }

      // Check if expired
      if (emergencyShare.expiresAt.isBefore(DateTime.now())) {
        throw Exception('Emergency share has expired');
      }

      // Decrypt and return data
      final encryptedData = shareData['encryptedData'];
      final decryptedData = _decryptEmergencyData(encryptedData);

      // Log access
      await _firestore
          .collection('emergency_shares')
          .doc(shareId)
          .update({
        'lastAccessedAt': FieldValue.serverTimestamp(),
        'accessCount': FieldValue.increment(1),
      });

      return decryptedData;
    } catch (e) {
      debugPrint('Error accessing emergency share: $e');
      rethrow;
    }
  }

  // Private helper methods
  Future<SharedConnection?> _getConnection(String connectionId) async {
    final doc = await _firestore
        .collection('shared_connections')
        .doc(connectionId)
        .get();
    
    if (doc.exists) {
      return SharedConnection.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> _setupSharedDataCollection(SharedConnection connection) async {
    await _firestore
        .collection('shared_data')
        .doc(connection.id)
        .set({
      'connectionId': connection.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _shareEncryptedData(String connectionId, String dataType, Map<String, dynamic> data) async {
    final encryptedData = _encryptSharedData(data);
    
    await _firestore
        .collection('shared_data')
        .doc(connectionId)
        .collection(dataType)
        .add({
      ...encryptedData,
      'sharedAt': FieldValue.serverTimestamp(),
    });
  }

  Map<String, dynamic> _encryptSharedData(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    final encrypted = _encrypter.encrypt(jsonString, iv: _iv);
    return {
      'encryptedData': encrypted.base64,
      'iv': _iv.base64,
    };
  }

  Map<String, dynamic> _decryptSharedData(Map<String, dynamic> encryptedData) {
    final encrypted = Encrypted.fromBase64(encryptedData['encryptedData']);
    final iv = IV.fromBase64(encryptedData['iv']);
    final decrypted = _encrypter.decrypt(encrypted, iv: iv);
    return jsonDecode(decrypted);
  }

  Map<String, dynamic> _encryptEmergencyData(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    final encrypted = _encrypter.encrypt(jsonString, iv: _iv);
    return {
      'encryptedData': encrypted.base64,
      'iv': _iv.base64,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> _decryptEmergencyData(Map<String, dynamic> encryptedData) {
    final encrypted = Encrypted.fromBase64(encryptedData['encryptedData']);
    final iv = IV.fromBase64(encryptedData['iv']);
    final decrypted = _encrypter.decrypt(encrypted, iv: iv);
    return jsonDecode(decrypted);
  }

  bool _canShareCycle(SharingPermissions permissions) {
    return permissions.canViewCycles;
  }

  bool _canShareTracking(SharingPermissions permissions) {
    return permissions.canViewTracking;
  }

  Future<void> _deleteSharedData(String connectionId) async {
    final sharedDataDoc = _firestore.collection('shared_data').doc(connectionId);
    
    // Delete cycles
    final cyclesQuery = await sharedDataDoc.collection('cycles').get();
    for (final doc in cyclesQuery.docs) {
      await doc.reference.delete();
    }
    
    // Delete tracking data
    final trackingQuery = await sharedDataDoc.collection('tracking').get();
    for (final doc in trackingQuery.docs) {
      await doc.reference.delete();
    }
    
    // Delete main document
    await sharedDataDoc.delete();
  }

  String _generateInvitationCode() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(Iterable.generate(
      8, (_) => characters.codeUnitAt(random.nextInt(characters.length))
    ));
  }

  String _generateConnectionId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random.secure().nextInt(10000).toString();
  }

  String _generateEmergencyShareId() {
    return 'emergency_' + DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _generateEmergencyAccessCode() {
    const characters = '0123456789';
    final random = Random.secure();
    return String.fromCharCodes(Iterable.generate(
      6, (_) => characters.codeUnitAt(random.nextInt(characters.length))
    ));
  }

  // Notification methods (to be implemented based on your notification system)
  Future<void> _sendSharingNotification(SharingInvitation invitation) async {
    // Implementation for sending invitation notification
  }

  Future<void> _notifyOwnerOfAcceptance(SharingInvitation invitation, User partner) async {
    // Implementation for notifying owner that invitation was accepted
  }

  Future<void> _notifyPartnerOfNewData(SharedConnection connection, int dataCount) async {
    // Implementation for notifying partner of new shared data
  }

  Future<void> _notifyPartnerOfPermissionChange(SharedConnection connection, SharingPermissions newPermissions) async {
    // Implementation for notifying partner of permission changes
  }

  Future<void> _notifyPartnerOfRevocation(SharedConnection connection, String reason) async {
    // Implementation for notifying partner of sharing revocation
  }

  Future<void> _sendEmergencyNotification(EmergencyShare emergencyShare) async {
    // Implementation for sending emergency sharing notification
  }
}

// Models for partner sharing
class SharingInvitation {
  final String id;
  final String ownerUserId;
  final String ownerEmail;
  final String partnerEmail;
  final SharingPermissions permissions;
  final SharingStatus status;
  final String invitationMessage;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? acceptedAt;
  final String? partnerUserId;

  SharingInvitation({
    required this.id,
    required this.ownerUserId,
    required this.ownerEmail,
    required this.partnerEmail,
    required this.permissions,
    required this.status,
    required this.invitationMessage,
    required this.createdAt,
    required this.expiresAt,
    this.acceptedAt,
    this.partnerUserId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerUserId': ownerUserId,
      'ownerEmail': ownerEmail,
      'partnerEmail': partnerEmail,
      'permissions': permissions.toMap(),
      'status': status.toString().split('.').last,
      'invitationMessage': invitationMessage,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'partnerUserId': partnerUserId,
    };
  }

  factory SharingInvitation.fromMap(Map<String, dynamic> map) {
    return SharingInvitation(
      id: map['id'],
      ownerUserId: map['ownerUserId'],
      ownerEmail: map['ownerEmail'],
      partnerEmail: map['partnerEmail'],
      permissions: SharingPermissions.fromMap(map['permissions']),
      status: SharingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status']
      ),
      invitationMessage: map['invitationMessage'],
      createdAt: DateTime.parse(map['createdAt']),
      expiresAt: DateTime.parse(map['expiresAt']),
      acceptedAt: map['acceptedAt'] != null ? DateTime.parse(map['acceptedAt']) : null,
      partnerUserId: map['partnerUserId'],
    );
  }
}

class SharedConnection {
  final String id;
  final String ownerUserId;
  final String ownerEmail;
  final String partnerUserId;
  final String partnerEmail;
  final SharingPermissions permissions;
  final ConnectionStatus status;
  final DateTime createdAt;
  final DateTime lastAccessedAt;

  SharedConnection({
    required this.id,
    required this.ownerUserId,
    required this.ownerEmail,
    required this.partnerUserId,
    required this.partnerEmail,
    required this.permissions,
    required this.status,
    required this.createdAt,
    required this.lastAccessedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerUserId': ownerUserId,
      'ownerEmail': ownerEmail,
      'partnerUserId': partnerUserId,
      'partnerEmail': partnerEmail,
      'permissions': permissions.toMap(),
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt.toIso8601String(),
    };
  }

  factory SharedConnection.fromMap(Map<String, dynamic> map) {
    return SharedConnection(
      id: map['id'],
      ownerUserId: map['ownerUserId'],
      ownerEmail: map['ownerEmail'],
      partnerUserId: map['partnerUserId'],
      partnerEmail: map['partnerEmail'],
      permissions: SharingPermissions.fromMap(map['permissions']),
      status: ConnectionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status']
      ),
      createdAt: DateTime.parse(map['createdAt']),
      lastAccessedAt: DateTime.parse(map['lastAccessedAt']),
    );
  }
}

class SharingPermissions {
  final bool canViewCycles;
  final bool canViewTracking;
  final bool canViewSymptoms;
  final bool canViewAnalytics;
  final bool canReceiveNotifications;
  final bool isHealthcareProvider;

  SharingPermissions({
    required this.canViewCycles,
    required this.canViewTracking,
    required this.canViewSymptoms,
    required this.canViewAnalytics,
    required this.canReceiveNotifications,
    this.isHealthcareProvider = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'canViewCycles': canViewCycles,
      'canViewTracking': canViewTracking,
      'canViewSymptoms': canViewSymptoms,
      'canViewAnalytics': canViewAnalytics,
      'canReceiveNotifications': canReceiveNotifications,
      'isHealthcareProvider': isHealthcareProvider,
    };
  }

  factory SharingPermissions.fromMap(Map<String, dynamic> map) {
    return SharingPermissions(
      canViewCycles: map['canViewCycles'] ?? false,
      canViewTracking: map['canViewTracking'] ?? false,
      canViewSymptoms: map['canViewSymptoms'] ?? false,
      canViewAnalytics: map['canViewAnalytics'] ?? false,
      canReceiveNotifications: map['canReceiveNotifications'] ?? false,
      isHealthcareProvider: map['isHealthcareProvider'] ?? false,
    );
  }
}

class SharedData {
  final String connectionId;
  final List<CycleData> cycles;
  final List<DailyTrackingData> trackingData;
  final DateTime lastUpdated;

  SharedData({
    required this.connectionId,
    required this.cycles,
    required this.trackingData,
    required this.lastUpdated,
  });
}

class EmergencyShare {
  final String id;
  final String ownerUserId;
  final String ownerEmail;
  final String healthcareProviderEmail;
  final String urgencyLevel;
  final String medicalContext;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String accessCode;

  EmergencyShare({
    required this.id,
    required this.ownerUserId,
    required this.ownerEmail,
    required this.healthcareProviderEmail,
    required this.urgencyLevel,
    required this.medicalContext,
    required this.createdAt,
    required this.expiresAt,
    required this.accessCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerUserId': ownerUserId,
      'ownerEmail': ownerEmail,
      'healthcareProviderEmail': healthcareProviderEmail,
      'urgencyLevel': urgencyLevel,
      'medicalContext': medicalContext,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'accessCode': accessCode,
    };
  }

  factory EmergencyShare.fromMap(Map<String, dynamic> map) {
    return EmergencyShare(
      id: map['id'],
      ownerUserId: map['ownerUserId'],
      ownerEmail: map['ownerEmail'],
      healthcareProviderEmail: map['healthcareProviderEmail'],
      urgencyLevel: map['urgencyLevel'],
      medicalContext: map['medicalContext'],
      createdAt: DateTime.parse(map['createdAt']),
      expiresAt: DateTime.parse(map['expiresAt']),
      accessCode: map['accessCode'],
    );
  }
}

enum SharingStatus { pending, accepted, declined, expired }
enum ConnectionStatus { active, paused, revoked }
