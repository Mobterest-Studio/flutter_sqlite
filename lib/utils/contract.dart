class ShoppingContract {
  // To prevent someone from accidentally instantiating the contract class,
  // make the constructor private.
  ShoppingContract._();

  static const String dbName = 'shopping.db';
  static const int databaseVersion = 2;

  static const String tableShoppingList = 'shoppinglist';
  static const String listColumnId = 'id';
  static const String listColumnTitle = 'title';
  static const String tableShoppingItem = 'shoppingitem';
  static const String itemColumnId = 'id';
  static const String itemColumnListId = 'listid';
  static const String itemColumnTitle = 'title';
  static const String itemColumnQuantity = 'quantity';
  static const String itemColumnUnit = 'unit';
  static const String itemColumnPrice = 'price';
  static const String itemColumnDone = 'done';
}
