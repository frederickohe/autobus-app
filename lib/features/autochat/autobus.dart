import 'package:autobus/barrel.dart';

class AutoBus extends StatefulWidget {
  const AutoBus({super.key});

  @override
  State<AutoBus> createState() => _AutoBusState();
}

class _AutoBusState extends State<AutoBus> {
  final TextEditingController commandController = TextEditingController();
  String transcription = '';
  bool isListening = false;
  late Future<List<dynamic>> ridesFuture;

  @override
  void initState() {
    super.initState();
    // Cache the future to prevent multiple API calls
    ridesFuture = context.read<ApiService>().getRides().catchError((e) {
      print('Error fetching rides: $e');
      return [];
    });
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
    return _AutoBusChatUI(
      user: user,
      controller: commandController,
      isListening: isListening,
      onMicTap: () {
        setState(() => isListening = !isListening);
      },
      onSend: () {
        if (commandController.text.isEmpty) return;

        context.read<AssistantBloc>().add(
          SendCommandEvent(command: commandController.text),
        );

        commandController.clear();
      },
    );
  }
}

class _AutoBusChatUI extends StatelessWidget {
  final dynamic user;
  final TextEditingController controller;
  final bool isListening;
  final VoidCallback onMicTap;
  final VoidCallback onSend;

  const _AutoBusChatUI({
    required this.user,
    required this.controller,
    required this.isListening,
    required this.onMicTap,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
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
                    /// User Bubble
                    Align(
                      alignment: Alignment.centerRight,
                      child: _chatBubble("Hello", isUser: true),
                    ),

                    const SizedBox(height: 16),

                    /// AI Bubble
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _chatBubble(
                        "Hello MD $username, what task we performing today?",
                        isUser: false,
                      ),
                    ),

                    const Spacer(),
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

                  /// Mic
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
