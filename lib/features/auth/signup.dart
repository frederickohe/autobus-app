import 'package:autobus/barrel.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController profilePictureController =
      TextEditingController();
  final TextEditingController bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Centered text
                        Center(
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.imprima(
                              color: Colors.black,
                              fontSize: 26,
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                        ),

                        // Back button positioned on the left
                        Positioned(
                          left: 0,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: CustColors.mainCol,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: CustColors.mainCol,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 50 * 0.35,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Center(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.asset('assets/img/bot.png'),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    SizedBox(
                      height: 450,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20.0, right: 20.0),
                              child: Text(
                                'Full Name',
                                style: GoogleFonts.imprima(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20.0,
                                right: 20.0,
                              ),
                              child: TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: EdgeInsets.only(left: 20.0, right: 20.0),
                              child: Text(
                                'Number/Phone',
                                style: GoogleFonts.imprima(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20.0,
                                right: 20.0,
                              ),
                              child: TextField(
                                controller: phoneController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: EdgeInsets.only(left: 20.0, right: 20.0),
                              child: Text(
                                'Email',
                                style: GoogleFonts.imprima(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20.0,
                                right: 20.0,
                              ),
                              child: TextField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: EdgeInsets.only(left: 20.0, right: 20.0),
                              child: Text(
                                'User Password',
                                style: GoogleFonts.imprima(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20.0,
                                right: 20.0,
                              ),
                              child: TextField(
                                controller: passwordController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return AppButton(
                            onPressed: () async {
                              context.read<AuthBloc>().add(
                                SignupEvent(
                                  firstname: nameController.text.split(' ')[0],
                                  lastname:
                                      nameController.text.split(' ').length > 1
                                      ? nameController.text.split(' ')[1]
                                      : '',
                                  username: nameController.text.replaceAll(
                                    ' ',
                                    '_',
                                  ),
                                  phone: phoneController.text,
                                  email: emailController.text,
                                  password: passwordController.text,
                                ),
                              );
                            },
                            buttonText: 'Sign Up',
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Have an Account ?',
                        style: GoogleFonts.imprima(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            PageTransition(
                              type: PageTransitionType.leftToRightWithFade,
                              childCurrent: widget,
                              duration: const Duration(milliseconds: 1000),
                              reverseDuration: const Duration(
                                milliseconds: 1000,
                              ),
                              child: const Signin(),
                            ),
                          ); // Handle sign up navigation
                        },
                        child: Text(
                          'Log In',
                          style: GoogleFonts.imprima(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
