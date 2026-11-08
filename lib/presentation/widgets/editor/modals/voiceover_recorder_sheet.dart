import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

class VoiceoverRecorderSheet extends StatefulWidget {
  final Duration startPosition;
  final Function(String title, Duration duration) onSaveVoiceover;

  const VoiceoverRecorderSheet({
    super.key,
    required this.startPosition,
    required this.onSaveVoiceover,
  });

  static Future<void> show({
    required BuildContext context,
    required Duration startPosition,
    required Function(String title, Duration duration) onSaveVoiceover,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => VoiceoverRecorderSheet(
        startPosition: startPosition,
        onSaveVoiceover: onSaveVoiceover,
      ),
    );
  }

  @override
  State<VoiceoverRecorderSheet> createState() => _VoiceoverRecorderSheetState();
}

class _VoiceoverRecorderSheetState extends State<VoiceoverRecorderSheet>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  Duration _recordedDuration = Duration.zero;
  Timer? _timer;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordedDuration = Duration.zero;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _recordedDuration += const Duration(milliseconds: 100);
      });
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() {
      _isRecording = false;
    });
  }

  void _handleSave() {
    if (_recordedDuration < const Duration(milliseconds: 500)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rekaman terlalu singkat (minimal 0.5 detik)'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final voiceoverTitle = 'Voiceover_${DateTime.now().millisecondsSinceEpoch % 10000}.m4a';
    widget.onSaveVoiceover(voiceoverTitle, _recordedDuration);
    Navigator.pop(context);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final tenths = (d.inMilliseconds.remainder(1000) ~/ 100).toString();
    return '$minutes:$seconds.$tenths';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            const Text(
              'Rekam Suara (Voiceover)',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Akan disematkan mulai posisi: ${_formatDuration(widget.startPosition)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Live Timer Display
            Text(
              _formatDuration(_recordedDuration),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: _isRecording ? const Color(0xFFFF2D55) : Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Mic Record Button with Pulse Effect
            GestureDetector(
              onTap: _toggleRecording,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = _isRecording ? 1.0 + (_pulseController.value * 0.15) : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? const Color(0xFFFF2D55) : AppColors.surface,
                        border: Border.all(
                          color: _isRecording ? const Color(0xFFFF375F) : AppColors.primary,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? const Color(0xFFFF2D55) : AppColors.primary)
                                .withValues(alpha: 0.35),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? LucideIcons.square : LucideIcons.mic,
                        color: _isRecording ? Colors.white : AppColors.primary,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            Text(
              _isRecording ? 'Ketuk untuk berhenti' : 'Ketuk mikrofon untuk mulai merekam',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _recordedDuration > Duration.zero ? _handleSave : null,
                    child: const Text(
                      'Gunakan Rekaman',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

