import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/charge_payment.dart';
import '../../data/datasources/apartment_remote_datasource.dart';
import '../../data/repositories/apartment_repository_impl.dart';
import '../../domain/entities/apartment.dart';
import '../../domain/entities/apartment_summary.dart';
import '../../domain/repositories/apartment_repository.dart';
import '../../domain/usecases/create_apartment_usecase.dart';
import '../../domain/usecases/deactivate_apartment_usecase.dart';
import '../../domain/usecases/get_apartment_by_id_usecase.dart';
import '../../domain/usecases/get_apartment_debt_usecase.dart';
import '../../domain/usecases/get_apartment_payment_history_usecase.dart';
import '../../domain/usecases/get_apartment_summaries_usecase.dart';
import '../../domain/usecases/update_apartment_usecase.dart';

final Provider<ApartmentRemoteDataSource> apartmentRemoteDataSourceProvider = Provider<ApartmentRemoteDataSource>((ref) => ApartmentRemoteDataSourceImpl(SupabaseService.client));
final Provider<ApartmentRepository> apartmentRepositoryProvider = Provider<ApartmentRepository>((ref) => ApartmentRepositoryImpl(ref.watch(apartmentRemoteDataSourceProvider)));
final Provider<GetApartmentSummariesUseCase> getApartmentSummariesUseCaseProvider = Provider((ref) => GetApartmentSummariesUseCase(ref.watch(apartmentRepositoryProvider)));
final Provider<GetApartmentByIdUseCase> getApartmentByIdUseCaseProvider = Provider((ref) => GetApartmentByIdUseCase(ref.watch(apartmentRepositoryProvider)));
final Provider<GetApartmentPaymentHistoryUseCase> getApartmentPaymentHistoryUseCaseProvider = Provider((ref) => GetApartmentPaymentHistoryUseCase(ref.watch(apartmentRepositoryProvider)));
final Provider<GetApartmentDebtUseCase> getApartmentDebtUseCaseProvider = Provider((ref) => GetApartmentDebtUseCase(ref.watch(apartmentRepositoryProvider)));
final Provider<CreateApartmentUseCase> createApartmentUseCaseProvider = Provider((ref) => CreateApartmentUseCase(ref.watch(apartmentRepositoryProvider)));
final Provider<UpdateApartmentUseCase> updateApartmentUseCaseProvider = Provider((ref) => UpdateApartmentUseCase(ref.watch(apartmentRepositoryProvider)));
final Provider<DeactivateApartmentUseCase> deactivateApartmentUseCaseProvider = Provider((ref) => DeactivateApartmentUseCase(ref.watch(apartmentRepositoryProvider)));

class ApartmentListNotifier extends AsyncNotifier<List<ApartmentSummary>> {
  @override
  Future<List<ApartmentSummary>> build() => _fetch();

  Future<List<ApartmentSummary>> _fetch() async {
    final Either<Failure, List<ApartmentSummary>> result = await ref.read(getApartmentSummariesUseCaseProvider)();
    return result.fold((failure) => throw failure, (list) => list);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

final AsyncNotifierProvider<ApartmentListNotifier, List<ApartmentSummary>> apartmentListProvider = AsyncNotifierProvider(ApartmentListNotifier.new);

final FutureProviderFamily<Apartment, String> apartmentDetailProvider = FutureProvider.family<Apartment, String>((ref, id) async {
  final result = await ref.read(getApartmentByIdUseCaseProvider)(id);
  return result.fold((failure) => throw failure, (a) => a);
});

final FutureProviderFamily<List<ChargePayment>, String> apartmentPaymentHistoryProvider = FutureProvider.family<List<ChargePayment>, String>((ref, apartmentId) async {
  final result = await ref.read(getApartmentPaymentHistoryUseCaseProvider)(apartmentId);
  return result.fold((failure) => throw failure, (list) => list);
});

final FutureProviderFamily<double, String> apartmentDebtProvider = FutureProvider.family<double, String>((ref, apartmentId) async {
  final result = await ref.read(getApartmentDebtUseCaseProvider)(apartmentId);
  return result.fold((failure) => throw failure, (d) => d);
});
