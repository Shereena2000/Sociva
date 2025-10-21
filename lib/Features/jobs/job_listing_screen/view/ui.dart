import 'package:flutter/material.dart';
import 'package:social_media_app/Settings/constants/sized_box.dart';

import 'widgets/job_cards.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Jobs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
            
            // Job Cards
            JobCard(
              jobTitle: "Flutter Developer",
              companyName: "TechCorp Solutions",
              location: "San Francisco, CA",
              jobType: "Full-Time",
              workMode: "Remote",
              experience: "Mid Level",
              postDate: "3 days ago",
              description: "We are looking for an experienced Flutter developer to join our mobile team.",
            ),
            SizeBoxH(16),
            
            JobCard(
              jobTitle: "UI/UX Designer",
              companyName: "Design Studio Pro",
              location: "New York, NY",
              jobType: "Contract",
              workMode: "Hybrid",
              experience: "Senior Level",
              postDate: "1 week ago",
              description: "Creative UI/UX designer needed for innovative mobile app projects.",
            ),
            SizeBoxH(16),
            
            JobCard(
              jobTitle: "Backend Developer",
              companyName: "CloudTech Inc",
              location: "Seattle, WA",
              jobType: "Full-Time",
              workMode: "On-Site",
              experience: "Entry Level",
              postDate: "2 days ago",
              description: "Join our backend team to build scalable cloud infrastructure.",
            ),
          ],
        ),
      ),
    );
  }

}

