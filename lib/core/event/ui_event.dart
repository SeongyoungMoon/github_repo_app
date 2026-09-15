sealed class UiEvent {}

class ShowSnackBarEvent extends UiEvent {
  final String message;

  ShowSnackBarEvent(this.message);
}
