import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:social_media_app/Features/wrapper/view_model/wrapper_view_model.dart';



List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => WrapperViewModel()),


];
