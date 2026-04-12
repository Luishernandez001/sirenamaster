// ============================================================
// expert_chat_screen.dart — Chat con asistente pedagógico IA
// Interfaz conversacional integrada en la app
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../core/models/report_model.dart';
import '../core/utils/groq_chat_service.dart';

class ExpertChatScreen extends StatefulWidget {
  final List<ReportModel> selectedReports;
  const ExpertChatScreen({super.key, required this.selectedReports});

  @override
  State<ExpertChatScreen> createState() => _ExpertChatScreenState();
}

class _ExpertChatScreenState extends State<ExpertChatScreen>
    with TickerProviderStateMixin {
  final GroqChatService _chatService = GroqChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = false;
  bool _initialLoading = true;
  String? _errorMessage;

  final List<_ChatBubbleData> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _startInitialConversation();
  }

  Future<void> _startInitialConversation() async {
    _bubbles.add(_ChatBubbleData(
      role: 'context',
      content: _buildContextSummary(),
      timestamp: DateTime.now(),
    ));

    setState(() => _initialLoading = true);

    try {
      final response =
          await _chatService.startConversation(widget.selectedReports);
      _bubbles.add(_ChatBubbleData(
        role: 'assistant',
        content: response,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    if (mounted) {
      setState(() => _initialLoading = false);
      _scrollToBottom();
    }
  }

  String _buildContextSummary() {
    final count = widget.selectedReports.length;
    final priorities = <String, int>{};
    final categories = <String, int>{};
    for (final r in widget.selectedReports) {
      priorities[r.priority] = (priorities[r.priority] ?? 0) + 1;
      categories[r.category] = (categories[r.category] ?? 0) + 1;
    }

    final prioStr =
        priorities.entries.map((e) => '${e.value} ${e.key}').join(', ');
    final catStr =
        categories.entries.map((e) => '${e.value} ${e.key}').join(', ');

    return 'Analizando $count reporte${count > 1 ? "s" : ""}:\n'
        'Prioridades: $prioStr\n'
        'Categorías: $catStr';
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _messageController.clear();
    _bubbles.add(_ChatBubbleData(
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    ));
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _scrollToBottom();

    try {
      final response = await _chatService.sendMessage(text);
      _bubbles.add(_ChatBubbleData(
        role: 'assistant',
        content: response,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    if (mounted) {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildChatArea()),
          if (_errorMessage != null) _buildErrorBanner(),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppColors.secondaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.psychology_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asistente Pedagógico',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  _isLoading || _initialLoading
                      ? 'Analizando…'
                      : 'Orientación escolar con IA',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _isLoading || _initialLoading
                        ? const Color(0xFF81C784)
                        : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFF0EDF6)),
      ),
    );
  }

  Widget _buildChatArea() {
    if (_initialLoading && _bubbles.length <= 1) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    AlwaysStoppedAnimation(Colors.deepPurple.shade300),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Consultando al asistente pedagógico…',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Analizando ${widget.selectedReports.length} reporte${widget.selectedReports.length > 1 ? "s" : ""} seleccionado${widget.selectedReports.length > 1 ? "s" : ""}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _bubbles.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _bubbles.length && _isLoading) {
          return const _TypingIndicator();
        }
        return _buildBubble(_bubbles[index]);
      },
    );
  }

  Widget _buildBubble(_ChatBubbleData data) {
    switch (data.role) {
      case 'context':
        return _ContextCard(content: data.content);
      case 'user':
        return _UserBubble(content: data.content, timestamp: data.timestamp);
      case 'assistant':
        return _AssistantBubble(
            content: data.content, timestamp: data.timestamp);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.priorityHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.priorityHighText, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage ?? 'Error desconocido',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.priorityHighText),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _errorMessage = null),
            child: const Icon(Icons.close_rounded,
                color: AppColors.priorityHighText, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0EDF6))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                enabled: !_isLoading && !_initialLoading,
                maxLines: 4,
                minLines: 1,
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'Escribe tu pregunta al experto…',
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textLight),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isLoading || _initialLoading ? null : _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: _isLoading || _initialLoading
                    ? null
                    : AppColors.secondaryGradient,
                color: _isLoading || _initialLoading
                    ? const Color(0xFFE0E0E0)
                    : null,
                borderRadius: BorderRadius.circular(22),
                boxShadow: _isLoading || _initialLoading
                    ? []
                    : [
                        BoxShadow(
                          color: const Color(0xFF81C784).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Icon(
                Icons.send_rounded,
                size: 20,
                color: _isLoading || _initialLoading
                    ? AppColors.textLight
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data class para burbujas ─────────────────────────────────
class _ChatBubbleData {
  final String role;
  final String content;
  final DateTime timestamp;

  _ChatBubbleData({
    required this.role,
    required this.content,
    required this.timestamp,
  });
}

// ── Widget: tarjeta de contexto (reportes cargados) ─────────
class _ContextCard extends StatelessWidget {
  final String content;
  const _ContextCard({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD1C4E9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF9575CD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.article_rounded,
                color: Colors.white, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reportes cargados',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5E35B1),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF7E57C2),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget: burbuja del usuario ──────────────────────────────
class _UserBubble extends StatelessWidget {
  final String content;
  final DateTime timestamp;
  const _UserBubble({required this.content, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(bottom: 12, left: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9575CD).withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget: burbuja del asistente ────────────────────────────
class _AssistantBubble extends StatelessWidget {
  final String content;
  final DateTime timestamp;
  const _AssistantBubble({required this.content, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: AppColors.secondaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.psychology_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12, right: 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormattedText(content: content),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: content));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Respuesta copiada al portapapeles',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              backgroundColor: const Color(0xFF9575CD),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Icon(Icons.copy_rounded,
                            size: 13, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget: texto formateado (negritas, listas) ─────────────
class _FormattedText extends StatelessWidget {
  final String content;
  const _FormattedText({required this.content});

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    final spans = <InlineSpan>[];

    for (var i = 0; i < lines.length; i++) {
      if (i > 0) spans.add(const TextSpan(text: '\n'));
      _parseLine(lines[i], spans);
    }

    return Text.rich(
      TextSpan(children: spans),
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: AppColors.textDark,
        height: 1.55,
      ),
    );
  }

  void _parseLine(String line, List<InlineSpan> spans) {
    final boldPattern = RegExp(r'\*\*(.+?)\*\*');
    var lastEnd = 0;

    for (final match in boldPattern.allMatches(line)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: line.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < line.length) {
      spans.add(TextSpan(text: line.substring(lastEnd)));
    }
  }
}

// ── Widget: indicador de "escribiendo…" ─────────────────────
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: AppColors.secondaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.psychology_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: AppColors.softShadow,
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.25;
                    final t = (_controller.value + delay) % 1.0;
                    final y = -4.0 * (t < 0.5 ? t : 1.0 - t);
                    return Transform.translate(
                      offset: Offset(0, y),
                      child: Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF81C784)
                              .withValues(alpha: 0.5 + 0.5 * (1.0 - t)),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
