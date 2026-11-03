/// Barrel file for Water Usage & Canal Scheduling Feature.
library;

// Domain
export 'domain/entities/water_usage_entity.dart';
export 'domain/repositories/water_usage_repository.dart';
export 'domain/usecases/get_water_usage_usecase.dart';
export 'domain/usecases/request_turn_swap_usecase.dart';

// Data
export 'data/datasources/water_usage_remote_datasource.dart';
export 'data/models/water_usage_model.dart';
export 'data/repositories/water_usage_repository_impl.dart';

// Presentation
export 'presentation/bloc/water_usage_bloc.dart';
export 'presentation/bloc/water_usage_event.dart';
export 'presentation/bloc/water_usage_state.dart';
export 'presentation/pages/water_usage_page.dart';
export 'presentation/widgets/canal_turn_card.dart';
export 'presentation/widgets/crop_water_breakdown_card.dart';
export 'presentation/widgets/request_turn_swap_sheet.dart';
export 'presentation/widgets/upcoming_canal_turn_card.dart';
export 'presentation/widgets/water_quota_hero_card.dart';
export 'presentation/widgets/water_usage_filter_chips.dart';
export 'presentation/widgets/water_usage_skeleton.dart';

