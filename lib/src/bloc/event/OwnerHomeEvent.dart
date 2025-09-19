import 'package:equatable/equatable.dart';

abstract class OwnerHomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadOwnerHomeData extends OwnerHomeEvent {}

class RefreshOwnerHomeData extends OwnerHomeEvent {}
