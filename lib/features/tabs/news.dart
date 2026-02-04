import 'package:flutter/material.dart';
import '../detail/detail_news.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,

        // BACK BUTTON FIXED
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'News',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      // LISTVIEW SCROLL
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          NewsItem(
            imagePath: 'assets/images/news1.png',
            title: '6 Tips Menghindari Bahaya Aliran Listrik Saat Banjir',
            author: 'Samuel',
            date: 'Dec 12, 2024',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewsDetailPage(),
              ),
            ),
          ),
          NewsItem(
            imagePath: 'assets/images/news2.png',
            title:
            'Tarif Listrik PLN 24–30 November 2025 untuk Golongan Subsidi dan Rumah Tangga',
            author: 'Samuel',
            date: 'Dec 12, 2024',
          ),
          NewsItem(
            imagePath: 'assets/images/news3.png',
            title:
            'Rumah di Lereng Gunung Kelud Terbakar Akibat Korsleting Listrik',
            author: 'Samuel',
            date: 'Nov 25, 2025',
          ),
          NewsItem(
            imagePath: 'assets/images/news4.png',
            title:
            'Kebakaran di Universitas Mega Buana Palopo Disebabkan Korsleting Listrik',
            author: 'Samuel',
            date: 'Nov 15, 2025',
          ),
          NewsItem(
            imagePath: 'assets/images/news5.png',
            title: 'Pahami Penyebab Korsleting Listrik & Cara Mengatasinya',
            author: 'Samuel',
            date: 'Feb 20, 2024',
          ),
          NewsItem(
            imagePath: 'assets/images/carousel3.jpg',
            title: 'Sering Tertukar, Ini Perbedaan Meteran Listrik dan MCB',
            author: 'Samuel',
            date: 'Feb 12, 2024',
          ),
          NewsItem(
            imagePath: 'assets/images/carousel2.jpg',
            title: 'Waspada Bahaya Listrik di Musim Hujan',
            author: 'Samuel',
            date: 'Mar 30, 2024',
          ),
          NewsItem(
            imagePath: 'assets/images/news5.png',
            title: 'Pahami Penyebab Korsleting Listrik & Cara Mengatasinya',
            author: 'Samuel',
            date: 'Apr 10, 2024',
          ),
        ],
      ),
    );
  }
}

class NewsItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String author;
  final String date;
  final VoidCallback? onTap;

  const NewsItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.author,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    width: 90,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            author,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Divider(height: 1),
            ),
          ],
        ),
      ),
    );
  }
}
