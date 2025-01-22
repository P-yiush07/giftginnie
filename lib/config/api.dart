abstract class ApiConstants {
  static const String baseUrl = 'http://18.218.49.219:8000/api/v1';
}

abstract class ApiEndpoints {
  // Auth endpoints
  static const String sendOTP = '/users/auth/sendOTP/';
  static const String verifyOTP = '/users/auth/verifyOTP/';
  static const String refreshToken = '/users/auth/tokens/refresh/';

  // User endpoints
  static const String userProfile = '/users/profile/';

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

  // User address endpoints
  static const String userAddresses = '/users/profile/address/';

  // profile update endpoint
  static const String updateUserProfile = '/users/profile/update/';

  // Cart endpoints
  static const String cart = '/cart/';

  // Carousel items endpoint
  static const String carouselItems = '/products/carausel-items/';

  // Coupon Fetch
  static const String coupons = '/coupon/';

  static const String cartApplyCoupon = '/cart/applyCoupon/';

  // Cart item removal endpoint
  static String cartItem(int itemId) => '/cart/item/$itemId/';

  // Add item to cart endpoint
  static const String addToCart = '/cart/item/';
}
