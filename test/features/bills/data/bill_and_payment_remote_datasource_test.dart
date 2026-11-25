import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/errors/exceptions.dart';
import 'package:wua_mobile/core/network/api_client.dart';
import 'package:wua_mobile/core/network/api_endpoints.dart';
import 'package:wua_mobile/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:wua_mobile/features/authentication/data/models/user_model.dart';
import 'package:wua_mobile/features/bills/data/datasources/bill_remote_datasource.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/payments/data/datasources/payment_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MockApiClient mockApiClient;
  late MockAuthLocalDataSource mockAuthLocalDataSource;
  late BillRemoteDataSourceImpl billDataSource;
  late PaymentRemoteDataSourceImpl paymentDataSource;

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
    authorities: ['SABHASAD_ONLY'],
  );

  const tStaffUser = UserModel(
    id: '2100',
    name: 'Sachiv User',
    email: '',
    phone: '9922322710',
    role: 'wua_official',
    isVerified: true,
    createdAt: '2026-01-01T00:00:00Z',
    societyId: 26,
    refTable: null,
    refTableId: 10,
    roles: ['सचिव'],
    authorities: ['SUPER_ADMIN_AND_SACHIV_AND_SANCHALAK_ONLY'],
  );

  setUp(() {
    mockApiClient = MockApiClient();
    mockAuthLocalDataSource = MockAuthLocalDataSource();
    billDataSource = BillRemoteDataSourceImpl(
      apiClient: mockApiClient,
      authLocalDataSource: mockAuthLocalDataSource,
    );
    paymentDataSource = PaymentRemoteDataSourceImpl(
      apiClient: mockApiClient,
      authLocalDataSource: mockAuthLocalDataSource,
    );
  });

  group('BillRemoteDataSourceImpl', () {
    test('queries iFarmerMemberId for SocietyFarmer login and parses bills', () async {
      when(
        () => mockAuthLocalDataSource.getCachedUser(),
      ).thenAnswer((_) async => tFarmerUser);

      final endpoint = ApiEndpoints.memberBillDetails(farmerMemberId: 69);
      when(() => mockApiClient.get<dynamic>(endpoint)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: endpoint),
          statusCode: 200,
          data: [
            {
              'id': 1,
              'iBillNo': 1001,
              'iFarmerMemberId': 69,
              'sSeason': 'रब्बी',
              'sCrop': 'भाजीपाला',
              'totalAmount': 1076.16,
              'paidAmount': 1076.16,
              'balanceAmount': 0.0,
              'isPaymentDone': true,
            },
            {
              'id': 2,
              'iBillNo': 1002,
              'iFarmerMemberId': 69,
              'sSeason': 'खरीप',
              'sCrop': 'कडधान्य',
              'totalAmount': 2050.0,
              'paidAmount': 0.0,
              'balanceAmount': 2050.0,
              'isPaymentDone': false,
            },
          ],
        ),
      );

      final bills = await billDataSource.getBills();

      expect(bills.length, equals(2));
      expect(bills[0].status, equals(BillStatus.paid));
      expect(bills[1].totalAmount, equals(2050.0));
      verify(() => mockApiClient.get<dynamic>(endpoint)).called(1);
    });

    test('queries iSocietyId instead of staff userId when logged in as Sachiv', () async {
      when(
        () => mockAuthLocalDataSource.getCachedUser(),
      ).thenAnswer((_) async => tStaffUser);

      final endpoint = ApiEndpoints.societyBillDetails(societyId: 26);
      when(() => mockApiClient.get<dynamic>(endpoint)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: endpoint),
          statusCode: 200,
          data: const <dynamic>[],
        ),
      );

      final bills = await billDataSource.getBills();
      expect(bills, isEmpty);
      verify(() => mockApiClient.get<dynamic>(endpoint)).called(1);
    });

    test('rethrows UnauthorizedException instead of swallowing to empty list', () async {
      when(
        () => mockAuthLocalDataSource.getCachedUser(),
      ).thenAnswer((_) async => tFarmerUser);

      final endpoint = ApiEndpoints.memberBillDetails(farmerMemberId: 69);
      when(() => mockApiClient.get<dynamic>(endpoint)).thenThrow(
        const UnauthorizedException(message: 'Token expired'),
      );

      await expectLater(
        () => billDataSource.getBills(),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });

  group('PaymentRemoteDataSourceImpl', () {
    test('rethrows NetworkException instead of swallowing to empty list', () async {
      when(
        () => mockAuthLocalDataSource.getCachedUser(),
      ).thenAnswer((_) async => tFarmerUser);

      final endpoint = ApiEndpoints.receiptsHistory(farmerMemberId: 69);
      when(() => mockApiClient.get<dynamic>(endpoint)).thenThrow(
        const NetworkException(message: 'No internet connection.'),
      );

      await expectLater(
        () => paymentDataSource.getPayments(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('uses dRequestDate fallback when dReceiptDate is null', () async {
      when(
        () => mockAuthLocalDataSource.getCachedUser(),
      ).thenAnswer((_) async => tFarmerUser);

      final endpoint = ApiEndpoints.receiptsHistory(farmerMemberId: 69);
      when(() => mockApiClient.get<dynamic>(endpoint)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: endpoint),
          statusCode: 200,
          data: [
            {
              'id': 501,
              'iFarmerMemberId': 69,
              'nAmount': 1076.16,
              'dReceiptDate': null,
              'dRequestDate': '2026-11-20T10:30:00Z',
              'sStatus': 'A',
              'season': 'रब्बी',
            },
          ],
        ),
      );

      final payments = await paymentDataSource.getPayments();
      expect(payments.length, equals(1));
      expect(
        payments.first.paymentDate,
        equals(DateTime.parse('2026-11-20T10:30:00Z')),
      );
    });
  });
}
