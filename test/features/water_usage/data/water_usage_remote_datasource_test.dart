import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/errors/exceptions.dart';
import 'package:wua_mobile/core/network/api_client.dart';
import 'package:wua_mobile/core/network/api_endpoints.dart';
import 'package:wua_mobile/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:wua_mobile/features/authentication/data/models/user_model.dart';
import 'package:wua_mobile/features/water_usage/data/datasources/water_usage_remote_datasource.dart';
import 'package:wua_mobile/features/water_usage/data/models/water_usage_model.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MockApiClient mockApiClient;
  late MockAuthLocalDataSource mockAuthLocalDataSource;
  late WaterUsageRemoteDataSourceImpl dataSource;

  const tFarmerUser = UserModel(
    id: '2500',
    name: 'Azure Dragon',
    email: '',
    phone: '9999999999',
    role: 'farmer',
    isVerified: true,
    createdAt: '2026-01-01T00:00:00Z',
    societyId: 26,
    refTable: 'SocietyFarmer',
    refTableId: 69,
    roles: ['सभासद'],
    authorities: ['SABHASAD_ONLY', 'WATER_USED_LIST_VIEW'],
  );

  setUp(() {
    mockApiClient = MockApiClient();
    mockAuthLocalDataSource = MockAuthLocalDataSource();
    dataSource = WaterUsageRemoteDataSourceImpl(
      apiClient: mockApiClient,
      authLocalDataSource: mockAuthLocalDataSource,
    );
    when(
      () => mockAuthLocalDataSource.getCachedUser(),
    ).thenAnswer((_) async => tFarmerUser);
  });

  group('CropWaterUsageModel.fromJson', () {
    test('parses backend CropDetailsDTO with String billGenerated and HP/Unit fields', () {
      final model = CropWaterUsageModel.fromJson(const <String, dynamic>{
        'id': 11,
        'fiscalYear': '2026-2027',
        'season': 'रब्बी',
        'rotation': '2',
        'village': 'Pune',
        'surveyNo': '69',
        'crop': 'भाजीपाला',
        'area': 2.5,
        'source': 'कालवा उपसा',
        'value': 456.0,
        'rateType': 'युनिट',
        'rateValue': 2.36,
        'perType': 'घनमीटर',
        'seasonalWaterUsage': 'घनमीटर',
        'amount': 1076.16,
        'waterAllocation': null,
        'waterUsageArea': null,
        'farmerMemberId': 69,
        'societyId': 26,
        'waterUsageId': 7,
        'billGenerated': 'Y',
        'isPaymentDone': true,
      });

      expect(model.cropName, equals('भाजीपाला'));
      expect(model.cropNameMarathi, equals('भाजीपाला'));
      expect(model.displayCropName, equals('भाजीपाला'));
      expect(model.areaAcres, equals(2.5));
      expect(model.billGenerated, isTrue);
      expect(model.isPaymentDone, isTrue);
      expect(model.waterValue, equals(456.0));
      expect(model.rateType, equals('युनिट'));
      expect(model.formattedUnitValue, equals('456 युनिट'));
      expect(model.memberId, equals(69));
      expect(model.farmerMemberId, equals(69));
      expect(model.amount, equals(1076.16));
    });

    test('parses waterAllocation and waterUsageArea when populated', () {
      final model = CropWaterUsageModel.fromJson(const <String, dynamic>{
        'crop': 'Sugarcane',
        'area': 3.0,
        'waterAllocation': 24.0,
        'waterUsageArea': 12.0,
        'billGenerated': 'N',
      });

      expect(model.allocatedHaCm, equals(24.0));
      expect(model.usedHaCm, equals(12.0));
      expect(model.percentage, equals(50.0));
      expect(model.billGenerated, isFalse);
    });
  });

  group('WaterUsageRemoteDataSourceImpl', () {
    test('returns CropDetails & WaterUsage when /api/wua-water-usages returns 403 for farmer', () async {
      final cropEndpoint = ApiEndpoints.farmerCropUsage(farmerMemberId: 69);
      final outwardEndpoint = ApiEndpoints.outwardWaterUsages(farmerMemberId: 69);
      final rotationsEndpoint = ApiEndpoints.canalRotations(societyId: 26);

      when(() => mockApiClient.get<dynamic>(cropEndpoint)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: cropEndpoint),
          statusCode: 200,
          data: [
            {
              'id': 1,
              'fiscalYear': '2026-2027',
              'season': 'खरीप',
              'rotation': '2',
              'village': 'Pune',
              'surveyNo': '69',
              'crop': 'कडधान्य',
              'area': 2.5,
              'source': 'कालवा उपसा',
              'value': 10,
              'rateType': 'HP',
              'rateValue': 205.0,
              'amount': 2050.0,
              'status': 'A',
              'billGenerated': 'Y',
              'farmerMemberId': 69,
              'waterUsageId': 5,
            },
            {
              'id': 2,
              'fiscalYear': '2026-2027',
              'season': 'रब्बी',
              'rotation': '2',
              'village': 'Pune',
              'surveyNo': '69',
              'crop': 'भाजीपाला',
              'area': 2.5,
              'source': 'कालवा उपसा',
              'value': 456,
              'rateType': 'युनिट',
              'rateValue': 2.36,
              'amount': 1076.16,
              'status': 'A',
              'billGenerated': 'Y',
              'farmerMemberId': 69,
              'waterUsageId': 6,
            },
          ],
        ),
      );

      when(() => mockApiClient.get<dynamic>(outwardEndpoint)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: outwardEndpoint),
          statusCode: 200,
          data: [
            {
              'id': 5,
              'fiscalYear': '2026-2027',
              'season': 'खरीप',
              'status': 'A',
              'farmerMemberId': 69,
            },
          ],
        ),
      );

      when(() => mockApiClient.get<dynamic>(rotationsEndpoint)).thenThrow(
        const ServerException(
          message: 'Access is denied',
          statusCode: 403,
        ),
      );

      final summary = await dataSource.getWaterUsageSummary();

      expect(summary.quota.cropBreakdown.length, equals(2));
      expect(summary.quota.cropBreakdown[0].displayCropName, equals('कडधान्य'));
      expect(summary.quota.cropBreakdown[1].displayCropName, equals('भाजीपाला'));
      expect(summary.quota.totalIrrigatedArea, equals(5.0));
      expect(summary.quota.totalCropAmount, closeTo(3126.16, 0.01));
      expect(summary.quota.canalStatus, equals('Recorded Usage'));
      expect(summary.allTurns, isEmpty);
    });

    test('rethrows UnauthorizedException when session token is invalid', () async {
      final cropEndpoint = ApiEndpoints.farmerCropUsage(farmerMemberId: 69);

      when(() => mockApiClient.get<dynamic>(cropEndpoint)).thenThrow(
        const UnauthorizedException(message: 'JWT expired'),
      );

      await expectLater(
        () => dataSource.getWaterUsageSummary(),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('sums water quota only for active fiscalYear and season', () async {
      final cropEndpoint = ApiEndpoints.farmerCropUsage(farmerMemberId: 69);
      final outwardEndpoint = ApiEndpoints.outwardWaterUsages(farmerMemberId: 69);
      final rotationsEndpoint = ApiEndpoints.canalRotations(societyId: 26);

      when(() => mockApiClient.get<dynamic>(cropEndpoint)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: cropEndpoint),
          statusCode: 200,
          data: [
            // Most recent entry: 2026-2027, रब्बी
            {
              'id': 20,
              'fiscalYear': '2026-2027',
              'season': 'रब्बी',
              'crop': 'Wheat',
              'area': 2.0,
              'waterAllocation': 10.0,
              'waterUsageArea': 4.0,
              'status': 'A',
              'farmerMemberId': 69,
            },
            // Previous season in same year: should not be added to active balance
            {
              'id': 19,
              'fiscalYear': '2026-2027',
              'season': 'खरीप',
              'crop': 'Soybean',
              'area': 2.0,
              'waterAllocation': 12.0,
              'waterUsageArea': 12.0,
              'status': 'A',
              'farmerMemberId': 69,
            },
            // Prior fiscal year: should not be added to active balance
            {
              'id': 10,
              'fiscalYear': '2025-2026',
              'season': 'रब्बी',
              'crop': 'Gram',
              'area': 1.5,
              'waterAllocation': 8.0,
              'waterUsageArea': 8.0,
              'status': 'A',
              'farmerMemberId': 69,
            },
          ],
        ),
      );
      when(() => mockApiClient.get<dynamic>(outwardEndpoint)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: outwardEndpoint),
          statusCode: 200,
          data: const <dynamic>[],
        ),
      );
      when(() => mockApiClient.get<dynamic>(rotationsEndpoint)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: rotationsEndpoint),
          statusCode: 200,
          data: const <dynamic>[],
        ),
      );

      final summary = await dataSource.getWaterUsageSummary();

      expect(summary.quota.season, equals('रब्बी'));
      expect(summary.quota.fiscalYear, equals('2026-2027'));
      expect(summary.quota.totalQuotaHaCm, equals(10.0));
      expect(summary.quota.usedQuotaHaCm, equals(4.0));
      expect(summary.quota.remainingQuotaHaCm, equals(6.0));
      expect(summary.quota.percentageUsed, equals(40.0));
      expect(summary.quota.cropBreakdown.length, equals(3));
    });
  });
}
