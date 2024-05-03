part of 'subscription_bloc.dart';

class SubscriptionState extends Equatable {
  const SubscriptionState({required this.subscription});

  final Subscription subscription;

  @override
  List<Object> get props => [subscription];

  SubscriptionState copyWith({Subscription? subsription}) {
    return SubscriptionState(
      subscription: subscription ?? this.subscription,
    );
  }
}
