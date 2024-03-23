import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/popups/models/inital_popup_type.dart';
import 'package:mamba/settings/data/settings_repository.dart';
import 'popups_state.dart';

class PopupsCubit extends Cubit<PopupState> {
  final SettingsRepository settingsRepository;

  PopupsCubit({required this.settingsRepository})
      : super(const PopupsInitial());

  Future<void> checkForForceAppUpdate() async {
    print(1);
    // Check App Version
    List<bool> result = await settingsRepository.checkAppVersion();
    // If result[0] == true, it needs to Update Dialog.
    // If result[1] == true, it needs to Force the Udate
    if (result[0]) {
      emit(
        InitialPopupLoaded(
          type: InitalPopupType.app_update,
          forceAppUpdate: result[1],
        ),
      );
    }
  }

  // You can add similar methods for other pop-ups like rate app, give feedback, etc.
}
