import 'package:autobus/barrel.dart';

class SplashPge extends StatefulWidget {
  const SplashPge({super.key});

  @override
  State<SplashPge> createState() => _SplashPgeState();
}

class _SplashPgeState extends State<SplashPge> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/img/splashback.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(75, 0, 0, 0),
                        Color.fromARGB(150, 0, 0, 0),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.width * 0.5),
                      SizedBox(
                        width: double.infinity,
                        child: Image.asset(
                          "assets/icons/autologo.png",
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width * 0.8),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: const EdgeInsets.only(top: 50),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
