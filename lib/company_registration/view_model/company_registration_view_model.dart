import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../model/company_model.dart';
import '../repository/company_repository.dart';
import '../../../Service/cloudinary_service.dart';

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

  // Form data
  String _companyName = '';
  String _website = '';
  String _industry = '';
  String _companySize = '';
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
  CompanyModel? _userCompany;

  // Getters
  String get companyName => _companyName;
  String get website => _website;
  String get industry => _industry;
  String get companySize => _companySize;
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
  File? get businessLicenseFile => _businessLicenseFile;
  File? get companyLogoFile => _companyLogoFile;
  String get businessLicenseUrl => _businessLicenseUrl;
  String get companyLogoUrl => _companyLogoUrl;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String get errorMessage => _errorMessage;
  bool get isRegistrationComplete => _isRegistrationComplete;
  bool get hasRegisteredCompany => _hasRegisteredCompany;
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
    _companySize = value ?? '';
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
      _companySize = companySizeController.text;
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

      // Create company model
      final company = CompanyModel(
        id: '', // Will be set by Firestore
        companyName: _companyName,
        website: _website,
        industry: _industry,
        companySize: _companySize,
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
        companyLogoUrl: _companyLogoUrl,
        userId: user.uid,
        isVerified: true, // Auto-verify company (no admin required)
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firebase
      final companyId = await _companyRepository.createCompany(company);
      
      print('✅ Company registered with ID: $companyId');

      _isRegistrationComplete = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
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
    if (businessLicenseNumberController.text.isEmpty) {
      _errorMessage = 'Business license number is required';
      return false;
    }
    if (taxIdController.text.isEmpty) {
      _errorMessage = 'Tax ID is required';
      return false;
    }
    if (_businessLicenseFile == null) {
      _errorMessage = 'Business license document is required';
      return false;
    }
    if (_companyLogoFile == null) {
      _errorMessage = 'Company logo is required';
      return false;
    }
    return true;
  }

  // Clear form
  void clearForm() {
    _companyName = '';
    _website = '';
    _industry = '';
    _companySize = '';
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
    _businessLicenseFile = null;
    _companyLogoFile = null;
    _businessLicenseUrl = '';
    _companyLogoUrl = '';
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
        print('❌ No user logged in');
        _hasRegisteredCompany = false;
        _userCompany = null;
        notifyListeners();
        return;
      }

      print('🔍 Loading company for user: ${user.uid}');
      _isLoading = true;
      notifyListeners();

      final company = await _companyRepository.getCompanyByUserId(user.uid);
      
      if (company != null) {
        print('✅ Company found: ${company.companyName}, Verified: ${company.isVerified}');
        _hasRegisteredCompany = true;
        _userCompany = company;
      } else {
        print('❌ No company found for user');
        _hasRegisteredCompany = false;
        _userCompany = null;
      }
    } catch (e) {
      print('❌ Error loading user company: $e');
      _hasRegisteredCompany = false;
      _userCompany = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if company is verified
  bool get isCompanyVerified => _userCompany?.isVerified ?? false;

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
    super.dispose();
  }
}
