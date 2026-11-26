import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/features/water_usage/data/models/water_usage_model.dart';
import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';

void main() {
  group('WaterUsageEntity tests', () {
    final tTurn = IrrigationTurnEntity(
      id: 'turn_1',
      turnNumber: 1,
      season: 'Rabi 2024-25',
      status: TurnStatus.upcoming,
      scheduledStartTime: DateTime(2026, 10, 31, 8, 0),
      scheduledEndTime: DateTime(2026, 10, 31, 20, 0),
      durationHours: 12.0,
      outletNo: 'Outlet 12',
      gateNo: 'Gate #4',
      dischargeCusecs: 50.0,
      waterDeliveredHaCm: 3.8,
      crop: 'Wheat',
      fieldParcel: 'Survey 42/1A',
    );

    test('TurnStatus properties should resolve correctly', () {
      expect(tTurn.isUpcoming, isTrue);
      expect(tTurn.isActive, isFalse);
      expect(tTurn.isCompleted, isFalse);
      expect(TurnStatus.toLabel(TurnStatus.active), contains('In Progress'));
      expect(TurnStatus.toLabel(TurnStatus.completed), contains('Completed'));
      expect(TurnStatus.toLabel(TurnStatus.upcoming), contains('Upcoming'));
    });

    test('formattedDate and formattedTimeRange format properly', () {
      expect(tTurn.formattedDate, equals('Saturday, 31 Oct 2026'));
      expect(
        tTurn.formattedTimeRange,
        contains('08:00 AM – 08:00 PM (12 Hours)'),
      );
    });

    test('WaterQuotaEntity calculated properties', () {
      const quota = WaterQuotaEntity(
        season: 'Rabi 2024-25',
        totalQuotaHaCm: 20.0,
        usedQuotaHaCm: 14.2,
        remainingQuotaHaCm: 5.8,
        percentageUsed: 71.0,
        canalName: 'Minor-3',
        canalStatus: 'Active',
        currentFlowCusecs: 125.0,
        outletNumber: 'Outlet 12',
        wuaSocietyName: 'Society',
        farmerName: 'Ramesh',
        totalTurnsCount: 5,
        completedTurnsCount: 3,
        cropBreakdown: [],
      );

      expect(quota.isNearLimit, isFalse);
      expect(quota.isLimitExceeded, isFalse);

      const nearLimitQuota = WaterQuotaEntity(
        season: 'Rabi 2024-25',
        totalQuotaHaCm: 20.0,
        usedQuotaHaCm: 18.0,
        remainingQuotaHaCm: 2.0,
        percentageUsed: 90.0,
        canalName: 'Minor-3',
        canalStatus: 'Active',
        currentFlowCusecs: 125.0,
        outletNumber: 'Outlet 12',
        wuaSocietyName: 'Society',
        farmerName: 'Ramesh',
        totalTurnsCount: 5,
        completedTurnsCount: 4,
        cropBreakdown: [],
      );

      expect(nearLimitQuota.isNearLimit, isTrue);
      expect(nearLimitQuota.isLimitExceeded, isFalse);
    });

    test('WaterUsage models use N/A and 0 defaults when API fields are missing', () {
      final quota = WaterQuotaModel.fromJson(const {});
      expect(quota.season, equals('N/A'));
      expect(quota.totalQuotaHaCm, equals(0.0));
      expect(quota.usedQuotaHaCm, equals(0.0));
      expect(quota.canalName, equals('N/A'));
      expect(quota.wuaSocietyName, equals('N/A'));
      expect(quota.farmerName, equals('N/A'));
      expect(quota.totalTurnsCount, equals(0));
      expect(quota.completedTurnsCount, equals(0));
      expect(quota.soilMoistureStatus, equals('N/A'));

      final turn = IrrigationTurnModel.fromJson(const {});
      expect(turn.turnNumber, equals(0));
      expect(turn.season, equals('N/A'));
      expect(turn.outletNo, equals('N/A'));
      expect(turn.gateNo, equals('N/A'));
      expect(turn.dischargeCusecs, equals(0.0));
      expect(turn.waterDeliveredHaCm, equals(0.0));
      expect(turn.crop, equals('N/A'));
      expect(turn.fieldParcel, equals('N/A'));
      expect(turn.inspectorName, equals('N/A'));

      final crop = CropWaterUsageModel.fromJson(const {});
      expect(crop.cropName, equals('N/A'));
      expect(crop.areaAcres, equals(0.0));
      expect(crop.allocatedHaCm, equals(0.0));
      expect(crop.usedHaCm, equals(0.0));
    });
  });
}
