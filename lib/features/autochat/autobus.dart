import 'package:autobus/barrel.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/autochat_repository.dart';
import 'chat_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import 'models/chat_message.dart';

class AutoBus extends StatefulWidget {
  final String title;

  /// Webhook `context` when set; otherwise inferred from [title].
  final String? webhookContext;

  const AutoBus({super.key, this.title = 'Orders', this.webhookContext});

  /// Maps dashboard titles to backend `context` values for `start-dialog`.
  static String defaultWebhookContextForTitle(String title) {
    switch (title.trim().toLowerCase()) {
      case 'orders':
        return 'order_agent';
      case 'chatbot':
        return 'chatbot_agent';
      case 'queries':
        return 'web_search_agent';
      case 'products':
        return 'products_agent';
      case 'messages':
        return 'chatbot_agent';
      case 'email':
        return 'email_agent';
      default:
        return 'chatbot_agent';
    }
  }

  @override
  State<AutoBus> createState() => _AutoBusState();
}

class _AutoBusState extends State<AutoBus> {
  final TextEditingController commandController = TextEditingController();
  String transcription = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    commandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is SessionExpired) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/signin', (route) => false);
          } else if (state is TokenRefreshFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Session error: ${state.message}'),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is TokenRefreshed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session refreshed'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              return _buildAuthenticatedAutoBus(authState.user);
            } else if (authState is TokenRefreshing) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Refreshing session...'),
                  ],
                ),
              );
            } else if (authState is SessionExpired) {
              return const Center(
                child: Text('Session expired. Redirecting to login...'),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildAuthenticatedAutoBus(dynamic user) {
    final repo = AutoChatRepository(client: http.Client());

    final ctx = widget.webhookContext ??
        AutoBus.defaultWebhookContextForTitle(widget.title);

    return BlocProvider(
      create: (_) => ChatBloc(repo),
      child: _AutoBusChatUI(
        user: user,
        title: widget.title,
        webhookContext: ctx,
        controller: commandController,
      ),
    );
  }
}

class _AutoBusChatUI extends StatefulWidget {
  final dynamic user;
  final String title;
  final String webhookContext;
  final TextEditingController controller;

  const _AutoBusChatUI({
    required this.user,
    required this.title,
    required this.webhookContext,
    required this.controller,
  });

  @override
  State<_AutoBusChatUI> createState() => _AutoBusChatUIState();
}

class _AutoBusChatUIState extends State<_AutoBusChatUI> {
  late TextEditingController _listen;
  late VoidCallback _controllerListener;

  static const Color _purple = Color(0xFF2A1447);
  static const Color _lightGrey = Color(0xFFEBEBEB);

  @override
  void initState() {
    super.initState();
    _listen = widget.controller;
    _controllerListener = () {
      if (mounted) setState(() {});
    };
    _listen.addListener(_controllerListener);
  }

  @override
  void dispose() {
    _listen.removeListener(_controllerListener);
    super.dispose();
  }

  void _sendMessage() {
    if (widget.controller.text.isEmpty) return;

    final String phone =
        (widget.user is Map &&
            (widget.user['phone'] ?? widget.user['phone']) != null)
        ? (widget.user['phone'] ?? widget.user['phone']).toString()
        : 'unknown';

    context.read<ChatBloc>().add(
      SendMessage(
        phone: phone,
        message: widget.controller.text,
        context: widget.webhookContext,
      ),
    );
    widget.controller.clear();
  }

  bool get _enableBackendFileBrowse =>
      widget.title.trim().toLowerCase() == 'chatbot';

  PopupMenuItem<String> _storageFileMenuItem({
    required String value,
    required IconData icon,
    required String label,
    bool enabled = true,
    bool destructive = false,
  }) {
    final Color base = destructive
        ? const Color(0xFFC62828)
        : _purple;
    final Color fg = enabled
        ? base
        : base.withValues(alpha: 0.38);
    return PopupMenuItem<String>(
      value: value,
      enabled: enabled,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: fg),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: fg,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _insertTextAtCursor(String text) {
    final controller = widget.controller;
    final selection = controller.selection;
    final original = controller.text;

    final start = selection.isValid ? selection.start : original.length;
    final end = selection.isValid ? selection.end : original.length;

    final newText = original.replaceRange(start, end, text);
    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: start + text.length),
      composing: TextRange.empty,
    );
  }

  Future<void> _openBackendFilesPicker() async {
    final api = context.read<ApiService>();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        final folderController = TextEditingController(text: 'chatbot-files');
        String folder = folderController.text.trim();
        bool uploading = false;
        bool uploadSuccess = false;
        String? uploadError;

        Future<List<Map<String, dynamic>>> load() {
          final f = folder.trim();
          return api.listMyStorageFiles(
            folder: f.isEmpty ? 'chatbot-files' : f,
          );
        }

        Future<void> openUri(Uri uri) async {
          final ok = await canLaunchUrl(uri);
          if (!ok) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not open link')),
              );
            }
            return;
          }
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }

        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickAndUpload() async {
              final activeFolder =
                  folder.trim().isEmpty ? 'chatbot-files' : folder.trim();

              setSheetState(() {
                uploading = true;
                uploadSuccess = false;
                uploadError = null;
              });

              try {
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: false,
                  withData: false,
                );
                if (result == null || result.files.isEmpty) {
                  setSheetState(() => uploading = false);
                  return;
                }

                final picked = result.files.first;
                final path = picked.path;
                if (path == null || path.trim().isEmpty) {
                  throw Exception('Selected file has no path');
                }

                await api.uploadMyStorageFile(
                  folder: activeFolder,
                  file: File(path),
                  filename: picked.name,
                );

                setSheetState(() {
                  uploading = false;
                  uploadSuccess = true;
                });

                // Refresh list so uploaded file appears.
                setSheetState(() {});

                // Auto-hide the success check after a moment.
                if (mounted) {
                  Future<void>.delayed(const Duration(seconds: 2), () {
                    if (!mounted) return;
                    setSheetState(() => uploadSuccess = false);
                  });
                }
              } catch (e) {
                setSheetState(() {
                  uploading = false;
                  uploadSuccess = false;
                  uploadError = e.toString();
                });
              }
            }

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.folder_open_rounded, color: _purple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Choose a file',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _purple,
                            ),
                          ),
                        ),
                        if (uploadSuccess) ...[
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: uploading ? null : pickAndUpload,
                          icon: uploading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.upload_file_rounded),
                          label: Text(
                            uploading ? 'Uploading…' : 'Upload file',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _purple,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: folderController,
                            decoration: InputDecoration(
                              hintText: 'Folder (e.g. chatbot-files)',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              filled: true,
                              fillColor: Colors.black.withValues(alpha: 0.04),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: _purple,
                              fontWeight: FontWeight.w500,
                            ),
                            onSubmitted: (_) {
                              setSheetState(() {
                                folder = folderController.text.trim();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Refresh',
                          onPressed: () {
                            setSheetState(() {
                              folder = folderController.text.trim();
                            });
                          },
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: _purple,
                          ),
                        ),
                      ],
                    ),
                    if (uploadError != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          uploadError!,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Expanded(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: load(),
                        builder: (context, snap) {
                          if (snap.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snap.hasError) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Could not load files. ${snap.error}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            );
                          }

                          final files = snap.data ?? const [];
                          if (files.isEmpty) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'No files found in "${folder.isEmpty ? 'chatbot-files' : folder}".',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: _purple.withValues(alpha: 0.65),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: files.length,
                            separatorBuilder: (_, __) => Divider(
                              color: Colors.black.withValues(alpha: 0.08),
                            ),
                            itemBuilder: (context, index) {
                              final f = files[index];
                              final name = (f['file_name'] ?? f['name'] ?? '')
                                  .toString();
                              final url =
                                  (f['file_url'] ??
                                          f['url'] ??
                                          f['presigned_url'] ??
                                          '')
                                      .toString();
                              final type =
                                  (f['file_type'] ?? f['content_type'] ?? '')
                                      .toString();

                              IconData icon = Icons.insert_drive_file_outlined;
                              final lower = name.toLowerCase();
                              if (lower.endsWith('.pdf')) {
                                icon = Icons.picture_as_pdf;
                              }
                              if (lower.endsWith('.docx') ||
                                  lower.endsWith('.doc')) {
                                icon = Icons.description_outlined;
                              }
                              if (lower.endsWith('.txt')) {
                                icon = Icons.text_snippet_outlined;
                              }

                              final activeFolder = folder.trim().isEmpty
                                  ? 'chatbot-files'
                                  : folder.trim();
                              final downloadUri = api.myStorageDownloadUri(
                                folder: activeFolder,
                                fileName: name,
                              );

                              return ListTile(
                                dense: true,
                                leading: Icon(icon, color: _purple),
                                title: Text(
                                  name.isEmpty ? 'Unnamed file' : name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    color: _purple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  type.isNotEmpty
                                      ? type
                                      : (url.isNotEmpty
                                            ? 'presigned link'
                                            : ''),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    color: _purple.withValues(alpha: 0.55),
                                  ),
                                ),
                                trailing: PopupMenuButton<String>(
                                  tooltip: 'File actions',
                                  offset: const Offset(0, 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  color: Colors.white,
                                  elevation: 12,
                                  shadowColor: _purple.withValues(alpha: 0.18),
                                  surfaceTintColor: Colors.transparent,
                                  constraints: const BoxConstraints(
                                    minWidth: 44,
                                    minHeight: 40,
                                  ),
                                  padding: EdgeInsets.zero,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _purple.withValues(alpha: 0.07),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _purple.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.more_horiz_rounded,
                                      color: _purple.withValues(alpha: 0.85),
                                      size: 22,
                                    ),
                                  ),
                                  onSelected: (action) async {
                                    if (action == 'insert') {
                                      Navigator.pop(context);
                                      final token = url.isNotEmpty
                                          ? url
                                          : (name.isNotEmpty ? name : '');
                                      if (token.isNotEmpty) {
                                        _insertTextAtCursor(' $token ');
                                      }
                                      return;
                                    }
                                    if (action == 'open') {
                                      final uri = Uri.tryParse(url);
                                      if (uri != null) await openUri(uri);
                                      return;
                                    }
                                    if (action == 'download') {
                                      await openUri(downloadUri);
                                      return;
                                    }
                                    if (action == 'delete') {
                                      try {
                                        await api.deleteMyStorageFile(
                                          folder: activeFolder,
                                          fileName: name,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Deleted $name'),
                                            ),
                                          );
                                        }
                                        setSheetState(() {});
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Delete failed: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                      return;
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    _storageFileMenuItem(
                                      value: 'insert',
                                      icon: Icons.chat_bubble_outline_rounded,
                                      label: 'Insert into chat',
                                    ),
                                    _storageFileMenuItem(
                                      value: 'open',
                                      icon: Icons.open_in_new_rounded,
                                      label: 'Open link',
                                      enabled: url.isNotEmpty,
                                    ),
                                    _storageFileMenuItem(
                                      value: 'download',
                                      icon: Icons.download_rounded,
                                      label: 'Download',
                                    ),
                                    const PopupMenuDivider(
                                      height: 1,
                                      indent: 12,
                                      endIndent: 12,
                                    ),
                                    _storageFileMenuItem(
                                      value: 'delete',
                                      icon: Icons.delete_outline_rounded,
                                      label: 'Delete',
                                      destructive: true,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  final token = url.isNotEmpty
                                      ? url
                                      : (name.isNotEmpty ? name : '');
                                  if (token.isNotEmpty) {
                                    _insertTextAtCursor(' $token ');
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final controller = widget.controller;
    final title = widget.title;
    String username = "User";

    if (user is Map && user.containsKey('fullname')) {
      username = user['fullname'];
    }

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 42),

            /// 🔝 HEADER (Figma: 64x64 circles, centered title)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: SizedBox(
                height: 54,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2A1447),
                            border: Border.all(
                              color: Color(0xFFA92FEB),
                              width: 0.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: _purple,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _avatarButton(user),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 26),

            /// 💬 CHAT AREA
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    Expanded(
                      child: BlocBuilder<ChatBloc, ChatState>(
                        builder: (context, state) {
                          List<ChatMessage> msgs = [];
                          if (state is ChatLoadSuccess) msgs = state.messages;

                          if (msgs.isEmpty) {
                            return ListView(
                              padding: const EdgeInsets.only(top: 8),
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _chatBubble(
                                    'Hello $username, what task we performing today?',
                                    isUser: false,
                                  ),
                                ),
                              ],
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.only(top: 8),
                            itemCount: msgs.length,
                            itemBuilder: (context, index) {
                              final m = msgs[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Align(
                                  alignment: m.sender == Sender.user
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: _chatBubble(
                                    m.text,
                                    isUser: m.sender == Sender.user,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// ⌨️ INPUT BAR
            Container(
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 16),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: _lightGrey,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Input (expands upward as it grows)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 140),
                    child: TextField(
                      controller: controller,
                      cursorColor: _purple,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      minLines: 1,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "Type Your Command Autobus ...",
                        hintStyle: GoogleFonts.montserrat(
                          color: _purple.withValues(alpha: 0.55),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: GoogleFonts.montserrat(
                        color: _purple,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      /// Plus Icon
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {},
                        icon: const Icon(
                          Icons.add_rounded,
                          color: _purple,
                          size: 26,
                        ),
                      ),

                      if (_enableBackendFileBrowse) ...[
                        const SizedBox(width: 6),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Browse files',
                          onPressed: _openBackendFilesPicker,
                          icon: const Icon(
                            Icons.folder_open_rounded,
                            color: _purple,
                            size: 24,
                          ),
                        ),
                      ],

                      const Spacer(),

                      /// Send (enabled only when there is text)
                      GestureDetector(
                        onTap: controller.text.trim().isEmpty
                            ? null
                            : _sendMessage,
                        child: Icon(
                          Icons.send_rounded,
                          size: 24,
                          color: controller.text.trim().isEmpty
                              ? _purple.withValues(alpha: 0.35)
                              : _purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarButton(dynamic user) {
    String? avatarUrl;
    String initials = 'U';

    if (user is Map) {
      final name = (user['fullname'] ?? user['email'] ?? 'User').toString();
      initials = name.trim().isNotEmpty
          ? name.trim()[0].toUpperCase()
          : initials;
      avatarUrl =
          (user['avatar'] ??
                  user['avatar_url'] ??
                  user['photo'] ??
                  user['photo_url'])
              ?.toString();
      if (avatarUrl != null && avatarUrl.trim().isEmpty) avatarUrl = null;
    }

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF2A1447),
        border: Border.all(color: Color(0xFFA92FEB), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: CircleAvatar(
          backgroundColor: const Color(0xFF2A1447),
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? Text(
                  initials,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  /// 💬 Bubble Widget
  Widget _chatBubble(String text, {required bool isUser}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _lightGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          height: 1.35,
          color: _purple,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
