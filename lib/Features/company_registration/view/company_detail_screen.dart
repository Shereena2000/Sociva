import 'package:flutter/material.dart';
import '../model/company_model.dart';
import '../../../Settings/utils/p_colors.dart';
import '../../../Settings/utils/p_text_styles.dart';
import '../../../Settings/constants/sized_box.dart';

/// Public-facing company detail screen for candidates
/// Shows company information without sensitive business details
class CompanyDetailScreen extends StatelessWidget {
  final CompanyModel company;

  const CompanyDetailScreen({
    super.key,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: PColors.scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: PColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Company Details',
          style: PTextStyles.headlineMedium.copyWith(
            color: PColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Header with Logo
            _buildCompanyHeader(),
            
            SizeBoxH(20),
            
            // Company Information Card
            _buildCard(
              children: [
                _buildSectionTitle('Company Information'),
                SizeBoxH(16),
                _buildInfoRow('Industry', company.industry, Icons.business_center),
                _buildInfoRow('Company Size', company.companySize, Icons.people),
                _buildInfoRow('Founded', company.foundedYear.toString(), Icons.calendar_today),
                _buildInfoRow('Type', company.companyType, Icons.category),
                if (company.website.isNotEmpty)
                  _buildInfoRow('Website', company.website, Icons.language),
              ],
            ),
            
            SizeBoxH(16),
            
            // About Company
            if (company.aboutCompany.isNotEmpty)
              _buildCard(
                children: [
                  _buildSectionTitle('About Us'),
                  SizeBoxH(12),
                  Text(
                    company.aboutCompany,
                    style: PTextStyles.bodyMedium.copyWith(
                      color: PColors.lightGray,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            
            if (company.aboutCompany.isNotEmpty) SizeBoxH(16),
            
            // Mission Statement
            if (company.missionStatement.isNotEmpty)
              _buildCard(
                children: [
                  _buildSectionTitle('Our Mission'),
                  SizeBoxH(12),
                  Text(
                    company.missionStatement,
                    style: PTextStyles.bodyMedium.copyWith(
                      color: PColors.lightGray,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            
            if (company.missionStatement.isNotEmpty) SizeBoxH(16),
            
            // Company Culture
            if (company.companyCulture.isNotEmpty)
              _buildCard(
                children: [
                  _buildSectionTitle('Company Culture'),
                  SizeBoxH(12),
                  Text(
                    company.companyCulture,
                    style: PTextStyles.bodyMedium.copyWith(
                      color: PColors.lightGray,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            
            if (company.companyCulture.isNotEmpty) SizeBoxH(16),
            
            // Contact Information
            _buildCard(
              children: [
                _buildSectionTitle('Contact Information'),
                SizeBoxH(16),
                _buildInfoRow('Contact Person', company.contactPerson, Icons.person),
                _buildInfoRow('Title', company.contactTitle, Icons.badge),
                _buildInfoRow('Email', company.email, Icons.email_outlined),
                _buildInfoRow('Phone', company.phone, Icons.phone_outlined),
              ],
            ),
            
            SizeBoxH(16),
            
            // Location
            _buildCard(
              children: [
                _buildSectionTitle('Location'),
                SizeBoxH(16),
                _buildLocationInfo(),
              ],
            ),
            
            SizeBoxH(32),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PColors.blueColor.withOpacity(0.2),
            PColors.purpleColor.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Company Logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PColors.primaryColor, width: 3),
              color: PColors.darkGray,
            ),
            child: company.companyLogoUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      company.companyLogoUrl,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(Icons.business, size: 50, color: PColors.lightGray),
          ),
          
          SizeBoxH(16),
          
          // Company Name
          Text(
            company.companyName,
            style: PTextStyles.displayMedium.copyWith(
              color: PColors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizeBoxH(8),
          
          // Verification Badge
          if (company.isVerified)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, size: 18, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Verified Company',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: PColors.darkGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: PTextStyles.headlineSmall.copyWith(
        color: PColors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    if (value.isEmpty) return SizedBox.shrink();
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: PColors.primaryColor),
          SizeBoxV(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: PTextStyles.labelMedium.copyWith(
                    color: PColors.lightGray,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: PTextStyles.bodyMedium.copyWith(
                    color: PColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    final locationParts = <String>[];
    
    if (company.address.isNotEmpty) locationParts.add(company.address);
    if (company.city.isNotEmpty) locationParts.add(company.city);
    if (company.state.isNotEmpty) locationParts.add(company.state);
    if (company.country.isNotEmpty) locationParts.add(company.country);
    if (company.postalCode.isNotEmpty) locationParts.add(company.postalCode);
    
    final fullAddress = locationParts.join(', ');
    
    if (fullAddress.isEmpty) {
      return Text(
        'Location not provided',
        style: PTextStyles.bodyMedium.copyWith(color: PColors.lightGray),
      );
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on, size: 20, color: PColors.primaryColor),
        SizeBoxV(12),
        Expanded(
          child: Text(
            fullAddress,
            style: PTextStyles.bodyMedium.copyWith(
              color: PColors.white,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

