abstract class ApiConstants {
  static const String baseUrl = 'https://api.giftginnie.in/api';
}

abstract class ApiEndpoints {
  // Auth endpoints
  static const String register = '/auth/register';
  static const String verifyEmailOTP = '/auth/verify';
  static const String refreshToken = '/users/auth/tokens/refresh/';
  static const String login = '/auth/login';
  static const String forgotPasswordSendOtp = '/auth/send-otp';
  static const String verifyOtpResetPassword = '/auth/verifyOtpResetPassword';
  static const String resetPassword = '/auth/resetpassword';
  // User endpoints
  static String userProfile(String userId) => '/user/$userId';

  // Product endpoints
  static const String products = '/products';
  static const String categories = '/products/categories/';

  // Order endpoints
  static const String orders = '/orders';

  // dummy auth
  static const String dummyToken = '/users/dummyToken/user/';

  // category product
  static String categoryProducts(String categoryId) =>
      '/products/categories/$categoryId/';

  // favourite products (get, post)
  static const String favouriteProducts = '/products/favourite/';
  static String productById(String productId) => '/products/$productId/';

  // Popular products endpoint
  static const String popularProducts = '/products/popular-products/';

  // Popular categories endpoint
  static const String popularCategories = '/products/popular-categories/';

  // User address endpoints (old)
  static const String userAddresses = '/users/profile/address/';
  
  // New address endpoints
  static const String addresses = '/address';

  // profile update endpoint (old)
  static const String updateUserProfile = '/users/profile/update/';
  
  // new profile update endpoint
  static const String updateUser = '/user';

  // Cart endpoints
  static const String cart = '/cart/';

  // Carousel items endpoint
  static const String carouselItems = '/banner';

  // Coupon Fetch
  static const String coupons = '/coupons';

  static const String cartApplyCoupon = '/cart/applyCoupon/';

  // Cart item removal endpoint
  static String cartItem(int itemId) => '/cart/item/$itemId/';

  // Add item to cart endpoint
  static const String addToCart = '/cart/item/';

  // Search products endpoint
  static String searchProducts(String query) => '/products/searchProducts?search=$query';

  //RazorPay Create Order
  static const String createOrder = '/orders/checkout/';

  //RazorPay endpoints
  static const String verifyPayment = '/orders/verifyPayment/';

  // Product rating endpoint
  static String productRating(String productId) => '/product/$productId/rating/';
}
