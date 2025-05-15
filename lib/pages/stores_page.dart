import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'store_product_view_screen.dart';

class StoresPage extends StatelessWidget {
  const StoresPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mağazalar'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('stores').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Henüz mağaza eklenmedi.'));
          }

          final stores = snapshot.data!.docs;

          return ListView.builder(
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              final name = store['name'] ?? 'Mağaza Adı';
              final description = store['description'] ?? 'Açıklama yok';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(name),
                  subtitle: Text(description),
                  trailing: const Icon(Icons.store),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoreProductViewScreen(storeId: store.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

