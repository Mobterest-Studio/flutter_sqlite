import 'package:flutter/material.dart';
import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:shopping_sqlite_app/utils/sql_helper.dart';
import 'main.dart';
import 'shopping_list.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController nameController = TextEditingController();
  List<ShoppingListHelper> shoppinglists = [];

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      // shoppinglists = switch (ref.watch(shoppingListProvider)) {
      //   AsyncData(:final value) => value,
      //   AsyncError() => [],
      //   _ => []
      // };
    });

    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Shopping",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "list",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
              child: Text(lorem(paragraphs: 1, words: 10)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(MediaQuery.of(context).size.width, 50)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("New List"),
                          content: TextField(controller: nameController),
                          actions: [
                            OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancel")),
                            ElevatedButton(
                                onPressed: () {
                                  if (nameController.text.isNotEmpty) {
                                    createNewShoppingList(nameController.text);
                                  }
                                  setState(() {});
                                  nameController.clear();
                                  Navigator.pop(context);
                                },
                                child: const Text("Save")),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text("Create new list")),
            ),
            FutureBuilder<List<ShoppingListHelper>>(
              future: shoppingProvider?.getShoppingLists(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(snapshot.data![index].title ?? ""),
                          subtitle: const Text("9 items"),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            Navigator.pushNamed(context, SList.routeName,
                                arguments: SListArguments(
                                    list: snapshot.data![index]));
                          },
                        ),
                      );
                    },
                  );
                }
              },
            )
          ],
        ),
      )),
    );
  }

  createNewShoppingList(String title) {
    shoppingProvider?.insertShoppingList(ShoppingListHelper(title: title));
  }
}
