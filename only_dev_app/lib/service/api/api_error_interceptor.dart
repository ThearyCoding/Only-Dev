import 'package:dio/dio.dart';
import '../../utils/app_toast_utils.dart';

class ApiErrorInterceptor extends Interceptor {
  static String extractErrorMessage(dynamic err) {
    if (err is DioException) {
      if (err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.sendTimeout ||
          err.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Please check your internet connection.';
      } else if (err.type == DioExceptionType.connectionError) {
        return 'Unable to connect to the Only-Dev server. Please check your network connection.';
      } else if (err.response != null) {
        final data = err.response?.data;
        if (data is Map<String, dynamic>) {
          if (data['error'] != null) {
            return data['error'].toString();
          } else if (data['message'] != null) {
            if (data['message'] is List) {
              return (data['message'] as List).join(', ');
            } else {
              return data['message'].toString();
            }
          }
        }
        if (err.response?.statusCode == 401) {
          return 'Authentication required. Please log in to proceed.';
        } else if (err.response?.statusCode == 403) {
          return 'Access denied. You do not have permission for this action.';
        } else if (err.response?.statusCode == 404) {
          return 'The requested course was not found.';
        } else if (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500) {
          return 'Server error (${err.response?.statusCode}). Please try again later.';
        }
      }
    }
    final raw = err?.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
    if (raw == null || raw.isEmpty || raw.contains('DioException')) {
      return 'Something went wrong while loading data. Please try again.';
    }
    return raw;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Allow requests to pass options: Options(extra: {'silent': true}) to bypass automatic toast
    final isSilent = err.requestOptions.extra['silent'] == true;
    final errorMessage = extractErrorMessage(err);

    if (!isSilent) {
      AppToastUtils.error(errorMessage);
    }

    super.onError(err, handler);
  }
}

