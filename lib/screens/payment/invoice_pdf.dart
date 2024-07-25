import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateInvoicePdf() async {
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
            pw.Text('John Doe', style: pw.TextStyle(fontSize: 18, font: ttf)),
            pw.Text('1234 Main St',
                style: pw.TextStyle(fontSize: 18, font: ttf)),
            pw.Text('Anytown, USA',
                style: pw.TextStyle(fontSize: 18, font: ttf)),
            pw.SizedBox(height: 20),
            pw.Text('Items:', style: pw.TextStyle(fontSize: 20, font: ttf)),
            pw.Table.fromTextArray(
              data: <List<String>>[
                <String>['Description', 'Quantity', 'Price', 'Total'],
                <String>['Item 1', '2', '\$30', '\$60'],
                <String>['Item 2', '1', '\$50', '\$50'],
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
                3: pw.FlexColumnWidth(1),
              },
            ),
            pw.SizedBox(height: 20),
            pw.Text('Total: \$110',
                style: pw.TextStyle(fontSize: 20, font: ttf)),
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
}
