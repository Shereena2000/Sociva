import 'package:flutter/material.dart';
import '../../../../Settings/common/widgets/custom_elevated_button.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_text_styles.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 
      appBar: AppBar(

        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,  size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Job Details',
          style: TextStyle(
     
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Job Overview Card
            _buildJobOverviewCard(),
            SizeBoxH(16),
            
            // Job Description Card
            _buildJobDescriptionCard(),
            SizeBoxH(16),
            
            // Company Info Card
            _buildCompanyInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildJobOverviewCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!, width: 2),
                ),
                child: Icon(
                  Icons.business,
                  color: Colors.blue[600],
                  size: 30,
                ),
              ),
              SizeBoxV(12),
              
              // Job Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Front End Developer',
                      style: PTextStyles.headlineLarge.copyWith(color: PColors.black),
                    ),
                    SizeBoxH(4),
                    Text(
                      'TechCorp Solutions',
                       style: PTextStyles.headlineMedium.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
                    ),   
              
               
                  ],
                ),
              ),
              
           
            ],
          ),
          
          SizeBoxH(20),
          
          // Job Details Row
          Row(
            children: [
              _buildJobDetailItem(Icons.work_outline, '0-3 years', 'Experience'),

              SizeBoxV(16),
              _buildJobDetailItem(Icons.location_on, 'Bengaluru, Chennai', 'Location'),
            ],
          ),
          
         Divider(),
          
          // Job Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildJobStat('Posted', '4 days ago'),
              _buildJobStat('Openings', '20'),
              _buildJobStat('Applicants', '100+'),
            ],
          ),
          
          SizeBoxH(20),
          CustomElavatedTextButton(onPressed: (){}, text: 'Apply Now',height: 46,)
          
        ],
      ),
    );
  }

  Widget _buildJobDetailItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizeBoxH(4),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildJobStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
         Text(
          label,
          style: PTextStyles.headlineSmall.copyWith(color: Colors.grey[600]),
        ),
      
         Text(
         ' : ',
          style: PTextStyles.headlineSmall
        ),
         Text(
          value,
          style: PTextStyles.headlineSmall,
        ),
      ],
    );
  }

  Widget _buildJobDescriptionCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PColors.white,
        borderRadius: BorderRadius.circular(12),
      
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Description',
            style: PTextStyles.headlineLarge.copyWith(
              color: Colors.black,
            
            ),
          ),
          SizeBoxH(16),
          
          // Role Summary
          Text(
            'Role Summary:',
            style: PTextStyles.bodyMedium.copyWith(
              color: PColors.black,
          
            ),
          ),
          SizeBoxH(8),
          Text(
            'Build and optimize user-facing features and interfaces for web applications.',
            style: PTextStyles.labelMedium.copyWith(
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizeBoxH(16),
          
          // Responsibilities
          Text(
            'Responsibilities:',
              style: PTextStyles.bodyMedium.copyWith(
              color: PColors.black,
          
            ),
          ),
          SizeBoxH(8),
          _buildBulletPoint('Translate UI/UX designs into responsive web interfaces.'),
          _buildBulletPoint('Optimize applications for speed and scalability.'),
          _buildBulletPoint('Collaborate with backend developers and designers.'),
          SizeBoxH(16),
          
          // Qualifications
          Text(
            'Qualifications:',
            style: PTextStyles.bodyMedium.copyWith(
              color: PColors.black,
          
            ),
          ),
          SizeBoxH(8),
          _buildBulletPoint('Bachelor\'s degree in Computer Science or related field.'),
          _buildBulletPoint('Experience with modern frontend frameworks.'),
          SizeBoxH(16),
          
          // Key Skills
          Text(
            'Key Skills:',
              style: PTextStyles.bodyMedium.copyWith(
              color: PColors.black,
          
            ),
          ),
          SizeBoxH(8),
          _buildBulletPoint('HTML, CSS, JavaScript'),
          _buildBulletPoint('React.js, Angular, or Vue.js'),
          _buildBulletPoint('Responsive design'),
          _buildBulletPoint('Version control (Git)'),
          _buildBulletPoint('Cross-browser compatibility'),
          SizeBoxH(16),
          

        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              text,
               style: PTextStyles.labelMedium.copyWith(
              color: Colors.grey[700],
              height: 1.5,
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          SizeBoxV(4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'About Company',
             style: PTextStyles.headlineLarge.copyWith(
              color: Colors.black,
            
            ),
          ),
          SizeBoxH(16),
          
          // Company Name
          Text(
            'TechCorp Solutions',
            style: PTextStyles.bodyMedium.copyWith(
              color: PColors.black,
          
            ),
          ),
          SizeBoxH(8),
          
          // Company Description
          Text(
            'We are a leading technology company specializing in innovative software solutions. Our team is dedicated to creating cutting-edge applications that drive digital transformation.',
             style: PTextStyles.labelMedium.copyWith(
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizeBoxH(16),
          
          // Company Info
          Text(
            'Company Info',
             style: PTextStyles.bodyMedium.copyWith(
              color: PColors.black,
          
            ),
          ),
          SizeBoxH(8),
          
          _buildCompanyDetailRow('Address:', '54, 33, Mount Poonamallee Rd, Sripuram Colony, Vir, Chennai, Tamilnadu, India'),
          _buildCompanyDetailRow('Industry:', 'Information Technology'),
          _buildCompanyDetailRow('Company Size:', '51-200 employees'),
          _buildCompanyDetailRow('Founded:', '2015'),
          _buildCompanyDetailRow('Website:', 'www.techcorp.com'),
        ],
      ),
    );
  }

  Widget _buildCompanyDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          SizeBoxV(4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}