import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'contract.dart';

/// ShoppingList model.
class ShoppingListHelper {
  /// ShoppingList model.
  ShoppingListHelper({required this.title});

  /// Read from a record.
  ShoppingListHelper.fromMap(Map map) {
    id = map[ShoppingContract.listColumnId] as int?;
    title = map[ShoppingContract.listColumnTitle] as String;
  }

  /// id.
  int? id;

  /// title.
  String? title;

  /// Convert to a record.
  Map<String, Object?> toMap() {
    final map = <String, Object?>{
      ShoppingContract.listColumnTitle: title,
    };
    if (id != null) {
      map[ShoppingContract.listColumnId] = id;
    }
    return map;
  }
}

/// ShoppingItem model.
class ShoppingItemHelper {
  /// ShoppingItem  model.
  ShoppingItemHelper(
      {required this.title,
      required this.listid,
      required this.price,
      required this.done,
      required this.unit,
      required this.quantity});

  /// Read from a record.
  ShoppingItemHelper.fromMap(Map map) {
    id = map[ShoppingContract.itemColumnId] as int?;
    listid = map[ShoppingContract.itemColumnListId] as int?;
    title = map[ShoppingContract.itemColumnTitle] as String?;
    quantity = map[ShoppingContract.itemColumnQuantity] as double?;
    unit = map[ShoppingContract.itemColumnUnit] as String?;
    price = map[ShoppingContract.itemColumnPrice] as double?;
    done = map[ShoppingContract.itemColumnDone] == 1;
  }

  /// item id.
  int? id;

  /// list id
  int? listid;

  /// title.
  String? title;

  /// quantity
  double? quantity;

  /// unit
  String? unit;

  /// price
  double? price;

  /// picked
  bool? done;

  /// Convert to a record.
  Map<String, Object?> toMap() {
    final map = <String, Object?>{
      ShoppingContract.itemColumnListId: listid,
      ShoppingContract.itemColumnTitle: title,
      ShoppingContract.itemColumnQuantity: quantity,
      ShoppingContract.itemColumnUnit: unit,
      ShoppingContract.itemColumnPrice: price,
      ShoppingContract.itemColumnDone: done == true ? 1 : 0
    };
    if (id != null) {
      map[ShoppingContract.itemColumnId] = id;
    }
    return map;
  }
}

class ShoppingProvider {
  late Database db;

  Future open(String path) async {
    // If you change the database schema, you must increment the database version.
    db = await openDatabase(
      path,
      version: ShoppingContract.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
    );
  }

  void _onCreate(Database db, int version) async {
    //Transaction processing
    await db.transaction((txn) async {
      // Ok
      await txn.execute('''
create table ${ShoppingContract.tableShoppingList} ( 
  ${ShoppingContract.listColumnId} integer primary key autoincrement, 
  ${ShoppingContract.listColumnTitle} text not null)
''');
      await txn.execute('''
create table ${ShoppingContract.tableShoppingItem} ( 
  ${ShoppingContract.itemColumnId} integer primary key autoincrement, 
   ${ShoppingContract.itemColumnListId} integer , 
  ${ShoppingContract.itemColumnTitle} text not null,
  ${ShoppingContract.itemColumnQuantity} double DEFAULT 0.0 not null,
  ${ShoppingContract.itemColumnUnit} text default "kg" not null,
  ${ShoppingContract.itemColumnPrice} double default 0.0 not null,
  ${ShoppingContract.itemColumnDone} integer  not null)
''');
    });
  }

  //Database Migration
  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    // This callback is triggered when the database version is increased.
    // You can use this callback to modify the database schema, add or alter tables,
    // or perform any other necessary migration tasks.

    // Called when the database needs to be upgraded
    // You can modify the database schema here
    // if (oldVersion == 1) {
    //     // Example: Add a new column in version 2
    //     await db.execute('ALTER TABLE table_name ADD COLUMN new_column TEXT');
    //   }

    print("Upgrading database from version $oldVersion to $newVersion");
  }

  void _onDowngrade(Database db, int oldVersion, int newVersion) {
    // This callback is triggered when the database version is decreased.
    //You can use this callback to handle downgrades or throw an exception if
    // downgrading is not supported.

    // Called when the database needs to be downgraded
    // You can handle downgrades here, or throw an exception to prevent it
    print("Downgrading database from version $oldVersion to $newVersion");
  }

  Future<void> insertShoppingList(ShoppingListHelper shoppinglist) async {
    shoppinglist.id = await db.insert(
        ShoppingContract.tableShoppingList, shoppinglist.toMap());

    //batch support
    Batch batch = db.batch();
    batch.insert(
        ShoppingContract.tableShoppingItem,
        ShoppingItemHelper(
                title: "Vegetables",
                listid: shoppinglist.id,
                price: 0,
                done: false,
                unit: "kg",
                quantity: 0)
            .toMap());
    batch.insert(
        ShoppingContract.tableShoppingItem,
        ShoppingItemHelper(
                title: "Fruits",
                listid: shoppinglist.id,
                price: 0,
                done: false,
                unit: "kg",
                quantity: 0)
            .toMap());
    await batch.commit();

    // return shoppinglist;
  }

  Future<ShoppingListHelper?> getShoppingList(int id) async {
    try {
      List<Map> maps = await db.query(ShoppingContract.tableShoppingList,
          columns: [
            ShoppingContract.listColumnId,
            ShoppingContract.listColumnTitle
          ],
          where: '${ShoppingContract.listColumnId} = ?',
          whereArgs: [id]);
      if (maps.isNotEmpty) {
        return ShoppingListHelper.fromMap(maps.first);
      }
    } on DatabaseException catch (e) {
      return null;
    }
    return null;
  }

  Future<List<ShoppingListHelper>> getShoppingLists() async {
    List<Map> shoppinglists =
        await db.query(ShoppingContract.tableShoppingList);

    List<ShoppingListHelper> lists = [];
    if (shoppinglists.isNotEmpty) {
      for (Map shoppinglist in shoppinglists) {
        lists.add(ShoppingListHelper.fromMap(shoppinglist));
      }
    }
    return lists;
  }

  Future<int> deleteShoppingList(int id) async {
    final deletedId = await db.delete(ShoppingContract.tableShoppingList,
        where: '${ShoppingContract.listColumnId} = ?', whereArgs: [id]);
    await db.delete(ShoppingContract.tableShoppingItem,
        where: '${ShoppingContract.itemColumnListId} = ?', whereArgs: [id]);

    return deletedId;
  }

  Future<int> updateShoppingList(ShoppingListHelper shoppinglist) async {
    return await db.update(
        ShoppingContract.tableShoppingList, shoppinglist.toMap(),
        where: '${ShoppingContract.listColumnId} = ?',
        whereArgs: [shoppinglist.id]);
  }

  Future<ShoppingItemHelper> insertShoppingItem(
      ShoppingItemHelper shoppingitem) async {
    shoppingitem.id = await db.insert(
        ShoppingContract.tableShoppingItem, shoppingitem.toMap());
    return shoppingitem;
  }

  Future<ShoppingItemHelper?> getShoppingItem(int id) async {
    List<Map> maps = await db.query(ShoppingContract.tableShoppingItem,
        columns: [
          ShoppingContract.itemColumnId,
          ShoppingContract.itemColumnTitle,
          ShoppingContract.itemColumnQuantity,
          ShoppingContract.itemColumnUnit,
          ShoppingContract.itemColumnPrice,
          ShoppingContract.itemColumnDone
        ],
        where: '${ShoppingContract.itemColumnId} = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return ShoppingItemHelper.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ShoppingItemHelper>> getShoppingItems(int? listid) async {
    List<Map> items = await db.query(ShoppingContract.tableShoppingItem,
        columns: [
          ShoppingContract.itemColumnId,
          ShoppingContract.itemColumnTitle,
          ShoppingContract.itemColumnQuantity,
          ShoppingContract.itemColumnUnit,
          ShoppingContract.itemColumnPrice,
          ShoppingContract.itemColumnDone
        ],
        where: '${ShoppingContract.itemColumnListId} = ?',
        whereArgs: [listid]);

    List<ShoppingItemHelper> _items = [];
    if (items.isNotEmpty) {
      for (Map item in items) {
        _items.add(ShoppingItemHelper.fromMap(item));
      }
    }
    return _items;
  }

  Future<int> deleteShoppingItem(int id) async {
    return await db.delete(ShoppingContract.tableShoppingItem,
        where: '${ShoppingContract.itemColumnId} = ?', whereArgs: [id]);
  }

  Future<int> updateShoppingItem(ShoppingItemHelper shoppingItem) async {
    return await db.update(
        ShoppingContract.tableShoppingItem, shoppingItem.toMap(),
        where: '${ShoppingContract.itemColumnId} = ?',
        whereArgs: [shoppingItem.id]);
  }

  Future close() async => db.close();

  Future<String> initDeleteDb(String dbName) async {
    final databasePath = await getDatabasesPath();
    // print(databasePath);
    final path = join(databasePath, dbName);

    // make sure the folder exists
    // ignore: avoid_slow_async_io
    if (await Directory(dirname(path)).exists()) {
      await deleteDatabase(path);
    } else {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }
    return path;
  }

  Future<void> deleteDatabase(String path) =>
      databaseFactory.deleteDatabase(path);
}
