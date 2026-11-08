import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/media_picker_service.dart';
import '../../data/models/project_draft.dart';
import '../../data/models/timeline_project.dart';
import 'editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _mediaPicker = MediaPickerService();

  // Sample initial drafts for presentation
  final List<ProjectDraft> _drafts = [
    ProjectDraft(
      id: 'draft-1',
      title: 'Vlog Senja Bali #1',
      duration: const Duration(minutes: 1, seconds: 24),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      aspectRatio: '9:16',
      clipCount: 4,
    ),
    ProjectDraft(
      id: 'draft-2',
      title: 'Cinematic Reel Beat Sync',
      duration: const Duration(seconds: 45),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      aspectRatio: '9:16',
      clipCount: 8,
    ),
    ProjectDraft(
      id: 'draft-3',
      title: 'Tutorial Masak Simple',
      duration: const Duration(minutes: 3, seconds: 12),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      aspectRatio: '16:9',
      clipCount: 6,
    ),
  ];

  Future<void> _openEditor({ProjectDraft? draft, TimelineProject? project}) async {
    final result = await Navigator.of(context).push<ProjectDraft>(
      MaterialPageRoute(
        builder: (context) => EditorScreen(
          initialDraft: draft,
          initialProject: project,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        final existingIndex = _drafts.indexWhere((d) => d.id == result.id);
        if (existingIndex >= 0) {
          _drafts[existingIndex] = result;
        } else {
          _drafts.insert(0, result);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Draft "${result.title}" berhasil disimpan'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleNewProject() async {
    final files = await _mediaPicker.pickMultipleVideos();
    if (!mounted) return;

    if (files.isNotEmpty) {
      final project = _mediaPicker.createProjectFromFiles(
        files: files,
        title: 'Proyek ${files.first.name}',
      );
      _openEditor(project: project);
    } else {
      _openEditor();
    }
  }

  Future<void> _handleCameraCapture() async {
    final file = await _mediaPicker.captureVideoWithCamera();
    if (!mounted || file == null) return;

    final project = _mediaPicker.createProjectFromFiles(
      files: [file],
      title: 'Rekaman ${file.name}',
    );
    _openEditor(project: project);
  }

  void _deleteDraft(String id) {
    setState(() {
      _drafts.removeWhere((d) => d.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Proyek berhasil dihapus'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accentBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                LucideIcons.scissors,
                size: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'BIL',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: '_CUT',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, size: 20),
            onPressed: () {},
            tooltip: 'Notifikasi',
          ),
          IconButton(
            icon: const Icon(LucideIcons.settings, size: 20),
            onPressed: _showSettingsSheet,
            tooltip: 'Pengaturan',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Banner New Project
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: _buildNewProjectHero(),
            ),
          ),

          // Quick Tools Row (Camera, AutoCut, Denoise, Prompt)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildQuickTools(),
            ),
          ),

          // Section Title: Proyek Terbaru
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Proyek Terbaru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_drafts.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Kelola',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Drafts List / Grid
          if (_drafts.isEmpty)
            SliverToBoxAdapter(
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final draft = _drafts[index];
                    return _buildDraftCard(draft);
                  },
                  childCount: _drafts.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildNewProjectHero() {
    return GestureDetector(
      onTap: _handleNewProject,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1E2836),
              Color(0xFF131A24),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              bottom: -15,
              child: Icon(
                LucideIcons.video,
                size: 110,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.plus,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Proyek Baru',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Import video atau foto untuk mulai mengedit',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    LucideIcons.chevronRight,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTools() {
    final tools = [
      {
        'icon': LucideIcons.camera,
        'label': 'Kamera',
        'color': const Color(0xFF00E5FF),
        'action': () => _handleCameraCapture(),
      },
      {
        'icon': LucideIcons.wand2,
        'label': 'AutoCut',
        'color': const Color(0xFFFF2D55),
        'action': () => _handleNewProject(),
      },
      {
        'icon': LucideIcons.fileText,
        'label': 'Teks ke Video',
        'color': const Color(0xFFFFD60A),
        'action': () => _openEditor(),
      },
      {
        'icon': LucideIcons.mic,
        'label': 'Voiceover',
        'color': const Color(0xFF30D158),
        'action': () => _openEditor(),
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: tools.map((tool) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: tool['action'] as VoidCallback?,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Icon(
                        tool['icon'] as IconData,
                        size: 22,
                        color: tool['color'] as Color,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tool['label'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accentBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.scissors,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'BIL',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              TextSpan(
                                text: '_CUT',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          'Versi 1.0.0 • Pro Video Editor Engine',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'ENGINE & ARSITEKTUR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                _buildSettingItem(
                  icon: LucideIcons.cpu,
                  title: 'Custom Timeline Engine',
                  subtitle: 'Multi-track LOD Ruler & Magnetic Snapping',
                ),
                _buildSettingItem(
                  icon: LucideIcons.sparkles,
                  title: 'GPU Shader Color Matrix',
                  subtitle: 'Real-time 60 FPS hardware color filter & adjustments',
                ),
                _buildSettingItem(
                  icon: LucideIcons.film,
                  title: 'Video Export Pipeline',
                  subtitle: '4K/1080P/720P multi-stage video compositing engine',
                ),
                const SizedBox(height: 16),
                const Text(
                  'PENYIMPANAN & CACHE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                  ),
                  title: const Text(
                    'Bersihkan Cache Video',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  subtitle: const Text(
                    'Hapus thumbnail sementara dan cache render preview',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cache aplikasi berhasil dibersihkan'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('Bersihkan', style: TextStyle(color: AppColors.error)),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Dibuat oleh Labildev • Flutter & Native Engine',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftCard(ProjectDraft draft) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openEditor(draft: draft),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail container
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        LucideIcons.film,
                        color: AppColors.textMuted,
                        size: 26,
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            draft.aspectRatio,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Project Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.clock,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            draft.formattedDuration,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            LucideIcons.layers,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${draft.clipCount} klip',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        draft.formattedDate,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action Menu Popup
                PopupMenuButton<String>(
                  icon: const Icon(
                    LucideIcons.moreVertical,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  color: AppColors.surfaceElevated,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteDraft(draft.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(LucideIcons.edit2, size: 16),
                          SizedBox(width: 10),
                          Text('Ganti Nama'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(LucideIcons.copy, size: 16),
                          SizedBox(width: 10),
                          Text('Duplikat'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                          SizedBox(width: 10),
                          Text('Hapus', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              LucideIcons.folderClosed,
              size: 40,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada draft proyek',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Klik tombol "Proyek Baru" di atas untuk mulai membuat video pertama Anda.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
