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
  final Subscription subscription;

  const BrandSuscriptionLoadedTrue(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class BrandSuscriptionLoadedFalse extends BrandSuscriptionState {

  const BrandSuscriptionLoadedFalse();

  @override
  List<Object?> get props => [];
}