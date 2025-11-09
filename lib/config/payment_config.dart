/// Payment backend configuration
/// This file can be overridden at build time using --dart-define
class PaymentConfig {
  /// Backend URL for payment processing
  /// Can be overridden at build time using:
  /// flutter build --dart-define=PAYMENT_BACKEND_URL=https://payment.yourdomain.com
  static const String backendUrl = String.fromEnvironment(
    'PAYMENT_BACKEND_URL',
    defaultValue: 'https://xibe-pay.n92dev.us.kg', // Production payment backend
  );
  
  /// Check if using production backend
  static bool get isProduction => 
      backendUrl.startsWith('https://') && !backendUrl.contains('localhost');
  
  /// Check if using local backend
  static bool get isLocal => backendUrl.contains('localhost');
  
  /// Get environment name
  static String get environment {
    if (isLocal) return 'local';
    if (backendUrl.contains('staging')) return 'staging';
    if (isProduction) return 'production';
    return 'unknown';
  }
}
