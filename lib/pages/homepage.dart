import 'package:flutter/material.dart';
import '../components/carousel.dart';
import '../components/room_cart.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: ''),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              const SizedBox(height: 16),
              _header(),
              const SizedBox(height: 16),
              const TopCarousel(),
              const SizedBox(height: 24),
              _usageHeader(),
              const SizedBox(height: 12),
              _roomGrid()
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          // backgroundImage: NetworkImage(
          //   "",
          // ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 180,
                child: AnimatedTextKit(
                  repeatForever: true,
                  pause: const Duration(milliseconds: 1000),
                  animatedTexts: [
                    TyperAnimatedText("Hi",
                        textStyle: const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Halo",
                        textStyle: const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Bonjour",
                        textStyle: const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Hola",
                        textStyle: const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Aloha",
                        textStyle: const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("您好",
                        textStyle: const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("こんにちは",
                        textStyle: const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("안녕하세요",
                        textStyle: const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Zdravstvuyte",
                        textStyle: const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Sàwàtdee",
                        textStyle: const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Guten Tag",
                        textStyle: const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Ciao",
                        textStyle: const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("مرحبا",
                        textStyle: const TextStyle(fontSize: 14, color: Colors.grey)),
                    TyperAnimatedText("Olá",
                        textStyle: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "Darren Samuel Nathan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () {},
        )
      ],
    );
  }

  Widget _usageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Usage by room",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("+ Add room"),
        ),
      ],
    );
  }

  Widget _roomGrid() {
    final items = [
      {"percent": 12, "name": "Kitchen", "isSelected": true},
      {"percent": 24, "name": "Home Office"},
      {"percent": 9, "name": "Bedroom"},
      {"percent": 11, "name": "Bathroom"},
      {"percent": 100, "name": "Gaming room"},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((e) {
        return RoomUsageCard(
          percentage: e["percent"] as int,
          label: e["name"] as String,
          isSelected: e["isSelected"] == true,
        );
      }).toList(),
    );
  }
}
