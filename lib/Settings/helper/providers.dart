import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:social_media_app/Features/wrapper/view_model/wrapper_view_model.dart';
import 'package:social_media_app/Features/post/view_model/post_view_model.dart';
import 'package:social_media_app/Features/profile/profile_screen/view_model/profile_view_model.dart';
import 'package:social_media_app/Features/auth/sign_in/view_model/sign_in_view_model.dart';
import 'package:social_media_app/Features/auth/sign_up/view_model/sign_up_view_model.dart';
import 'package:social_media_app/Features/profile/create_profile/view_model/create_profile_view_model.dart';
import 'package:social_media_app/Features/home/view_model/home_view_model.dart';
import 'package:social_media_app/Features/feed/view_model/feed_view_model.dart';
import 'package:social_media_app/Features/search/view_model/search_view_model.dart';
import 'package:social_media_app/Features/chat/chat_list/view_model/chat_list_view_model.dart';
import 'package:social_media_app/Features/company_registration/view_model/company_registration_view_model.dart';
import 'package:social_media_app/Features/chat/chat_detail/view_model/chat_detail_view_model.dart';
import 'package:social_media_app/Features/jobs/add_job_post/view_model/add_job_view_model.dart';
import 'package:social_media_app/Features/jobs/job_listing_screen/view_model/job_listing_view_model.dart';
import 'package:social_media_app/Features/jobs/job_detail_screen/view_model/job_detail_view_model.dart';
import 'package:social_media_app/Features/jobs/add_job_post/repository/job_repository.dart';
import 'package:social_media_app/Features/company_registration/repository/company_repository.dart';
import 'package:social_media_app/Features/jobs/service/job_application_service.dart';
import 'package:social_media_app/Features/menu/saved_job/view_model/saved_job_view_model.dart';

import '../../Features/post/view_model/post_detail_view_model.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => WrapperViewModel()),
  ChangeNotifierProvider(create: (_) => PostViewModel()),
  ChangeNotifierProvider(create: (_) => ProfileViewModel()),
  ChangeNotifierProvider(create: (_) => SignInViewModel()),
  ChangeNotifierProvider(create: (_) => SignUpViewModel()),
  ChangeNotifierProvider(create: (_) => CreateProfileViewModel()),
  ChangeNotifierProvider(create: (_) => HomeViewModel()),
  ChangeNotifierProvider(create: (_) => FeedViewModel()),
  ChangeNotifierProvider(create: (_) => SearchViewModel()),
  ChangeNotifierProvider(create: (_) => ChatListViewModel()),
  ChangeNotifierProvider(create: (_) => ChatDetailViewModel()),
  ChangeNotifierProvider(create: (_) => CompanyRegistrationViewModel()),
  ChangeNotifierProvider(create: (_) => AddJobViewModel()),
  ChangeNotifierProvider(create: (_) => JobListingViewModel()),
  ChangeNotifierProvider(
    create: (_) => JobDetailViewModel(
      jobRepository: JobRepository(),
      companyRepository: CompanyRepository(),
      jobApplicationService: JobApplicationService(),
    ),
    lazy: true, // Make it lazy to avoid initialization issues
  ),
  ChangeNotifierProvider(create: (_) => SavedJobViewModel()),



];
