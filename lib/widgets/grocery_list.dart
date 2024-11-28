import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_items.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  late Future<List<GroceryItem>> _loadedItems;

  String? _error;

  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
        'flutterdemoproject-91752-default-rtdb.firebaseio.com',
        'shopping-list.json');
    final response = await http.get(url);
    if (response.statusCode >= 400) {
      // setState(() {
      //   _error = 'Failed to fetch data.Please try after sometime...';
      // });
      throw Exception('Failed to fetch Grocery items. Please try again later.');
    }

    if (response.body == 'null') {
      // setState(() {
      //   _isLoading = false;
      // });
      return [];
    }

    final listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere((element) => element.value.name == item.value['category'])
          .value;
      loadedItems.add(GroceryItem(
        id: item.key,
        name: item.value['name'],
        quantity: int.parse(item.value['quantity']),
        category: category,
      ));
      // if (kDebugMode) {
      //   print(item.value);
      // }
    }
    return loadedItems;
    // setState(() {
    //   _groceryItems = loadedItems;
    //   _isLoading = false;
    // });
    // } catch (error) {
    //   setState(() {
    //     _error = 'something went wrong! Please try again.';
    //   });
    // }
  }

  // void _loadItems() async {
  //   final url = Uri.https(
  //       'flutterdemoproject-91752-default-rtdb.firebaseio.com',
  //       'shopping-list.json');
  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode >= 400) {
  //       setState(() {
  //         _error = 'Failed to fetch data.Please try after sometime...';
  //       });
  //     }

  //     if (response.body == 'null') {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       return;
  //     }

  //     final listData = json.decode(response.body);
  //     final List<GroceryItem> loadedItems = [];
  //     for (final item in listData.entries) {
  //       final category = categories.entries
  //           .firstWhere(
  //               (element) => element.value.name == item.value['category'])
  //           .value;
  //       loadedItems.add(GroceryItem(
  //         id: item.key,
  //         name: item.value['name'],
  //         quantity: int.parse(item.value['quantity']),
  //         category: category,
  //       ));
  //       // if (kDebugMode) {
  //       //   print(item.value);
  //       // }
  //     }
  //     setState(() {
  //       _groceryItems = loadedItems;
  //       _isLoading = false;
  //     });
  //   } catch (error) {
  //     setState(() {
  //       _error = 'something went wrong! Please try again.';
  //     });
  //   }
  // }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItemScreen(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      // _groceryItems.add(newItem);
      _groceryItems.add(newItem);
    });
// setState(() {
//   _groceryItems =
// });
    // _loadItems();
  }

  void _removeItem(GroceryItem item) async {
    final itemIndex = groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
        'flutterdemoproject-91752-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
//if delete operation failed at the server then we will have to revert the changes in the local data.
      setState(() {
        _groceryItems.insert(itemIndex, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Widget body;
    // if (_groceryItems.isEmpty) {
    //   body = const Center(
    //       child: Text(
    //     'No item added',
    //     textAlign: TextAlign.center,
    //   ));
    // } else {
    //   body = ListView.builder(
    //     itemCount: _groceryItems.length,
    //     itemBuilder: (context, index) => Dismissible(
    //       key: ValueKey(_groceryItems[index]),
    //       onDismissed: (direction) {
    //         _removeItem(_groceryItems[index]);
    //       },
    //       child: ListTile(
    //         title: Text(_groceryItems[index].name),
    //         leading: Container(
    //           width: 24,
    //           height: 24,
    //           color: _groceryItems[index].category.color,
    //         ),
    //         trailing: Text(_groceryItems[index].quantity.toString()),
    //       ),
    //     ),
    //   );
    // }

    // if (_isLoading) {
    //   body = const Center(child: CircularProgressIndicator());
    // }

    // if (_error != null) {
    //   body = Center(
    //       child: Text(
    //     _error!,
    //     textAlign: TextAlign.center,
    //   ));
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Grocery'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      // body: body,
      //FutureBuilder is not ideal for this app as while we use FutureBuilder we are not able to update the UI by calling build().
      //so we cann't use add and delete functionality of this app if we use FutureBuilder. 
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error!.toString()),
            );
          }

          if(snapshot.data!.isEmpty){
            return const Center(
              child: Text('No item found.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => Dismissible(
              key: ValueKey(snapshot.data![index]),
              onDismissed: (direction) {
                _removeItem(snapshot.data![index]);
              },
              child: ListTile(
                title: Text(snapshot.data![index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: snapshot.data![index].category.color,
                ),
                trailing: Text(snapshot.data![index].quantity.toString()),
              ),
            ),
          );
        },
      ),
    );
  }
}
