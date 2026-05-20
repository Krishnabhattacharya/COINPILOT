import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewListingsNotifier extends ChangeNotifier {
  String _filter = 'All';
  String get filter => _filter;

  void setFilter(String f) {
    if (_filter == f) return;
    _filter = f;
    notifyListeners();
  }
}

final newListingsProvider = ChangeNotifierProvider.autoDispose(
  (ref) => NewListingsNotifier(),
);
