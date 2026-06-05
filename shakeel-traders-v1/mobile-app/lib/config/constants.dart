class AppConstants {
  static const String appName = 'Shakeel Traders';
  static const String appVersion = '1.0.0';

  // SharedPreferences keys
  static const String keyServerIp = 'server_ip';
  static const String keyServerPort = 'server_port';
  static const String keyJwt = 'jwt_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyUserName = 'user_name';
  static const String keyLastSync = 'last_sync';

  // Default values
  static const int defaultPort = 3000;

  // API endpoints
  static const String apiTestConnection = '/api/auth/test-connection';
  static const String apiLogin = '/api/auth/login';
  static const String apiSyncMorning = '/api/sync/morning';
  static const String apiSyncMidday = '/api/sync/midday';
  static const String apiSyncEvening = '/api/sync/evening';
  static const String apiSyncOrders = '/api/sync/orders';
  static const String apiSyncRecoveries = '/api/sync/recoveries';
  static const String apiSalesmanMorning = '/api/sync/salesman/morning';
  static const String apiSalesmanIssuance = '/api/sync/salesman/issuance';
  static const String apiSalesmanIssuanceStatus =
      '/api/sync/salesman/issuance-status';
  static const String apiSalesmanReturn = '/api/sync/salesman/return';

  // User roles
  static const String roleOrderBooker = 'order_booker';
  static const String roleSalesman = 'salesman';
}
