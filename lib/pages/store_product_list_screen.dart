import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'store_add_product_screen.dart';

class StoreProductListScreen extends StatefulWidget {
  final String? storeId;

  const StoreProductListScreen({Key? key, this.storeId}) : super(key: key);

  @override
  State<StoreProductListScreen> createState() => _StoreProductListScreenState();
}

class _StoreProductListScreenState extends State<StoreProductListScreen> {
  String? storeId;

  @override
  void initState() {
    super.initState();
    if (widget.storeId != null) {
      storeId = widget.storeId;
    } else {
      _getStoreIdForCurrentUser();
    }
  }

  Future<void> _getStoreIdForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('stores')
          .where('ownerId', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          storeId = querySnapshot.docs.first.id;
        });
      }
    }
  }

  void _showEditDialog(BuildContext context, String productId, Map<String, dynamic> data) {
    final TextEditingController nameController = TextEditingController(text: data['name']);
    final TextEditingController descriptionController = TextEditingController(text: data['description'] ?? '');
    final TextEditingController priceController = TextEditingController(text: data['price'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürünü Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Ürün Adı'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Açıklama'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Fiyat'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('stores')
                  .doc(storeId)
                  .collection('products')
                  .doc(productId)
                  .update({
                'name': nameController.text,
                'description': descriptionController.text,
                'price': double.tryParse(priceController.text) ?? 0,
              });

              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (storeId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürünlerim'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stores')
            .doc(storeId)
            .collection('products')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Henüz ürün eklenmedi.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final data = product.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(data['name'] ?? 'Ürün Adı'),
                  subtitle: Text(data['description'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          _showEditDialog(context, product.id, data);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Silme Onayı'),
                              content: const Text('Bu ürünü silmek istediğinize emin misiniz?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('İptal'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Sil'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await FirebaseFirestore.instance
                                .collection('stores')
                                .doc(storeId)
                                .collection('products')
                                .doc(product.id)
                                .delete();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StoreAddProductScreen(),
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}





