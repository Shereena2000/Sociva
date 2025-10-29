import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool showControls;
  final double? height;
  final double? width;
  final BoxFit fit;
  final bool enableDoubleTapPlayPause; // Enable double tap to play/pause (for video tab)
  final VoidCallback? onSingleTap; // Optional callback for single tap (overrides default toggleControls)

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
    this.showControls = true,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.enableDoubleTapPlayPause = false,
    this.onSingleTap,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isLoading = true;
  bool _isMuted = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      
      // Add timeout to prevent hanging
      await _controller!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Video initialization timeout');
        },
      );
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });

        if (widget.autoPlay) {
          _controller!.play();
          setState(() {
            _isPlaying = true;
          });
        }

        // Initialize volume based on mute state
        _controller!.setVolume(_isMuted ? 0.0 : 1.0);

        _controller!.addListener(_videoListener);
        
        // Wait for duration to be available (might be 0 initially)
        if (mounted) {
          setState(() {
            _duration = _controller!.value.duration;
            _position = _controller!.value.position;
          });
          
          // If duration is 0, wait a bit and check again
          if (_duration == Duration.zero || _duration.inMilliseconds == 0) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && _controller != null) {
                final newDuration = _controller!.value.duration;
                if (newDuration != Duration.zero && newDuration.inMilliseconds > 0) {
                  setState(() {
                    _duration = newDuration;
                    _position = _controller!.value.position;
                  });
                }
              }
            });
            
            // Also try after 1 second
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted && _controller != null) {
                final newDuration = _controller!.value.duration;
                if (newDuration != Duration.zero && newDuration.inMilliseconds > 0) {
                  setState(() {
                    _duration = newDuration;
                    _position = _controller!.value.position;
                  });
                }
              }
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_controller != null && _isInitialized) {
      if (_isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _videoListener() {
    if (mounted && !_isDragging && _controller != null) {
      final newDuration = _controller!.value.duration;
      final newPosition = _controller!.value.position;
      
      // Only update if duration is valid (greater than 0)
      final validDuration = newDuration != Duration.zero && newDuration.inMilliseconds > 0;
      
      setState(() {
        _isPlaying = _controller!.value.isPlaying;
        _position = newPosition;
        // Only update duration if it's valid, otherwise keep the last known duration
        if (validDuration) {
          _duration = newDuration;
        }
      });
    }
  }

  void _toggleMute() {
    if (_controller != null && _isInitialized) {
      setState(() {
        _isMuted = !_isMuted;
        _controller!.setVolume(_isMuted ? 0.0 : 1.0);
      });
    }
  }

  void _seekTo(Duration position) {
    if (_controller != null && _isInitialized) {
      _controller!.seekTo(position);
      setState(() {
        _position = position;
      });
    }
  }

  void _onSliderChanged(double value) {
    if (_controller != null && _isInitialized) {
      final newPosition = Duration(milliseconds: value.toInt());
      _seekTo(newPosition);
    }
  }

  void _onSliderStart(double value) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onSliderEnd(double value) {
    setState(() {
      _isDragging = false;
    });
    // Sync with actual position after drag ends
    if (_controller != null && _isInitialized) {
      setState(() {
        _position = _controller!.value.position;
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSingleTap ?? _toggleControls, // Use custom callback if provided, otherwise toggle controls
      onDoubleTap: widget.enableDoubleTapPlayPause ? _togglePlayPause : null,
      child: Container(
        height: widget.height,
        width: widget.width,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video player
            if (_isInitialized && _controller != null)
              SizedBox(
                width: widget.width ?? double.infinity,
                height: widget.height ?? 200,
                child: FittedBox(
                  fit: widget.fit,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              )
            else if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Icon(
                    Icons.videocam,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),

            // Mute/Unmute button (top-right corner) - Always visible
            if (_isInitialized && widget.showControls)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _toggleMute,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

            // Play/Pause overlay
            if (_isInitialized && widget.showControls)
              Center(
                child: AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),

            // Video duration, progress bar, and time (draggable)
            if (_isInitialized && widget.showControls && _showControls)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Draggable progress bar
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3.0,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6.0,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12.0,
                          ),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withOpacity(0.3),
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _duration.inMilliseconds > 0
                              ? _position.inMilliseconds.toDouble().clamp(0.0, _duration.inMilliseconds.toDouble())
                              : 0.0,
                          max: _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
                          onChangeStart: _onSliderStart,
                          onChangeEnd: _onSliderEnd,
                          onChanged: _onSliderChanged,
                        ),
                      ),
                      // Time display
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
