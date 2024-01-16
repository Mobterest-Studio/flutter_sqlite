import 'package:flutter/material.dart';

import 'main.dart';
import 'utils/sql_helper.dart';

class SList extends StatefulWidget {
  const SList({super.key});

  @override
  State<SList> createState() => _ShoppingItemState();

  static const routeName = "/shoppinglist";
}

class _ShoppingItemState extends State<SList> {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as SListArguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          args.list.title ?? "",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: const Text("Delete list"),
              onPressed: () {
                shoppingProvider!.deleteShoppingList(args.list.id!);
                Navigator.pop(context); //DOES NOT REFRESH
              },
            ),
          )
        ],
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FutureBuilder<List<ShoppingItemHelper>>(
              future: shoppingProvider!.getShoppingItems(args.list.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                } else {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Items (${snapshot.data!.length})"),
                              RichText(
                                text: TextSpan(
                                  text: 'Total: ',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  children: <TextSpan>[
                                    const TextSpan(
                                      text: ' \$',
                                    ),
                                    TextSpan(
                                        text: getSum(snapshot.data!).toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ]),
                        TextField(
                          controller: itemController,
                          decoration:
                              const InputDecoration(hintText: "Add item"),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              shoppingProvider!
                                  .insertShoppingItem(ShoppingItemHelper(
                                title: value,
                                listid: args.list.id,
                                quantity: 0,
                                unit: '',
                                price: 0,
                                done: false,
                              ));
                              setState(() {
                                itemController.clear();
                              });
                            }
                          },
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: snapshot.data![index].title,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black),
                                            children: <TextSpan>[
                                              const TextSpan(
                                                text: ' | ',
                                              ),
                                              TextSpan(
                                                text: snapshot
                                                    .data![index].quantity
                                                    .toString(),
                                              ),
                                              TextSpan(
                                                  text:
                                                      ' ${snapshot.data![index].unit}'),
                                            ],
                                          ),
                                        ),
                                        Text("\$${snapshot.data![index].price}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))
                                      ],
                                    ),
                                    const Spacer(),
                                    IconButton(
                                        onPressed: () async {
                                          snapshot.data![index].done =
                                              !(snapshot.data![index].done!);
                                          snapshot.data![index].listid =
                                              args.list.id;
                                          await shoppingProvider
                                              ?.updateShoppingItem(
                                                  snapshot.data![index]);
                                          setState(() {});
                                        },
                                        icon: Icon(
                                          Icons.check,
                                          color: (snapshot.data![index].done !=
                                                      null &&
                                                  snapshot.data![index].done ==
                                                      false)
                                              ? Colors.black
                                              : (snapshot.data![index].done !=
                                                          null &&
                                                      snapshot.data![index]
                                                              .done ==
                                                          true)
                                                  ? Colors.red
                                                  : Colors.black,
                                          weight: 5,
                                          fill: 0.9,
                                        )),
                                    IconButton(
                                        onPressed: () {
                                          if (snapshot.data![index].done !=
                                                  null &&
                                              snapshot.data![index].done ==
                                                  false) {
                                            priceController.text = snapshot
                                                .data![index].price
                                                .toString();
                                            quantityController.text = snapshot
                                                .data![index].quantity
                                                .toString();
                                            unitController.text = snapshot
                                                .data![index].unit
                                                .toString();
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(snapshot
                                                          .data![index].title ??
                                                      ""),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      TextField(
                                                        controller:
                                                            priceController,
                                                        decoration:
                                                            const InputDecoration(
                                                                hintText:
                                                                    "Enter Price"),
                                                      ),
                                                      TextField(
                                                        controller:
                                                            quantityController,
                                                        decoration:
                                                            const InputDecoration(
                                                                hintText:
                                                                    "Enter Quantity"),
                                                      ),
                                                      TextField(
                                                        controller:
                                                            unitController,
                                                        decoration:
                                                            const InputDecoration(
                                                                hintText:
                                                                    "Enter Unit"),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    OutlinedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            "Cancel")),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          snapshot.data![index]
                                                                  .quantity =
                                                              double.parse(
                                                                  quantityController
                                                                      .text);
                                                          snapshot.data![index]
                                                                  .unit =
                                                              unitController
                                                                  .text;
                                                          snapshot.data![index]
                                                                  .price =
                                                              double.parse(
                                                                  priceController
                                                                      .text);
                                                          snapshot.data![index]
                                                                  .listid =
                                                              args.list.id;
                                                          snapshot.data![index]
                                                              .done = (snapshot
                                                                  .data![index]
                                                                  .done ??
                                                              false);
                                                          shoppingProvider
                                                              ?.updateShoppingItem(
                                                                  snapshot.data![
                                                                      index]);
                                                          priceController
                                                              .clear();
                                                          quantityController
                                                              .clear();
                                                          unitController
                                                              .clear();
                                                          Navigator.pop(
                                                              context);
                                                          setState(() {});
                                                        },
                                                        child:
                                                            const Text("Save"))
                                                  ],
                                                );
                                              },
                                            );
                                          } else {
                                            shoppingProvider!
                                                .deleteShoppingItem(
                                                    snapshot.data![index].id!);
                                            setState(() {});
                                          }
                                        },
                                        icon: Icon((snapshot
                                                        .data![index].done !=
                                                    null &&
                                                snapshot.data![index].done ==
                                                    false)
                                            ? Icons.more_vert
                                            : (snapshot.data![index].done !=
                                                        null &&
                                                    snapshot.data![index]
                                                            .done ==
                                                        true)
                                                ? Icons.delete_forever
                                                : Icons.more_vert))
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      ]);
                }
              },
            )),
      ),
    );
  }

  getSum(List<ShoppingItemHelper> items) {
    double sum = 0;
    for (ShoppingItemHelper item in items) {
      sum += item.price ?? 0;
    }
    return sum;
  }
}

class SListArguments {
  ShoppingListHelper list;
  SListArguments({required this.list});
}
