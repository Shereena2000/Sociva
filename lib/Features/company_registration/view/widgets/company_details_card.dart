import 'package:flutter/material.dart';
import '../../model/company_model.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_text_styles.dart';
import '../../../../Settings/constants/sized_box.dart';

class CompanyDetailsCard extends StatelessWidget {
  final CompanyModel company;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CompanyDetailsCard({
    super.key,
    required this.company,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: PColors.darkGray,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Logo and Status
            _buildHeader(),
            
            SizeBoxH(20),
            Divider(color: Colors.grey[700]),
            SizeBoxH(20),
            
            // Company Information Section
            _buildSection(
              'Company Information',
              [
                _buildInfoRow('Company Name', company.companyName),
                _buildInfoRow('Website', company.website),
                _buildInfoRow('Industry', company.industry),
                _buildInfoRow('Company Size', company.companySize),
                _buildInfoRow('Founded Year', company.foundedYear.toString()),
                _buildInfoRow('Company Type', company.companyType),
              ],
            ),
            
            SizeBoxH(20),
            
            // Contact Details Section
            _buildSection(
              'Contact Details',
              [
                _buildInfoRow('Contact Person', company.contactPerson),
                _buildInfoRow('Title', company.contactTitle),
                _buildInfoRow('Email', company.email, icon: Icons.email_outlined),
                _buildInfoRow('Phone', company.phone, icon: Icons.phone_outlined),
              ],
            ),
            
            SizeBoxH(20),
            
            // Address Section
            _buildSection(
              'Address',
              [
                _buildInfoRow('Street', company.address),
                _buildInfoRow('City', company.city),
                _buildInfoRow('State/Province', company.state),
                _buildInfoRow('Country', company.country),
                _buildInfoRow('Postal Code', company.postalCode),
              ],
            ),
            
            SizeBoxH(20),
            
            // Business Details Section
            _buildSection(
              'Business Details',
              [
                _buildInfoRow('Business License', company.businessLicenseNumber, 
                  icon: Icons.badge_outlined, isReadOnly: true),
                _buildInfoRow('Tax ID', company.taxId, 
                  icon: Icons.numbers_outlined, isReadOnly: true),
              ],
            ),
            
            SizeBoxH(20),
            
            // Description Section
            if (company.aboutCompany.isNotEmpty) ...[
              _buildSection(
                'About Company',
                [
                  Text(
                    company.aboutCompany,
                    style: PTextStyles.bodyMedium.copyWith(
                      color: PColors.lightGray,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              SizeBoxH(16),
            ],
            
            if (company.missionStatement.isNotEmpty) ...[
              _buildSection(
                'Mission Statement',
                [
                  Text(
                    company.missionStatement,
                    style: PTextStyles.bodyMedium.copyWith(
                      color: PColors.lightGray,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              SizeBoxH(16),
            ],
            
            if (company.companyCulture.isNotEmpty) ...[
              _buildSection(
                'Company Culture',
                [
                  Text(
                    company.companyCulture,
                    style: PTextStyles.bodyMedium.copyWith(
                      color: PColors.lightGray,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              SizeBoxH(16),
            ],
            
            SizeBoxH(20),
            Divider(color: Colors.grey[700]),
            SizeBoxH(20),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Company Logo
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PColors.primaryColor, width: 2),
          ),
          child: company.companyLogoUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    company.companyLogoUrl,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(Icons.business, size: 40, color: PColors.lightGray),
        ),
        
        SizeBoxV(16),
        
        // Company Name and Status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                company.companyName,
                style: PTextStyles.headlineMedium.copyWith(
                  color: PColors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizeBoxH(8),
              _buildStatusBadge(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: company.isVerified ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: company.isVerified ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            company.isVerified ? Icons.verified : Icons.pending,
            size: 16,
            color: company.isVerified ? Colors.green : Colors.orange,
          ),
          SizedBox(width: 6),
          Text(
            company.isVerified ? 'Verified' : 'Pending Verification',
            style: TextStyle(
              color: company.isVerified ? Colors.green : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: PTextStyles.headlineSmall.copyWith(
            color: PColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizeBoxH(12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon, bool isReadOnly = false}) {
    if (value.isEmpty) return SizedBox.shrink();
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: PColors.primaryColor),
            SizeBoxV(12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: PTextStyles.labelMedium.copyWith(
                        color: PColors.lightGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isReadOnly) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Read-only',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, size: 20),
            label: Text('Edit Company'),
            style: OutlinedButton.styleFrom(
              foregroundColor: PColors.primaryColor,
              side: BorderSide(color: PColors.primaryColor),
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizeBoxV(12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, size: 20),
            label: Text('Delete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

