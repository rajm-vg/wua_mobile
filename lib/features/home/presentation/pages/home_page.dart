import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_event.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_state.dart';
import 'package:wua_mobile/features/home/presentation/widgets/farmer_services_grid.dart';
import 'package:wua_mobile/features/home/presentation/widgets/home_header.dart';
import 'package:wua_mobile/features/home/presentation/widgets/next_canal_turn_card.dart';
import 'package:wua_mobile/features/home/presentation/widgets/pani_patti_bill_card.dart';
import 'package:wua_mobile/features/home/presentation/widgets/recent_activity_card.dart';
import 'package:wua_mobile/features/home/presentation/widgets/water_metrics_row.dart';
import 'package:wua_mobile/shared/widgets/wua_scaffold.dart';

/// Regional WUA Irrigation Dashboard home screen.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => sl<AuthBloc>()..add(const AuthCheckRequested()),
      child: const _HomePageView(),
    );
  }
}

class _HomePageView extends StatelessWidget {
  const _HomePageView();

  Future<void> _onRefresh(BuildContext context) async {
    context.read<AuthBloc>().add(const AuthCheckRequested());
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return WuaScaffold(
          hideAppBar: true,
          useSafeArea: false,
          padding: EdgeInsets.zero,
          scrollable: true,
          systemUiOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: AppSpacing.md),

                    // Next Canal Turn • Wari Card
                    NextCanalTurnCard(),
                    SizedBox(height: AppSpacing.md),

                    // Current Pani Patti Bill Card
                    PaniPattiBillCard(),
                    SizedBox(height: AppSpacing.md),

                    // Water Balance & Total Dues Metrics Row
                    WaterMetricsRow(),
                    SizedBox(height: AppSpacing.md),

                    // Farmer Services 4-column Grid
                    FarmerServicesGrid(),
                    SizedBox(height: AppSpacing.md),

                    // Recent Activity / Kharif Payment Card
                    RecentActivityCard(),

                    // Spacing for floating bottom navigation bar
                    SizedBox(height: 96),
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
