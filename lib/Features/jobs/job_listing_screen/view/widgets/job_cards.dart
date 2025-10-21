import 'package:flutter/material.dart';

import '../../../../../Settings/constants/sized_box.dart';
import '../../../../../Settings/utils/p_text_styles.dart';
import '../../../../../Settings/utils/p_pages.dart';

class JobCard extends StatelessWidget {
  final String jobTitle;
  final String companyName;
  final String location;
  final String jobType;
  final String workMode;
  final String experience;
  final String postDate;
  final String description;

  const JobCard({
    super.key,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.jobType,
    required this.workMode,
    required this.experience,
    required this.postDate,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, PPages.jobDetailScreen);
      },
      child: Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Logo
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.business,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ),
              SizeBoxV(10),
              
              // Job Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jobTitle,
                      style: PTextStyles.headlineMedium.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizeBoxH(4),
                    Text(
                      companyName,
                      style: PTextStyles.labelMedium.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizeBoxH(4),
                    Text(
                      postDate,
                      style: PTextStyles.labelMedium.copyWith(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
                  //add geture detctor to navigate to job detail screen
              // View Button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "View",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          SizeBoxH(16),
          
          // Description
          Text(
            description,
            style: PTextStyles.bodyMedium.copyWith(
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          
          SizeBoxH(16),
          
          // Location
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 20,
                color: Colors.grey[600],
              ),
              SizeBoxV(8),
              Text(
                location,
                style: PTextStyles.labelMedium.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Icon(
                Icons.bookmark_border_outlined,
                size: 24,
                color: Colors.grey[600],
              ),
            ],
          ),
          
          SizeBoxH(16),
          
          // Job Tags
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildJobTag(jobType),
              _buildJobTag(workMode),
              _buildJobTag(experience),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildJobTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
