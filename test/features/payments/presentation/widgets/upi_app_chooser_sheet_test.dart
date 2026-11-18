import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/app_theme.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/checkout/upi_app_chooser_sheet.dart';

void main() {
  const tBill = BillEntity(
    id: 'bill_rabi_01',
    billNumber: 'WUA/PANI/2024/001',
    status: BillStatus.pending,
    totalAmount: 1240.0,
    outstandingAmount: 1240.0,
    consumerName: 'Ramesh Patil',
    wuaSocietyName: 'Ganga-Godavari WUA #12',
    season: 'Rabi Season (2024-25)',
    cropType: 'Wheat',
  );

  Widget buildTestWidget() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                UpiAppChooserSheet.show(context, bill: tBill);
              },
              child: const Text('Open Sheet'),
            );
          },
        ),
      ),
    );
  }

  group('UpiAppChooserSheet Tests', () {
    testWidgets('renders installed UPI apps and bill information', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Pay via UPI App'), findsOneWidget);
      expect(find.text('Rabi Season (2024-25)'), findsOneWidget);
      expect(find.text('₹ 1,240'), findsOneWidget);

      expect(find.text('Google Pay'), findsOneWidget);
      expect(find.text('PhonePe'), findsOneWidget);
      expect(find.text('Paytm UPI'), findsOneWidget);
      expect(find.text('BHIM Govt UPI'), findsOneWidget);
      expect(find.text('CRED UPI'), findsOneWidget);

      expect(
        find.text('Pay via Net Banking / Debit Card Gateway'),
        findsOneWidget,
      );
    });
  });
}
