import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'shopping_list.dart';
import 'home.dart';
import 'utils/contract.dart';
import 'utils/sql_helper.dart';

ShoppingProvider? shoppingProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  shoppingProvider = ShoppingProvider();

  // Get a location using getDatabasesPath
  String databasePath = await getDatabasesPath();
  String path = join(databasePath, ShoppingContract.dbName);

  //deleteDatabase(path);

  await shoppingProvider!.open(path);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const Home(),
        SList.routeName: (context) => const SList()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
