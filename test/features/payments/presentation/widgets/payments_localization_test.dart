import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/app_theme.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/bills/presentation/widgets/bill_card.dart';
import 'package:wua_mobile/features/bills/presentation/widgets/bill_receipt_sheet.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/payment_card.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/payments_summary_card.dart';

void main() {
  Widget wrapWithLocale(Locale locale, Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  final successPayment = PaymentEntity(
    id: 'pay-1',
    paymentNumber: 'REC-001',
    status: PaymentStatus.success,
    amount: 1250,
    paymentDate: DateTime(2026, 8, 14, 10, 30),
    billNumber: 'BILL-001',
    season: 'Kharif 2026',
  );

  final failedPayment = PaymentEntity(
    id: 'pay-2',
    paymentNumber: 'REC-002',
    status: PaymentStatus.failed,
    amount: 900,
    paymentDate: DateTime(2026, 8, 10, 14, 15),
    billNumber: 'BILL-002',
    season: 'Rabi 2025',
  );

  final pendingPayment = PaymentEntity(
    id: 'pay-3',
    paymentNumber: 'REC-003',
    status: PaymentStatus.pending,
    amount: 750,
    paymentDate: DateTime(2026, 8, 12, 9, 0),
    billNumber: 'BILL-003',
    season: 'Summer 2026',
  );

  const unpaidBill = BillEntity(
    id: 'bill-1',
    billNumber: 'WUA-2026-01',
    status: BillStatus.pending,
    totalAmount: 1850,
    outstandingAmount: 1850,
    subtotal: 1500,
    taxes: 200,
    maintenanceCess: 150,
    waterQuantityLiters: 18500,
    landAreaAcres: 4.5,
  );

  const paidBill = BillEntity(
    id: 'bill-2',
    billNumber: 'WUA-2026-02',
    status: BillStatus.paid,
    totalAmount: 1200,
    paidAmount: 1200,
    subtotal: 1000,
    taxes: 120,
    maintenanceCess: 80,
    landAreaAcres: 3.0,
  );

  group('Payments, Bills & Receipt Localization', () {
    testWidgets('renders localized Marathi labels', (tester) async {
      await tester.pumpWidget(
        wrapWithLocale(
          const Locale('mr'),
          Column(
            children: [
              const PaymentsSummaryCard(
                totalAmountPaid: 1250,
                successCount: 1,
                pendingCount: 1,
                failedCount: 1,
              ),
              PaymentCard(payment: successPayment),
              PaymentCard(payment: failedPayment),
              PaymentCard(payment: pendingPayment),
              const BillCard(bill: unpaidBill),
              const BillCard(bill: paidBill),
              const BillReceiptSheet(bill: paidBill),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('एकूण भरलेली रक्कम'), findsOneWidget);
      expect(find.text('१ पूर्ण'), findsNothing);
      expect(find.text('1 पूर्ण'), findsOneWidget);
      expect(find.text('आता भरा'), findsOneWidget);
      expect(find.text('पावती'), findsNWidgets(2));
      expect(find.text('पुन्हा प्रयत्न करा'), findsOneWidget);
      expect(find.text('तपशील'), findsOneWidget);
      expect(find.text('जलसंपदा विभाग'), findsOneWidget);
      expect(find.text('पाणीपट्टी ई-पावती'), findsOneWidget);
      expect(find.text('PDF डाउनलोड करा'), findsOneWidget);
      expect(find.text('पावती शेअर करा'), findsOneWidget);
    });

    testWidgets('renders localized Hindi labels', (tester) async {
      await tester.pumpWidget(
        wrapWithLocale(
          const Locale('hi'),
          Column(
            children: [
              const PaymentsSummaryCard(
                totalAmountPaid: 1250,
                successCount: 2,
                pendingCount: 0,
                failedCount: 0,
              ),
              PaymentCard(payment: successPayment),
              const BillCard(bill: unpaidBill),
              const BillReceiptSheet(bill: paidBill),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('कुल निपटाए गए भुगतान'), findsOneWidget);
      expect(find.text('2 पूर्ण'), findsOneWidget);
      expect(find.text('अभी भुगतान करें'), findsOneWidget);
      expect(find.text('रसीद'), findsOneWidget);
      expect(find.text('जल संसाधन विभाग'), findsOneWidget);
      expect(find.text('पानी पट्टी ई-रसीद'), findsOneWidget);
      expect(find.text('PDF डाउनलोड करें'), findsOneWidget);
      expect(find.text('रसीद साझा करें'), findsOneWidget);
    });
  });
}

