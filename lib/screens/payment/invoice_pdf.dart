import 'dart:io';

import 'package:epos_application/components/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateInvoicePdf(
    {required BuildContext context,
    required ProcessedOrder order,
    required String currency}) async {
  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final pdf = pw.Document();

  // Load a font from the assets
  final fontData = await rootBundle.load('assets/fonts/OpenSans-Regular.ttf');
  final ttf = pw.Font.ttf(fontData);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('INVOICE', style: pw.TextStyle(fontSize: 40, font: ttf)),
            pw.SizedBox(height: 20),
            pw.Text('Date: ${DateTime.now().toString()}',
                style: pw.TextStyle(fontSize: 20, font: ttf)),
            pw.SizedBox(height: 20),
            pw.Text('Bill To:', style: pw.TextStyle(fontSize: 20, font: ttf)),
            pw.Text(order.billedTo ?? "Guest",
                style: pw.TextStyle(fontSize: 18, font: ttf)),
            pw.SizedBox(height: 20),
            pw.Text('Items:', style: pw.TextStyle(fontSize: 20, font: ttf)),
            pw.TableHelper.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>['Description', 'Price'],
                <String>[order.items, '$currency${order.price}'],
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
              },
            ),
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Sub Total: $currency${order.price}',
                  style: pw.TextStyle(fontSize: 22, font: ttf)),
            ),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                  'Discount: $currency${order.price - order.adjustedPrice}',
                  style: pw.TextStyle(fontSize: 22, font: ttf)),
            ),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Total: $currency${order.adjustedPrice}',
                  style: pw.TextStyle(fontSize: 22, font: ttf)),
            ),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                  '(Inclusive 20% VAT @$currency${order.adjustedPrice * 0.2})',
                  style: pw.TextStyle(fontSize: 18, font: ttf)),
            ),
          ],
        );
      },
    ),
  );

  // Save the PDF document
  final output = await getTemporaryDirectory();
  final file = File("${output.path}/example.pdf");
  await file.writeAsBytes(await pdf.save());

  // Optionally, print the PDF
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );

  // Lock orientation to landscape when done
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}
