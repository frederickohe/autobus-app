import 'package:autobus/barrel.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle session expiration
        if (state is SessionExpired) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/signin', (route) => false);
        }
        // Handle token refresh failure
        else if (state is TokenRefreshFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Session error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return const Welcome();
          } else if (state is Unauthenticated) {
            return const Signin();
          } else if (state is SessionExpired) {
            return const LogorSign();
          } else if (state is Registered) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SelectPlan()),
              );
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is AuthError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            });
            // Render relevant page based on error source
            if (state.source == 'signup') {
              return const Signup();
            } else {
              return const Signin();
            }
          } else if (state is TokenRefreshing) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
