import 'dart:io';

import 'package:epos_application/components/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<String> generateInvoicePdf({
  required BuildContext context,
  required ProcessedOrder order,
  required String currency,
  required List<OrderItem> priceList,
  required String logoUrl,
}) async {
  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final pdf = pw.Document();

  // Load a font from the assets
  final fontData = await rootBundle.load('assets/fonts/OpenSans-Regular.ttf');
  final ttf = pw.Font.ttf(fontData);

  // Fetch the logo image
  final logoImage = await _fetchImage(logoUrl);

  print("Length of priceList = ${priceList.length}");

  // Parse the items string into a list of rows
  List<List<String>> itemRows = _parseItems(order.items, currency, priceList);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Stack(
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('INVOICE',
                    style: pw.TextStyle(fontSize: 40, font: ttf)),
                pw.SizedBox(height: 20),
                pw.Text('Date: ${DateTime.now().toString()}',
                    style: pw.TextStyle(fontSize: 20, font: ttf)),
                pw.SizedBox(height: 20),
                pw.Text('Bill To:',
                    style: pw.TextStyle(fontSize: 20, font: ttf)),
                pw.Text(order.billedTo ?? "Guest",
                    style: pw.TextStyle(fontSize: 18, font: ttf)),
                pw.SizedBox(height: 20),
                pw.Text('Items:', style: pw.TextStyle(fontSize: 20, font: ttf)),
                pw.TableHelper.fromTextArray(
                  context: context,
                  data: <List<String>>[
                    <String>['Description', 'Quantity', 'Subtotal'],
                    ...itemRows, // Dynamic item rows
                  ],
                  headerStyle: pw.TextStyle(
                      fontSize: 20, font: ttf, fontWeight: pw.FontWeight.bold),
                  cellStyle: pw.TextStyle(fontSize: 18, font: ttf),
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.grey300),
                  cellHeight: 30,
                  columnWidths: const {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(1),
                    2: pw.FlexColumnWidth(1),
                  },
                ),
                pw.SizedBox(height: 20),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                      'Sub Total: $currency${order.price.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 22, font: ttf)),
                ),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                      'Discount: $currency${(order.price - order.adjustedPrice).toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 22, font: ttf)),
                ),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                      'Total: $currency${order.adjustedPrice.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 22, font: ttf)),
                ),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                      '(Inclusive 20% VAT @$currency${(order.adjustedPrice * 0.2).toStringAsFixed(2)})',
                      style: pw.TextStyle(fontSize: 18, font: ttf)),
                ),
              ],
            ),
            if (logoImage != null)
              pw.Positioned(
                right: 0,
                top: 0,
                child: pw.Image(
                  pw.MemoryImage(logoImage),
                  width: 100,
                  height: 100,
                ),
              ),
          ],
        );
      },
    ),
  );

  // Save the PDF document
  final output = await getTemporaryDirectory();
  final filePath = "${output.path}/invoice_${order.id}.pdf";
  final file = File(filePath);
  await file.writeAsBytes(await pdf.save());

  // // Optionally, print the PDF
  // await Printing.layoutPdf(
  //   onLayout: (PdfPageFormat format) async => pdf.save(),
  // );

  // Lock orientation to landscape when done
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  return filePath;
}

// Function to fetch an image from a URL
Future<Uint8List?> _fetchImage(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      print("Failed to load image from URL: $url");
      return null;
    }
  } catch (e) {
    print("Error fetching image: $e");
    return null;
  }
}

// Function to parse the items string into rows for the table
List<List<String>> _parseItems(
    String itemsString, String currency, List<OrderItem> priceList) {
  // Split the items by commas and trim whitespace
  final itemsList = itemsString.split(',').map((e) => e.trim()).toList();

  // Create rows for the table
  List<List<String>> rows = itemsList.map((item) {
    final parts = item.split(' x');
    if (parts.length == 2) {
      final name = parts[0];
      final quantity = int.tryParse(parts[1]) ?? 0;
      // Find the item in the priceList to get its price
      final orderItem = priceList.firstWhere(
        (p) => p.name == name,
        orElse: () => OrderItem(name: name, price: 0, quantity: 0),
      );
      final subtotal = orderItem.price * quantity;
      return [name, 'x$quantity', '$currency${subtotal.toStringAsFixed(2)}'];
    }
    return [item, '', '']; // Default case if format is not as expected
  }).toList();

  return rows;
}
