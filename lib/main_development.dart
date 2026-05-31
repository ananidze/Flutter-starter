import 'package:flutter_starter/app/config/app_config.dart';
import 'package:flutter_starter/bootstrap.dart';

Future<void> main() => bootstrap(AppConfig.fromEnvironment('development'));
