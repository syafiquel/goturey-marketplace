
import 'dart:io';
import 'package:goturey_marketplace/models/firestore_order.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  static Future<File> generate(FirestoreOrder order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Transaction Statement', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Order ID: ${order.orderId}'),
              pw.Text('Order Date: ${order.orderDate.toDate()}'),
              pw.Text('Total Amount: ${order.currency} ${order.totalAmount.toStringAsFixed(2)}'),
              pw.SizedBox(height: 20),
              pw.Text('Products:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.ListView.builder(
                itemCount: order.products.length,
                itemBuilder: (context, index) {
                  final product = order.products[index];
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('${product['prodName'] ?? ''} (x${product['prodQuantity'] ?? 0})'),
                      pw.Text('${order.currency} ${(product['prodPrice'] ?? 0).toStringAsFixed(2)}'),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/transaction_${order.orderId}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
