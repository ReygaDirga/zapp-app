import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.zapp.software',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final session =
              Supabase.instance.client.auth.currentSession;

          if (session != null) {
            options.headers['Authorization'] =
                'Bearer ${session.accessToken}';
          }

          return handler.next(options);
        },
      ),
    );
}