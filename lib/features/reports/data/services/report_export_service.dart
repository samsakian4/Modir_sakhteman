import 'dart:typed_data';

import 'package:excel/excel.dart' as xls;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/services/file_share.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/monthly_report.dart';

/// Builds and shares a PDF or Excel export of a [MonthlyReport].
/// Kept outside the repository/usecase layers deliberately: this is pure
/// device-side rendering, not a data source — it does not touch Supabase.
abstract class ReportExportService {
  ReportExportService._();

  static Future<void> exportPdf(MonthlyReport report) async {
    final pw.Document doc = pw.Document();
    final ByteData fontData = await rootBundle.load('assets/fonts/Vazirmatn-Regular.ttf');
    final ByteData boldFontData = await rootBundle.load('assets/fonts/Vazirmatn-Bold.ttf');
    final pw.Font regularFont = pw.Font.ttf(fontData);
    final pw.Font boldFont = pw.Font.ttf(boldFontData);
    final String periodLabel = '${DateFormatter.jalaliMonthName(report.jalaliMonth)} ${CurrencyFormatter.toPersianDigits(report.jalaliYear.toString())}';

    doc.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('گزارش مالی ماهانه صندوق شارژ ساختمان', style: pw.TextStyle(font: boldFont, fontSize: 18)),
                pw.SizedBox(height: 4),
                pw.Text('دوره: $periodLabel', style: const pw.TextStyle(fontSize: 13)),
                pw.SizedBox(height: 16),
                _pdfSummaryTable(report, boldFont, regularFont),
                pw.SizedBox(height: 20),
                if (report.categoryBreakdown.isNotEmpty) ...[
                  pw.Text('ریز هزینه‌ها به تفکیک دسته‌بندی', style: pw.TextStyle(font: boldFont, fontSize: 14)),
                  pw.SizedBox(height: 8),
                  _pdfCategoryTable(report, boldFont, regularFont),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    final Uint8List bytes = await doc.save();
    final String fileName = 'report-${report.jalaliYear}-${report.jalaliMonth.toString().padLeft(2, '0')}.pdf';
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  static pw.Widget _pdfSummaryTable(MonthlyReport report, pw.Font bold, pw.Font regular) {
    final List<List<String>> rows = [
      ['مجموع شارژهای دریافتی', '${CurrencyFormatter.formatAmount(report.totalIncome)} تومان'],
      ['مجموع هزینه‌ها', '${CurrencyFormatter.formatAmount(report.totalExpenses)} تومان'],
      ['مانده خالص این ماه', '${CurrencyFormatter.formatAmount(report.netBalance)} تومان'],
      ['واحدهای پرداخت‌کرده', '${report.paidUnitsCount} از ${report.totalActiveApartments}'],
      ['واحدهای بدهکار', '${report.unpaidUnitsCount}'],
    ];
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(font: bold, fontSize: 11),
      cellStyle: pw.TextStyle(font: regular, fontSize: 11),
      cellAlignment: pw.Alignment.centerRight,
      headers: const ['شاخص', 'مقدار'],
      data: rows,
    );
  }

  static pw.Widget _pdfCategoryTable(MonthlyReport report, pw.Font bold, pw.Font regular) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(font: bold, fontSize: 11),
      cellStyle: pw.TextStyle(font: regular, fontSize: 11),
      cellAlignment: pw.Alignment.centerRight,
      headers: const ['دسته‌بندی', 'مبلغ (تومان)'],
      data: [for (final CategoryBreakdown item in report.categoryBreakdown) [item.category.label, CurrencyFormatter.formatAmount(item.amount)]],
    );
  }

  static Future<void> exportExcel(MonthlyReport report) async {
    final xls.Excel excel = xls.Excel.createExcel();
    final String sheetName = 'گزارش ماهانه';
    final xls.Sheet sheet = excel[sheetName];
    excel.delete('Sheet1');

    sheet.appendRow([xls.TextCellValue('شاخص'), xls.TextCellValue('مقدار')]);
    sheet.appendRow([xls.TextCellValue('سال شمسی'), xls.IntCellValue(report.jalaliYear)]);
    sheet.appendRow([xls.TextCellValue('ماه شمسی'), xls.TextCellValue(DateFormatter.jalaliMonthName(report.jalaliMonth))]);
    sheet.appendRow([xls.TextCellValue('مجموع شارژهای دریافتی (تومان)'), xls.DoubleCellValue(report.totalIncome)]);
    sheet.appendRow([xls.TextCellValue('مجموع هزینه‌ها (تومان)'), xls.DoubleCellValue(report.totalExpenses)]);
    sheet.appendRow([xls.TextCellValue('مانده خالص این ماه (تومان)'), xls.DoubleCellValue(report.netBalance)]);
    sheet.appendRow([xls.TextCellValue('واحدهای پرداخت‌کرده'), xls.IntCellValue(report.paidUnitsCount)]);
    sheet.appendRow([xls.TextCellValue('واحدهای بدهکار'), xls.IntCellValue(report.unpaidUnitsCount)]);
    sheet.appendRow([]);
    sheet.appendRow([xls.TextCellValue('دسته‌بندی هزینه'), xls.TextCellValue('مبلغ (تومان)')]);
    for (final CategoryBreakdown item in report.categoryBreakdown) {
      sheet.appendRow([xls.TextCellValue(item.category.label), xls.DoubleCellValue(item.amount)]);
    }

    final List<int>? bytes = excel.encode();
    if (bytes == null) return;

    final String fileName = 'report-${report.jalaliYear}-${report.jalaliMonth.toString().padLeft(2, '0')}.xlsx';
    await deliverFile(bytes: Uint8List.fromList(bytes), fileName: fileName, mimeType: mimeTypeFor(fileName));
  }
}
