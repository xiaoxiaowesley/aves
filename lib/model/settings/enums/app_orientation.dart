import 'package:aves/services/common/services.dart';
import 'package:aves/services/window_service.dart';
import 'package:aves_model/aves_model.dart';

extension ExtraAppOrientation on AppOrientation {
  void apply() {
    final service = windowService;
    if (service is PlatformWindowService) {
      int code;
      switch (this) {
        case AppOrientation.system:
          code = PlatformWindowService.screenOrientationUnspecified;
        case AppOrientation.portrait:
          code = PlatformWindowService.screenOrientationUserPortrait;
        case AppOrientation.landscape:
          code = PlatformWindowService.screenOrientationUserLandscape;
        case AppOrientation.reversePortrait:
          code = PlatformWindowService.screenOrientationReversePortrait;
        case AppOrientation.reverseLandscape:
          code = PlatformWindowService.screenOrientationReverseLandscape;
      }
      service.requestOrientationCode(code);
    }
  }
}
