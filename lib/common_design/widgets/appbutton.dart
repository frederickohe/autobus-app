import 'package:autobus/barrel.dart';

class AppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const AppButton({
    required this.onPressed,
    required this.buttonText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.black,
        minimumSize: const Size(270, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: GoogleFonts.imprima(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
