import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'log out pages.dart';

class AdminMenuPage extends StatelessWidget {
  const AdminMenuPage({super.key});

  CollectionReference get menuRef =>
      FirebaseFirestore.instance.collection('menu');

  // حذف منتج
  void deleteItem(String id) {
    menuRef.doc(id).delete();
  }

  // إضافة أو تعديل منتج
  void openAddEditDialog(BuildContext context,
      {DocumentSnapshot? doc}) {
    final nameController =
    TextEditingController(text: doc?['name'] ?? "");
    final priceController =
    TextEditingController(text: doc?['price']?.toString() ?? "");
    final groupController =
    TextEditingController(text: doc?['group'] ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(doc == null ? "إضافة منتج" : "تعديل منتج"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "اسم المنتج"),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "السعر"),
              ),
              TextField(
                controller: groupController,
                decoration: const InputDecoration(labelText: "القسم"),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final data = {
                "name": nameController.text,
                "price": double.parse(priceController.text),
                "group": groupController.text,
                "image": "images/na7ya.webp",
                "active": true,
              };

              if (doc == null) {
                await menuRef.add(data);
              } else {
                await menuRef.doc(doc.id).update(data);
              }

              Navigator.pop(context);
            },
            child: const Text("حفظ"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: const Text("إدارة المنيو", style: TextStyle(color: Colors.white),)),
        backgroundColor: Colors.green,
        actions: [LogoutButton()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: menuRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("لا يوجد منتجات"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];

              return Card(
                color: Colors.white.withOpacity(0.0),
                margin:
                const EdgeInsets.symmetric(horizontal: 20, vertical:10),
                child: ListTile(
                  title: Text(doc['name']),
                  subtitle: Column(
                    children: [
                      Text("السعر: ${doc['price']}"),
                      Text(" القسم: ${doc['group']}")
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            openAddEditDialog(context, doc: doc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteItem(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 60,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, "/admin");
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long),
                SizedBox(width: 8),
                Text("طلبات"),
              ],
            ),
          ),
        ),
      ),

    );
  }
}
