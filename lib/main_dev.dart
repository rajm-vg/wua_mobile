import 'package:wua_mobile/core/constants/env_config.dart';
import 'package:wua_mobile/main.dart';

Future<void> main() async {
  await bootstrap(AppEnvironment.development);
}
