import 'package:drift/drift.dart';
import 'package:drift/web.dart'; // ignore: deprecated_member_use

QueryExecutor openConnection() {
  return WebDatabase('church_analytics');
}
