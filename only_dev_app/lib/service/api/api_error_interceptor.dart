import 'package:dio/dio.dart';
import '../../utils/app_toast_utils.dart';

class ApiErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Allow requests to pass options: Options(extra: {'silent': true}) to bypass automatic toast
    final isSilent = err.requestOptions.extra['silent'] == true;

    String errorMessage = 'Something went wrong. Please try again.';

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Connection timed out. Please check your internet connection.';
    } else if (err.type == DioExceptionType.connectionError) {
      errorMessage = 'Unable to connect to the Only-Dev server. Please check your network.';
    } else if (err.response != null) {
      final data = err.response?.data;
      if (data is Map<String, dynamic>) {
        if (data['error'] != null) {
          errorMessage = data['error'].toString();
        } else if (data['message'] != null) {
          if (data['message'] is List) {
            errorMessage = (data['message'] as List).join(', ');
          } else {
            errorMessage = data['message'].toString();
          }
        }
      } else if (err.response?.statusCode == 401) {
        errorMessage = 'Your session has expired. Please log in again.';
      } else if (err.response?.statusCode == 403) {
        errorMessage = 'Access denied. You do not have permission for this action.';
      } else if (err.response?.statusCode == 404) {
        errorMessage = 'The requested resource was not found.';
      } else if (err.response?.statusCode != null && err.response!.statusCode! >= 500) {
        errorMessage = 'Server error (${err.response?.statusCode}). Please try again later.';
      }
    }

    if (!isSilent) {
      AppToastUtils.error(errorMessage);
    }

    super.onError(err, handler);
  }
}

