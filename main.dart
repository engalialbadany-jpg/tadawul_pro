import 'package:flutter/material.dart';

void main() => runApp(TadawulProSmartApp());

class TadawulProSmartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'منصة تداول برو - النسخة الاستثمارية الذكية',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF0B0E14),
        primaryColor: Color(0xFFF0B90B),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFFF0B90B),
          secondary: Color(0xFF0ECB81),
          surface: Color(0xFF1E2329),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class ProfitLog {
  String date;
  double profitAmount;
  double withdrawnAmount;
  double charityAmount;
  double reinvestedAmount;
  double currentPriceAtRecord;
  String coinStatusNote;

  ProfitLog({
    required this.date,
    required this.profitAmount,
    required this.withdrawnAmount,
    required this.charityAmount,
    required this.reinvestedAmount,
    required this.currentPriceAtRecord,
    required this.coinStatusNote,
  });
}

class TradeRecord {
  String coinName;
  double capital;
  double entryPrice;
  String investmentModel;
  String coinCategory;
  String riskLevel;
  List<ProfitLog> profitLogs;

  TradeRecord({
    required this.coinName,
    required this.capital,
    required this.entryPrice,
    required this.investmentModel,
    required this.coinCategory,
    required this.riskLevel,
    required this.profitLogs,
  });

  double get totalProfit => profitLogs.fold(0.0, (sum, log) => sum + log.profitAmount);
  double get totalWithdrawn => profitLogs.fold(0.0, (sum, log) => sum + log.withdrawnAmount);
  double get totalCharity => profitLogs.fold(0.0, (sum, log) => sum + log.charityAmount);
  double get totalReinvested => profitLogs.fold(0.0, (sum, log) => sum + log.reinvestedAmount);

  double get remainingCapital {
    double remaining = capital - totalWithdrawn;
    return remaining < 0 ? 0 : remaining;
  }

  double get profitPercentage {
    if (capital <= 0) return 0.0;
    return (totalProfit / capital) * 100;
  }

  String get capitalStatus {
    if (totalWithdrawn >= capital) {
      return '🟢 استرداد كامل رأس المال (مخاطر صفرية تماماً)';
    } else {
      return '⏳ متبقي لاسترداد رأس المال: ${remainingCapital.toStringAsFixed(2)} \$';
    }
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double userCharityPercentage = 2.5;
  bool isApiConnected = false;

  final List<TradeRecord> trades = [
    TradeRecord(
      coinName: 'TAO',
      capital: 500.0,
      entryPrice: 220.0,
      investmentModel: 'الآلية الأسبوعية (Cashflow)',
      coinCategory: 'عملات البنية التحتية والذكاء الاصطناعي',
      riskLevel: 'متوسطة - واعدة جداً',
      profitLogs: [
        ProfitLog(
          date: '2026-09-12',
          profitAmount: 60.0,
          withdrawnAmount: 30.0,
          charityAmount: 1.5,
          reinvestedAmount: 28.5,
          currentPriceAtRecord: 245.0,
          coinStatusNote: 'قاع قوي للصعود - مشروع حقيقي',
        ),
      ],
    ),
  ];

  double get totalCapital => trades.fold(0.0, (sum, t) => sum + t.capital);
  double get totalWithdrawn => trades.fold(0.0, (sum, t) => sum + t.totalWithdrawn);
  double get totalCharityVault => trades.fold(0.0, (sum, t) => sum + t.totalCharity);

  void _addNewTrade() async {
    final newTrade = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditTradeScreen()),
    );
    if (newTrade != null) {
      setState(() => trades.add(newTrade));
    }
  }

  void _showSettingsDialog() {
    bool tempApiState = isApiConnected;
    TextEditingController _controller = TextEditingController(text: userCharityPercentage.toString());
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Color(0xFF1E2329),
          title: Text('أدوات الضبط والربط الذكي', style: TextStyle(color: Color(0xFFF0B90B), fontSize: 14)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'نسبة الاقتطاع لصندوق الخير (%)'),
              ),
              SizedBox(height: 15),
              SwitchListTile(
                title: Text('ربط المنصة (قراءة فقط API)', style: TextStyle(fontSize: 12)),
                subtitle: Text('قراءة البيانات لمراقبة السوق دون أي صلاحية سحب أو بيع وشراء.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                value: tempApiState,
                activeColor: Color(0xFF0ECB81),
                onChanged: (val) {
                  setDialogState(() => tempApiState = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(child: Text('إلغاء', style: TextStyle(color: Colors.grey)), onPressed: () => Navigator.pop(context)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFF0B90B)),
              child: Text('حفظ', style: TextStyle(color: Colors.black)),
              onPressed: () {
                setState(() {
                  userCharityPercentage = double.tryParse(_controller.text) ?? userCharityPercentage;
                  isApiConnected = tempApiState;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تداول برو - النسخة الذكية والملهمة', style: TextStyle(color: Color(0xFFF0B90B), fontSize: 11, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF1E2329),
        actions: [
          IconButton(
            icon: Icon(Icons.lightbulb, color: Colors.amberAccent),
            tooltip: 'رادار العملات الواعدة',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MarketInsightsScreen())),
          ),
          IconButton(
            icon: Icon(Icons.menu_book, color: Colors.blueAccent),
            tooltip: 'دليل الاستخدام الخيري',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GuideScreen())),
          ),
          IconButton(
            icon: Icon(Icons.calculate, color: Color(0xFFF0B90B)),
            tooltip: 'حاسبة إدارة المخاطر',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RiskCalculatorScreen())),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Color(0xFFF0B90B)),
            tooltip: 'أدوات الضبط والربط',
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFF1E2329),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFF0B90B).withOpacity(0.4)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('إجمالي رأس المال', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text('${totalCapital.toStringAsFixed(2)} \$', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Container(height: 25, width: 1, color: Colors.grey[700]),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('خزنة الخير والبيئة', style: TextStyle(color: Color(0xFF0ECB81), fontSize: 11)),
                        Text('+${totalCharityVault.toStringAsFixed(2)} \$', style: TextStyle(color: Color(0xFF0ECB81), fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Divider(color: Colors.grey[800]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('وضع الربط: ${isApiConnected ? "🟢 متصل (قراءة فقط)" : "✍️ إدخال يدوي آمن"}', style: TextStyle(color: isApiConnected ? Color(0xFF0ECB81) : Colors.amberAccent, fontSize: 10)),
                    Text('نسبة التطوع: $userCharityPercentage%', style: TextStyle(color: Colors.amberAccent, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الأصول النشطة وتصنياتها:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text('اضغط لتفاصيل السجل', style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemCount: trades.length,
              itemBuilder: (context, index) {
                final trade = trades[index];
                return Card(
                  color: Color(0xFF1E2329),
                  margin: EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text('العملة: ${trade.coinName} | الدخول: ${trade.entryPrice}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text('التصنيف: ${trade.coinCategory}', style: TextStyle(color: Colors.cyanAccent, fontSize: 11)),
                        Text('الخطورة: ${trade.riskLevel}', style: TextStyle(color: Colors.orangeAccent, fontSize: 10)),
                        Text('رأس المال: ${trade.capital} \$ | مسحوب: +${trade.totalWithdrawn.toStringAsFixed(2)} \$ (${trade.profitPercentage.toStringAsFixed(1)}%)', style: TextStyle(color: Color(0xFF0ECB81), fontSize: 11)),
                        Text('حالة الأمان: ${trade.capitalStatus}', style: TextStyle(color: Color(0xFFF0B90B), fontSize: 10)),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Color(0xFFF0B90B), size: 18),
                          onPressed: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddEditTradeScreen(existingTrade: trade)),
                            );
                            if (updated != null) setState(() => trades[index] = updated);
                          },
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CoinDetailScreen(trade: trade, charityRate: userCharityPercentage)),
                      ).then((_) => setState(() {}));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFF0B90B),
        child: Icon(Icons.add, color: Colors.black),
        onPressed: _addNewTrade,
      ),
    );
  }
}

class MarketInsightsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('رادار السوق والعملات الواعدة'), backgroundColor: Color(0xFF1E2329)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              color: Color(0xFF1E2329),
              child: Padding(
                padding: EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🏗️ قطاع البنية التحتية والذكاء الاصطناعي:', style: TextStyle(color: Color(0xFFF0B90B), fontWeight: FontWeight.bold, fontSize: 12)),
                    SizedBox(height: 6),
                    Text('• العملات المقترحة: TAO, RENDER, NEAR\n• التقييم: مشاريع حقيقية ذات طلب تقني عالمي.', style: TextStyle(color: Colors.grey[300], fontSize: 11)),
                  ],
                ),
              ),
            ),
            Card(
              color: Color(0xFF1E2329),
              child: Padding(
                padding: EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🌐 قطاع الأصول القيادية (L1):', style: TextStyle(color: Color(0xFF0ECB81), fontWeight: FontWeight.bold, fontSize: 12)),
                    SizedBox(height: 6),
                    Text('• العملات المقترحة: BTC, SOL, ETH\n• التقييم: استقرار عالٍ وسيولة عميقة.', style: TextStyle(color: Colors.grey[300], fontSize: 11)),
                  ],
                ),
              ),
            ),
            Card(
              color: Color(0xFF1E2329),
              child: Padding(
                padding: EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⚡ عملات المضاربة العالية:', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                    SizedBox(height: 6),
                    Text('• العملات الناشئة ذات التذبذب السريع.\n• ⚠️ تحذير: أرباح سريعة لكنها تحمل خطورة هبوط حادة؛ يرجى الالتزام بسيولة الاحتياطي (20%).', style: TextStyle(color: Colors.grey[300], fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuideScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('دليل الاستخدام ونشر الخير'), backgroundColor: Color(0xFF1E2329)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              color: Color(0xFF1E2329),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('رسالة المشروع والأهداف الإنسانية:', style: TextStyle(color: Color(0xFFF0B90B), fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 10),
                    Text(
                      'هذا التطبيق صُمم ليكون نموذجاً للاستثمار الواعي والأخلاقي عبر الالتزام بقاعدة استرداد رأس المال وعزل نسبة الخير والبيئة.',
                      style: TextStyle(color: Colors.grey[300], fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RiskCalculatorScreen extends StatefulWidget {
  @override
  _RiskCalculatorScreenState createState() => _RiskCalculatorScreenState();
}

class _RiskCalculatorScreenState extends State<RiskCalculatorScreen> {
  final TextEditingController _totalCapitalController = TextEditingController(text: '1000');
  double spotLongTerm = 500;
  double swingCashflow = 300;
  double scalpReserve = 200;

  void _calculate(String value) {
    double total = double.tryParse(value) ?? 1000;
    setState(() {
      spotLongTerm = total * 0.50;
      swingCashflow = total * 0.30;
      scalpReserve = total * 0.20;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('حاسبة إدارة المخاطر وتوزيع السيولة'), backgroundColor: Color(0xFF1E2329)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _totalCapitalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'إجمالي المحفظة الجديدة (USDT)'),
              onChanged: _calculate,
            ),
            SizedBox(height: 20),
            Card(
              color: Color(0xFF1E2329),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('توزيع السيولة الآمن:', style: TextStyle(color: Color(0xFFF0B90B), fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('🔹 استثمار طويل (50%): ${spotLongTerm.toStringAsFixed(2)} \$', style: TextStyle(color: Colors.white, fontSize: 13)),
                    SizedBox(height: 6),
                    Text('🔹 سيولة أسبوعية (30%): ${swingCashflow.toStringAsFixed(2)} \$', style: TextStyle(color: Color(0xFF0ECB81), fontSize: 13)),
                    SizedBox(height: 6),
                    Text('🔹 احتياطي لحظي (20%): ${scalpReserve.toStringAsFixed(2)} \$', style: TextStyle(color: Colors.amberAccent, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddEditTradeScreen extends StatefulWidget {
  final TradeRecord? existingTrade;
  AddEditTradeScreen({this.existingTrade});

  @override
  _AddEditTradeScreenState createState() => _AddEditTradeScreenState();
}

class _AddEditTradeScreenState extends State<AddEditTradeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _coinController;
  late TextEditingController _capitalController;
  late TextEditingController _entryController;
  String _selectedModel = 'الآلية الأسبوعية (Cashflow)';
  String _selectedCategory = 'عملات البنية التحتية والذكاء الاصطناعي';
  String _selectedRisk = 'متوسطة - واعدة جداً';

  final List<String> _models = ['الآلية الأسبوعية (Cashflow)', 'الآلية الشهرية (Compound)'];
  final List<String> _categories = [
    'عملات البنية التحتية والذكاء الاصطناعي',
    'أصول الأصول القيادية (L1)',
    'عملات الترميز (RWA)',
    'عملات المضاربة السريعة'
  ];
  final List<String> _risks = ['آمنة - مستقرة', 'متوسطة - واعدة جداً', 'عالية المخاطر ومضاربية'];

  @override
  void initState() {
    super.initState();
    _coinController = TextEditingController(text: widget.existingTrade?.coinName ?? '');
    _capitalController = TextEditingController(text: widget.existingTrade != null ? widget.existingTrade!.capital.toString() : '');
    _entryController = TextEditingController(text: widget.existingTrade != null ? widget.existingTrade!.entryPrice.toString() : '');
    _selectedModel = widget.existingTrade?.investmentModel ?? 'الآلية الأسبوعية (Cashflow)';
    _selectedCategory = widget.existingTrade?.coinCategory ?? 'عملات البنية التحتية والذكاء الاصطناعي';
    _selectedRisk = widget.existingTrade?.riskLevel ?? 'متوسطة - واعدة جداً';
  }

  @override
  void dispose() {
    _coinController.dispose();
    _capitalController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.existingTrade != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'تعديل بيانات الأصل' : 'إضافة أصل وتصنيفه'), backgroundColor: Color(0xFF1E2329)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _coinController, decoration: InputDecoration(labelText: 'اسم العملة (مثال: SOL, TAO)'), validator: (v) => v!.isEmpty ? 'أدخل الاسم' : null),
              TextFormField(controller: _capitalController, decoration: InputDecoration(labelText: 'رأس المال (USDT)'), keyboardType: TextInputType.number, validator: (v) => double.tryParse(v ?? '') == null ? 'أدخل قيمة' : null),
              TextFormField(controller: _entryController, decoration: InputDecoration(labelText: 'سعر الدخول'), keyboardType: TextInputType.number, validator: (v) => double.tryParse(v ?? '') == null ? 'أدخل سعر' : null),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedModel,
                decoration: InputDecoration(labelText: 'الآلية الاستثمارية'),
                items: _models.map((m) => DropdownMenuItem(value: m, child: Text(m, style: TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) => setState(() => _selectedModel = v!),
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'تصنيف مجال العملة'),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedRisk,
                decoration: InputDecoration(labelText: 'تقييم المخاطر والمشروع'),
                items: _risks.map((r) => DropdownMenuItem(value: r, child: Text(r, style: TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) => setState(() => _selectedRisk = v!),
              ),
              SizedBox(height: 35),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFF0B90B), padding: EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    double capital = double.parse(_capitalController.text);
                    double entryPrice = double.parse(_entryController.text);
                    String coinName = _coinController.text.toUpperCase();

                    if (isEditing) {
                      widget.existingTrade!.coinName = coinName;
                      widget.existingTrade!.capital = capital;
                      widget.existingTrade!.entryPrice = entryPrice;
                      widget.existingTrade!.investmentModel = _selectedModel;
                      widget.existingTrade!.coinCategory = _selectedCategory;
                      widget.existingTrade!.riskLevel = _selectedRisk;
                      Navigator.pop(context, widget.existingTrade);
                    } else {
                      Navigator.pop(context, TradeRecord(
                        coinName: coinName,
                        capital: capital,
                        entryPrice: entryPrice,
                        investmentModel: _selectedModel,
                        coinCategory: _selectedCategory,
                        riskLevel: _selectedRisk,
                        profitLogs: [],
                      ));
                    }
                  }
                },
                child: Text(isEditing ? 'حفظ التعديلات' : 'اعتماد الأصل', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CoinDetailScreen extends StatelessWidget {
  final TradeRecord trade;
  final double charityRate;

  CoinDetailScreen({required this.trade, required this.charityRate});

  @override
  Widget build(BuildContext context) {
    double targetPrice50 = trade.entryPrice * 1.10;
    double targetPrice100 = trade.entryPrice * 1.20;

    return Scaffold(
      appBar: AppBar(title: Text('سجل أرباح وتحليل: ${trade.coinName}'), backgroundColor: Color(0xFF1E2329)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Color(0xFF1E2329),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('التصنيف: ${trade.coinCategory}', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(height: 4),
                    Text('تقييم المخاطر: ${trade.riskLevel}', style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
                    SizedBox(height: 6),
                    Text('سعر الدخول الأساسي: ${trade.entryPrice} \$', style: TextStyle(color: Colors.white, fontSize: 12)),
                    SizedBox(height: 4),
                    Text('إجمالي مساهمة الخزنة الإنسانية: +${trade.totalCharity.toStringAsFixed(2)} \$', style: TextStyle(color: Color(0xFF0ECB81), fontSize: 12)),
                    SizedBox(height: 4),
                    Text(trade.capitalStatus, style: TextStyle(color: Colors.grey[300], fontSize: 11)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Card(
              color: Color(0xFF1A222D),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🎯 حاسبة الهدف الذكي لاسترداد رأس المال:', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                    SizedBox(height: 6),
                    Text('• هدف 10% (استرداد جزئي): ${targetPrice50.toStringAsFixed(2)} \$', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    Text('• هدف 20% (استرداد 100% رأس المال): ${targetPrice100.toStringAsFixed(2)} \$', style: TextStyle(color: Color(0xFF0ECB81), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('السجل التاريخي:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0ECB81)),
                  icon: Icon(Icons.add, color: Colors.black, size: 16),
                  label: Text('توريد ربح ودورة', style: TextStyle(color: Colors.black, fontSize: 11)),
                  onPressed: () async {
                    final newLog = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddProfitLogScreen(currentRate: charityRate)),
                    );
                    if (newLog != null) {
                      (context as Element).markNeedsBuild();
                      trade.profitLogs.add(newLog);
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: trade.profitLogs.isEmpty
                  ? Center(child: Text('لا توجد أرباح مسجلة', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: trade.profitLogs.length,
                      itemBuilder: (context, index) {
                        final log = trade.profitLogs[index];
                        return Card(
                          color: Color(0xFF1E2329),
                          child: ListTile(
                            title: Text('التاريخ: ${log.date} | الربح: +${log.profitAmount}\$', style: TextStyle(color: Colors.white, fontSize: 12)),
                            subtitle: Text('مسحوب لجيبك: ${log.withdrawnAmount}\$ | للخير ($charityRate%): ${log.charityAmount}\$\nتحليل: ${log.coinStatusNote}', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddProfitLogScreen extends StatefulWidget {
  final double currentRate;
  AddProfitLogScreen({required this.currentRate});

  @override
  _AddProfitLogScreenState createState() => _AddProfitLogScreenState();
}

class _AddProfitLogScreenState extends State<AddProfitLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController(text: '2026-09-12');
  final TextEditingController _profitController = TextEditingController();
  final TextEditingController _withdrawnController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController(text: 'قاع قوي - صاعد');

  @override
  void dispose() {
    _dateController.dispose();
    _profitController.dispose();
    _withdrawnController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('توريد أرباح الدورة'), backgroundColor: Color(0xFF1E2329)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _dateController, decoration: InputDecoration(labelText: 'التاريخ')),
              TextFormField(controller: _profitController, decoration: InputDecoration(labelText: 'إجمالي الربح (USDT)'), keyboardType: TextInputType.number, validator: (v) => double.tryParse(v ?? '') == null ? 'أدخل قيمة' : null),
              TextFormField(controller: _withdrawnController, decoration: InputDecoration(labelText: 'المسحب لجيبك (USDT)'), keyboardType: TextInputType.number, validator: (v) => double.tryParse(v ?? '') == null ? 'أدخل قيمة' : null),
              TextFormField(controller: _priceController, decoration: InputDecoration(labelText: 'السعر وقت التوريد'), keyboardType: TextInputType.number, validator: (v) => double.tryParse(v ?? '') == null ? 'أدخل سعر' : null),
              TextFormField(controller: _noteController, decoration: InputDecoration(labelText: 'ملاحظة تحليلية')),
              SizedBox(height: 35),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0ECB81), padding: EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    double totalProfit = double.parse(_profitController.text);
                    double withdrawn = double.parse(_withdrawnController.text);
                    double currentPrice = double.parse(_priceController.text);
                    double charity = (totalProfit * widget.currentRate) / 100;
                    double reinvested = totalProfit - withdrawn - charity;
                    if (reinvested < 0) reinvested = 0;

                    Navigator.pop(
                      context,
                      ProfitLog(
                        date: _dateController.text,
                        profitAmount: totalProfit,
                        withdrawnAmount: withdrawn,
                        charityAmount: charity,
                        reinvestedAmount: reinvested,
                        currentPriceAtRecord: currentPrice,
                        coinStatusNote: _noteController.text,
                      ),
                    );
                  }
                },
                child: Text('اعتماد التوريد وعزل الخزنة', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
