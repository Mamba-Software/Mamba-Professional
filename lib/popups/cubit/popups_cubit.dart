import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/popups/models/inital_popup_type.dart';
import 'package:mamba/settings/data/settings_repository.dart';
import 'popups_state.dart';

class PopupsCubit extends Cubit<PopupState> {
  final SettingsRepository settingsRepository;

  PopupsCubit({required this.settingsRepository})
      : super(const PopupsInitial());

  Future<void> checkForForceAppUpdate() async {
    List<bool> result = await settingsRepository.checkAppVersion();
    print("Check App Update Result: $result"); // Debugging
    if (result[0]) {
      print("Emitting Update Required State"); // Debugging
      emit(
        InitialPopupLoaded(
          type: InitalPopupType.app_update,
          forceAppUpdate: result[1],
        ),
      );
    } else {
      await Future.delayed(Duration(seconds: 5));
      bool whatsNew = settingsRepository.getWhatsNewBoolean();
      if (!whatsNew) {
        String emailHTML = await settingsRepository.getProductUpdatesHTML();
        emit(
          InitialPopupLoaded(
            type: InitalPopupType.whats_new,
            html: emailHTML,
          ),
        );
      }
    }
  }
}
