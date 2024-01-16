import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_sqlite_app/utils/sql_helper.dart';
//It allows also mocking sqflite during regular flutter unit test (i.e. not using the emulator/simulator).
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('open database', () async {
    // initialize the default factory.
    databaseFactory = databaseFactoryFfi;
    final shoppingProvider = ShoppingProvider();
    final path = await shoppingProvider.initDeleteDb('shopping.db');

    await shoppingProvider.open(path);
    await shoppingProvider.close();
  });

  test('insert/query/update/delete lists', () async {
    databaseFactory = databaseFactoryFfi;
    final shoppingProvider = ShoppingProvider();
    final path = await shoppingProvider.initDeleteDb('shopping.db');

    await shoppingProvider.open(path);

    var list = ShoppingListHelper(title: 'home');
    await shoppingProvider.insertShoppingList(list);
    expect(list.id, 1);

    expect(await shoppingProvider.getShoppingList(0), null);
    list = (await shoppingProvider.getShoppingList(1))!;
    expect(list.id, 1);
    expect(list.title, 'home');

    expect(await shoppingProvider.updateShoppingList(list), 1);
    list = (await shoppingProvider.getShoppingList(1))!;
    expect(list.id, 1);
    expect(list.title, 'home');

    expect(await shoppingProvider.deleteShoppingList(0), 0);
    expect(await shoppingProvider.deleteShoppingList(1), 1);
    expect(await shoppingProvider.getShoppingList(1), null);

    await shoppingProvider.close();
  });

  test('insert/query/update/delete items', () async {
    databaseFactory = databaseFactoryFfi;
    final shoppingProvider = ShoppingProvider();
    final path = await shoppingProvider.initDeleteDb('shopping.db');

    await shoppingProvider.open(path);

    var item = ShoppingItemHelper(
        title: 'bread',
        listid: 1,
        price: 0,
        done: false,
        unit: 'gms',
        quantity: 0);
    await shoppingProvider.insertShoppingItem(item);
    expect(item.id, 1);

    expect(await shoppingProvider.getShoppingItem(0), null);
    item = (await shoppingProvider.getShoppingItem(1))!;
    expect(item.id, 1);
    expect(item.title, 'bread');
    expect(item.done, false);

    item.done = true;
    expect(await shoppingProvider.updateShoppingItem(item), 1);
    item = (await shoppingProvider.getShoppingItem(1))!;
    expect(item.id, 1);
    expect(item.title, 'bread');
    expect(item.done, true);

    expect(await shoppingProvider.deleteShoppingItem(0), 0);
    expect(await shoppingProvider.deleteShoppingItem(1), 1);
    expect(await shoppingProvider.getShoppingItem(1), null);

    await shoppingProvider.close();
  });
}
