import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../data/file_service.dart';
import '../../logic/search_cubit.dart';
import '../../logic/search_state.dart';
import '../widgets/video_player_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _keywordController = TextEditingController();
  File? _selectedFile;
  String _fileType = 'text';
  final FileService _fileService = FileService();
  VideoPlayerController? _videoController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _pulseController;

  static const Color _bg = Color(0xFF0D0D14);
  static const Color _card = Color(0xFF16161F);
  static const Color _accent = Color(0xFF6C63FF);
  static const Color _accentLight = Color(0xFF9D97FF);
  static const Color _surface = Color(0xFF1E1E2A);
  static const Color _textPrimary = Color(0xFFE8E8F0);
  static const Color _textSecondary = Color(0xFF7A7A9A);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer.dispose();
    _pulseController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String type) async {
    FileType pickerType;
    switch (type) {
      case 'audio':
        pickerType = FileType.audio;
        break;
      case 'video':
        pickerType = FileType.video;
        break;
      default:
        pickerType = FileType.any;
    }

    final file = await _fileService.pickFile(type: pickerType);
    if (file != null) {
      _videoController?.dispose();
      setState(() {
        _selectedFile = file;
        _fileType = type;
        _videoController = null;
      });

      if (type == 'video') {
        final controller = VideoPlayerController.file(file);
        await controller.initialize();
        setState(() => _videoController = controller);
      }
      context.read<SearchCubit>().reset();
    }
  }

  String _formatDuration(double seconds) {
    final d = Duration(milliseconds: (seconds * 1000).toInt());
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  IconData _fileIcon() {
    switch (_fileType) {
      case 'audio':
        return Icons.music_note_rounded;
      case 'video':
        return Icons.videocam_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  Color _fileColor() {
    switch (_fileType) {
      case 'audio':
        return const Color(0xFF00C9A7);
      case 'video':
        return const Color(0xFFFF6584);
      default:
        return _accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_accent, Color(0xFFB06AFF)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.search_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Speck to text',
                              style: TextStyle(
                                color: _textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Smart Search',
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'SELECT FILE TYPE',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildFileTypeButton(
                          'text',
                          'Text',
                          Icons.description_rounded,
                          _accent,
                        ),
                        const SizedBox(width: 10),
                        _buildFileTypeButton(
                          'audio',
                          'Audio',
                          Icons.music_note_rounded,
                          const Color(0xFF00C9A7),
                        ),
                        const SizedBox(width: 10),
                        _buildFileTypeButton(
                          'video',
                          'Video',
                          Icons.videocam_rounded,
                          const Color(0xFFFF6584),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Selected file card
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _selectedFile != null
                          ? _buildSelectedFileCard()
                          : _buildEmptyFileCard(),
                    ),

                    const SizedBox(height: 20),

                    // Search field
                    Container(
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: TextField(
                        controller: _keywordController,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter keyword to search...',
                          hintStyle: TextStyle(color: _textSecondary),
                          prefixIcon: Icon(
                            Icons.manage_search_rounded,
                            color: _textSecondary,
                            size: 22,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        onSubmitted: (_) => _doSearch(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Search button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _doSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt_rounded, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Search with AI',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Results
            SliverToBoxAdapter(
              child: BlocConsumer<SearchCubit, SearchState>(
                listener: (context, state) {
                  if (state is SearchResult && state.timestamp != null) {
                    final dur = Duration(
                      milliseconds: (state.timestamp! * 1000).toInt(),
                    );
                    if (_fileType == 'video' && _videoController != null) {
                      _videoController!.seekTo(dur);
                      _videoController!.play();
                    } else if (_fileType == 'audio') {
                      _audioPlayer.play(DeviceFileSource(_selectedFile!.path));
                      _audioPlayer.seek(dur);
                    }
                  }
                },
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildResultArea(state),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTypeButton(
    String type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _fileType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => _pickFile(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color.withOpacity(0.6) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : _textSecondary, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : _textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyFileCard() {
    return GestureDetector(
      onTap: () => _pickFile(_fileType),
      child: Container(
        key: const ValueKey('empty'),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_upload_outlined, color: _textSecondary, size: 40),
            const SizedBox(height: 10),
            Text(
              'Tap to pick a file',
              style: TextStyle(color: _textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFileCard() {
    final name = _selectedFile!.path.split('/').last;
    final color = _fileColor();
    return Container(
      key: const ValueKey('selected'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_fileIcon(), color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _fileType.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _pickFile(_fileType),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.swap_horiz_rounded,
                color: _textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultArea(SearchState state) {
    if (state is SearchLoading) {
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) => Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _accent.withOpacity(0.1 + _pulseController.value * 0.2),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: const AlwaysStoppedAnimation<Color>(_accent),
                  backgroundColor: _accent.withOpacity(0.15),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'AI is analyzing your file...',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'This may take a moment',
                style: TextStyle(color: _textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (state is SearchError) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6584).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF6584).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFFF6584),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.message,
                style: const TextStyle(color: Color(0xFFFF6584), fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    if (state is SearchResult) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_accent, Color(0xFFB06AFF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Result Found',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Timestamp result
          if (state.timestamp != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _accent.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.timer_outlined,
                      color: _accent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Found at timestamp',
                        style: TextStyle(color: _textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(state.timestamp!),
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Text location result
          if (state.textLocation != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _fileType == 'text'
                            ? Icons.format_quote_rounded
                            : Icons.subtitles_outlined,
                        color: _accentLight,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _fileType == 'text' ? 'AI Analysis' : 'Transcript',
                        style: const TextStyle(
                          color: _accentLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.textLocation!,
                    style: TextStyle(
                      color: _textPrimary.withOpacity(0.85),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Video player
          if (_fileType == 'video' &&
              _videoController != null &&
              _videoController!.value.isInitialized) ...[
            VideoPlayerWidget(controller: _videoController!),
            const SizedBox(height: 12),
          ],

          // Audio controls
          if (_fileType == 'audio' && state.timestamp != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00C9A7).withOpacity(0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.music_note_rounded,
                    color: const Color(0xFF00C9A7),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Audio playing from ${_formatDuration(state.timestamp!)}',
                      style: const TextStyle(color: _textPrimary, fontSize: 14),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _audioPlayer.pause(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C9A7).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.pause_rounded,
                        color: Color(0xFF00C9A7),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.manage_search_rounded,
            color: _textSecondary.withOpacity(0.4),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Ready to Search',
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick a file and enter a keyword\nto find its location with AI',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textSecondary, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  void _doSearch() {
    if (_selectedFile != null && _keywordController.text.trim().isNotEmpty) {
      context.read<SearchCubit>().search(
        _selectedFile!,
        _keywordController.text.trim(),
        _fileType,
      );
    }
  }
}
