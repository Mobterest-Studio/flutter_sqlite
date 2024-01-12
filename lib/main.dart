import 'package:flutter/material.dart';
import 'package:flutter_lorem/flutter_lorem.dart';

void main() {
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
        "/": (context) => const ShoppingList(),
        "/item": (context) => const ShoppingItem()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {},
                  child: const Text("Create new list")),
            ),
            Column(children: buildWidgets())
          ],
        ),
      )),
    );
  }

  List<Widget> buildWidgets() {
    List<Widget> list = [];

    for (int i = 0; i < 10; i++) {
      list.add(Card(
        child: ListTile(
          title: const Text("Barbecue"),
          subtitle: const Text("9 items"),
          trailing: const Icon(Icons.more_vert),
          onTap: () {
            Navigator.pushNamed(context, "/item");
          },
        ),
      ));
    }

    return list;
  }
}

class ShoppingItem extends StatefulWidget {
  const ShoppingItem({super.key});

  @override
  State<ShoppingItem> createState() => _ShoppingItemState();
}

class _ShoppingItemState extends State<ShoppingItem> {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Anna birthday",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("Items (17)"),
                RichText(
                  text: const TextSpan(
                    text: 'Total: ',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: ' \$',
                      ),
                      TextSpan(
                          text: '115',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ]),
              TextField(
                controller: itemController,
                decoration: const InputDecoration(hintText: "Add item"),
              ),
              Column(
                children: buildWidgets(),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildWidgets() {
    List<Widget> items = [];
    for (int i = 0; i < 10; i++) {
      items.add(Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10.0)),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'Chocolate ',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' | ',
                        ),
                        TextSpan(
                          text: '200',
                        ),
                        TextSpan(text: ' g'),
                      ],
                    ),
                  ),
                  const Text("\$2",
                      style: TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.check)),
              IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Chocolate"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: priceController,
                                decoration: const InputDecoration(
                                    hintText: "Enter Price"),
                              ),
                              TextField(
                                controller: quantityController,
                                decoration: const InputDecoration(
                                    hintText: "Enter Quantity"),
                              ),
                              TextField(
                                controller: sizeController,
                                decoration: const InputDecoration(
                                    hintText: "Enter Size"),
                              ),
                            ],
                          ),
                          actions: [
                            OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancel")),
                            ElevatedButton(
                                onPressed: () {}, child: const Text("Save"))
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.more_vert))
            ],
          ),
        ),
      ));
    }

    return items;
  }
}
