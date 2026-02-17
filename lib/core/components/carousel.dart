import 'package:flutter/material.dart';
import 'package:zapp/features/models/news.dart';
import 'package:zapp/features/services/news_service.dart';
import 'package:zapp/features/detail/detail_news.dart';
import 'dart:async';

class TopCarousel extends StatefulWidget {
  const TopCarousel({super.key});

  @override
  State<TopCarousel> createState() => _TopCarouselState();
}

class _TopCarouselState extends State<TopCarousel> {
  List<News> items = [];
  int currentIndex = 0;
  final PageController controller = PageController();
  bool isLoading = true;
  Timer? _autoSlideTimer;
  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      final result = await NewsService.fetchNews();

      if (!mounted) return;

      setState(() {
        items = result.take(3).toList();
        isLoading = false;
      });
      _startAutoSlide();
    } catch (e) {
      debugPrint("Error fetch news: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || items.isEmpty) return;

      int nextPage = currentIndex + 1;

      if (nextPage >= items.length) {
        nextPage = 0;
      }

      controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildPlaceholder("Loading news...");
    }

    if (items.isEmpty) {
      return _buildPlaceholder("No news available");
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 170,
        child: Stack(
          children: [
            PageView.builder(
              controller: controller,
              itemCount: items.length,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              itemBuilder: (context, index) {
                final item = items[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsDetailPage(news: item),
                      ),
                    );
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      item.imageUrl.isNotEmpty
                          ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),

                      Container(
                        color: Colors.black.withValues(alpha: 0.4)

                      ),

                      Positioned(
                        bottom: 15,
                        left: 15,
                        right: 15,
                        child: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            Positioned(
              bottom: 10,
              right: 15,
              child: Row(
                children: List.generate(
                  items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: currentIndex == index ? 10 : 6,
                    height: currentIndex == index ? 10 : 6,
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? Colors.white
                          : Colors.white54,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 170,
        width: double.infinity,
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
