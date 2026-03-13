import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/auth/firm_id_provider.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/billing/data/datasources/invoice_local_source.dart';
import 'package:ca_app/features/billing/data/datasources/invoice_remote_source.dart';
import 'package:ca_app/features/billing/data/datasources/payment_local_source.dart';
import 'package:ca_app/features/billing/data/datasources/payment_remote_source.dart';
import 'package:ca_app/features/billing/data/repositories/invoice_repository_impl.dart';
import 'package:ca_app/features/billing/data/repositories/mock_invoice_repository.dart';
import 'package:ca_app/features/billing/data/repositories/mock_payment_repository.dart';
import 'package:ca_app/features/billing/data/repositories/payment_repository_impl.dart';
import 'package:ca_app/features/billing/domain/repositories/invoice_repository.dart';
import 'package:ca_app/features/billing/domain/repositories/payment_repository.dart';

final invoiceRemoteSourceProvider = Provider<InvoiceRemoteSource>((ref) {
  return InvoiceRemoteSource(Supabase.instance.client);
});

final invoiceLocalSourceProvider = Provider<InvoiceLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return InvoiceLocalSource(db);
});

final paymentRemoteSourceProvider = Provider<PaymentRemoteSource>((ref) {
  return PaymentRemoteSource(Supabase.instance.client);
});

final paymentLocalSourceProvider = Provider<PaymentLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PaymentLocalSource(db);
});

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('billing_real_repo') ?? false;

  if (!useReal) {
    return MockInvoiceRepository();
  }

  final firmId = ref.watch(currentFirmIdProvider);
  return InvoiceRepositoryImpl(
    remote: ref.watch(invoiceRemoteSourceProvider),
    local: ref.watch(invoiceLocalSourceProvider),
    firmId: firmId,
  );
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('billing_real_repo') ?? false;

  if (!useReal) {
    return MockPaymentRepository();
  }

  final firmId = ref.watch(currentFirmIdProvider);
  return PaymentRepositoryImpl(
    remote: ref.watch(paymentRemoteSourceProvider),
    local: ref.watch(paymentLocalSourceProvider),
    firmId: firmId,
  );
});
