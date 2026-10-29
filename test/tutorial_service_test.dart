import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/constants/constants.dart';
import 'package:medicard/core/tutorial/tutorial_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      SharedPrefKeys.medicardCardNo: 'customer-a',
    });
  });

  test('tracks tutorial completion separately for each customer', () async {
    expect(await TutorialService.shouldShow(), isTrue);

    await TutorialService.markSeen();
    expect(await TutorialService.shouldShow(), isFalse);

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(SharedPrefKeys.medicardCardNo, 'customer-b');
    expect(await TutorialService.shouldShow(), isTrue);

    await TutorialService.markSeen();
    expect(await TutorialService.shouldShow(), isFalse);

    await preferences.setString(SharedPrefKeys.medicardCardNo, 'customer-a');
    expect(await TutorialService.shouldShow(), isFalse);
  });

  test('reset only replays the current customer tutorial', () async {
    await TutorialService.markSeen();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(SharedPrefKeys.medicardCardNo, 'customer-b');
    await TutorialService.markSeen();

    await TutorialService.reset();
    expect(await TutorialService.shouldShow(), isTrue);

    await preferences.setString(SharedPrefKeys.medicardCardNo, 'customer-a');
    expect(await TutorialService.shouldShow(), isFalse);
  });
}
