part of 'stripe_connect_cubit.dart';

@immutable
sealed class StripeConnectState {}

final class StripeConnectInitial extends StripeConnectState {}

final class Loading extends StripeConnectState {}

final class StripeConnectGettingLink extends StripeConnectState {}

final class StripeConnectGetLinkSuccess extends StripeConnectState {
  final String url;
  StripeConnectGetLinkSuccess(this.url);
}

final class StripeConnectGetLinkError extends StripeConnectState {
  final String error;
  StripeConnectGetLinkError(this.error);
}

final class StripeConnectWebLoading extends StripeConnectState {}

final class StripeConnectWebLoaded extends StripeConnectState {
  StripeConnectWebLoaded();
}

final class StripeConnectWebError extends StripeConnectState {
  final String error;
  StripeConnectWebError(this.error);
}

final class StripeConnectSuccess extends StripeConnectState {
  final Brand user;
  StripeConnectSuccess(this.user);
}
