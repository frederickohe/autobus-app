import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autobus/barrel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController commandController = TextEditingController();
  String transcription = '';
  bool isListening = false;

  // initializeSpeech() async {
  //   // Initialize text-to-speech
  //   await textToSpeech.setLanguage("en-US");
  //   await textToSpeech.setPitch(1.0);
  //   await textToSpeech.setSpeechRate(0.5);

  //   // Initialize speech-to-text
  //   bool available = await speechToText.initialize();
  //   if (!available) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Speech recognition not available'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  // startListening() async {
  //   FocusScope.of(context).unfocus(); // Dismiss keyboard
  //   if (await speechToText.initialize()) {
  //     setState(() => isListening = true);
  //     speechToText.listen(
  //       onResult: (result) {
  //         setState(() {
  //           transcription = result.recognizedWords;
  //           commandController.text = transcription;
  //         });
  //       },
  //       listenFor: const Duration(seconds: 30),
  //       pauseFor: const Duration(seconds: 5),
  //     );
  //   }
  // }

  // stopListening() async {
  //   await speechToText.stop();
  //   setState(() => isListening = false);
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   initializeSpeech();
  // }

  // @override
  // void dispose() {
  //   speechToText.stop();
  //   textToSpeech.stop();
  //   commandController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Unauthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: Image.asset('assets/img/aibot.png'),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextField(
                      controller: commandController,
                      decoration: InputDecoration(
                        hintText: 'Ai Assistant Command',
                        border: const UnderlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isListening ? Icons.mic_off : Icons.mic,
                            color: isListening ? Colors.red : Colors.blue,
                          ),
                          onPressed: () {
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<AssistantBloc, AssistantState>(
                    builder: (context, assistantState) {
                      if (assistantState is AssistantLoading) {
                        return const CircularProgressIndicator();
                      } else if (assistantState is AssistantSuccess) {
                        // Speak the response
                        
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            assistantState.response,
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      } else if (assistantState is AssistantError) {
                        return Text(
                          assistantState.message,
                          style: const TextStyle(color: Colors.red),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  AppButton(
                    onPressed: () {
                      if (commandController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      context.read<AssistantBloc>().add(
                        SendCommandEvent(
                          command: commandController.text,
                        ),
                      );
                    },
                    buttonText: 'Send',
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your action here
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Floating Action Button Pressed')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}