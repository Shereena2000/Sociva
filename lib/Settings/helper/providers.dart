import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:social_media_app/Features/wrapper/view_model/wrapper_view_model.dart';
import 'package:social_media_app/Features/post/view_model/post_view_model.dart';
import 'package:social_media_app/Features/profile/view_model/profile_view_model.dart';



List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => WrapperViewModel()),
  ChangeNotifierProvider(create: (_) => PostViewModel()),
  ChangeNotifierProvider(create: (_) => ProfileViewModel()),


];
