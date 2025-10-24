import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../model/company_model.dart';
import '../repository/company_repository.dart';
import '../../../../Service/cloudinary_service.dart';

class CompanyRegistrationViewModel extends ChangeNotifier {
  final CompanyRepository _companyRepository = CompanyRepository();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();

  // Text Controllers
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController industryController = TextEditingController();
  final TextEditingController companySizeController = TextEditingController();
  final TextEditingController foundedYearController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController contactTitleController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController aboutCompanyController = TextEditingController();
  final TextEditingController missionStatementController = TextEditingController();
  final TextEditingController companyCultureController = TextEditingController();
  final TextEditingController businessLicenseNumberController = TextEditingController();
  final TextEditingController taxIdController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();

  // Form data
  String _companyName = '';
  String _website = '';
  String _industry = '';
  String? _companySize;
  int _foundedYear = DateTime.now().year;
  String _companyType = '';
  String _contactPerson = '';
  String _contactTitle = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _city = '';
  String _state = '';
  String _country = '';
  String _postalCode = '';
  String _aboutCompany = '';
  String _missionStatement = '';
  String _companyCulture = '';
  String _businessLicenseNumber = '';
  String _taxId = '';
  String _gstNumber = '';

  // File uploads
  File? _businessLicenseFile;
  File? _companyLogoFile;
  String _businessLicenseUrl = '';
  String _companyLogoUrl = '';

  // UI state
  bool _isLoading = false;
  bool _isUploading = false;
  String _errorMessage = '';
  bool _isRegistrationComplete = false;
  bool _hasRegisteredCompany = false;
  bool _isEditMode = false;
  CompanyModel? _userCompany;

  // Getters
  String get companyName => _companyName;
  String get website => _website;
  String get industry => _industry;
  String? get companySize => _companySize;
  int get foundedYear => _foundedYear;
  String get companyType => _companyType;
  String get contactPerson => _contactPerson;
  String get contactTitle => _contactTitle;
  String get email => _email;
  String get phone => _phone;
  String get address => _address;
  String get city => _city;
  String get state => _state;
  String get country => _country;
  String get postalCode => _postalCode;
  String get aboutCompany => _aboutCompany;
  String get missionStatement => _missionStatement;
  String get companyCulture => _companyCulture;
  String get businessLicenseNumber => _businessLicenseNumber;
  String get taxId => _taxId;
  String get gstNumber => _gstNumber;
  File? get businessLicenseFile => _businessLicenseFile;
  File? get companyLogoFile => _companyLogoFile;
  String get businessLicenseUrl => _businessLicenseUrl;
  String get companyLogoUrl => _companyLogoUrl;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String get errorMessage => _errorMessage;
  bool get isRegistrationComplete => _isRegistrationComplete;
  bool get hasRegisteredCompany => _hasRegisteredCompany;
  bool get isEditMode => _isEditMode;
  CompanyModel? get userCompany => _userCompany;

  // Setters
  void setCompanyName(String? value) {
    _companyName = value ?? '';
    notifyListeners();
  }

  void setWebsite(String? value) {
    _website = value ?? '';
    notifyListeners();
  }

  void setIndustry(String? value) {
    _industry = value ?? '';
    notifyListeners();
  }

  void setCompanySize(String? value) {
    _companySize = value;
    notifyListeners();
  }

  void setFoundedYear(int value) {
    _foundedYear = value;
    notifyListeners();
  }

  void setCompanyType(String value) {
    _companyType = value;
    notifyListeners();
  }

  void setContactPerson(String? value) {
    _contactPerson = value ?? '';
    notifyListeners();
  }

  void setContactTitle(String? value) {
    _contactTitle = value ?? '';
    notifyListeners();
  }

  void setEmail(String? value) {
    _email = value ?? '';
    notifyListeners();
  }

  void setPhone(String? value) {
    _phone = value ?? '';
    notifyListeners();
  }

  void setAddress(String? value) {
    _address = value ?? '';
    notifyListeners();
  }

  void setCity(String? value) {
    _city = value ?? '';
    notifyListeners();
  }

  void setState(String? value) {
    _state = value ?? '';
    notifyListeners();
  }

  void setCountry(String? value) {
    _country = value ?? '';
    notifyListeners();
  }

  void setPostalCode(String? value) {
    _postalCode = value ?? '';
    notifyListeners();
  }

  void setAboutCompany(String? value) {
    _aboutCompany = value ?? '';
    notifyListeners();
  }

  void setMissionStatement(String? value) {
    _missionStatement = value ?? '';
    notifyListeners();
  }

  void setCompanyCulture(String? value) {
    _companyCulture = value ?? '';
    notifyListeners();
  }

  void setBusinessLicenseNumber(String? value) {
    _businessLicenseNumber = value ?? '';
    notifyListeners();
  }

  void setTaxId(String? value) {
    _taxId = value ?? '';
    notifyListeners();
  }

  void setGstNumber(String? value) {
    _gstNumber = value ?? '';
    notifyListeners();
  }

  // File upload methods
  Future<void> pickBusinessLicense() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (file != null) {
        _businessLicenseFile = File(file.path);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick business license: $e';
      notifyListeners();
    }
  }

  Future<void> pickCompanyLogo() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (file != null) {
        _companyLogoFile = File(file.path);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick company logo: $e';
      notifyListeners();
    }
  }

  // Upload files to Cloudinary
  Future<void> uploadBusinessLicense() async {
    if (_businessLicenseFile == null) return;

    try {
      _isUploading = true;
      _errorMessage = '';
      notifyListeners();

      _businessLicenseUrl = await _cloudinaryService.uploadMedia(
        _businessLicenseFile!,
        isVideo: false,
      );
    } catch (e) {
      _errorMessage = 'Failed to upload business license: $e';
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> uploadCompanyLogo() async {
    if (_companyLogoFile == null) return;

    try {
      _isUploading = true;
      _errorMessage = '';
      notifyListeners();

      _companyLogoUrl = await _cloudinaryService.uploadImage(
        _companyLogoFile!.path,
      );
    } catch (e) {
      _errorMessage = 'Failed to upload company logo: $e';
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // Register company
  Future<bool> registerCompany() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      // Validate required fields
      if (!_validateForm()) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Upload files if not already uploaded
      if (_businessLicenseFile != null && _businessLicenseUrl.isEmpty) {
        await uploadBusinessLicense();
        if (_errorMessage.isNotEmpty) return false;
      }

      if (_companyLogoFile != null && _companyLogoUrl.isEmpty) {
        await uploadCompanyLogo();
        if (_errorMessage.isNotEmpty) return false;
      }

      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _errorMessage = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get values from controllers
      _companyName = companyNameController.text;
      _website = websiteController.text;
      _industry = industryController.text;
      _companySize = _companySize; // Keep the dropdown value
      _foundedYear = int.tryParse(foundedYearController.text) ?? DateTime.now().year;
      _contactPerson = contactPersonController.text;
      _contactTitle = contactTitleController.text;
      _email = emailController.text;
      _phone = phoneController.text;
      _address = addressController.text;
      _city = cityController.text;
      _state = stateController.text;
      _country = countryController.text;
      _postalCode = postalCodeController.text;
      _aboutCompany = aboutCompanyController.text;
      _missionStatement = missionStatementController.text;
      _companyCulture = companyCultureController.text;
      _businessLicenseNumber = businessLicenseNumberController.text;
      _taxId = taxIdController.text;
      _gstNumber = gstNumberController.text;

      if (_isEditMode && _userCompany != null) {
        // UPDATE existing company
        
        final updates = {
          'companyName': _companyName,
          'website': _website,
          'industry': _industry,
          'companySize': _companySize,
          'foundedYear': _foundedYear,
          'companyType': _companyType,
          'contactPerson': _contactPerson,
          'contactTitle': _contactTitle,
          'email': _email,
          'phone': _phone,
          'address': _address,
          'city': _city,
          'state': _state,
          'country': _country,
          'postalCode': _postalCode,
          'aboutCompany': _aboutCompany,
          'missionStatement': _missionStatement,
          'companyCulture': _companyCulture,
          // Note: businessLicenseNumber and taxId are NOT updated (read-only)
          if (_companyLogoUrl.isNotEmpty) 'companyLogoUrl': _companyLogoUrl,
        };
        
        await _companyRepository.updateCompany(_userCompany!.id, updates);
      } else {
        // CREATE new company
        
        final company = CompanyModel(
          id: '', // Will be set by Firestore
          companyName: _companyName,
          website: _website,
          industry: _industry,
          companySize: _companySize ?? '',
          foundedYear: _foundedYear,
          companyType: _companyType,
          contactPerson: _contactPerson,
          contactTitle: _contactTitle,
          email: _email,
          phone: _phone,
          address: _address,
          city: _city,
          state: _state,
          country: _country,
          postalCode: _postalCode,
          aboutCompany: _aboutCompany,
          missionStatement: _missionStatement,
          companyCulture: _companyCulture,
          businessLicenseNumber: _businessLicenseNumber,
          businessLicenseUrl: _businessLicenseUrl,
          taxId: _taxId,
          gstNumber: _gstNumber,
          companyLogoUrl: _companyLogoUrl,
          userId: user.uid,
          isVerified: true, // Auto-verify company (no admin required)
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save to Firebase
        await _companyRepository.createCompany(company);
      }

      // Load the company back to get the complete data
      await loadUserCompany();
      

      _isRegistrationComplete = true;
      _isEditMode = false; // Reset edit mode
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _isEditMode 
          ? 'Update failed: $e' 
          : 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Validate form
  bool _validateForm() {
    if (companyNameController.text.isEmpty) {
      _errorMessage = 'Company name is required';
      return false;
    }
    if (websiteController.text.isEmpty) {
      _errorMessage = 'Website is required';
      return false;
    }
    if (industryController.text.isEmpty) {
      _errorMessage = 'Industry is required';
      return false;
    }
    if (contactPersonController.text.isEmpty) {
      _errorMessage = 'Contact person is required';
      return false;
    }
    if (_companySize == null || _companySize!.isEmpty) {
      _errorMessage = 'Company size is required';
      return false;
    }
    if (emailController.text.isEmpty) {
      _errorMessage = 'Email is required';
      return false;
    }
    if (phoneController.text.isEmpty) {
      _errorMessage = 'Phone is required';
      return false;
    }
    if (addressController.text.isEmpty) {
      _errorMessage = 'Address is required';
      return false;
    }
    
    // Only validate business license, tax ID, and GST for new registrations (not edits)
    if (!_isEditMode) {
      if (businessLicenseNumberController.text.isEmpty) {
        _errorMessage = 'Business license number is required';
        return false;
      }
      if (taxIdController.text.isEmpty) {
        _errorMessage = 'Tax ID is required';
        return false;
      }
      if (gstNumberController.text.isEmpty) {
        _errorMessage = 'GST number is required';
        return false;
      }
      if (_businessLicenseFile == null && _businessLicenseUrl.isEmpty) {
        _errorMessage = 'Business license document is required';
        return false;
      }
    }
    
    // Logo validation (only required for new registrations)
    if (!_isEditMode && _companyLogoFile == null && _companyLogoUrl.isEmpty) {
      _errorMessage = 'Company logo is required';
      return false;
    }
    return true;
  }

  // Clear form
  void clearForm() {
    // Clear controllers
    companyNameController.clear();
    websiteController.clear();
    industryController.clear();
    companySizeController.clear();
    foundedYearController.clear();
    contactPersonController.clear();
    contactTitleController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    cityController.clear();
    stateController.clear();
    countryController.clear();
    postalCodeController.clear();
    aboutCompanyController.clear();
    missionStatementController.clear();
    companyCultureController.clear();
    businessLicenseNumberController.clear();
    taxIdController.clear();
    gstNumberController.clear();
    
    // Clear private variables
    _companyName = '';
    _website = '';
    _industry = '';
    _companySize = null;
    _foundedYear = DateTime.now().year;
    _companyType = '';
    _contactPerson = '';
    _contactTitle = '';
    _email = '';
    _phone = '';
    _address = '';
    _city = '';
    _state = '';
    _country = '';
    _postalCode = '';
    _aboutCompany = '';
    _missionStatement = '';
    _companyCulture = '';
    _businessLicenseNumber = '';
    _taxId = '';
    _gstNumber = '';
    _businessLicenseFile = null;
    _companyLogoFile = null;
    _businessLicenseUrl = '';
    _companyLogoUrl = '';
    _errorMessage = '';
    _isEditMode = false;
    _isLoading = false;
    _isUploading = false;
    _errorMessage = '';
    _isRegistrationComplete = false;
    notifyListeners();
  }

  // Check if user already has a company
  Future<bool> checkExistingCompany() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      return await _companyRepository.isUserCompanyRegistered(user.uid);
    } catch (e) {
      _errorMessage = 'Failed to check existing company: $e';
      notifyListeners();
      return false;
    }
  }

  // Load user's company data
  Future<void> loadUserCompany() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _hasRegisteredCompany = false;
        _userCompany = null;
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();

      final company = await _companyRepository.getCompanyByUserId(user.uid);
      
      if (company != null) {
        _hasRegisteredCompany = true;
        _userCompany = company;
      } else {
        _hasRegisteredCompany = false;
        _userCompany = null;
      }
    } catch (e) {
      _hasRegisteredCompany = false;
      _userCompany = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if company is verified
  bool get isCompanyVerified => _userCompany?.isVerified ?? false;

  // Load company data into form for editing
  void loadCompanyForEdit() {
    if (_userCompany == null) return;
    
    
    _isEditMode = true; // Set edit mode
    
    companyNameController.text = _userCompany!.companyName;
    websiteController.text = _userCompany!.website;
    industryController.text = _userCompany!.industry;
    _companySize = _userCompany!.companySize;
    foundedYearController.text = _userCompany!.foundedYear.toString();
    contactPersonController.text = _userCompany!.contactPerson;
    contactTitleController.text = _userCompany!.contactTitle;
    emailController.text = _userCompany!.email;
    phoneController.text = _userCompany!.phone;
    addressController.text = _userCompany!.address;
    cityController.text = _userCompany!.city;
    stateController.text = _userCompany!.state;
    countryController.text = _userCompany!.country;
    postalCodeController.text = _userCompany!.postalCode;
    aboutCompanyController.text = _userCompany!.aboutCompany;
    missionStatementController.text = _userCompany!.missionStatement;
    companyCultureController.text = _userCompany!.companyCulture;
    businessLicenseNumberController.text = _userCompany!.businessLicenseNumber;
    taxIdController.text = _userCompany!.taxId;
    gstNumberController.text = _userCompany!.gstNumber;
    
    _companyType = _userCompany!.companyType;
    _companyLogoUrl = _userCompany!.companyLogoUrl;
    _businessLicenseUrl = _userCompany!.businessLicenseUrl;
    
    notifyListeners();
  }

  // Delete company
  Future<bool> deleteCompany() async {
    if (_userCompany == null) return false;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      await _companyRepository.deleteCompany(_userCompany!.id);
      
      // Update user document
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'isCompanyRegistered': false,
          'companyId': FieldValue.delete(),
          'companyName': FieldValue.delete(),
        });
      }
      
      // Clear local state
      _hasRegisteredCompany = false;
      _userCompany = null;
      clearForm();
      
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete company: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    companyNameController.dispose();
    websiteController.dispose();
    industryController.dispose();
    companySizeController.dispose();
    foundedYearController.dispose();
    contactPersonController.dispose();
    contactTitleController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    postalCodeController.dispose();
    aboutCompanyController.dispose();
    missionStatementController.dispose();
    companyCultureController.dispose();
    businessLicenseNumberController.dispose();
    taxIdController.dispose();
    gstNumberController.dispose();
    super.dispose();
  }
}
