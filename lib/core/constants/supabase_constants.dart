abstract class SupabaseTables {
  SupabaseTables._();
  static const String users = 'users';
  static const String apartments = 'apartments';
  static const String chargePayments = 'charge_payments';
  static const String monthlyChargeRates = 'monthly_charge_rates';
  static const String expenses = 'expenses';
  static const String goals = 'goals';
  static const String attachments = 'attachments';
  static const String activityLogs = 'activity_logs';
}

abstract class SupabaseBuckets {
  SupabaseBuckets._();
  static const String expenseFiles = 'expense-files';
  static const String goalFiles = 'goal-files';
  static const String avatars = 'avatars';
}

abstract class AttachmentEntityType {
  AttachmentEntityType._();
  static const String expense = 'expense';
  static const String goal = 'goal';
}

abstract class SupabaseRpc {
  SupabaseRpc._();
  static const String getFundSummary = 'get_fund_summary';
  static const String getDashboardSummary = 'get_dashboard_summary';
  static const String getApartmentDebt = 'get_apartment_debt';
  static const String getMonthlyReport = 'get_monthly_report';
  static const String getApartmentsWithStatus = 'get_apartments_with_status';
  static const String getApartmentPaymentHistory = 'get_apartment_payment_history';
}
