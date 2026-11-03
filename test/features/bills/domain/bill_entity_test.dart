import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';

void main() {
  group('BillEntity Tests', () {
    test('should properly calculate isPaid status', () {
      const paidBill = BillEntity(
        id: 'bill_1',
        billNumber: 'WUA/001',
        status: BillStatus.paid,
        totalAmount: 1240,
        paidAmount: 1240,
        outstandingAmount: 0,
      );

      const unpaidBill = BillEntity(
        id: 'bill_2',
        billNumber: 'WUA/002',
        status: BillStatus.pending,
        totalAmount: 1240,
        paidAmount: 0,
        outstandingAmount: 1240,
      );

      expect(paidBill.isPaid, isTrue);
      expect(paidBill.isPayable, isFalse);
      expect(unpaidBill.isPaid, isFalse);
      expect(unpaidBill.isPayable, isTrue);
    });

    test('should identify overdue status correctly based on date', () {
      final pastDueDate = DateTime.now().subtract(const Duration(days: 5));
      final futureDueDate = DateTime.now().add(const Duration(days: 15));

      final overdueBill = BillEntity(
        id: 'bill_overdue',
        billNumber: 'WUA/OD/01',
        status: BillStatus.pending,
        dueDate: pastDueDate,
        totalAmount: 500,
        outstandingAmount: 500,
      );

      final pendingBill = BillEntity(
        id: 'bill_pending',
        billNumber: 'WUA/P/01',
        status: BillStatus.pending,
        dueDate: futureDueDate,
        totalAmount: 500,
        outstandingAmount: 500,
      );

      expect(overdueBill.isOverdue, isTrue);
      expect(pendingBill.isOverdue, isFalse);
    });

    test('should format BillStatus labels correctly', () {
      expect(BillStatus.toLabel('PAID'), equals('Paid'));
      expect(BillStatus.toLabel('PENDING'), equals('Due / Pending'));
      expect(BillStatus.toLabel('OVERDUE'), equals('Overdue'));
      expect(BillStatus.toLabel('PARTIALLY_PAID'), equals('Partially Paid'));
      expect(BillStatus.toLabel('APPROVED'), equals('Approved'));
    });
  });
}
