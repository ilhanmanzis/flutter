import 'package:flutter/material.dart';

class ReviewDetailPage extends StatelessWidget {
  final Map<String, dynamic> reviewData;

  const ReviewDetailPage({super.key, required this.reviewData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(reviewData["nama"])),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(reviewData['foto']),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewData['nama'] ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        reviewData['rating'] ?? 0,
                        (index) =>
                            Icon(Icons.star, color: Colors.amber, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Tanggal: ${reviewData['tanggal'].toString()}",
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              "Komentar:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(reviewData['komentar'] ?? '', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
