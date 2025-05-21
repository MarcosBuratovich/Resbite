import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Added for Ticker and TickerCallback
import 'package:flutter_riverpod/flutter_riverpod.dart';

final resbiteTabControllerProvider = Provider.autoDispose<TabController>((ref) {
  final vsync = ref.watch(tickerProvider);
  return TabController(
    length: 2,
    vsync: vsync,
  )..addListener(() {
      // Handle tab index changes if needed
    });
});

final tickerProvider = Provider.autoDispose((ref) {
  return TickerProviderReference();
});

class TickerProviderReference extends ChangeNotifier implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}
