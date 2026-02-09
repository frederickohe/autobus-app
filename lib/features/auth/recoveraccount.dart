import 'package:autobus/barrel.dart';

class RecoverAccount extends StatefulWidget {
  const RecoverAccount({super.key});
  @override
  State<RecoverAccount> createState() => _RecoverAccountState();
}

class _RecoverAccountState extends State<RecoverAccount> {
  final TextEditingController emailController = TextEditingController();
  bool _emailVerified = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is EmailExists) {
          setState(() => _emailVerified = true);
          // Show dialog or message that email exists and code will be sent
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email verified. Sending reset code...')),
          );
          // Automatically send the reset code
          context.read<AuthBloc>().add(SendResetCodeEvent(email: state.email));
        } else if (state is ResetCodeSent) {
          // Navigate to VerifyCode screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VerifyCode(email: state.email)),
          );
        } else if (state is AuthError && state.source == 'check_email') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Back',
                          style: GoogleFonts.imprima(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Text(
                        'Recover Account',
                        style: GoogleFonts.imprima(
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                  ],
                ),
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
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text(
                  'Email',
                  style: GoogleFonts.imprima(
                    color: const Color.fromARGB(255, 12, 12, 12),
                    fontSize: 14,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: '',
                    border: UnderlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Center(
                child: AppButton(
                  onPressed: () {
                    if (emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter your email'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    context.read<AuthBloc>().add(
                    CheckEmailExistsEvent(email: emailController.text),
                  );
                  },
                  buttonText: 'Verify',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
