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
      appBar: AppBar(
        title: const Text('Autobus Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Manual session/token refresh if needed
              context.read<AuthBloc>().add(RefreshTokenEvent());
            },
            tooltip: 'Refresh Session',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
            },
            tooltip: 'Logout',
          ),
        ],
      ),
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
              return _buildAuthenticatedHome(authState.user);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Floating Action Button Pressed')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAuthenticatedHome(dynamic user) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Autobus!',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            if (user is Map && user.containsKey('email'))
              Text(
                'User: ${user['email']}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Assistant',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Image.asset(
                        'assets/img/aibot.png',
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commandController,
                      decoration: InputDecoration(
                        hintText: 'Enter AI Assistant Command',
                        border: const UnderlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isListening ? Icons.mic_off : Icons.mic,
                            color: isListening ? Colors.red : Colors.blue,
                          ),
                          onPressed: () {
                            setState(() => isListening = !isListening);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<AssistantBloc, AssistantState>(
                      builder: (context, assistantState) {
                        if (assistantState is AssistantLoading) {
                          return const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 16),
                              Text('Processing...'),
                            ],
                          );
                        } else if (assistantState is AssistantSuccess) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              assistantState.response,
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        } else if (assistantState is AssistantError) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              assistantState.message,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (commandController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a command'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          context.read<AssistantBloc>().add(
                            SendCommandEvent(command: commandController.text),
                          );
                        },
                        child: const Text('Send Command'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Rides',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<dynamic>>(
                      future: context.read<ApiService>().getRides(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          );
                        } else if (snapshot.hasData &&
                            snapshot.data!.isNotEmpty) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final ride = snapshot.data![index];
                              return ListTile(
                                title: Text(
                                  ride['title'] ?? 'Ride ${index + 1}',
                                ),
                                subtitle: Text(
                                  ride['description'] ?? 'Available seats',
                                ),
                                trailing: const Icon(Icons.arrow_forward),
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: Text('No rides available'),
                          );
                        }
                      },
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
}
