import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ComplaintsAdminScreen extends StatelessWidget {
  const ComplaintsAdminScreen({super.key});

  Future<void> _openMap(double lat, double lng) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('complaints')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Complaints')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No complaints yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final d = doc.data();
              final imageUrl = d['imageUrl'] as String?;
              final lat = (d['latitude'] as num?)?.toDouble();
              final lng = (d['longitude'] as num?)?.toDouble();
              final status = (d['status'] ?? 'pending') as String;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              d['title'] ?? '',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Chip(label: Text(d['priority'] ?? '')),
                        ],
                      ),
                      Text('${d['category']} • ${d['studentName']} (${d['regNo']})'),
                      const SizedBox(height: 8),
                      Text(d['description'] ?? ''),
                      const SizedBox(height: 4),
                      Text('Where: ${d['locationDetail'] ?? ''}'),
                      if (imageUrl != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (c, child, p) => p == null
                                ? child
                                : const SizedBox(
                              height: 180,
                              child: Center(
                                  child: CircularProgressIndicator()),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (lat != null && lng != null)
                            TextButton.icon(
                              onPressed: () => _openMap(lat, lng),
                              icon: const Icon(Icons.map_outlined),
                              label: const Text('View on map'),
                            ),
                          const Spacer(),
                          DropdownButton<String>(
                            value: status,
                            items: const ['pending', 'in_progress', 'resolved']
                                .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                doc.reference.update({'status': v});
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}