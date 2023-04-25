part of 'BrandSuscriptionCubit.dart';

abstract class BrandSuscriptionState extends Equatable {
  const BrandSuscriptionState();
}

class BrandSuscriptionInitial extends BrandSuscriptionState {
  const BrandSuscriptionInitial();

  @override
  List<Object?> get props => [];
}

class BrandSuscriptionLoading extends BrandSuscriptionState {
  const BrandSuscriptionLoading();

  @override
  List<Object?> get props => [];
}

class BrandSuscriptionLoadedTrue extends BrandSuscriptionState {
  final String title;
  final String expirationDate;

  const BrandSuscriptionLoadedTrue(this.title, this.expirationDate);

  @override
  List<Object?> get props => [title, expirationDate];
}

class BrandSuscriptionLoadedFalse extends BrandSuscriptionState {

  const BrandSuscriptionLoadedFalse();

  @override
  List<Object?> get props => [];
}