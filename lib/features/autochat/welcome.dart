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
      body: BlocBuilder<AuthBloc, AuthState>(
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
                      'Experience the',
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 46,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                    Text(
                      'Auto Bus!',
                      style: GoogleFonts.righteous(
                        color: Colors.black,
                        fontSize: 72,
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
                    'assets/img/bot.png',
                    fit: BoxFit.cover,
                    width: 50,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.5),
                const CtaButton(),
              ],
            ),
          );
        },
      ),
    );
  }
}
