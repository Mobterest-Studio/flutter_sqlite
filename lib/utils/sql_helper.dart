import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'constants.dart';

/// ShoppingList model.
class ShoppingListHelper {
  /// ShoppingList model.
  ShoppingListHelper({required this.title});

  /// Read from a record.
  ShoppingListHelper.fromMap(Map map) {
    id = map[listColumnId] as int?;
    title = map[listColumnTitle] as String;
  }

  /// id.
  int? id;

  /// title.
  String? title;

  /// Convert to a record.
  Map<String, Object?> toMap() {
    final map = <String, Object?>{
      listColumnTitle: title,
    };
    if (id != null) {
      map[listColumnId] = id;
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
    id = map[itemColumnId] as int?;
    listid = map[itemColumnListId] as int?;
    title = map[itemColumnTitle] as String?;
    quantity = map[itemColumnQuantity] as double?;
    unit = map[itemColumnUnit] as String?;
    price = map[itemColumnPrice] as double?;
    done = map[itemColumnDone] == 1;
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
      itemColumnListId: listid,
      itemColumnTitle: title,
      itemColumnQuantity: quantity,
      itemColumnUnit: unit,
      itemColumnPrice: price,
      itemColumnDone: done == true ? 1 : 0
    };
    if (id != null) {
      map[itemColumnId] = id;
    }
    return map;
  }
}

class ShoppingProvider {
  late Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      //Transaction processing
      await db.transaction((txn) async {
        // Ok
        await txn.execute('''
create table $tableShoppingList ( 
  $listColumnId integer primary key autoincrement, 
  $listColumnTitle text not null)
''');
        await txn.execute('''
create table $tableShoppingItem ( 
  $itemColumnId integer primary key autoincrement, 
   $itemColumnListId integer , 
  $itemColumnTitle text not null,
  $itemColumnQuantity double DEFAULT 0.0 not null,
  $itemColumnUnit text default "kg" not null,
  $itemColumnPrice double default 0.0 not null,
  $itemColumnDone integer  not null)
''');
      });
    });
  }

  Future<void> insertShoppingList(ShoppingListHelper shoppinglist) async {
    shoppinglist.id = await db.insert(tableShoppingList, shoppinglist.toMap());

    //batch support
    Batch batch = db.batch();
    batch.insert(
        tableShoppingItem,
        ShoppingItemHelper(
                title: "Vegetables",
                listid: shoppinglist.id,
                price: 0,
                done: false,
                unit: "kg",
                quantity: 0)
            .toMap());
    batch.insert(
        tableShoppingItem,
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
    List<Map> maps = await db.query(tableShoppingList,
        columns: [listColumnId, listColumnTitle],
        where: '$listColumnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return ShoppingListHelper.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ShoppingListHelper>> getShoppingLists() async {
    List<Map> shoppinglists = await db.query(tableShoppingList);

    List<ShoppingListHelper> lists = [];
    if (shoppinglists.isNotEmpty) {
      for (Map shoppinglist in shoppinglists) {
        lists.add(ShoppingListHelper.fromMap(shoppinglist));
      }
    }
    return lists;
  }

  Future<int> deleteShoppingList(int id) async {
    final deletedId = await db
        .delete(tableShoppingList, where: '$listColumnId = ?', whereArgs: [id]);
    await db.delete(tableShoppingItem,
        where: '$itemColumnListId = ?', whereArgs: [id]);

    return deletedId;
  }

  Future<int> updateShoppingList(ShoppingListHelper shoppinglist) async {
    return await db.update(tableShoppingList, shoppinglist.toMap(),
        where: '$listColumnId = ?', whereArgs: [shoppinglist.id]);
  }

  Future<ShoppingItemHelper> insertShoppingItem(
      ShoppingItemHelper shoppingitem) async {
    shoppingitem.id = await db.insert(tableShoppingItem, shoppingitem.toMap());
    return shoppingitem;
  }

  Future<ShoppingItemHelper?> getShoppingItem(int id) async {
    List<Map> maps = await db.query(tableShoppingItem,
        columns: [
          itemColumnId,
          itemColumnTitle,
          itemColumnQuantity,
          itemColumnUnit,
          itemColumnPrice,
          itemColumnDone
        ],
        where: '$itemColumnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return ShoppingItemHelper.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ShoppingItemHelper>> getShoppingItems(int? listid) async {
    List<Map> items = await db.query(tableShoppingItem,
        columns: [
          itemColumnId,
          itemColumnTitle,
          itemColumnQuantity,
          itemColumnUnit,
          itemColumnPrice,
          itemColumnDone
        ],
        where: '$itemColumnListId = ?',
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
    return await db
        .delete(tableShoppingItem, where: '$itemColumnId = ?', whereArgs: [id]);
  }

  Future<int> updateShoppingItem(ShoppingItemHelper shoppingItem) async {
    return await db.update(tableShoppingItem, shoppingItem.toMap(),
        where: '$itemColumnId = ?', whereArgs: [shoppingItem.id]);
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
