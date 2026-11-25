import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_event.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_state.dart';
import 'package:wua_mobile/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:wua_mobile/features/bills/presentation/bloc/bills_event.dart';
import 'package:wua_mobile/features/bills/presentation/bloc/bills_state.dart';
import 'package:wua_mobile/features/home/presentation/widgets/farmer_services_grid.dart';
import 'package:wua_mobile/features/home/presentation/widgets/home_header.dart';
import 'package:wua_mobile/features/home/presentation/widgets/next_canal_turn_card.dart';
import 'package:wua_mobile/features/home/presentation/widgets/pani_patti_bill_card.dart';
import 'package:wua_mobile/features/home/presentation/widgets/recent_activity_card.dart';
import 'package:wua_mobile/features/home/presentation/widgets/water_metrics_row.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_state.dart';
import 'package:wua_mobile/features/water_usage/presentation/bloc/water_usage_bloc.dart';
import 'package:wua_mobile/features/water_usage/presentation/bloc/water_usage_event.dart';
import 'package:wua_mobile/features/water_usage/presentation/bloc/water_usage_state.dart';
import 'package:wua_mobile/shared/widgets/wua_scaffold.dart';

/// Regional WUA Irrigation Dashboard home screen with live backend data integration.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        if (sl.isRegistered<BillsBloc>())
          BlocProvider<BillsBloc>(
            create: (context) => sl<BillsBloc>()..add(const LoadBillsEvent()),
          ),
        if (sl.isRegistered<WaterUsageBloc>())
          BlocProvider<WaterUsageBloc>(
            create: (context) => sl<WaterUsageBloc>()..add(const LoadWaterUsageEvent()),
          ),
        if (sl.isRegistered<PaymentsBloc>())
          BlocProvider<PaymentsBloc>(
            create: (context) => sl<PaymentsBloc>()..add(const LoadPaymentsEvent()),
          ),
      ],
      child: const _HomePageView(),
    );
  }
}

class _HomePageView extends StatelessWidget {
  const _HomePageView();

  Future<void> _onRefresh(BuildContext context) async {
    context.read<AuthBloc>().add(const AuthCheckRequested());
    if (sl.isRegistered<BillsBloc>()) {
      context.read<BillsBloc>().add(const LoadBillsEvent(refresh: true));
    }
    if (sl.isRegistered<WaterUsageBloc>()) {
      context.read<WaterUsageBloc>().add(const LoadWaterUsageEvent(refresh: true));
    }
    if (sl.isRegistered<PaymentsBloc>()) {
      context.read<PaymentsBloc>().add(const LoadPaymentsEvent(refresh: true));
    }
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  Widget _buildNextTurnCard() {
    if (!sl.isRegistered<WaterUsageBloc>()) {
      return const NextCanalTurnCard(isEmpty: true);
    }
    return BlocBuilder<WaterUsageBloc, WaterUsageState>(
      builder: (context, state) {
        if (state is WaterUsageLoaded) {
          final nextTurn = state.summary.nextTurn;
          if (nextTurn != null) {
            return NextCanalTurnCard(turn: nextTurn);
          } else {
            return const NextCanalTurnCard(isEmpty: true);
          }
        }
        return const NextCanalTurnCard(isEmpty: true);
      },
    );
  }

  Widget _buildBillCard() {
    if (!sl.isRegistered<BillsBloc>()) {
      return const PaniPattiBillCard(isEmpty: true);
    }
    return BlocBuilder<BillsBloc, BillsState>(
      builder: (context, state) {
        if (state is BillsLoaded) {
          final unpaid = state.allBills.where((b) => !b.isPaid).toList();
          if (unpaid.isNotEmpty) {
            return PaniPattiBillCard(bill: unpaid.first);
          } else {
            return const PaniPattiBillCard(isEmpty: true);
          }
        }
        return const PaniPattiBillCard(isEmpty: true);
      },
    );
  }

  Widget _buildWaterMetricsRow(UserEntity? user) {
    final hasWater = sl.isRegistered<WaterUsageBloc>();
    final hasBills = sl.isRegistered<BillsBloc>();
    if (!hasWater && !hasBills) {
      return const WaterMetricsRow(totalDues: 0.0);
    }

    return Builder(
      builder: (context) {
        final waterState = hasWater ? context.watch<WaterUsageBloc>().state : null;
        final billsState = hasBills ? context.watch<BillsBloc>().state : null;

        final quota = waterState is WaterUsageLoaded ? waterState.summary.quota : null;
        final totalDues = billsState is BillsLoaded
            ? billsState.totalOutstandingAmount
            : (user?.totalBalance ?? 0.0);

        return WaterMetricsRow(
          quota: quota,
          totalDues: totalDues,
        );
      },
    );
  }

  Widget _buildRecentActivityCard() {
    if (!sl.isRegistered<PaymentsBloc>()) {
      return const RecentActivityCard(isEmpty: true);
    }
    return BlocBuilder<PaymentsBloc, PaymentsState>(
      builder: (context, state) {
        if (state is PaymentsLoaded) {
          if (state.allPayments.isNotEmpty) {
            return RecentActivityCard(payment: state.allPayments.first);
          } else {
            return const RecentActivityCard(isEmpty: true);
          }
        }
        return const RecentActivityCard(isEmpty: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return WuaScaffold(
          hideAppBar: true,
          useSafeArea: false,
          padding: EdgeInsets.zero,
          scrollable: true,
          systemUiOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: colors.headerBackground,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          onRefresh: () => _onRefresh(context),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Deep Teal Header (under status bar)
              HomeHeader(user: user),

              // 2. Dashboard Cards and Actions with consistent spacing
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    // Next Canal Turn • Wari Card
                    _buildNextTurnCard(),
                    const SizedBox(height: AppSpacing.md),

                    // Current Pani Patti Bill Card
                    _buildBillCard(),
                    const SizedBox(height: AppSpacing.md),

                    // Water Balance & Total Dues Metrics Row
                    _buildWaterMetricsRow(user),
                    const SizedBox(height: AppSpacing.md),

                    // Farmer Services 4-column Grid
                    const FarmerServicesGrid(),
                    const SizedBox(height: AppSpacing.md),

                    // Recent Activity / Kharif Payment Card
                    _buildRecentActivityCard(),

                    // Spacing for floating bottom navigation bar
                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
