import 'package:autobus/barrel.dart';

class CtaButton extends StatelessWidget {
  const CtaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            childCurrent: const Home(),
            duration: const Duration(milliseconds: 1000),
            reverseDuration: const Duration(milliseconds: 600),
            child: const Home(),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        fixedSize: Size(300, 70), // Button size
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50), // Rounded corners
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Padding
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 22,
            child: Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
          ),
          Text('Continue', style: TextStyle(color: Colors.white, fontSize: 18)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 12),
                Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
