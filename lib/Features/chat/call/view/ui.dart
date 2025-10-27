import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../model/call_model.dart';
import '../view_model/call_view_model.dart';

class CallScreen extends StatelessWidget {
  final CallModel call;
  final bool isCaller;

  const CallScreen({
    super.key,
    required this.call,
    required this.isCaller,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = CallViewModel();
        if (!isCaller) {
          // Receiver accepts the call
          viewModel.acceptCall(call);
        }
        return viewModel;
      },
      child: _CallScreenContent(
        call: call,
        isCaller: isCaller,
      ),
    );
  }
}

class _CallScreenContent extends StatelessWidget {
  final CallModel call;
  final bool isCaller;

  const _CallScreenContent({
    required this.call,
    required this.isCaller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CallViewModel>(
        builder: (context, viewModel, child) {
          // Show error if any
          if (viewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }

          return SafeArea(
            child: Stack(
              children: [
                // Video views (if video enabled)
                if (viewModel.videoEnabled)
                  _buildVideoViews(context, viewModel)
                else
                  _buildVoiceCallUI(context, viewModel),

                // Top bar with minimize button
                Positioned(
                  top: 20,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                // Bottom controls
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: _buildCallControls(context, viewModel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoViews(BuildContext context, CallViewModel viewModel) {
    return Stack(
      children: [
        // Remote video (full screen)
        if (viewModel.remoteUid != null)
          SizedBox.expand(
            child: AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: viewModel.engine!,
                canvas: VideoCanvas(uid: viewModel.remoteUid),
                connection: RtcConnection(channelId: call.channelName),
              ),
            ),
          )
        else
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    isCaller ? call.receiverImage : call.callerImage
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isCaller ? call.receiverName : call.callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Connecting...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

        // Local video (small preview)
        if (viewModel.localUserJoined)
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => viewModel.switchCamera(),
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: viewModel.engine!,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVoiceCallUI(BuildContext context, CallViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Profile image with rings
          Stack(
            alignment: Alignment.center,
            children: [
              // Animated rings
              ...List.generate(3, (index) {
                return Container(
                  width: 200 + (index * 40.0),
                  height: 200 + (index * 40.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1 - (index * 0.03)),
                      width: 2,
                    ),
                  ),
                );
              }),
              // Profile image
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: CircleAvatar(
                  radius: 76,
                  backgroundImage: NetworkImage(
                    isCaller ? call.receiverImage : call.callerImage
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          
          // Caller name
          Text(
            isCaller ? call.receiverName : call.callerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Call status
          Text(
            viewModel.remoteUid != null ? 'Connected' : 'Calling...',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls(BuildContext context, CallViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Speaker button (voice call only)
          if (!viewModel.videoEnabled)
            _buildControlButton(
              icon: viewModel.isSpeakerOn ? Icons.volume_up : Icons.volume_off,
              label: 'Speaker',
              color: viewModel.isSpeakerOn ? Colors.blue : Colors.white,
              backgroundColor: viewModel.isSpeakerOn 
                  ? Colors.blue.withOpacity(0.2) 
                  : Colors.white.withOpacity(0.2),
              onTap: () => viewModel.toggleSpeaker(),
            ),

          // Start/Stop Video button
          _buildControlButton(
            icon: viewModel.videoEnabled ? Icons.videocam : Icons.videocam_off,
            label: viewModel.videoEnabled ? 'Stop Video' : 'Start Video',
            color: Colors.white,
            backgroundColor: Colors.white.withOpacity(0.2),
            onTap: () async {
              if (viewModel.videoEnabled) {
                await viewModel.disableVideo();
              } else {
                // Show confirmation dialog for starting video
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.grey[900],
                    title: const Text(
                      'Share Video',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'Do you want to start video call?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Start Video'),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true) {
                  await viewModel.enableVideo();
                }
              }
            },
          ),

          // Mute button
          _buildControlButton(
            icon: viewModel.muted ? Icons.mic_off : Icons.mic,
            label: 'Mute',
            color: Colors.white,
            backgroundColor: viewModel.muted 
                ? Colors.red.withOpacity(0.3) 
                : Colors.white.withOpacity(0.2),
            onTap: () => viewModel.toggleMute(),
          ),

          // End call button
          _buildControlButton(
            icon: Icons.call_end,
            label: 'End Call',
            color: Colors.white,
            backgroundColor: Colors.red,
            onTap: () async {
              await viewModel.endCall();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
