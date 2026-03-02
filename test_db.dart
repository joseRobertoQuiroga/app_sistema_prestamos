import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

void main() {
  // Try to find the DB. Windows flutter usually puts it in Documents or AppData.
  // Actually, drift on Windows puts it in `Document/app_name/` or similar.
  // We can just use sqlite3 to open the local sqlite db if it's there.
  // Let's first search where the database is.
  var dir = Directory.current;
  print("Current Dir: ${dir.path}");
  
  // Try to find .sqlite or .db files in the project or user documents
  var docsPath = Platform.environment['USERPROFILE']! + '\\Documents';
  print("Docs Path: $docsPath");
}
