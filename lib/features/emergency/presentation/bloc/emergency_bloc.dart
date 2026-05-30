import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/analytics_service.dart';
import '../../domain/usecases/send_safe_status_usecase.dart';
import 'emergency_event.dart';
import 'emergency_state.dart';

/// BLoC for emergency status management
/// Handles the 'Ben İyiyim' (I am safe) flow
class EmergencyBloc extends Bloc<EmergencyEvent, EmergencyState> {
  final SendSafeStatusUseCase _sendSafeStatusUseCase;
  final NetworkInfo _networkInfo;
  final AnalyticsService _analyticsService;

  EmergencyBloc(
    this._sendSafeStatusUseCase,
    this._networkInfo,
    this._analyticsService,
  ) : super(const EmergencyState()) {
    on<SendSafeStatusEvent>(_onSendSafeStatus);
    on<LoadEmergencyStatusEvent>(_onLoadStatus);
    on<TriggerSmsFallbackEvent>(_onSmsFallback);
    on<ResetEmergencyEvent>(_onReset);
  }

  Future<void> _onSendSafeStatus(
    SendSafeStatusEvent event,
    Emitter<EmergencyState> emit,
  ) async {
    emit(state.copyWith(status: EmergencyStatus.loading));

    // Check connectivity first
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      // Offline: trigger SMS fallback
      emit(state.copyWith(
        status: EmergencyStatus.offline,
        errorMessage: 'İnternet bağlantısı yok. SMS ile bildirim gönderilecek.',
      ));
      await _analyticsService.logSmsFallback(event.contacts.length);
      return;
    }

    // Get FCM tokens from contacts (in a real app, stored in Firestore)
    final contactTokens = event.contacts
        .where((c) => c.fcmToken != null)
        .map((c) => c.fcmToken!)
        .toList();

    final contactAppUserIds = event.contacts
        .where((c) => c.appUserId != null)
        .map((c) => c.appUserId!)
        .toList();

    final result = await _sendSafeStatusUseCase(
      SendSafeStatusParams(
        uid: event.uid,
        userName: event.userName,
        contactTokens: contactTokens,
        contactAppUserIds: contactAppUserIds,
        status: event.status,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: EmergencyStatus.error,
        errorMessage: failure.message,
      )),
      (status) {
        emit(state.copyWith(
          status: EmergencyStatus.sent,
          activeStatus: status,
          notifiedCount: event.contacts.length,
        ));
        _analyticsService.logEmergencyStatusSent();
      },
    );
  }

  Future<void> _onLoadStatus(
    LoadEmergencyStatusEvent event,
    Emitter<EmergencyState> emit,
  ) async {
    // Status loading is handled via stream in the repository
    // This event is for one-off loads if needed
  }

  Future<void> _onSmsFallback(
    TriggerSmsFallbackEvent event,
    Emitter<EmergencyState> emit,
  ) async {
    if (event.contacts.isEmpty) {
      emit(state.copyWith(
        status: EmergencyStatus.error,
        errorMessage: 'Acil durum kontağı eklenmemiş. Lütfen önce kontağ ekleyin.',
      ));
      return;
    }

    // Send SMS to first contact (user will send to each manually)
    final firstContact = event.contacts.first;
    final message =
        '${AppConstants.defaultSmsMessage}\n- ${event.userName}';

    final smsUri = Uri.parse(
        'sms:${firstContact.phone}?body=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
      emit(state.copyWith(
        status: EmergencyStatus.smsFallbackTriggered,
        smsPhone: firstContact.phone,
        smsMessage: message,
      ));
      await _analyticsService.logSmsFallback(event.contacts.length);
    } else {
      emit(state.copyWith(
        status: EmergencyStatus.error,
        errorMessage: 'SMS gönderme açılamadı',
      ));
    }
  }

  void _onReset(
    ResetEmergencyEvent event,
    Emitter<EmergencyState> emit,
  ) {
    emit(const EmergencyState());
  }
}
