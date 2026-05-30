import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final ProfileRepository _profileRepository;

  ProfileBloc(
    this._getProfileUseCase,
    this._updateProfileUseCase,
    this._profileRepository,
  ) : super(const ProfileState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<DeleteAccountEvent>(_onDeleteAccount);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    await emit.forEach(
      _getProfileUseCase.stream(event.uid),
      onData: (result) => result.fold(
        (failure) => state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        ),
        (profile) => state.copyWith(
          status: ProfileStatus.loaded,
          profile: profile,
        ),
      ),
      onError: (_, __) => state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Profil yüklenemedi',
      ),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.saving));

    final result = await _updateProfileUseCase(
      UpdateProfileParams(
        uid: event.uid,
        displayName: event.displayName,
        phone: event.phone,
        photoUrl: event.photoUrl,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.actionSuccess,
        successMessage: 'Profil başarıyla güncellendi',
        profile: profile,
      )),
    );
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await _profileRepository.deleteAccount(event.uid);
    result.fold(
      (failure) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: ProfileStatus.accountDeleted,
        successMessage: 'Hesap başarıyla silindi',
      )),
    );
  }
}
