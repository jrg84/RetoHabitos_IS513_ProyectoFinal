import 'dart:async';
import 'package:flutter/material.dart';
import '../models/HabitosModel.dart';

class HabitoTimerView extends StatefulWidget {
  final Habito habito;

  const HabitoTimerView({super.key, required this.habito});

  @override
  _HabitoTimerViewState createState() => _HabitoTimerViewState();
}

class _HabitoTimerViewState extends State<HabitoTimerView> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;

  void _startTimer() {
    if (_isRunning) return;

    setState(() => _isRunning = true);

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habito.nombre),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_seconds),
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            _isRunning
                ? ElevatedButton(
                    onPressed: _stopTimer,
                    child: Text("Detener"),
                  )
                : ElevatedButton(
                    onPressed: _startTimer,
                    child: Text("Comenzar"),
                  ),
          ],
        ),
      ),
    );
  }
}
