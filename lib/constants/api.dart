abstract class ApiConstants {
  static const String baseUrl = 'https://api.example.com';
}

abstract class ApiEndpoints {
  // Auth endpoints
  static const String sendOTP = '/auth/send-otp';
  static const String verifyOTP = '/auth/verify-otp';
  
  // User endpoints
  static const String userProfile = '/user/profile';
  
  // Product endpoints
  static const String products = '/products';
  
  // Order endpoints
  static const String orders = '/orders';
  
}