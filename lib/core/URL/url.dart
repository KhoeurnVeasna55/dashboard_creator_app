 import 'package:flutter_dotenv/flutter_dotenv.dart';

// ignore: non_constant_identifier_names
var URL = dotenv.env["FLUTTER_ENV"] == "production" ?   dotenv.env['API_KEY_PRODUCTION'] :  dotenv.env['API_KEY_DEVELOPMENT'];
