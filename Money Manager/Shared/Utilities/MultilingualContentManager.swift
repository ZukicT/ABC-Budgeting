import Foundation

/// Manages multilingual content for the entire app
class MultilingualContentManager: ObservableObject {
    static let shared = MultilingualContentManager()
    
    @Published var currentLanguage: String = "en-US"
    
    private init() {
        // Load saved language preference
        currentLanguage = UserDefaults.standard.string(forKey: "selected_language") ?? "en-US"
    }
    
    func updateLanguage(_ language: String) {
        currentLanguage = language
        UserDefaults.standard.set(language, forKey: "selected_language")
    }
    
    // MARK: - Localization Helper
    
    func localizedString(_ key: String) -> String {
        switch currentLanguage {
        case "zh-CN":
            return chineseStrings[key] ?? englishStrings[key] ?? key
        case "ja-JP":
            return japaneseStrings[key] ?? englishStrings[key] ?? key
        default:
            return englishStrings[key] ?? key
        }
    }
    
    // MARK: - Localization Strings
    
    private let englishStrings: [String: String] = [
        // Navigation & Tabs
        "tab.overview": "Overview",
        "tab.transactions": "Transactions", 
        "tab.budget": "Budget",
        "tab.loans": "Loans",
        "tab.settings": "Settings",
        
        // Overview Tab
        "overview.title": "Overview",
        "overview.balance": "Current Balance",
        "overview.monthly_change": "Monthly Change",
        "overview.income": "Income",
        "overview.expenses": "Expenses",
        "overview.savings": "Savings",
        "overview.recent_transactions": "Recent Transactions",
        "overview.budgets": "Budgets",
        "overview.loans": "Loans",
        "overview.financial_insights": "Financial Insights",
        "overview.monthly_overview": "Monthly Overview",
        
        // Transactions Tab
        "transactions.title": "Transactions",
        "transactions.add_transaction": "Add Transaction",
        "transactions.edit_transaction": "Edit Transaction",
        "transactions.delete_transaction": "Delete Transaction",
        "transactions.income": "Income",
        "transactions.expense": "Expense",
        "transactions.amount": "Amount",
        "transactions.category": "Category",
        "transactions.date": "Date",
        "transactions.description": "Description",
        "transactions.search": "Search transactions...",
        "transactions.filter": "Filter",
        "transactions.all": "All",
        "transactions.no_transactions": "No transactions yet",
        "transactions.add_first": "Add your first transaction to get started",
        
        // Budget Tab
        "budget.title": "Budget",
        "budget.add_budget": "Add Budget",
        "budget.edit_budget": "Edit Budget",
        "budget.delete_budget": "Delete Budget",
        "budget.name": "Name",
        "budget.amount": "Amount",
        "budget.spent": "Spent",
        "budget.remaining": "Remaining",
        "budget.progress": "Progress",
        "budget.period": "Period",
        "budget.weekly": "Weekly",
        "budget.monthly": "Monthly",
        "budget.yearly": "Yearly",
        "budget.no_budgets": "No budgets yet",
        "budget.add_first": "Add your first budget to start tracking",
        
        // Settings Tab
        "settings.title": "Settings",
        "settings.notifications": "Notifications",
        "settings.push_notifications": "Push Notifications",
        "settings.budget_alerts": "Budget Alerts",
        "settings.budget_settings": "Budget Settings",
        "settings.default_currency": "Default Currency",
        "settings.budget_period": "Budget Period",
        "settings.language": "Language",
        "settings.text_to_speech_language": "Text-to-Speech Language",
        "settings.data_privacy": "Data & Privacy",
        "settings.export_data": "Export Data",
        "settings.clear_all_data": "Clear All Data",
        "settings.test_data": "Test Data",
        "settings.add_test_data": "Add Test Data",
        "settings.remove_test_data": "Remove Test Data",
        "settings.about": "About",
        "settings.version": "Version",
        "settings.version_history": "Version History",
        "settings.privacy_policy": "Privacy Policy",
        "settings.terms_of_service": "Terms of Service",
        "settings.font_licensing": "Font Licensing",
        
        // Common Actions
        "action.add": "Add",
        "action.edit": "Edit",
        "action.delete": "Delete",
        "action.save": "Save",
        "action.cancel": "Cancel",
        "action.done": "Done",
        "action.close": "Close",
        "action.confirm": "Confirm",
        "action.export": "Export",
        "action.import": "Import",
        "action.clear": "Clear",
        "action.reset": "Reset",
        
        // Categories
        "category.food": "Food",
        "category.transport": "Transport",
        "category.entertainment": "Entertainment",
        "category.healthcare": "Healthcare",
        "category.bills": "Bills",
        "category.shopping": "Shopping",
        "category.education": "Education",
        "category.travel": "Travel",
        "category.other": "Other",
        
        // Loan Categories
        "loan.student": "Student Loan",
        "loan.auto": "Auto Loan",
        "loan.mortgage": "Mortgage",
        "loan.personal": "Personal Loan",
        "loan.credit_card": "Credit Card",
        "loan.home_improvement": "Home Improvement",
        
        // Alerts & Messages
        "alert.confirm_delete": "Confirm Delete",
        "alert.delete_transaction": "Are you sure you want to delete this transaction?",
        "alert.delete_budget": "Are you sure you want to delete this budget?",
        "alert.clear_all_data": "Clear All Data",
        "alert.clear_data_message": "This will permanently delete all your transactions, budgets, and loans. This action cannot be undone.",
        "alert.success": "Success",
        "alert.error": "Error",
        "alert.data_exported": "Data exported successfully",
        "alert.data_cleared": "All data cleared successfully",
        
        // Empty States
        "empty.no_data": "No data available",
        "empty.add_first_item": "Add your first item to get started",
        "empty.no_results": "No results found",
        "empty.try_different_search": "Try a different search term",
        
        // Currency
        "currency.usd": "US Dollar",
        "currency.eur": "Euro",
        "currency.gbp": "British Pound",
        "currency.jpy": "Japanese Yen",
        "currency.cny": "Chinese Yuan",
        
        // Time Periods
        "period.today": "Today",
        "period.yesterday": "Yesterday",
        "period.this_week": "This Week",
        "period.last_week": "Last Week",
        "period.this_month": "This Month",
        "period.last_month": "Last Month",
        "period.this_year": "This Year",
        "period.last_year": "Last Year",
        
        // Accessibility
        "accessibility.play": "Play",
        "accessibility.pause": "Pause",
        "accessibility.stop": "Stop",
        "accessibility.speed_control": "Speed Control",
        "accessibility.language_selector": "Language Selector",
        "accessibility.currency_selector": "Currency Selector",
        "accessibility.category_selector": "Category Selector",
        
        // Onboarding
        "onboarding.welcome": "Welcome to Money Manager",
        "onboarding.get_started": "Get Started",
        "onboarding.next": "Next",
        "onboarding.skip": "Skip",
        "onboarding.complete": "Complete",
        
        // Export
        "export.title": "Export Data",
        "export.subtitle": "Choose what data you want to export to CSV format",
        "export.transactions": "Transactions",
        "export.budgets": "Budgets", 
        "export.loans": "Loans",
        "export.all_data": "All Data",
        "export.transactions_desc": "Export all your transaction records",
        "export.budgets_desc": "Export all your budget information",
        "export.loans_desc": "Export all your loan details",
        "export.all_data_desc": "Export everything in one file"
    ]
    
    private let chineseStrings: [String: String] = [
        // Navigation & Tabs
        "tab.overview": "概览",
        "tab.transactions": "交易",
        "tab.budget": "预算",
        "tab.loans": "贷款",
        "tab.settings": "设置",
        
        // Overview Tab
        "overview.title": "概览",
        "overview.balance": "当前余额",
        "overview.monthly_change": "月度变化",
        "overview.income": "收入",
        "overview.expenses": "支出",
        "overview.savings": "储蓄",
        "overview.recent_transactions": "最近交易",
        "overview.budgets": "预算",
        "overview.loans": "贷款",
        "overview.financial_insights": "财务洞察",
        "overview.monthly_overview": "月度概览",
        
        // Transactions Tab
        "transactions.title": "交易",
        "transactions.add_transaction": "添加交易",
        "transactions.edit_transaction": "编辑交易",
        "transactions.delete_transaction": "删除交易",
        "transactions.income": "收入",
        "transactions.expense": "支出",
        "transactions.amount": "金额",
        "transactions.category": "类别",
        "transactions.date": "日期",
        "transactions.description": "描述",
        "transactions.search": "搜索交易...",
        "transactions.filter": "筛选",
        "transactions.all": "全部",
        "transactions.no_transactions": "暂无交易",
        "transactions.add_first": "添加您的第一笔交易开始使用",
        
        // Budget Tab
        "budget.title": "预算",
        "budget.add_budget": "添加预算",
        "budget.edit_budget": "编辑预算",
        "budget.delete_budget": "删除预算",
        "budget.name": "名称",
        "budget.amount": "金额",
        "budget.spent": "已花费",
        "budget.remaining": "剩余",
        "budget.progress": "进度",
        "budget.period": "周期",
        "budget.weekly": "每周",
        "budget.monthly": "每月",
        "budget.yearly": "每年",
        "budget.no_budgets": "暂无预算",
        "budget.add_first": "添加您的第一个预算开始跟踪",
        
        // Settings Tab
        "settings.title": "设置",
        "settings.notifications": "通知",
        "settings.push_notifications": "推送通知",
        "settings.budget_alerts": "预算提醒",
        "settings.budget_settings": "预算设置",
        "settings.default_currency": "默认货币",
        "settings.budget_period": "预算周期",
        "settings.language": "语言",
        "settings.text_to_speech_language": "语音语言",
        "settings.data_privacy": "数据与隐私",
        "settings.export_data": "导出数据",
        "settings.clear_all_data": "清除所有数据",
        "settings.test_data": "测试数据",
        "settings.add_test_data": "添加测试数据",
        "settings.remove_test_data": "移除测试数据",
        "settings.about": "关于",
        "settings.version": "版本",
        "settings.version_history": "版本历史",
        "settings.privacy_policy": "隐私政策",
        "settings.terms_of_service": "服务条款",
        "settings.font_licensing": "字体许可",
        
        // Common Actions
        "action.add": "添加",
        "action.edit": "编辑",
        "action.delete": "删除",
        "action.save": "保存",
        "action.cancel": "取消",
        "action.done": "完成",
        "action.close": "关闭",
        "action.confirm": "确认",
        "action.export": "导出",
        "action.import": "导入",
        "action.clear": "清除",
        "action.reset": "重置",
        
        // Categories
        "category.food": "食物",
        "category.transport": "交通",
        "category.entertainment": "娱乐",
        "category.healthcare": "医疗",
        "category.bills": "账单",
        "category.shopping": "购物",
        "category.education": "教育",
        "category.travel": "旅行",
        "category.other": "其他",
        
        // Loan Categories
        "loan.student": "学生贷款",
        "loan.auto": "汽车贷款",
        "loan.mortgage": "抵押贷款",
        "loan.personal": "个人贷款",
        "loan.credit_card": "信用卡",
        "loan.home_improvement": "房屋装修",
        
        // Alerts & Messages
        "alert.confirm_delete": "确认删除",
        "alert.delete_transaction": "您确定要删除这笔交易吗？",
        "alert.delete_budget": "您确定要删除这个预算吗？",
        "alert.clear_all_data": "清除所有数据",
        "alert.clear_data_message": "这将永久删除您的所有交易、预算和贷款。此操作无法撤销。",
        "alert.success": "成功",
        "alert.error": "错误",
        "alert.data_exported": "数据导出成功",
        "alert.data_cleared": "所有数据清除成功",
        
        // Empty States
        "empty.no_data": "暂无数据",
        "empty.add_first_item": "添加您的第一个项目开始使用",
        "empty.no_results": "未找到结果",
        "empty.try_different_search": "尝试不同的搜索词",
        
        // Currency
        "currency.usd": "美元",
        "currency.eur": "欧元",
        "currency.gbp": "英镑",
        "currency.jpy": "日元",
        "currency.cny": "人民币",
        
        // Time Periods
        "period.today": "今天",
        "period.yesterday": "昨天",
        "period.this_week": "本周",
        "period.last_week": "上周",
        "period.this_month": "本月",
        "period.last_month": "上月",
        "period.this_year": "今年",
        "period.last_year": "去年",
        
        // Accessibility
        "accessibility.play": "播放",
        "accessibility.pause": "暂停",
        "accessibility.stop": "停止",
        "accessibility.speed_control": "速度控制",
        "accessibility.language_selector": "语言选择器",
        "accessibility.currency_selector": "货币选择器",
        "accessibility.category_selector": "类别选择器",
        
        // Onboarding
        "onboarding.welcome": "欢迎使用Money Manager",
        "onboarding.get_started": "开始使用",
        "onboarding.next": "下一步",
        "onboarding.skip": "跳过",
        "onboarding.complete": "完成",
        
        // Export
        "export.title": "导出数据",
        "export.subtitle": "选择要导出为CSV格式的数据",
        "export.transactions": "交易",
        "export.budgets": "预算",
        "export.loans": "贷款",
        "export.all_data": "所有数据",
        "export.transactions_desc": "导出所有交易记录",
        "export.budgets_desc": "导出所有预算信息",
        "export.loans_desc": "导出所有贷款详情",
        "export.all_data_desc": "一次性导出所有内容"
    ]
    
    private let japaneseStrings: [String: String] = [
        // Navigation & Tabs
        "tab.overview": "概要",
        "tab.transactions": "取引",
        "tab.budget": "予算",
        "tab.loans": "ローン",
        "tab.settings": "設定",
        
        // Overview Tab
        "overview.title": "概要",
        "overview.balance": "現在の残高",
        "overview.monthly_change": "月次変化",
        "overview.income": "収入",
        "overview.expenses": "支出",
        "overview.savings": "貯蓄",
        "overview.recent_transactions": "最近の取引",
        "overview.budgets": "予算",
        "overview.loans": "ローン",
        "overview.financial_insights": "財務インサイト",
        "overview.monthly_overview": "月次概要",
        
        // Transactions Tab
        "transactions.title": "取引",
        "transactions.add_transaction": "取引を追加",
        "transactions.edit_transaction": "取引を編集",
        "transactions.delete_transaction": "取引を削除",
        "transactions.income": "収入",
        "transactions.expense": "支出",
        "transactions.amount": "金額",
        "transactions.category": "カテゴリ",
        "transactions.date": "日付",
        "transactions.description": "説明",
        "transactions.search": "取引を検索...",
        "transactions.filter": "フィルター",
        "transactions.all": "すべて",
        "transactions.no_transactions": "取引がありません",
        "transactions.add_first": "最初の取引を追加して開始",
        
        // Budget Tab
        "budget.title": "予算",
        "budget.add_budget": "予算を追加",
        "budget.edit_budget": "予算を編集",
        "budget.delete_budget": "予算を削除",
        "budget.name": "名前",
        "budget.amount": "金額",
        "budget.spent": "使用済み",
        "budget.remaining": "残り",
        "budget.progress": "進捗",
        "budget.period": "期間",
        "budget.weekly": "週次",
        "budget.monthly": "月次",
        "budget.yearly": "年次",
        "budget.no_budgets": "予算がありません",
        "budget.add_first": "最初の予算を追加して追跡開始",
        
        // Settings Tab
        "settings.title": "設定",
        "settings.notifications": "通知",
        "settings.push_notifications": "プッシュ通知",
        "settings.budget_alerts": "予算アラート",
        "settings.budget_settings": "予算設定",
        "settings.default_currency": "デフォルト通貨",
        "settings.budget_period": "予算期間",
        "settings.language": "言語",
        "settings.text_to_speech_language": "音声読み上げ言語",
        "settings.data_privacy": "データとプライバシー",
        "settings.export_data": "データをエクスポート",
        "settings.clear_all_data": "すべてのデータをクリア",
        "settings.test_data": "テストデータ",
        "settings.add_test_data": "テストデータを追加",
        "settings.remove_test_data": "テストデータを削除",
        "settings.about": "について",
        "settings.version": "バージョン",
        "settings.version_history": "バージョン履歴",
        "settings.privacy_policy": "プライバシーポリシー",
        "settings.terms_of_service": "利用規約",
        "settings.font_licensing": "フォントライセンス",
        
        // Common Actions
        "action.add": "追加",
        "action.edit": "編集",
        "action.delete": "削除",
        "action.save": "保存",
        "action.cancel": "キャンセル",
        "action.done": "完了",
        "action.close": "閉じる",
        "action.confirm": "確認",
        "action.export": "エクスポート",
        "action.import": "インポート",
        "action.clear": "クリア",
        "action.reset": "リセット",
        
        // Categories
        "category.food": "食事",
        "category.transport": "交通",
        "category.entertainment": "エンターテイメント",
        "category.healthcare": "医療",
        "category.bills": "請求書",
        "category.shopping": "ショッピング",
        "category.education": "教育",
        "category.travel": "旅行",
        "category.other": "その他",
        
        // Loan Categories
        "loan.student": "学生ローン",
        "loan.auto": "自動車ローン",
        "loan.mortgage": "住宅ローン",
        "loan.personal": "個人ローン",
        "loan.credit_card": "クレジットカード",
        "loan.home_improvement": "住宅改築",
        
        // Alerts & Messages
        "alert.confirm_delete": "削除を確認",
        "alert.delete_transaction": "この取引を削除してもよろしいですか？",
        "alert.delete_budget": "この予算を削除してもよろしいですか？",
        "alert.clear_all_data": "すべてのデータをクリア",
        "alert.clear_data_message": "これにより、すべての取引、予算、ローンが永久に削除されます。この操作は元に戻せません。",
        "alert.success": "成功",
        "alert.error": "エラー",
        "alert.data_exported": "データのエクスポートが成功しました",
        "alert.data_cleared": "すべてのデータがクリアされました",
        
        // Empty States
        "empty.no_data": "データがありません",
        "empty.add_first_item": "最初のアイテムを追加して開始",
        "empty.no_results": "結果が見つかりません",
        "empty.try_different_search": "別の検索語を試してください",
        
        // Currency
        "currency.usd": "米ドル",
        "currency.eur": "ユーロ",
        "currency.gbp": "英ポンド",
        "currency.jpy": "日本円",
        "currency.cny": "中国元",
        
        // Time Periods
        "period.today": "今日",
        "period.yesterday": "昨日",
        "period.this_week": "今週",
        "period.last_week": "先週",
        "period.this_month": "今月",
        "period.last_month": "先月",
        "period.this_year": "今年",
        "period.last_year": "昨年",
        
        // Accessibility
        "accessibility.play": "再生",
        "accessibility.pause": "一時停止",
        "accessibility.stop": "停止",
        "accessibility.speed_control": "速度制御",
        "accessibility.language_selector": "言語選択器",
        "accessibility.currency_selector": "通貨選択器",
        "accessibility.category_selector": "カテゴリ選択器",
        
        // Onboarding
        "onboarding.welcome": "Money Managerへようこそ",
        "onboarding.get_started": "開始",
        "onboarding.next": "次へ",
        "onboarding.skip": "スキップ",
        "onboarding.complete": "完了",
        
        // Export
        "export.title": "データをエクスポート",
        "export.subtitle": "CSV形式でエクスポートするデータを選択",
        "export.transactions": "取引",
        "export.budgets": "予算",
        "export.loans": "ローン",
        "export.all_data": "すべてのデータ",
        "export.transactions_desc": "すべての取引記録をエクスポート",
        "export.budgets_desc": "すべての予算情報をエクスポート",
        "export.loans_desc": "すべてのローン詳細をエクスポート",
        "export.all_data_desc": "すべてを1つのファイルでエクスポート"
    ]
    
    // MARK: - Privacy Policy Content
    
    func getPrivacyPolicyTitle() -> String {
        switch currentLanguage {
        case "zh-CN":
            return "隐私政策"
        case "ja-JP":
            return "プライバシーポリシー"
        default:
            return "Privacy Policy"
        }
    }
    
    func getPrivacyPolicyContent() -> String {
        switch currentLanguage {
        case "zh-CN":
            return """
            隐私政策
            
            最后更新：2024年9月28日
            
            欢迎使用Money Manager！我们非常重视您的隐私和数据安全。
            
            数据存储
            
            重要说明：您的所有财务数据都安全地存储在您的设备上。我们不会收集、存储或传输您的任何个人财务信息到我们的服务器或任何第三方服务。
            
            • 所有交易记录都保存在您的设备本地
            • 所有预算信息都存储在您的设备上
            • 所有贷款数据都保留在您的设备上
            • 我们无法访问您的任何财务数据
            
            无数据收集
            
            我们不会收集以下任何信息：
            • 个人身份信息
            • 财务交易数据
            • 预算信息
            • 设备使用统计
            • 位置信息
            • 任何其他个人数据
            
            无第三方连接
            
            此应用程序：
            • 不连接到互联网
            • 不与任何外部服务通信
            • 不发送数据到任何服务器
            • 不使用分析或跟踪服务
            
            数据安全
            
            您的数据安全是我们的首要任务：
            • 所有数据都使用iOS的安全存储机制加密
            • 数据仅存储在您的设备上
            • 没有云同步或备份到外部服务
            • 您可以随时通过应用内功能删除所有数据
            
            您的权利
            
            您完全控制您的数据：
            • 随时查看您的所有数据
            • 导出您的数据为CSV格式
            • 完全删除所有数据
            • 无需担心数据泄露或未经授权的访问
            
            联系我们
            
            如果您对此隐私政策有任何疑问，请通过应用内支持联系我们。
            
            此政策确保您的财务隐私和数据安全始终受到保护。
            """
        case "ja-JP":
            return """
            プライバシーポリシー
            
            最終更新：2024年9月28日
            
            Money Managerをご利用いただき、ありがとうございます！私たちはあなたのプライバシーとデータセキュリティを非常に重視しています。
            
            データストレージ
            
            重要な注意事項：あなたのすべての財務データは、あなたのデバイスに安全に保存されています。私たちはあなたの個人財務情報をサーバーや第三者サービスに収集、保存、または送信することはありません。
            
            • すべての取引記録はあなたのデバイスにローカルに保存されます
            • すべての予算情報はあなたのデバイスに保存されます
            • すべてのローンデータはあなたのデバイスに保持されます
            • 私たちはあなたの財務データにアクセスすることはできません
            
            データ収集なし
            
            私たちは以下の情報を収集しません：
            • 個人識別情報
            • 財務取引データ
            • 予算情報
            • デバイス使用統計
            • 位置情報
            • その他の個人データ
            
            第三者接続なし
            
            このアプリケーションは：
            • インターネットに接続しません
            • 外部サービスと通信しません
            • データをサーバーに送信しません
            • 分析やトラッキングサービスを使用しません
            
            データセキュリティ
            
            あなたのデータセキュリティは私たちの最優先事項です：
            • すべてのデータはiOSの安全なストレージメカニズムで暗号化されています
            • データはあなたのデバイスにのみ保存されます
            • クラウド同期や外部サービスへのバックアップはありません
            • アプリ内機能でいつでもすべてのデータを削除できます
            
            あなたの権利
            
            あなたはデータを完全にコントロールできます：
            • いつでもすべてのデータを表示
            • データをCSV形式でエクスポート
            • すべてのデータを完全に削除
            • データ漏洩や不正アクセスの心配はありません
            
            お問い合わせ
            
            このプライバシーポリシーについてご質問がございましたら、アプリ内サポートからお問い合わせください。
            
            このポリシーにより、あなたの財務プライバシーとデータセキュリティが常に保護されます。
            """
        default:
            return """
            Privacy Policy
            
            Last Updated: September 28, 2024
            
            Welcome to Money Manager! We take your privacy and data security very seriously.
            
            Data Storage
            
            Important Notice: All your financial data is securely stored on your device. We do not collect, store, or transmit any of your personal financial information to our servers or any third-party services.
            
            • All transaction records are saved locally on your device
            • All budget information is stored on your device
            • All loan data remains on your device
            • We cannot access any of your financial data
            
            No Data Collection
            
            We do not collect any of the following information:
            • Personal identification information
            • Financial transaction data
            • Budget information
            • Device usage statistics
            • Location information
            • Any other personal data
            
            No Third-Party Connections
            
            This application:
            • Does not connect to the internet
            • Does not communicate with any external services
            • Does not send data to any servers
            • Does not use analytics or tracking services
            
            Data Security
            
            Your data security is our top priority:
            • All data is encrypted using iOS's secure storage mechanisms
            • Data is only stored on your device
            • No cloud sync or backup to external services
            • You can delete all data at any time using in-app features
            
            Your Rights
            
            You have complete control over your data:
            • View all your data at any time
            • Export your data in CSV format
            • Completely delete all data
            • No worries about data breaches or unauthorized access
            
            Contact Us
            
            If you have any questions about this privacy policy, please contact us through in-app support.
            
            This policy ensures your financial privacy and data security are always protected.
            """
        }
    }
    
    // MARK: - Terms of Service Content
    
    func getTermsOfServiceTitle() -> String {
        switch currentLanguage {
        case "zh-CN":
            return "服务条款"
        case "ja-JP":
            return "利用規約"
        default:
            return "Terms of Service"
        }
    }
    
    func getTermsOfServiceContent() -> String {
        switch currentLanguage {
        case "zh-CN":
            return """
            服务条款
            
            最后更新：2024年9月28日
            
            欢迎使用Money Manager！请仔细阅读这些服务条款。
            
            重要法律免责声明
            
            数据丢失风险：使用此应用程序时，您承认并同意以下重要免责声明：
            
            • 我们不对任何数据丢失承担责任
            • 我们不对任何财务损失承担责任
            • 我们不对任何间接损害承担责任
            • 您使用此应用程序的风险完全由您自己承担
            
            完整法律保护
            
            我们提供完整的法律保护，包括但不限于：
            
            • 对任何和所有索赔的完全免责
            • 对任何财务建议或指导的免责
            • 对任何数据丢失或损坏的免责
            • 对任何第三方行为的免责
            
            关键免责声明
            
            财务建议免责：此应用程序不提供财务建议。所有信息仅供一般参考，不应被视为专业财务建议。
            
            • 不构成财务建议
            • 不构成投资建议
            • 不构成税务建议
            • 仅供个人使用
            
            使用风险自负
            
            您同意：
            
            • 您使用此应用程序的风险完全由您自己承担
            • 您对使用此应用程序产生的任何后果负责
            • 您理解并接受所有相关风险
            • 您不会因使用此应用程序而对我们提出任何索赔
            
            应用程序使用
            
            通过使用此应用程序，您同意：
            
            • 仅将应用程序用于合法目的
            • 不滥用或误用应用程序功能
            • 遵守所有适用的法律法规
            • 对您的使用行为负责
            
            数据管理
            
            您理解并同意：
            
            • 所有数据都存储在您的设备上
            • 您负责备份和保护您的数据
            • 我们不对数据丢失承担责任
            • 您可以随时删除所有数据
            
            联系我们
            
            如果您对这些条款有任何疑问，请通过应用内支持联系我们。
            
            通过使用此应用程序，您确认已阅读、理解并同意受这些服务条款的约束。
            """
        case "ja-JP":
            return """
            利用規約
            
            最終更新：2024年9月28日
            
            Money Managerをご利用いただき、ありがとうございます！これらの利用規約を注意深くお読みください。
            
            重要な法的免責事項
            
            データ損失のリスク：このアプリケーションを使用する際、以下の重要な免責事項を認識し、同意するものとします：
            
            • 私たちはデータ損失について責任を負いません
            • 私たちは財務損失について責任を負いません
            • 私たちは間接的な損害について責任を負いません
            • このアプリケーションの使用リスクは完全にあなた自身にあります
            
            完全な法的保護
            
            私たちは以下の完全な法的保護を提供します：
            
            • すべての請求に対する完全な免責
            • 財務アドバイスや指導に対する免責
            • データ損失や損害に対する免責
            • 第三者行為に対する免責
            
            重要な免責事項
            
            財務アドバイス免責：このアプリケーションは財務アドバイスを提供しません。すべての情報は一般的な参考用であり、専門的な財務アドバイスと見なされるべきではありません。
            
            • 財務アドバイスを構成しません
            • 投資アドバイスを構成しません
            • 税務アドバイスを構成しません
            • 個人使用のみを目的としています
            
            使用リスク自己負担
            
            あなたは以下に同意します：
            
            • このアプリケーションの使用リスクは完全にあなた自身にあります
            • このアプリケーションの使用から生じる結果について責任を負います
            • 関連するすべてのリスクを理解し、受け入れます
            • このアプリケーションの使用について私たちに請求することはありません
            
            アプリケーション使用
            
            このアプリケーションを使用することで、あなたは以下に同意します：
            
            • アプリケーションを合法的な目的でのみ使用
            • アプリケーション機能を悪用または誤用しない
            • 適用されるすべての法律規制に従う
            • あなたの使用行為に責任を負う
            
            データ管理
            
            あなたは以下を理解し、同意します：
            
            • すべてのデータはあなたのデバイスに保存されます
            • データのバックアップと保護に責任を負います
            • 私たちはデータ損失について責任を負いません
            • いつでもすべてのデータを削除できます
            
            お問い合わせ
            
            これらの規約についてご質問がございましたら、アプリ内サポートからお問い合わせください。
            
            このアプリケーションを使用することで、あなたはこれらの利用規約を読み、理解し、拘束されることに同意したことを確認します。
            """
        default:
            return """
            Terms of Service
            
            Last Updated: September 28, 2024
            
            Welcome to Money Manager! Please read these terms of service carefully.
            
            Important Legal Disclaimer
            
            Data Loss Risk: By using this application, you acknowledge and agree to the following important disclaimer:
            
            • We are not responsible for any data loss
            • We are not responsible for any financial losses
            • We are not responsible for any indirect damages
            • You use this application at your own risk
            
            Complete Legal Protection
            
            We provide complete legal protection, including but not limited to:
            
            • Complete disclaimer for any and all claims
            • Disclaimer for any financial advice or guidance
            • Disclaimer for any data loss or damage
            • Disclaimer for any third-party actions
            
            Critical Disclaimer
            
            Financial Advice Disclaimer: This application does not provide financial advice. All information is for general reference only and should not be considered professional financial advice.
            
            • Does not constitute financial advice
            • Does not constitute investment advice
            • Does not constitute tax advice
            • For personal use only
            
            Use at Your Own Risk
            
            You agree that:
            
            • You use this application at your own risk
            • You are responsible for any consequences of using this application
            • You understand and accept all associated risks
            • You will not make any claims against us for using this application
            
            Application Usage
            
            By using this application, you agree to:
            
            • Use the application only for lawful purposes
            • Not abuse or misuse application features
            • Comply with all applicable laws and regulations
            • Be responsible for your usage behavior
            
            Data Management
            
            You understand and agree that:
            
            • All data is stored on your device
            • You are responsible for backing up and protecting your data
            • We are not responsible for data loss
            • You can delete all data at any time
            
            Contact Us
            
            If you have any questions about these terms, please contact us through in-app support.
            
            By using this application, you confirm that you have read, understood, and agree to be bound by these terms of service.
            """
        }
    }
    
    // MARK: - Font Licensing Content
    
    func getFontLicensingTitle() -> String {
        switch currentLanguage {
        case "zh-CN":
            return "字体许可"
        case "ja-JP":
            return "フォントライセンス"
        default:
            return "Font Licensing"
        }
    }
    
    func getFontLicensingContent() -> String {
        switch currentLanguage {
        case "zh-CN":
            return """
            字体许可
            
            最后更新：2024年9月28日
            
            Trap字体许可信息
            
            字体设计师
            
            Trap字体由专业字体设计师设计，为Money Manager应用程序提供现代、专业的视觉体验。
            
            使用权利
            
            您有权在Money Manager应用程序中使用Trap字体：
            
            • 个人使用：完全允许
            • 商业使用：在应用程序内完全允许
            • 显示用途：所有界面元素
            • 打印用途：导出和报告功能
            
            使用限制
            
            请注意以下使用限制：
            
            • 不得将字体文件分发给第三方
            • 不得将字体用于其他应用程序
            • 不得修改或逆向工程字体文件
            • 不得将字体用于非Money Manager相关项目
            
            版权信息
            
            Trap字体受版权保护：
            
            • 版权归字体设计师所有
            • 所有权利保留
            • 未经许可不得复制或分发
            • 仅限Money Manager应用程序使用
            
            技术支持
            
            如果您对字体使用有任何疑问，请通过应用内支持联系我们。
            
            此许可确保Trap字体在Money Manager中的合法和适当使用。
            """
        case "ja-JP":
            return """
            フォントライセンス
            
            最終更新：2024年9月28日
            
            Trapフォントライセンス情報
            
            フォントデザイナー
            
            Trapフォントは専門のフォントデザイナーによって設計され、Money Managerアプリケーションにモダンでプロフェッショナルな視覚体験を提供します。
            
            使用権利
            
            あなたはMoney Managerアプリケーション内でTrapフォントを使用する権利があります：
            
            • 個人使用：完全に許可
            • 商業使用：アプリケーション内で完全に許可
            • 表示用途：すべてのインターフェース要素
            • 印刷用途：エクスポートとレポート機能
            
            使用制限
            
            以下の使用制限にご注意ください：
            
            • フォントファイルを第三者に配布してはいけません
            • フォントを他のアプリケーションで使用してはいけません
            • フォントファイルを変更またはリバースエンジニアリングしてはいけません
            • フォントをMoney Manager以外のプロジェクトで使用してはいけません
            
            著作権情報
            
            Trapフォントは著作権で保護されています：
            
            • 著作権はフォントデザイナーに帰属
            • すべての権利を留保
            • 許可なく複製または配布してはいけません
            • Money Managerアプリケーションでの使用のみ
            
            技術サポート
            
            フォント使用についてご質問がございましたら、アプリ内サポートからお問い合わせください。
            
            このライセンスにより、TrapフォントのMoney Managerでの合法的で適切な使用が保証されます。
            """
        default:
            return """
            Font Licensing
            
            Last Updated: September 28, 2024
            
            Trap Font Licensing Information
            
            Font Designer
            
            The Trap font was designed by professional font designers to provide a modern, professional visual experience for the Money Manager application.
            
            Usage Rights
            
            You have the right to use the Trap font within the Money Manager application:
            
            • Personal Use: Fully permitted
            • Commercial Use: Fully permitted within the application
            • Display Purposes: All interface elements
            • Print Purposes: Export and reporting features
            
            Usage Restrictions
            
            Please note the following usage restrictions:
            
            • Font files may not be distributed to third parties
            • Font may not be used in other applications
            • Font files may not be modified or reverse engineered
            • Font may not be used for non-Money Manager related projects
            
            Copyright Information
            
            The Trap font is protected by copyright:
            
            • Copyright belongs to the font designer
            • All rights reserved
            • May not be copied or distributed without permission
            • For use in Money Manager application only
            
            Technical Support
            
            If you have any questions about font usage, please contact us through in-app support.
            
            This license ensures the legal and appropriate use of the Trap font in Money Manager.
            """
        }
    }
    
    // MARK: - Version History Content
    
    func getVersionHistoryTitle() -> String {
        switch currentLanguage {
        case "zh-CN":
            return "版本历史"
        case "ja-JP":
            return "バージョン履歴"
        default:
            return "Version History"
        }
    }
    
    func getVersionHistoryContent() -> String {
        switch currentLanguage {
        case "zh-CN":
            return """
            版本历史
            
            以下是Money Manager的版本更新历史：
            
            版本 1.0.0 (2024年9月28日)
            • 初始发布
            • 完整的财务管理功能
            • 交易记录和预算管理
            • 贷款跟踪功能
            • 数据导出功能
            • 多语言支持（英语、中文、日语）
            • 文本转语音功能
            
            版本 0.9.0 (2024年9月20日)
            • 测试版发布
            • 核心功能实现
            • 用户界面优化
            • 性能改进
            
            版本 0.8.0 (2024年9月15日)
            • 开发版本
            • 基础架构完成
            • 数据模型实现
            • 初步用户界面
            
            版本 0.7.0 (2024年9月10日)
            • 早期开发版本
            • 项目初始化
            • 基础框架设置
            """
        case "ja-JP":
            return """
            バージョン履歴
            
            以下はMoney Managerのバージョン更新履歴です：
            
            バージョン 1.0.0 (2024年9月28日)
            • 初回リリース
            • 完全な財務管理機能
            • 取引記録と予算管理
            • ローン追跡機能
            • データエクスポート機能
            • 多言語サポート（英語、中国語、日本語）
            • テキスト読み上げ機能
            
            バージョン 0.9.0 (2024年9月20日)
            • ベータ版リリース
            • コア機能実装
            • ユーザーインターフェース最適化
            • パフォーマンス改善
            
            バージョン 0.8.0 (2024年9月15日)
            • 開発版
            • 基本アーキテクチャ完成
            • データモデル実装
            • 初期ユーザーインターフェース
            
            バージョン 0.7.0 (2024年9月10日)
            • 早期開発版
            • プロジェクト初期化
            • 基本フレームワーク設定
            """
        default:
            return """
            Version History
            
            Here is the version update history for Money Manager:
            
            Version 1.0.0 (September 28, 2024)
            • Initial release
            • Complete financial management features
            • Transaction recording and budget management
            • Loan tracking functionality
            • Data export functionality
            • Multilingual support (English, Chinese, Japanese)
            • Text-to-speech functionality
            
            Version 0.9.0 (September 20, 2024)
            • Beta release
            • Core functionality implementation
            • User interface optimization
            • Performance improvements
            
            Version 0.8.0 (September 15, 2024)
            • Development version
            • Basic architecture completion
            • Data model implementation
            • Initial user interface
            
            Version 0.7.0 (September 10, 2024)
            • Early development version
            • Project initialization
            • Basic framework setup
            """
        }
    }
}
