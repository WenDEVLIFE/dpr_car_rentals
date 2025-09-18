import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String uid;

  LoadProfile(this.uid);

  @override
  List<Object?> get props => [uid];
}

class UpdateProfile extends ProfileEvent {
  final String uid;
  final Map<String, dynamic> details;

  UpdateProfile(this.uid, this.details);

  @override
  List<Object?> get props => [uid, details];
}
