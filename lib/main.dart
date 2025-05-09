import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'all_review.dart';
import 'detail_survey.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rating & Ulasan',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
      ), // Sesuai tampilan yang kamu lampirkan
      home: ReviewPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Rating dan Ulasan")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TotalRatingSection(),
          Divider(),
          Expanded(child: RecentReviewsSection()),
        ],
      ),
    );
  }
}

class TotalRatingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('ulasan').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final docs = snapshot.data!.docs;
        final total = docs.length;

        // Hitung jumlah bintang
        final ratingCount = [0, 0, 0, 0, 0];
        for (var doc in docs) {
          final rating = (doc['rating'] as int);
          if (rating >= 1 && rating <= 5) {
            ratingCount[rating - 1]++;
          }
        }

        double avgRating = 0;
        for (int i = 0; i < 5; i++) {
          avgRating += (i + 1) * ratingCount[i];
        }
        avgRating = total > 0 ? avgRating / total : 0;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Survey Kepuasan Masyarakat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.star, color: Colors.amber, size: 30),
                ],
              ),
              Text("$total ulasan"),
              SizedBox(height: 12),
              ...List.generate(5, (i) {
                int star = 5 - i;
                return Row(
                  children: [
                    Text("$star", style: TextStyle(fontSize: 20)),
                    SizedBox(width: 4),
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.star, color: Colors.amber, size: 20),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: total > 0 ? ratingCount[star - 1] / total : 0,
                        backgroundColor: Colors.grey[300],
                        color: Colors.blue[300],
                        minHeight: 13, // agar lebih tebal dan terlihat rapi
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text("${ratingCount[star - 1]}"),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class RecentReviewsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('ulasan')
                .orderBy('tanggal', descending: true)
                .limit(3)
                .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final reviews = snapshot.data!.docs;

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              ...reviews.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(data['foto']),
                  ),
                  title: Text(data['nama'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          data['rating'] ?? 0,
                          (i) =>
                              Icon(Icons.star, size: 16, color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ReviewDetailPage(reviewData: data),
                      ),
                    );
                  },
                );
              }).toList(),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllReviewsPage()),
                    );
                  },
                  child: Text("Lihat semua ulasan"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
