import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoreProductViewScreen extends StatelessWidget {
  final String storeId; //

  const StoreProductViewScreen({Key? key, required this.storeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mağaza Ürünleri'),
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
            return const Center(child: Text("Bu mağazada henüz ürün bulunmuyor."));
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
                  trailing: Text('${data['price']} ₺'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
