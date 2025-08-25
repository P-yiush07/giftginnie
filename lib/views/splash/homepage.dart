import 'package:flutter/material.dart';
import 'package:giftginnie_ui/views/Auth%20Screen/authHome_screen.dart';
import 'fluid_card.dart';
import 'fluid_carousel.dart';

// NOTE: Agr apko ye onboarding screen use krni hain to ap nechy text ko change kr skty hain
class Showcase extends StatefulWidget {
  const Showcase({super.key, required this.title});

  final String title;

  @override
  State<Showcase> createState() => _ShowcaseState();
}

class _ShowcaseState extends State<Showcase> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FluidCarousel(
        children: <Widget>[
          FluidCard(
            color: 'Red',
            altColor: Color(0xFF4259B2),
            title: "Discover the Perfect Gift",
            subtitle:
                "Browse unique gifts for every occasion, handpicked to bring a smile to your loved ones.",
          ),
          FluidCard(
            color: 'Yellow',
            altColor: Color(0xFF904E93),
            title: "Send Gifts Effortlessly",
            subtitle:
                "Choose, personalize, and send gifts with just a few taps—making every moment special.",
          ),
          FluidCard(
            color: 'Blue',
            altColor: Color(0xFFFFB138),
            title: "Delight Your Loved Ones",
            subtitle:
                "Track your gifts and enjoy the joy of giving, ensuring every surprise leaves a lasting memory.",
          ),
        ],
        onLastCardSwipe: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AuthHomeScreen()),
          );
        },
        onSkip: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AuthHomeScreen()),
          );
        },
      ),
    );
  }
}
