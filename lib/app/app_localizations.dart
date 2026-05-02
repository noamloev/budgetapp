import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english('en'),
  hebrew('he');

  const AppLanguage(this.code);

  final String code;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (item) => item.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

class AppLocaleController extends ChangeNotifier {
  static const _languageKey = 'budget_app_language_v1';

  AppLanguage _language = AppLanguage.english;

  AppLanguage get language => _language;
  Locale get locale => _language.locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _language = AppLanguage.fromCode(prefs.getString(_languageKey));
    notifyListeners();
  }

  Future<void> updateLanguage(AppLanguage language) async {
    if (_language == language) {
      return;
    }
    _language = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.code);
    notifyListeners();
  }
}

class AppLocaleScope extends InheritedNotifier<AppLocaleController> {
  const AppLocaleScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppLocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'AppLocaleScope not found in widget tree.');
    return scope!.notifier!;
  }
}

class AppLocalizations {
  AppLocalizations(this.language);

  final AppLanguage language;

  static const delegate = _AppLocalizationsDelegate();
  static const supportedLocales = [Locale('en'), Locale('he')];
  static const List<LocalizationsDelegate<dynamic>> delegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations not found in widget tree.');
    return localizations!;
  }

  bool get isHebrew => language == AppLanguage.hebrew;
  TextDirection get textDirection =>
      isHebrew ? TextDirection.rtl : TextDirection.ltr;

  String get appTitle => _text('app_title');
  String get close => _text('close');
  String get edit => _text('edit');
  String get delete => _text('delete');
  String get add => _text('add');
  String get saveChanges => _text('save_changes');
  String get cancel => _text('cancel');
  String get yes => _text('yes');
  String get no => _text('no');

  String categoryLabel(String value) => _lookup(_categoryLabels, value);
  String paymentMethodLabel(String value) =>
      _lookup(_paymentMethodLabels, value);
  String recurringCategoryLabel(String value) =>
      _lookup(_recurringCategoryLabels, value);
  String scheduleLabel(String value) => _lookup(_scheduleLabels, value);
  String contributionSourceLabel(String value) =>
      _lookup(_contributionSourceLabels, value);
  String text(String key) => _text(key);

  String _lookup(Map<String, List<String>> map, String value) {
    final resolved = map[value];
    if (resolved == null) {
      return value;
    }
    return isHebrew ? resolved[1] : resolved[0];
  }

  String _text(String key) {
    final values = _strings[key]!;
    return isHebrew ? values[1] : values[0];
  }

  static const Map<String, List<String>> _categoryLabels = {
    'Food': ['Food', 'אוכל'],
    'Transport': ['Transport', 'תחבורה'],
    'Shopping': ['Shopping', 'קניות'],
    'Bills': ['Bills', 'חשבונות'],
    'Health': ['Health', 'בריאות'],
    'Entertainment': ['Entertainment', 'בילויים'],
    'Charity': ['Charity', 'תרומות'],
    'Investing': ['Investing', 'השקעות'],
    'Savings': ['Savings', 'חיסכון'],
    'Loan': ['Loan', 'הלוואה'],
    'Other': ['Other', 'אחר'],
  };

  static const Map<String, List<String>> _paymentMethodLabels = {
    'Card': ['Card', 'כרטיס'],
    'Cash': ['Cash', 'מזומן'],
    'Bank Transfer': ['Bank Transfer', 'העברה בנקאית'],
    'Digital Wallet': ['Digital Wallet', 'ארנק דיגיטלי'],
  };

  static const Map<String, List<String>> _recurringCategoryLabels = {
    'Investing': ['Investing', 'השקעות'],
    'Charity': ['Charity', 'תרומות'],
    'Bills': ['Bills', 'חשבונות'],
    'Savings': ['Savings', 'חיסכון'],
    'Loan': ['Loan', 'הלוואה'],
    'Other': ['Other', 'אחר'],
  };

  static const Map<String, List<String>> _scheduleLabels = {
    'Monthly': ['Monthly', 'חודשי'],
    'Weekly': ['Weekly', 'שבועי'],
    'Yearly': ['Yearly', 'שנתי'],
  };

  static const Map<String, List<String>> _contributionSourceLabels = {
    'manual': ['Manual', 'ידני'],
    'recurring': ['Automatic', 'אוטומטי'],
  };

  static const Map<String, List<String>> _strings = {
    'app_title': ['Budget Flow', 'Budget Flow'],
    'close': ['Close', 'סגור'],
    'edit': ['Edit', 'ערוך'],
    'delete': ['Delete', 'מחק'],
    'add': ['Add', 'הוסף'],
    'save_changes': ['Save Changes', 'שמור שינויים'],
    'cancel': ['Cancel', 'בטל'],
    'yes': ['Yes', 'כן'],
    'no': ['No', 'לא'],
    'screen_help_tooltip': ['What does this screen do?', 'מה המסך הזה עושה?'],
    'settings': ['Settings', 'הגדרות'],
    'language': ['Language', 'שפה'],
    'english': ['English', 'English'],
    'hebrew': ['Hebrew', 'עברית'],
    'cycle_start_day': ['Cycle start day', 'יום התחלת המחזור'],
    'day_prefix': ['Day', 'יום'],
    'update_center': ['Update Center', 'מרכז עדכונים'],
    'check_updates': ['Check Updates', 'בדוק עדכונים'],
    'checking': ['Checking...', 'בודק...'],
    'open_latest_apk': ['Open Latest APK', 'פתח APK אחרון'],
    'not_checked': ['Not checked', 'לא נבדק'],
    'dashboard': ['Dashboard', 'דשבורד'],
    'expenses': ['Expenses', 'הוצאות'],
    'plan': ['Plan', 'תכנון'],
    'history': ['History', 'היסטוריה'],
    'stocks': ['Stocks', 'מניות'],
    'home': ['Home', 'בית'],
    'add_income': ['Add Income', 'הוסף הכנסה'],
    'add_payment': ['Add Payment', 'הוסף תשלום'],
    'add_goal': ['Add Goal', 'הוסף יעד'],
    'add_allocation': ['Add Allocation', 'הוסף הקצאה'],
    'portfolio_balance': ['Portfolio Balance', 'יתרת פורטפוליו'],
    'available_to_spend': ['Available To Spend', 'זמין להוצאה'],
    'earned_total': ['Earned Total', 'סה״כ הכנסות'],
    'spent_total': ['Spent Total', 'סה״כ הוצאות'],
    'stock_value': ['Stock Value', 'שווי מניות'],
    'profit_loss': ['Profit / Loss', 'רווח / הפסד'],
    'quantity': ['Quantity', 'כמות'],
    'buy_price': ['Buy Price', 'מחיר קניה'],
    'current_price': ['Current Price', 'מחיר נוכחי'],
    'symbol': ['Symbol', 'סימול'],
    'company_name': ['Company Name', 'שם חברה'],
    'search_stocks': ['Search stocks', 'חפש מניות'],
    'no_stocks': ['No stocks yet', 'עדיין אין מניות'],
    'stock_empty_subtitle': [
      'Add a holding to track invested amount, current value, and profit or loss.',
      'הוסף החזקה כדי לעקוב אחרי ההשקעה, השווי הנוכחי והרווח או ההפסד.',
    ],
    'add_first_stock': ['Add First Stock', 'הוסף מניה ראשונה'],
    'save_stock': ['Save Stock', 'שמור מניה'],
    'edit_stock': ['Edit Stock', 'ערוך מניה'],
    'add_stock': ['Add Stock', 'הוסף מניה'],
    'goal_link': ['Linked goal', 'יעד מקושר'],
    'no_goal_link': ['No linked goal', 'ללא יעד מקושר'],
    'goal_contributions': ['Goal Contributions', 'הפקדות ליעדים'],
    'contribute': ['Add contribution', 'הוסף הפקדה'],
    'contribution_amount': ['Contribution amount', 'סכום הפקדה'],
    'save_goal': ['Save Goal', 'שמור יעד'],
    'save_income': ['Save Income', 'שמור הכנסה'],
    'save_payment': ['Save Payment', 'שמור תשלום'],
    'save_allocation': ['Save Allocation', 'שמור הקצאה'],
    'save_numbers': ['Save Numbers', 'שמור נתונים'],
    'save_category_budgets': ['Save Category Budgets', 'שמור תקציבי קטגוריות'],
    'monthly_income': ['Monthly income', 'הכנסה חודשית'],
    'monthly_tax': ['Monthly tax', 'מס חודשי'],
    'monthly_spending_goal': ['Monthly spending goal', 'יעד הוצאה חודשי'],
    'name': ['Name', 'שם'],
    'amount': ['Amount', 'סכום'],
    'category': ['Category', 'קטגוריה'],
    'schedule': ['Schedule', 'תדירות'],
    'title': ['Title', 'כותרת'],
    'who_added_it': ['Who added it?', 'מי הוסיף את זה?'],
    'what_paid_for': ['What did you pay for?', 'על מה שילמת?'],
    'payment_method': ['Payment Method', 'אמצעי תשלום'],
    'note': ['Note', 'הערה'],
    'goal_name': ['Goal name', 'שם היעד'],
    'target_amount': ['Target amount', 'סכום יעד'],
    'already_saved': ['Already saved', 'כבר נחסך'],
    'target_year': ['Target year', 'שנת יעד'],
    'allocation_name': ['Allocation name', 'שם ההקצאה'],
    'until_month': ['Until month', 'עד חודש'],
    'until_year': ['Until year', 'עד שנה'],
    'all': ['All', 'הכל'],
    'search_payments': ['Search payments', 'חפש תשלומים'],
    'register': ['Register', 'הרשמה'],
    'log_in': ['Log In', 'התחברות'],
    'shared_email': ['Shared email', 'אימייל משותף'],
    'shared_password': ['Shared password', 'סיסמה משותפת'],
    'please_wait': ['Please wait...', 'המתן...'],
    'register_shared_account': ['Register Shared Account', 'צור חשבון משותף'],
    'skip': ['Skip', 'דלג'],
    'continue': ['Continue', 'המשך'],
    'finish_setup': ['Finish Setup', 'סיים הגדרה'],
    'current_version': ['Current Version', 'גרסה נוכחית'],
    'latest_release': ['Latest Release', 'גרסה אחרונה'],
    'installed_app_build': ['Installed app build', 'גרסת אפליקציה מותקנת'],
    'use_button_below': ['Use the button below', 'השתמש בכפתור למטה'],
    'pulled_from_github': ['Pulled from GitHub', 'נמשך מ-GitHub'],
    'github_source': ['GitHub Source', 'מקור GitHub'],
    'refresh_from_cloud': ['Refresh from cloud', 'רענן מהענן'],
    'log_out': ['Log out', 'התנתק'],
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'he'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(AppLanguage.fromCode(locale.languageCode));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this);
  AppLocaleController get localeController => AppLocaleScope.of(this);
}
