import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/call_model.dart';

class CallRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Create a new call document
  Future<CallModel> createCall({
    required String receiverId,
    required String callerName,
    required String callerImage,
    required String receiverName,
    required String receiverImage,
    required String callType,
  }) async {
    try {
      final callerId = currentUserId;
      if (callerId == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique channel name
      final channelName = '${callerId}_${receiverId}_${DateTime.now().millisecondsSinceEpoch}';
      
      final call = CallModel(
        callId: channelName,
        callerId: callerId,
        receiverId: receiverId,
        callerName: callerName,
        callerImage: callerImage,
        receiverName: receiverName,
        receiverImage: receiverImage,
        channelName: channelName,
        callType: callType,
        status: 'ringing',
        timestamp: DateTime.now(),
      );

      await _firestore.collection('calls').doc(channelName).set(call.toMap());
      
      return call;
    } catch (e) {
      throw Exception('Failed to create call: $e');
    }
  }

  /// Update call status
  Future<void> updateCallStatus(String callId, String status) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update call status: $e');
    }
  }

  /// End call and delete document
  Future<void> endCall(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).delete();
    } catch (e) {
      throw Exception('Failed to end call: $e');
    }
  }

  /// Listen for incoming calls
  Stream<List<CallModel>> listenForIncomingCalls() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('calls')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CallModel.fromMap(doc.data());
      }).toList();
    });
  }

  /// Get call by ID
  Future<CallModel?> getCall(String callId) async {
    try {
      final doc = await _firestore.collection('calls').doc(callId).get();
      if (doc.exists) {
        return CallModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Listen to call status changes
  Stream<CallModel?> listenToCallStatus(String callId) {
    return _firestore
        .collection('calls')
        .doc(callId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return CallModel.fromMap(snapshot.data()!);
      }
      return null;
    });
  }
}

