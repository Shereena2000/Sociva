import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:social_media_app/Features/wrapper/view_model/wrapper_view_model.dart';
import 'package:social_media_app/Features/post/view_model/post_view_model.dart';
import 'package:social_media_app/Features/profile/profile_screen/view_model/profile_view_model.dart';
import 'package:social_media_app/Features/auth/sign_in/view_model/sign_in_view_model.dart';
import 'package:social_media_app/Features/auth/sign_up/view_model/sign_up_view_model.dart';
import 'package:social_media_app/Features/profile/create_profile/view_model/create_profile_view_model.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => WrapperViewModel()),
  ChangeNotifierProvider(create: (_) => PostViewModel()),
  ChangeNotifierProvider(create: (_) => ProfileViewModel()),
  ChangeNotifierProvider(create: (_) => SignInViewModel()),
  ChangeNotifierProvider(create: (_) => SignUpViewModel()),
  ChangeNotifierProvider(create: (_) => CreateProfileViewModel()),
];
