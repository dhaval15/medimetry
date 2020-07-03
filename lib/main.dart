import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Database database = await databaseFactoryIo
      .openDatabase(join(dir.path, 'medimetry.db'), version: 1);
  runApp(MediMetryApp(
    database: database,
  ));
}
