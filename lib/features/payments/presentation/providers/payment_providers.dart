import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/charge_payment.dart';
import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/create_payment_usecase.dart';
import '../../domain/usecases/get_payments_usecase.dart';
import '../../domain/usecases/update_payment_usecase.dart';
import '../../domain/usecases/void_payment_usecase.dart';

final Provider<PaymentRemoteDataSource> paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>((ref) => PaymentRemoteDataSourceImpl(SupabaseService.client));
final Provider<PaymentRepository> paymentRepositoryProvider = Provider<PaymentRepository>((ref) => PaymentRepositoryImpl(ref.watch(paymentRemoteDataSourceProvider)));
final Provider<GetPaymentsUseCase> getPaymentsUseCaseProvider = Provider((ref) => GetPaymentsUseCase(ref.watch(paymentRepositoryProvider)));
final Provider<CreatePaymentUseCase> createPaymentUseCaseProvider = Provider((ref) => CreatePaymentUseCase(ref.watch(paymentRepositoryProvider)));
final Provider<UpdatePaymentUseCase> updatePaymentUseCaseProvider = Provider((ref) => UpdatePaymentUseCase(ref.watch(paymentRepositoryProvider)));
final Provider<VoidPaymentUseCase> voidPaymentUseCaseProvider = Provider((ref) => VoidPaymentUseCase(ref.watch(paymentRepositoryProvider)));

class PaymentListNotifier extends AsyncNotifier<List<ChargePayment>> {
  @override
  Future<List<ChargePayment>> build() => _fetch();

  Future<List<ChargePayment>> _fetch() async {
    final Either<Failure, List<ChargePayment>> result = await ref.read(getPaymentsUseCaseProvider)();
    return result.fold((failure) => throw failure, (list) => list);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

final AsyncNotifierProvider<PaymentListNotifier, List<ChargePayment>> paymentListProvider = AsyncNotifierProvider(PaymentListNotifier.new);
