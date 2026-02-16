import 'package:autobus/barrel.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _GradientBackground(
        child: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              // Show welcome page content for authenticated users
              return Center(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.width * 0.1),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Operate Business',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                        Text(
                          'With Ai!',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 92,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.2),
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: Image.asset(
                        'assets/img/welcomeai.png',
                        fit: BoxFit.cover,
                        width: 50,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.5),
                    TransparentCtaButton(
                      label: 'Get Started',
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const Home()),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  final Widget child;
  const _GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF130522), Color(0xFF2D0C51), Color(0xFF130522)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
