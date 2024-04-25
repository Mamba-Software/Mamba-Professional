part of 'brand_bloc.dart';

class BrandState extends Equatable {
  const BrandState({required this.brand});

  final Brand brand;

  @override
  List<Object> get props => [brand];

  BrandState copyWith({Brand? brand}) {
    return BrandState(
      brand: brand ?? this.brand,
    );
  }
}
