import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/RegisterRepository.dart';
import 'event/ProfileEvent.dart';
import 'state/ProfileState.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final RegisterRepositoryImpl registerRepository;

  ProfileBloc(this.registerRepository) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  void _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      // Get user data from Firestore
      final userData = await registerRepository.getUserData(event.uid);
      if (userData != null) {
        emit(ProfileLoaded(userData));
      } else {
        emit(ProfileError('User data not found'));
      }
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  void _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    try {
      final userData = await registerRepository.getUserData(event.uid);
      final role = userData?['Role']?.toString();

      if (role == 'user') {
        await registerRepository.updateUserDetails(event.uid, event.details);
      } else if (role == 'owner') {
        await registerRepository.updateOwnerDetails(event.uid, event.details);
      }

      emit(ProfileUpdated('Profile updated successfully'));
    } catch (e) {
      emit(ProfileError('Failed to update profile: $e'));
    }
  }
}
