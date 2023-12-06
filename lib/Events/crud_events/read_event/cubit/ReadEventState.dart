part of 'ReadEventCubit.dart';

class ReadEventLoaded extends Equatable {
  final Event event;
  final bool isLoaded;
  final List<String> userIsBlockedBy;
  final List<double?> eventClientsFeedback;

  const ReadEventLoaded(
    this.event,
    this.isLoaded,
    this.userIsBlockedBy,
    this.eventClientsFeedback,
  );

  @override
  List<Object?> get props => [
        event,
        isLoaded,
        userIsBlockedBy,
        eventClientsFeedback,
      ];
}
