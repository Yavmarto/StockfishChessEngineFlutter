import 'dart:async';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:stockfish/stockfish.dart';
import 'package:stockfish/stockfish_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late Stockfish _stockfish;
  final _fenController = TextEditingController();
  late StreamSubscription _stockfishOutputSubsciption;
  var _timeMs = 1000.0;
  var _nextMove = '';

  @override
  void initState() {
    _stockfish = Stockfish();
    _stockfishOutputSubsciption =
        _stockfish.stdout.listen(_readStockfishOutput);
    super.initState();
  }

  @override
  void dispose() {
    _stockfishOutputSubsciption.cancel();
    super.dispose();
  }

  void _readStockfishOutput(String output) {
    debugPrint(output);
    if (output.startsWith('bestmove')) {
      final parts = output.split(' ');
      setState(() {
        _nextMove = parts[1];
      });
    }
  }

  void _pasteFen() {
    FlutterClipboard.paste().then((value) {
      // Do what ever you want with the value.
      setState(() {
        _fenController.text = value;
      });
    });
  }

  void _updateThinkingTime(double newValue) {
    setState(() {
      _timeMs = newValue;
    });
  }

  void _computeNextMove() {
    _stockfish.stdin = 'position fen ${_fenController.text}';
    _stockfish.stdin = 'go movetime ${_timeMs.toInt()}';
  }

  void _stopStockfish() async {
    if (_stockfish.state.value == StockfishState.disposed ||
        _stockfish.state.value == StockfishState.error) {
      return;
    }
    _stockfishOutputSubsciption.cancel();
    _stockfish.stdin = 'quit';
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {});
  }

  void _startStockfish() {
    setState(() {
      if (_stockfish.state.value == StockfishState.ready ||
          _stockfish.state.value == StockfishState.starting) {
        return;
      }
      _stockfish = Stockfish();
      _stockfishOutputSubsciption =
          _stockfish.stdout.listen(_readStockfishOutput);
    });
  }

  Icon _getStockfishStatusIcon() {
    Color color;
    switch (_stockfish.state.value) {
      case StockfishState.ready:
        color = Colors.green;
        break;
      case StockfishState.disposed:
      case StockfishState.error:
        color = Colors.red;
        break;
      case StockfishState.starting:
        color = Colors.orange;
    }
    return Icon(MdiIcons.circle, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Stockfish Chess Engine example"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _fenController,
                decoration: const InputDecoration(
                  hintText: 'Position FEN value',
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                onPressed: _pasteFen,
                child: const Text('Coller FEN'),
              ),
              Slider(
                value: _timeMs,
                onChanged: _updateThinkingTime,
                min: 500,
                max: 3000,
              ),
              Text('Thinking time : ${_timeMs.toInt()} millis'),
              ElevatedButton(
                onPressed: _computeNextMove,
                child: const Text('Search next move'),
              ),
              Text('Best move: $_nextMove'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _getStockfishStatusIcon(),
                  ElevatedButton(
                    onPressed: _startStockfish,
                    child: const Text('Start Stockfish'),
                  ),
                  ElevatedButton(
                    onPressed: _stopStockfish,
                    child: const Text('Stop Stockfish'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
