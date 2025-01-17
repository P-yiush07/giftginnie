abstract class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
}

abstract class ApiEndpoints {
  // Auth endpoints
  static const String sendOTP = '/users/auth/sendOTP/';
  static const String verifyOTP = '/users/auth/verifyOTP/';
  static const String refreshToken = '/users/auth/tokens/refresh/';
  
  // User endpoints
  static const String userProfile = '/user/profile';
  
  // Product endpoints
  static const String products = '/products';
  
  // Order endpoints
  static const String orders = '/orders';
  
  // Add this line with the other endpoints
  static const String dummyToken = '/users/dummyToken/user/';
}