part of 'brand_bloc.dart';

abstract class BrandState extends Equatable {
  const BrandState();
}

class BrandInitial extends BrandState {
  const BrandInitial();

  @override
  List<Object?> get props => [];
}

class BrandLoaded extends BrandState {  
  final Brand brand;
  
  const BrandLoaded({required this.brand});

  @override
  List<Object?> get props => [brand];

  BrandLoaded copyWith({Brand? brand}) {
    return BrandLoaded(
      brand: brand ?? this.brand,
    );
  }
}

class BrandError extends BrandState {
  final String message;
  const BrandError(this.message);

  @override
  List<Object?> get props => [message];
}