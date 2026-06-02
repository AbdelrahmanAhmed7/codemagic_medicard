import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ErrorHandler {
  static String handle(dynamic error, [BuildContext? context]) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return context != null
            ? 'errors.connection_timeout'.tr()
            : "Connection timeout, please try again later.";
      }

      if (error.type == DioExceptionType.badResponse) {
        final response = error.response;

        if (response?.data is Map<String, dynamic>) {
          final message = response?.data['message'];
          if (message != null && message.toString().isNotEmpty) {
            return message.toString();
          }
        }

        switch (response?.statusCode) {
          case 400:
            return context != null
                ? 'errors.bad_request'.tr()
                : "Bad request. Please check your input.";
          case 401:
            return context != null
                ? 'errors.unauthorized'.tr()
                : "Unauthorized. Please log in again.";
          case 403:
            return context != null
                ? 'errors.access_denied'.tr()
                : "Access denied.";
          case 404:
            return context != null
                ? 'errors.not_found'.tr()
                : "Endpoint not found.";
          case 500:
            return context != null
                ? 'errors.internal_server_error'.tr()
                : "Internal server error.";
          default:
            return context != null
                ? 'errors.unexpected_error'.tr()
                : "Unexpected server error.";
        }
      }

      if (error.type == DioExceptionType.unknown) {
        if (error.error is SocketException) {
          return context != null
              ? 'errors.no_internet'.tr()
              : "No internet connection. Please check your network.";
        }
      }

      // Connection error (network unreachable)
      if (error.type == DioExceptionType.connectionError) {
        return context != null
            ? 'errors.connection_error'.tr()
            : "Connection error. Please check your internet connection.";
      }

      return context != null
          ? 'errors.something_went_wrong'.tr()
          : "Something went wrong. Please try again.";
    } else {
      return context != null
          ? 'errors.unexpected_error_occurred'.tr()
          : "Unexpected error occurred.";
    }
  }
}