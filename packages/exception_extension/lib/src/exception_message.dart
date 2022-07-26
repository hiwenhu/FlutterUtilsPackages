import 'dart:io';

import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart';

extension ObjectX on Object {
  String get exceptionMsg {
    var e = this;
    String? errorMessage;
    if (e is PlatformException) {
      errorMessage = e.message;
    } else if (e is SocketException) {
      errorMessage = e.message;
    } else if (e is DetailedApiRequestError) {
      errorMessage = e.message;
    } else if (e is FileSystemException) {
      errorMessage = e.message;
    }
    errorMessage ??= e.toString();
    return errorMessage;
  }
}
