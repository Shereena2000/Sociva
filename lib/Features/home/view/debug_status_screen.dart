import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Debug screen to check status data in Firebase
/// This helps troubleshoot why statuses aren't showing
class DebugStatusScreen extends StatelessWidget {
  const DebugStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug: Status Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Current User Info', _buildCurrentUserInfo()),
            const SizedBox(height: 20),
            _buildSection('All Statuses (Collection Group)', _buildAllStatuses()),
            const SizedBox(height: 20),
            _buildSection('My Statuses Only', _buildMyStatuses()),
            const SizedBox(height: 20),
            _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCurrentUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const Text('❌ Not logged in', style: TextStyle(color: Colors.red));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('✅ Logged in', style: TextStyle(color: Colors.green)),
        const SizedBox(height: 8),
        Text('User ID: ${user.uid}', style: TextStyle(color: Colors.white70)),
        Text('Email: ${user.email ?? "N/A"}', style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildAllStatuses() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('statuses')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('❌ Error: ${snapshot.error}', 
                style: TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              if (snapshot.error.toString().contains('index'))
                  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ ERROR LOADING STATUSES!',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check Firebase Console and verify the statuses collection exists.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
            ],
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text(
            '📭 No statuses found in entire database',
            style: TextStyle(color: Colors.orange),
          );
        }

        final statuses = snapshot.data!.docs;
        final now = DateTime.now();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✅ Found ${statuses.length} total statuses',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...statuses.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
              final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
              final isExpired = expiresAt != null && now.isAfter(expiresAt);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isExpired ? Colors.red[900] : Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${isExpired ? "⏰ EXPIRED" : "✅ ACTIVE"} - ${data['userName'] ?? "Unknown"}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('User ID: ${data['userId'] ?? "N/A"}', 
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('Caption: ${data['caption'] ?? "N/A"}',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('Created: ${createdAt?.toString() ?? "N/A"}',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                    if (isExpired)
                      Text('❌ Expired: ${expiresAt.toString()}',
                        style: TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildMyStatuses() {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const Text('❌ Not logged in', style: TextStyle(color: Colors.red));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('statuses')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('❌ Error: ${snapshot.error}', 
            style: TextStyle(color: Colors.red));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text(
            '📭 You have no statuses',
            style: TextStyle(color: Colors.orange),
          );
        }

        final statuses = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✅ You have ${statuses.length} status(es)',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...statuses.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Caption: ${data['caption'] ?? "N/A"}',
                      style: TextStyle(color: Colors.white)),
                    Text('Created: ${(data['createdAt'] as Timestamp).toDate().toString()}',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 How to Fix Issues',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '1. If "No statuses found":\n'
            '   • Create a status from home or profile screen\n'
            '   • Have another user create a status\n'
            '   • Check Firebase Console → statuses collection\n\n'
            '2. If statuses show as EXPIRED:\n'
            '   • Statuses automatically expire after 24 hours\n'
            '   • Create a new status to test\n\n'
            '3. Firebase Structure (NEW - Top-Level Collection):\n'
            '   • OLD: users/{userId}/statuses/{statusId}\n'
            '   • NEW: statuses/{statusId}\n'
            '   • This is standard for social media apps\n'
            '   • No Firebase index required!\n\n'
            '4. If still not working:\n'
            '   • Make sure you created status AFTER this update\n'
            '   • Old statuses in subcollection won\'t appear\n'
            '   • Create a new status to test',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
}

