import 'package:flutter/material.dart';

class NewsDetailPage extends StatelessWidget {
  const NewsDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      // CONTENT SCROLL
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Banjir Jakarta, Ini 6 Tips Menghindari Sengatan Listrik dalam Air saat Banjir',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Abraham Herdyanto',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  Text(
                    '08 Jul 2025, 16:15 WIB',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/banjir_listrik.png',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 12),

              // IMAGE CAPTION
              const Center(
                child: Text(
                  'Banjir akibat luapan Kali Bekasi\n(IDN Times / Imam Faishal)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 16),

              // CONTENT
              const Text(
                'Kondisi banjir di Jakarta memang selalu menguji kesabaran. '
                    'Mulai dari transportasi hingga komunikasi, semuanya terganggu. '
                    'Dari segala masalah, ada satu kondisi bahaya yang patut '
                    'diwaspadai dari kondisi banjir ini, yaitu sengatan listrik.\n\n'
                    'Mothersip.sg sempat melaporkan adanya korban meninggal dari '
                    'sengatan listrik di Meksiko akibat menyentuh tiang listrik kala '
                    'banjir. Banjir di Jakarta juga pernah menelan korban akibat '
                    'sengatan listrik saat banjir.\n\n'
                    'Melansir berbagai sumber, berikut ini beberapa tips '
                    'menghindari sengatan listrik saat banjir yang bisa kamu '
                    'lakukan demi menghindari kondisi berbahaya tersebut.\n\n',
                style: TextStyle(fontSize: 14, height: 1.6),
              ),

              const Text(
                '1. Hindari area sumber listrik\n'
                    'Jauhi tiang listrik, gardu, atau sumber listrik lainnya. '
                    'Jika ingin berteduh, pilih tempat yang dipastikan tidak ada '
                    'aliran listrik.\n\n'

                    '2. Gunakan sepatu boots\n'
                    'Sepatu boots kedap air dapat membantu melindungi kaki dari '
                    'aliran listrik. Selain itu, sepatu ini juga melindungi dari '
                    'paku dan benda berbahaya lainnya.\n\n'

                    '3. Gunakan sarung tangan karet\n'
                    'Jika tubuh dalam kondisi basah, gunakan sarung tangan karet '
                    'saat memegang benda apa pun. Sarung tangan karet membantu '
                    'menghambat hantaran listrik.\n\n'

                    '4. Matikan listrik\n'
                    'Bagi yang masih berada di dalam rumah, segera matikan aliran '
                    'listrik dan cabut semua peralatan elektronik dari stop kontak '
                    'untuk menghindari risiko sengatan.\n\n'

                    '5. Perhatikan alat elektronik yang terkena air\n'
                    'Peralatan elektronik yang terendam air dapat berbahaya jika '
                    'kembali disambungkan ke listrik. Pastikan alat benar-benar '
                    'aman sebelum digunakan kembali.\n\n'

                    '6. Hubungi pihak berwenang\n'
                    'Saat kembali ke rumah pascabanjir, sebaiknya didampingi oleh '
                    'pihak yang memahami kelistrikan seperti PLN atau pemadam '
                    'kebakaran guna memastikan kondisi aman.\n\n'

                    'Perhatikan kondisi sekitarmu dengan baik. Ingat bahwa air '
                    'merupakan penghantar listrik yang sangat baik. Sengatan '
                    'listrik bisa terjadi tanpa terlihat dan berakibat fatal.',
                style: TextStyle(fontSize: 14, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
