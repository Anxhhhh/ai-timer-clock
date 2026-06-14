# AI-Powered Timer App

A premium, glassmorphic focus timer app that integrates Gemini AI to provide dynamic motivational messages at specific checkpoints during a focus session, paired with Text-to-Speech (TTS).

## Project Overview

This app goes beyond a simple countdown timer by acting as an AI productivity assistant. It allows users to:
- Select preset durations or create highly customized timers.
- Receive AI-recommended session parameters based on task inputs.
- Automatically receive contextually aware voice motivation exactly when they need it: halfway through, at the 10-second mark, and upon completion.
- View productivity metrics on a dedicated Analytics Dashboard.
- Customize app settings via a unified Settings Dashboard.

## Setup Instructions

1. Ensure you have the Flutter SDK (>=3.12.0) installed.
2. Clone this repository.
3. Run `flutter pub get` to download all necessary dependencies.
4. Set up your `.env` file (see Environment Variables below).
5. Ensure you have an active emulator or connected device.
6. Run `flutter run`.

## Environment Variables

This project uses the `flutter_dotenv` package to securely load the Gemini API key.

1. Create a file named `.env` in the root directory of the project.
2. Add your Gemini API key in the following format:
   ```env
   GEMINI_API_KEY=your_api_key_here
   ```
*(A `.env.example` file is included in the repository for reference).*

## APK Build Instructions

To build a release APK for Android, run the following command in your terminal from the root directory:

```bash
flutter build apk --release
```

The compiled APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## Internship Assignment Answers

### 1. How did you ensure the timer never froze during Gemini API calls?

To prevent the timer from freezing, I implemented a strict non-blocking asynchronous architecture. The `_onTick` method in the `FocusTimerController` (which runs every 1 second) is completely synchronous. 

Instead of pausing the tick loop to `await` the Gemini response, the `_onTick` method simply evaluates the state (e.g., checking if `remainingSeconds == 10`) and dispatches a fire-and-forget asynchronous function (`_handleCheckpoint`). 

```dart
// Checkpoint detected synchronously
if (remaining == 10 && !_tenSecondsTriggered) {
  _tenSecondsTriggered = true;
  _handleCheckpoint('10seconds'); // Fired asynchronously without `await`
}
```

The `_handleCheckpoint` method then independently calls the `GeminiService` and the `TtsService`. Because Dart handles `async` methods by scheduling them on the microtask and event queues, the synchronous timer execution immediately continues on its scheduled 1-second interval without waiting for network I/O. Furthermore, the `GeminiService` includes a `.timeout` duration to ensure the background task doesn't hang indefinitely if the network is poor.

### 2. What was the biggest AI-generated code issue that required manual fixing?

The most significant AI-generated issue was related to Flutter's state lifecycle and the use of the `late` keyword for the `FocusTimerController`. 

When iterating rapidly using Flutter's Hot Reload, the AI provided a solution where `_controller` was defined as `late` and initialized inside `initState()`. However, because `initState()` is only called once when a widget is inserted into the tree, applying a Hot Reload on a live widget preserved the `State` object but did not run `initState()` again. This resulted in a persistent `LateInitializationError` because the new `late` field was accessed in the `build()` method before it was ever initialized.

To manually fix this, I refactored the controller to use inline lazy initialization:

```dart
late final FocusTimerController _controller = FocusTimerController(...);
```

By initializing it directly at the declaration site, Dart's lazy evaluation guarantees the controller is instantiated the exact moment it is first accessed (e.g., during the first `build` pass after the Hot Reload), entirely eliminating the crash without requiring the developer to perform a full Hot Restart.
# ai-timer-clock
