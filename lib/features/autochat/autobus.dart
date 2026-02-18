import 'package:autobus/barrel.dart';
import 'package:http/http.dart' as http;
import 'services/autochat_repository.dart';
import 'chat_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import 'models/chat_message.dart';

class AutoBus extends StatefulWidget {
  const AutoBus({super.key});

  @override
  State<AutoBus> createState() => _AutoBusState();
}

class _AutoBusState extends State<AutoBus> {
  final TextEditingController commandController = TextEditingController();
  String transcription = '';
  bool isListening = false;

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

    return BlocProvider(
      create: (_) => ChatBloc(repo),
      child: _AutoBusChatUI(
        user: user,
        controller: commandController,
        isListening: isListening,
        onMicTap: () {
          setState(() => isListening = !isListening);
        },
      ),
    );
  }
}

class _AutoBusChatUI extends StatefulWidget {
  final dynamic user;
  final TextEditingController controller;
  final bool isListening;
  final VoidCallback onMicTap;

  const _AutoBusChatUI({
    required this.user,
    required this.controller,
    required this.isListening,
    required this.onMicTap,
  });

  @override
  State<_AutoBusChatUI> createState() => _AutoBusChatUIState();
}

class _AutoBusChatUIState extends State<_AutoBusChatUI> {
  late TextEditingController _listen;

  @override
  void initState() {
    super.initState();
    _listen = widget.controller;
    _listen.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _listen.removeListener(() => setState(() {}));
    super.dispose();
  }

  void _sendMessage() {
    if (widget.controller.text.isEmpty) return;

    final String userId =
        (widget.user is Map &&
            (widget.user['id'] ?? widget.user['userid']) != null)
        ? (widget.user['id'] ?? widget.user['userid']).toString()
        : 'unknown';

    context.read<ChatBloc>().add(
      SendMessage(userId: userId, message: widget.controller.text),
    );
    widget.controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final controller = widget.controller;
    final isListening = widget.isListening;
    final onMicTap = widget.onMicTap;
    String username = "User";

    if (user is Map && user.containsKey('fullname')) {
      username = user['fullname'];
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF4F4F4), Color(0xFFEDEDED), Color(0xFFE6E6E6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// 🔝 HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Back
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: CustColors.mainCol,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),

                  /// Title
                  Text(
                    "Autobus on Orders",
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

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
              margin: const EdgeInsets.all(18),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  /// Plus Icon
                  const Icon(Icons.add, color: Colors.black87),

                  const SizedBox(width: 10),

                  /// Input
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Type Your Command Autobus …",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  /// Send Button (shows if text is not empty)
                  if (controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: _sendMessage,
                      child: const Icon(Icons.send, color: CustColors.mainCol),
                    )
                  else
                    /// Mic (shows if text is empty)
                    GestureDetector(
                      onTap: onMicTap,
                      child: Icon(
                        isListening ? Icons.mic_off : Icons.mic,
                        color: CustColors.mainCol,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 💬 Bubble Widget
  Widget _chatBubble(String text, {required bool isUser}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser
            ? Colors.white.withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}
