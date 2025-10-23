import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../../../Service/cloudinary_service.dart';
import '../../chat/model/message_model.dart';
import '../../chat/repository/chat_repository.dart';
import '../../notifications/service/notification_service.dart';
import '../model/job_application_model.dart';

class JobApplicationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ChatRepository _chatRepository = ChatRepository();
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = Uuid();

  // Submit job application with resume
  Future<JobApplicationModel> submitJobApplication({
    required String jobId,
    required String jobTitle,
    required String companyId,
    required String companyName,
    required String resumePath,
    required String resumeFileName,
  }) async {
    try {
      print('📝 JobApplicationService: Starting application submission...');
      
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // 1. Upload resume to Cloudinary
      print('☁️ Uploading resume to Cloudinary...');
      final resumeUrl = await _uploadResumeToCloudinary(resumePath, resumeFileName);
      print('✅ Resume uploaded: $resumeUrl');

      // 2. Create job application document
      print('📄 Creating job application document...');
      final applicationId = _uuid.v4();
      final application = JobApplicationModel(
        id: applicationId,
        jobId: jobId,
        jobTitle: jobTitle,
        applicantId: currentUser.uid,
        companyId: companyId,
        companyName: companyName,
        resumeUrl: resumeUrl,
        resumeFileName: resumeFileName,
        status: ApplicationStatus.pending,
        appliedAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore
          .collection('jobApplications')
          .doc(applicationId)
          .set(application.toMap());

      print('✅ Job application saved to Firestore');

      // 3. Get company owner's user ID (the actual person to notify)
      print('🔍 Getting company owner user ID...');
      final companyOwnerUserId = await _getCompanyOwnerUserId(companyId);
      if (companyOwnerUserId == null) {
        throw Exception('Company owner not found');
      }
      print('✅ Company owner user ID: $companyOwnerUserId');

      // 4. Create or get chat room between user and company owner
      print('💬 Creating chat room with company owner...');
      final chatRoomId = await _createOrGetChatRoom(
        userId: currentUser.uid,
        companyOwnerUserId: companyOwnerUserId,
      );

      // 5. Send resume as chat message to company owner
      print('📤 Sending resume as chat message...');
      await _sendResumeMessage(
        chatRoomId: chatRoomId,
        jobId: jobId,
        jobTitle: jobTitle,
        resumeUrl: resumeUrl,
        resumeFileName: resumeFileName,
        applicationId: applicationId,
        companyOwnerUserId: companyOwnerUserId,
      );

      // 6. Send notification to company owner
      print('🔔 Sending notification to company owner...');
      await _notificationService.notifyJobApplication(
        fromUserId: currentUser.uid,
        toUserId: companyOwnerUserId,
        jobTitle: jobTitle,
        applicationId: applicationId,
      );

      print('🎉 Job application submitted successfully!');
      return application;

    } catch (e) {
      print('❌ JobApplicationService: Error submitting application: $e');
      throw Exception('Failed to submit job application: $e');
    }
  }

  // Upload resume to Cloudinary
  Future<String> _uploadResumeToCloudinary(String filePath, String fileName) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Resume file not found');
      }

      // Upload to Cloudinary with specific folder for resumes
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/${_cloudinaryService.cloudName}/upload');
      
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = _cloudinaryService.uploadPreset;
      request.fields['folder'] = 'job_applications/resumes';
      request.fields['resource_type'] = 'raw';

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        filePath,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['secure_url'] ?? responseData['url'] ?? '';
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error uploading resume to Cloudinary: $e');
      throw Exception('Failed to upload resume: $e');
    }
  }

  // Get company owner's user ID
  Future<String?> _getCompanyOwnerUserId(String companyId) async {
    try {
      final companyDoc = await _firestore.collection('companies').doc(companyId).get();
      if (companyDoc.exists) {
        final companyData = companyDoc.data()!;
        final userId = companyData['userId'] as String?;
        print('🔍 Company owner user ID: $userId');
        return userId;
      }
      print('❌ Company not found: $companyId');
      return null;
    } catch (e) {
      print('❌ Error getting company owner: $e');
      return null;
    }
  }

  // Create or get chat room between user and company owner
  Future<String> _createOrGetChatRoom({
    required String userId,
    required String companyOwnerUserId,
  }) async {
    try {
      print('🔍 Checking for existing chat room between $userId and $companyOwnerUserId');
      // Check if chat room already exists
      final existingRooms = await _firestore
          .collection('chatRooms')
          .where('participants', arrayContains: userId)
          .get();

      print('🔍 Found ${existingRooms.docs.length} existing chat rooms');
      for (var room in existingRooms.docs) {
        final participants = List<String>.from(room.data()['participants'] ?? []);
        print('   - Room ${room.id}: participants = $participants');
        if (participants.contains(companyOwnerUserId)) {
          print('✅ Found existing chat room: ${room.id}');
          return room.id;
        }
      }

      // Create new chat room
      final chatRoomId = _uuid.v4();
      print('🔨 Creating new chat room: $chatRoomId');
      print('   Participants: [$userId, $companyOwnerUserId]');
      
      await _firestore.collection('chatRooms').doc(chatRoomId).set({
        'chatRoomId': chatRoomId,
        'participants': [userId, companyOwnerUserId],
        'lastMessage': '',
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
        'lastMessageSenderId': userId,
        'unreadCount': {userId: 0, companyOwnerUserId: 0},
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'type': 'jobApplication', // Special type for job application chats
      });

      print('✅ Created new chat room: $chatRoomId');
      return chatRoomId;

    } catch (e) {
      print('❌ Error creating chat room: $e');
      throw Exception('Failed to create chat room: $e');
    }
  }

  // Send resume as chat message
  Future<void> _sendResumeMessage({
    required String chatRoomId,
    required String jobId,
    required String jobTitle,
    required String resumeUrl,
    required String resumeFileName,
    required String applicationId,
    required String companyOwnerUserId,
  }) async {
    try {
      final currentUser = _auth.currentUser!;
      final messageId = _uuid.v4();

      // Create resume message
      final message = MessageModel(
        messageId: messageId,
        chatRoomId: chatRoomId,
        senderId: currentUser.uid,
        receiverId: companyOwnerUserId,
        content: 'I have applied for the position: $jobTitle. Please find my resume attached.',
        messageType: MessageType.jobApplication,
        timestamp: DateTime.now(),
        mediaUrl: resumeUrl,
        metadata: {
          'jobId': jobId,
          'jobTitle': jobTitle,
          'applicationId': applicationId,
          'resumeFileName': resumeFileName,
          'resumeUrl': resumeUrl,
          'messageType': 'jobApplication',
        },
      );

      // Send message through chat repository
      await _chatRepository.sendMessage(
        chatRoomId: chatRoomId,
        receiverId: companyOwnerUserId,
        content: message.content,
        messageType: message.messageType,
        mediaUrl: message.mediaUrl,
      );

      print('✅ Resume message sent to company');

    } catch (e) {
      print('❌ Error sending resume message: $e');
      throw Exception('Failed to send resume message: $e');
    }
  }


  // Get user's job applications
  Future<List<JobApplicationModel>> getUserApplications() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final snapshot = await _firestore
          .collection('jobApplications')
          .where('applicantId', isEqualTo: currentUser.uid)
          .orderBy('appliedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => JobApplicationModel.fromMap(doc.data()))
          .toList();

    } catch (e) {
      print('❌ Error fetching user applications: $e');
      return [];
    }
  }

  // Get applications for a company
  Future<List<JobApplicationModel>> getCompanyApplications(String companyId) async {
    try {
      final snapshot = await _firestore
          .collection('jobApplications')
          .where('companyId', isEqualTo: companyId)
          .orderBy('appliedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => JobApplicationModel.fromMap(doc.data()))
          .toList();

    } catch (e) {
      print('❌ Error fetching company applications: $e');
      return [];
    }
  }

  // Check if user has already applied to a job
  Future<bool> hasUserAppliedToJob(String jobId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      print('🔍 Checking if user has applied to job: $jobId');

      final snapshot = await _firestore
          .collection('jobApplications')
          .where('jobId', isEqualTo: jobId)
          .where('applicantId', isEqualTo: currentUser.uid)
          .limit(1)
          .get();

      final hasApplied = snapshot.docs.isNotEmpty;
      print(hasApplied ? '✅ User has already applied' : '❌ User has not applied');
      
      return hasApplied;

    } catch (e) {
      print('❌ Error checking if user applied: $e');
      return false;
    }
  }

  // Update application status
  Future<void> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus status,
    String? notes,
  }) async {
    try {
      await _firestore.collection('jobApplications').doc(applicationId).update({
        'status': status.toString().split('.').last,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        if (notes != null) 'notes': notes,
      });

      print('✅ Application status updated: $status');

    } catch (e) {
      print('❌ Error updating application status: $e');
      throw Exception('Failed to update application status: $e');
    }
  }
}
