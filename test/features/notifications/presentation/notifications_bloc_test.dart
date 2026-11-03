import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/usecases/usecase.dart';
import 'package:wua_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:wua_mobile/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:wua_mobile/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:wua_mobile/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:wua_mobile/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:wua_mobile/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:wua_mobile/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:wua_mobile/features/notifications/presentation/bloc/notifications_state.dart';

class MockGetNotificationsUseCase extends Mock
    implements GetNotificationsUseCase {}

class MockMarkNotificationReadUseCase extends Mock
    implements MarkNotificationReadUseCase {}

class MockMarkAllNotificationsReadUseCase extends Mock
    implements MarkAllNotificationsReadUseCase {}

class MockDeleteNotificationUseCase extends Mock
    implements DeleteNotificationUseCase {}

void main() {
  late MockGetNotificationsUseCase mockGetNotificationsUseCase;
  late MockMarkNotificationReadUseCase mockMarkNotificationReadUseCase;
  late MockMarkAllNotificationsReadUseCase mockMarkAllNotificationsReadUseCase;
  late MockDeleteNotificationUseCase mockDeleteNotificationUseCase;
  late NotificationsBloc bloc;

  setUpAll(() {
    registerFallbackValue(const GetNotificationsParams());
    registerFallbackValue(const MarkNotificationReadParams('n1'));
    registerFallbackValue(const DeleteNotificationParams('n1'));
    registerFallbackValue(const NoParams());
  });

  final tNotificationBill = NotificationEntity(
    id: 'n_bill_1',
    title: 'New Bill Generated',
    message: 'Kharif irrigation bill is ready',
    type: NotificationType.billGenerated,
    category: NotificationCategory.bill,
    timestamp: DateTime(2026, 11, 1, 9, 0),
    isRead: false,
    amount: 1450.0,
    referenceId: 'BILL-01',
  );

  final tNotificationPayment = NotificationEntity(
    id: 'n_pay_1',
    title: 'Payment Received',
    message: 'Payment received successfully',
    type: NotificationType.paymentSuccess,
    category: NotificationCategory.payment,
    timestamp: DateTime(2026, 10, 30, 14, 0),
    isRead: true,
    amount: 2400.0,
    referenceId: 'PAY-01',
  );

  final tNotificationsList = [tNotificationBill, tNotificationPayment];

  setUp(() {
    mockGetNotificationsUseCase = MockGetNotificationsUseCase();
    mockMarkNotificationReadUseCase = MockMarkNotificationReadUseCase();
    mockMarkAllNotificationsReadUseCase = MockMarkAllNotificationsReadUseCase();
    mockDeleteNotificationUseCase = MockDeleteNotificationUseCase();

    bloc = NotificationsBloc(
      getNotificationsUseCase: mockGetNotificationsUseCase,
      markNotificationReadUseCase: mockMarkNotificationReadUseCase,
      markAllNotificationsReadUseCase: mockMarkAllNotificationsReadUseCase,
      deleteNotificationUseCase: mockDeleteNotificationUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be NotificationsInitial', () {
    expect(bloc.state, equals(const NotificationsInitial()));
  });

  group('LoadNotificationsEvent', () {
    blocTest<NotificationsBloc, NotificationsState>(
      'emits [NotificationsLoading, NotificationsLoaded] when successful',
      build: () {
        when(() => mockGetNotificationsUseCase(any())).thenAnswer(
          (_) async => Right(tNotificationsList),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadNotificationsEvent()),
      expect: () => [
        const NotificationsLoading(),
        NotificationsLoaded(
          allNotifications: tNotificationsList,
          filteredNotifications: tNotificationsList,
          selectedFilter: 'ALL',
        ),
      ],
      verify: (_) {
        verify(() => mockGetNotificationsUseCase(any())).called(1);
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'emits [NotificationsLoading, NotificationsError] on failure',
      build: () {
        when(() => mockGetNotificationsUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server Error')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadNotificationsEvent()),
      expect: () => [
        const NotificationsLoading(),
        const NotificationsError('Server Error'),
      ],
    );
  });

  group('FilterNotificationsEvent', () {
    blocTest<NotificationsBloc, NotificationsState>(
      'filters to UNREAD correctly',
      build: () => bloc,
      seed: () => NotificationsLoaded(
        allNotifications: tNotificationsList,
        filteredNotifications: tNotificationsList,
        selectedFilter: 'ALL',
      ),
      act: (bloc) => bloc.add(const FilterNotificationsEvent('UNREAD')),
      expect: () => [
        NotificationsLoaded(
          allNotifications: tNotificationsList,
          filteredNotifications: [tNotificationBill],
          selectedFilter: 'UNREAD',
        ),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'filters to BILLS correctly',
      build: () => bloc,
      seed: () => NotificationsLoaded(
        allNotifications: tNotificationsList,
        filteredNotifications: tNotificationsList,
        selectedFilter: 'ALL',
      ),
      act: (bloc) => bloc.add(const FilterNotificationsEvent('BILLS')),
      expect: () => [
        NotificationsLoaded(
          allNotifications: tNotificationsList,
          filteredNotifications: [tNotificationBill],
          selectedFilter: 'BILLS',
        ),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'filters to PAYMENTS correctly',
      build: () => bloc,
      seed: () => NotificationsLoaded(
        allNotifications: tNotificationsList,
        filteredNotifications: tNotificationsList,
        selectedFilter: 'ALL',
      ),
      act: (bloc) => bloc.add(const FilterNotificationsEvent('PAYMENTS')),
      expect: () => [
        NotificationsLoaded(
          allNotifications: tNotificationsList,
          filteredNotifications: [tNotificationPayment],
          selectedFilter: 'PAYMENTS',
        ),
      ],
    );
  });

  group('MarkNotificationAsReadEvent', () {
    blocTest<NotificationsBloc, NotificationsState>(
      'marks target notification as read and calls usecase',
      build: () {
        when(() => mockMarkNotificationReadUseCase(any())).thenAnswer(
          (_) async => const Right(true),
        );
        return bloc;
      },
      seed: () => NotificationsLoaded(
        allNotifications: tNotificationsList,
        filteredNotifications: tNotificationsList,
        selectedFilter: 'ALL',
      ),
      act: (bloc) =>
          bloc.add(const MarkNotificationAsReadEvent('n_bill_1')),
      expect: () => [
        NotificationsLoaded(
          allNotifications: [
            tNotificationBill.copyWith(isRead: true),
            tNotificationPayment,
          ],
          filteredNotifications: [
            tNotificationBill.copyWith(isRead: true),
            tNotificationPayment,
          ],
          selectedFilter: 'ALL',
        ),
      ],
      verify: (_) {
        verify(
          () => mockMarkNotificationReadUseCase(
            const MarkNotificationReadParams('n_bill_1'),
          ),
        ).called(1);
      },
    );
  });

  group('DeleteNotificationEvent', () {
    blocTest<NotificationsBloc, NotificationsState>(
      'removes notification and calls usecase',
      build: () {
        when(() => mockDeleteNotificationUseCase(any())).thenAnswer(
          (_) async => const Right(true),
        );
        return bloc;
      },
      seed: () => NotificationsLoaded(
        allNotifications: tNotificationsList,
        filteredNotifications: tNotificationsList,
        selectedFilter: 'ALL',
      ),
      act: (bloc) => bloc.add(const DeleteNotificationEvent('n_bill_1')),
      expect: () => [
        NotificationsLoaded(
          allNotifications: [tNotificationPayment],
          filteredNotifications: [tNotificationPayment],
          selectedFilter: 'ALL',
        ),
      ],
      verify: (_) {
        verify(
          () => mockDeleteNotificationUseCase(
            const DeleteNotificationParams('n_bill_1'),
          ),
        ).called(1);
      },
    );
  });
}

