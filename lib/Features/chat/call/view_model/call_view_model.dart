import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../model/call_model.dart';
import '../repository/call_repository.dart';
import '../config/agora_config.dart';

class CallViewModel extends ChangeNotifier {
  final CallRepository _callRepository = CallRepository();
  
  RtcEngine? _engine;
  CallModel? _currentCall;
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _muted = false;
  bool _videoEnabled = false;
  bool _isInitialized = false;
  String? _errorMessage;
  bool _isSpeakerOn = false;

  // Getters
  RtcEngine? get engine => _engine;
  CallModel? get currentCall => _currentCall;
  int? get remoteUid => _remoteUid;
  bool get localUserJoined => _localUserJoined;
  bool get muted => _muted;
  bool get videoEnabled => _videoEnabled;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isVideoCall => _currentCall?.callType == 'video';

  /// Initialize Agora Engine
  Future<bool> initializeAgora() async {
    try {
      // Check if Agora is configured
      if (!AgoraConfig.isConfigured) {
        _errorMessage = 'Agora App ID not configured. Please add your App ID in agora_config.dart';
        notifyListeners();
        return false;
      }

      // Create engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: AgoraConfig.appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Register event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
            debugPrint('✅ Local user joined channel: ${connection.channelId}');
            _localUserJoined = true;
            
            // Enable speaker for voice calls after joining
            if (!_videoEnabled) {
              try {
                await _engine?.setEnableSpeakerphone(true);
                _isSpeakerOn = true;
                debugPrint('🔊 Speaker enabled');
              } catch (e) {
                debugPrint('⚠️ Could not enable speaker: $e');
              }
            }
            
            notifyListeners();
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint('👤 Remote user joined: $remoteUid');
            _remoteUid = remoteUid;
            notifyListeners();
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint('👋 Remote user left: $remoteUid');
            _remoteUid = null;
            notifyListeners();
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            debugPrint('📞 Left channel');
            _localUserJoined = false;
            _remoteUid = null;
            notifyListeners();
          },
        ),
      );

      _isInitialized = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error initializing Agora: $e');
      _errorMessage = 'Failed to initialize: $e';
      notifyListeners();
      return false;
    }
  }

  /// Request permissions
  Future<bool> requestPermissions(bool needVideo) async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        if (needVideo) Permission.camera,
      ].request();

      bool allGranted = statuses.values.every((status) => status.isGranted);
      
      if (!allGranted) {
        _errorMessage = 'Permissions not granted';
        notifyListeners();
      }
      
      return allGranted;
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
      _errorMessage = 'Failed to request permissions: $e';
      notifyListeners();
      return false;
    }
  }

  /// Start call (for caller)
  Future<CallModel?> startCall({
    required String receiverId,
    required String callerName,
    required String callerImage,
    required String receiverName,
    required String receiverImage,
    required bool isVideo,
  }) async {
    try {
      // Request permissions
      bool permissionsGranted = await requestPermissions(isVideo);
      if (!permissionsGranted) {
        return null;
      }

      // Initialize Agora if not already initialized
      if (!_isInitialized) {
        bool initialized = await initializeAgora();
        if (!initialized) {
          return null;
        }
      }

      // Create call in Firestore
      final call = await _callRepository.createCall(
        receiverId: receiverId,
        callerName: callerName,
        callerImage: callerImage,
        receiverName: receiverName,
        receiverImage: receiverImage,
        callType: isVideo ? 'video' : 'voice',
      );

      _currentCall = call;
      _videoEnabled = isVideo;

      // Join channel
      await joinChannel(call.channelName, isVideo);

      notifyListeners();
      return call;
    } catch (e) {
      debugPrint('❌ Error starting call: $e');
      _errorMessage = 'Failed to start call: $e';
      notifyListeners();
      return null;
    }
  }

  /// Join channel
  Future<void> joinChannel(String channelName, bool enableVideo) async {
    try {
      if (_engine == null) {
        throw Exception('Engine not initialized');
      }

      if (enableVideo) {
        await _engine!.enableVideo();
        await _engine!.startPreview();
        _videoEnabled = true;
      } else {
        await _engine!.enableAudio();
        _videoEnabled = false;
      }

      // Join channel
      await _engine!.joinChannel(
        token: AgoraConfig.token ?? '',
        channelId: channelName,
        uid: 0,
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          autoSubscribeAudio: true,
          autoSubscribeVideo: enableVideo,
        ),
      );

      debugPrint('📞 Joining channel: $channelName');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error joining channel: $e');
      _errorMessage = 'Failed to join channel: $e';
      notifyListeners();
    }
  }

  /// Toggle mute
  Future<void> toggleMute() async {
    try {
      _muted = !_muted;
      await _engine?.muteLocalAudioStream(_muted);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error toggling mute: $e');
    }
  }

  /// Toggle speaker
  Future<void> toggleSpeaker() async {
    try {
      _isSpeakerOn = !_isSpeakerOn;
      await _engine?.setEnableSpeakerphone(_isSpeakerOn);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error toggling speaker: $e');
    }
  }

  /// Enable video (upgrade from voice to video call)
  Future<void> enableVideo() async {
    try {
      if (_videoEnabled) return;

      // Request camera permission
      bool permissionGranted = await Permission.camera.request().isGranted;
      if (!permissionGranted) {
        _errorMessage = 'Camera permission not granted';
        notifyListeners();
        return;
      }

      await _engine?.enableVideo();
      await _engine?.startPreview();
      _videoEnabled = true;
      
      // Update call type in Firestore
      if (_currentCall != null) {
        await _callRepository.updateCallStatus(_currentCall!.callId, 'ongoing');
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error enabling video: $e');
      _errorMessage = 'Failed to enable video: $e';
      notifyListeners();
    }
  }

  /// Disable video
  Future<void> disableVideo() async {
    try {
      await _engine?.disableVideo();
      await _engine?.stopPreview();
      _videoEnabled = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error disabling video: $e');
    }
  }

  /// Switch camera
  Future<void> switchCamera() async {
    try {
      await _engine?.switchCamera();
    } catch (e) {
      debugPrint('❌ Error switching camera: $e');
    }
  }

  /// End call
  Future<void> endCall() async {
    try {
      // Leave channel
      await _engine?.leaveChannel();
      
      // Stop preview if video enabled
      if (_videoEnabled) {
        await _engine?.stopPreview();
      }

      // Update call status in Firestore
      if (_currentCall != null) {
        await _callRepository.endCall(_currentCall!.callId);
      }

      // Reset state
      _currentCall = null;
      _remoteUid = null;
      _localUserJoined = false;
      _muted = false;
      _videoEnabled = false;
      _isSpeakerOn = false;

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error ending call: $e');
    }
  }

  /// Accept incoming call
  Future<void> acceptCall(CallModel call) async {
    try {
      _currentCall = call;
      
      // Request permissions
      bool permissionsGranted = await requestPermissions(call.callType == 'video');
      if (!permissionsGranted) {
        return;
      }

      // Initialize Agora if not already initialized
      if (!_isInitialized) {
        bool initialized = await initializeAgora();
        if (!initialized) {
          return;
        }
      }

      // Update call status
      await _callRepository.updateCallStatus(call.callId, 'ongoing');

      // Join channel
      await joinChannel(call.channelName, call.callType == 'video');

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error accepting call: $e');
      _errorMessage = 'Failed to accept call: $e';
      notifyListeners();
    }
  }

  /// Reject incoming call
  Future<void> rejectCall(CallModel call) async {
    try {
      await _callRepository.updateCallStatus(call.callId, 'rejected');
      await _callRepository.endCall(call.callId);
    } catch (e) {
      debugPrint('❌ Error rejecting call: $e');
    }
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }
}

