import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/app_theme.dart';
import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';
import 'package:wua_mobile/features/water_usage/presentation/bloc/water_usage_bloc.dart';
import 'package:wua_mobile/features/water_usage/presentation/bloc/water_usage_event.dart';
import 'package:wua_mobile/features/water_usage/presentation/bloc/water_usage_state.dart';
import 'package:wua_mobile/features/water_usage/presentation/pages/water_usage_page.dart';

class MockWaterUsageBloc extends MockBloc<WaterUsageEvent, WaterUsageState>
    implements WaterUsageBloc {}

void main() {
  late MockWaterUsageBloc mockWaterUsageBloc;

  setUpAll(() {
    registerFallbackValue(const LoadWaterUsageEvent());
  });

  setUp(() {
    mockWaterUsageBloc = MockWaterUsageBloc();
    if (sl.isRegistered<WaterUsageBloc>()) {
      sl.unregister<WaterUsageBloc>();
    }
    sl.registerFactory<WaterUsageBloc>(() => mockWaterUsageBloc);
  });

  tearDown(() {
    if (sl.isRegistered<WaterUsageBloc>()) {
      sl.unregister<WaterUsageBloc>();
    }
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const WaterUsagePage(),
    );
  }

  group('WaterUsagePage Widget Tests', () {
    testWidgets(
      'renders outward CropDetails entries and hides unavailable turns/soil moisture/ha-cm quota',
      (tester) async {
        const crops = [
          CropWaterUsage(
            id: 1,
            cropName: 'कडधान्य',
            cropNameMarathi: 'कडधान्य',
            allocatedHaCm: 0.0,
            usedHaCm: 0.0,
            areaAcres: 2.5,
            percentage: 0.0,
            fiscalYear: '2026-2027',
            season: 'खरीप',
            rotation: '2',
            village: 'Pune',
            surveyNo: '69',
            source: 'कालवा उपसा',
            waterValue: 10.0,
            rateType: 'HP',
            rateValue: 205.0,
            perType: 'घनमीटर',
            seasonalWaterUsage: 'हंगाम',
            amount: 2050.0,
            billGenerated: true,
          ),
          CropWaterUsage(
            id: 2,
            cropName: 'भाजीपाला',
            cropNameMarathi: 'भाजीपाला',
            allocatedHaCm: 0.0,
            usedHaCm: 0.0,
            areaAcres: 2.5,
            percentage: 0.0,
            fiscalYear: '2026-2027',
            season: 'रब्बी',
            rotation: '2',
            village: 'Pune',
            surveyNo: '69',
            source: 'कालवा उपसा',
            waterValue: 456.0,
            rateType: 'युनिट',
            rateValue: 2.36,
            perType: 'घनमीटर',
            seasonalWaterUsage: 'घनमीटर',
            amount: 1076.16,
            billGenerated: true,
          ),
        ];

        const quota = WaterQuotaEntity(
          season: 'खरीप',
          fiscalYear: '2026-2027',
          totalQuotaHaCm: 0.0,
          usedQuotaHaCm: 0.0,
          remainingQuotaHaCm: 0.0,
          percentageUsed: 0.0,
          canalName: 'कालवा उपसा',
          canalStatus: 'Recorded Usage',
          currentFlowCusecs: 0.0,
          outletNumber: 'Survey 69',
          wuaSocietyName: '',
          farmerName: 'Azure Dragon',
          totalTurnsCount: 0,
          completedTurnsCount: 0,
          cropBreakdown: crops,
        );

        const summary = WaterUsageSummaryEntity(
          quota: quota,
          allTurns: [],
        );

        when(() => mockWaterUsageBloc.state).thenReturn(
          const WaterUsageLoaded(
            summary: summary,
            filteredTurns: [],
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('WATER USAGE SUMMARY'), findsOneWidget);
        expect(find.text('कडधान्य'), findsOneWidget);
        expect(find.text('भाजीपाला'), findsOneWidget);
        expect(find.text('10 HP'), findsOneWidget);
        expect(find.text('456 युनिट'), findsOneWidget);
        expect(find.text('Bill Generated'), findsNWidgets(2));

        // Unavailable canal rotation / soil moisture / ha-cm metrics must not appear
        expect(find.text('CANAL ROTATION ACTIVE'), findsNothing);
        expect(find.text('0 Turns'), findsNothing);
        expect(find.text('Soil Moisture'), findsNothing);
        expect(find.text('Turns (वारी)'), findsNothing);
        expect(find.text('Remaining'), findsNothing);
      },
    );

    testWidgets(
      'renders clean empty state when neither crop usage nor canal turns exist',
      (tester) async {
        const emptySummary = WaterUsageSummaryEntity(
          quota: WaterQuotaEntity(
            season: 'N/A',
            totalQuotaHaCm: 0.0,
            usedQuotaHaCm: 0.0,
            remainingQuotaHaCm: 0.0,
            percentageUsed: 0.0,
            canalName: 'N/A',
            canalStatus: 'N/A',
            currentFlowCusecs: 0.0,
            outletNumber: 'N/A',
            wuaSocietyName: '',
            farmerName: '',
            totalTurnsCount: 0,
            completedTurnsCount: 0,
            cropBreakdown: [],
          ),
          allTurns: [],
        );

        when(() => mockWaterUsageBloc.state).thenReturn(
          const WaterUsageLoaded(
            summary: emptySummary,
            filteredTurns: [],
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('No water usage records found'), findsOneWidget);
        expect(find.text('CANAL ROTATION ACTIVE'), findsNothing);
        expect(find.text('0.0'), findsNothing);
        expect(find.text('0 Turns'), findsNothing);
        expect(find.text('Soil Moisture'), findsNothing);
      },
    );
  });
}
