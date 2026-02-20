import 'package:autobus/barrel.dart';

class LogorSign extends StatelessWidget {
  const LogorSign({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/splash.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              SizedBox(
                width: double.infinity,
                child: Image.asset(
                  "assets/icons/autologo.png",
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.width * 0.9),
              Container(
                height: 200.0,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: CustColors.mainCol,
                  borderRadius: BorderRadius.circular(35.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  childCurrent: const Signin(),
                                  duration: const Duration(milliseconds: 1000),
                                  reverseDuration: const Duration(
                                    milliseconds: 800,
                                  ),
                                  child: const Signin(),
                                ),
                              );
                            },
                            child: Center(
                              child: Text(
                                'Log In',
                                style: GoogleFonts.imprima(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(height: 40, width: 1.5, color: Colors.white),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  childCurrent: const Signup(),
                                  duration: const Duration(milliseconds: 1000),
                                  reverseDuration: const Duration(
                                    milliseconds: 600,
                                  ),
                                  child: const Signup(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.imprima(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (context) => const Terms(),
                            //   ),
                            // );
                          },
                          child: Text(
                            'Terms & Conditions',
                            style: GoogleFonts.imprima(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (context) => const Privacy(),
                            //   ),
                            // );
                          },
                          child: Text(
                            'Privacy Policy',
                            style: GoogleFonts.imprima(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (context) => const HelpAndAssistance(),
                            //   ),
                            // );
                          },
                          child: Text(
                            'Help & Support',
                            style: GoogleFonts.imprima(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w100,
                            ),
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
      ),
    );
  }
}
