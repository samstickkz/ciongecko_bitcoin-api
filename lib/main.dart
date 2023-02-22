import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitcoin Price',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Bitcoin Price'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Timer _timer;
  late Map<String, dynamic> _bitcoinPriceData;
  bool _isLoading = true;

  Future<void> fetchBitcoinPrice() async {
    final response = await http.get(Uri.parse(
        'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd'));

    if (response.statusCode == 200) {
      setState(() {
        _bitcoinPriceData = json.decode(response.body)['bitcoin'];
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to fetch Bitcoin price');
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch the Bitcoin price data when the widget is first created
    fetchBitcoinPrice();

    // Set up a timer to refresh the Bitcoin price data every 5 minutes
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchBitcoinPrice();
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Cancel the timer when the widget is disposed to avoid memory leaks
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Text(
          '\$${_bitcoinPriceData['usd'].toStringAsFixed(2)}',
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}
