# MindTick
> Focus Smarter. Finish Stronger.

<div align="center">
  <!-- Placeholder for App UI Screenshots or Banner -->
  <img src="https://via.placeholder.com/800x200.png?text=MindTick+Banner" alt="MindTick Banner" width="100%">
</div>

## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## PROJECT OVERVIEW
## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**MindTick** is a modern, AI-powered focus timer built with Flutter and Google's Gemini AI. 

Designed to solve the modern productivity problem of digital distraction and burnout, MindTick provides the structure and encouragement needed to stay on track. The application combines a rigorous focus timer with dynamically generated AI motivation, helping users sustain deep work without losing momentum. 

By leveraging advanced asynchronous architecture, MindTick ensures precise timekeeping while delivering rich features like Text-to-Speech (TTS) announcements, comprehensive session analytics, and custom timer creation.

## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## FEATURES
## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- ✓ **Focus Sessions**
- ✓ **Custom Timer Creation**
- ✓ **AI-Powered Motivation**
- ✓ **Gemini Integration**
- ✓ **Text-to-Speech Announcements**
- ✓ **Analytics Dashboard**
- ✓ **Session Tracking**
- ✓ **Completion Statistics**
- ✓ **Pause / Resume Support**
- ✓ **Offline Fallback Messages**
- ✓ **Dark Theme UI**
- ✓ **Responsive Design**
- ✓ **Non-Blocking Timer Logic**

## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## TECH STACK
## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Frontend:**
- Flutter
- Dart

**AI:**
- Google Gemini API

**State Management:**
- Provider

**Storage:**
- SharedPreferences

**Speech:**
- `flutter_tts`

**Visualization:**
- `fl_chart`

**UI:**
- Material Design 3
- Google Fonts

## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## PROJECT ARCHITECTURE
## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```text
User
  ↓
MindTick App
  ↓
Timer Engine
  ↓
Checkpoint Manager
  ↓
Gemini Service
  ↓
Response Processor
  ↓
Text-To-Speech Service
  ↓
User Feedback
```

### Layer Responsibilities

- **UI Layer**: Handles rendering of the user interface, responding to state changes, and capturing user interactions seamlessly using Material Design 3.
- **Timer Layer**: Manages the core countdown logic, guaranteeing accurate timekeeping independent of UI frames or network latency.
- **AI Layer**: Interfaces with the Google Gemini API to dynamically generate context-aware motivational content during active sessions.
- **TTS Layer**: Converts text responses into spoken audio using native text-to-speech engine capabilities.
- **Analytics Layer**: Aggregates, processes, and prepares session data for visualization in the analytics dashboard.
- **Persistence Layer**: Manages local data storage to securely save analytics, session history, and user settings across app launches.

## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## ASYNC ARCHITECTURE
## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A core requirement for MindTick is ensuring precise timing while simultaneously handling network requests and audio playback. This is achieved through a strict **non-blocking asynchronous architecture**.

- **Future-Based Execution**: Network requests to Gemini and TTS generation utilize Dart's `Future` and `async/await` patterns to avoid blocking the main isolate.
- **Background Processing**: The countdown timer operates independently from the Gemini API requests. A UI ticker updates the clock seamlessly, completely decoupled from data-fetching delays.
- **Non-Blocking Architecture**: When a timer reaches a specific milestone (checkpoint event), it triggers asynchronous tasks without pausing or delaying the countdown clock. The UI remains fully responsive.
- **Independent TTS**: Text-to-Speech execution runs entirely decoupled from timer updates, ensuring announcements play smoothly without stalling the visual countdown.
- **Fallback Handling**: If asynchronous tasks fail or time out, the system falls back to localized synchronous operations without interrupting the user's focus session.

## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## AI IMPLEMENTATION
## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MindTick integrates the **Google Gemini API** to deliver context-aware, highly personalized motivational messages. As the user reaches predefined focus milestones, Gemini evaluates the context and generates tailored encouragement.

To guarantee an uninterrupted experience, robust fallback mechanics handle all edge cases:
- **Internet is Unavailable**: Instantly shifts to local, on-device motivational quotes.
- **Gemini Fails**: Graceful degradation to pre-configured positive affirmations.
- **Rate Limits Occur**: Intelligent detection of API limits triggers cached fallback messages.
- **Timeouts Occur**: If the API response exceeds the threshold, the request is abandoned in favor of local messaging to prevent latency.

## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## TEXT TO SPEECH
## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Generated AI messages are brought to life via the `flutter_tts` package, delivering hands-free audio announcements.
- The conversion of text to speech runs completely asynchronously.
- A speech lifecycle management queue actively prevents overlapping announcements, ensuring that rapid consecutive checkpoint triggers are handled cleanly.

## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## ANALYTICS
## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MindTick tracks and persists vital productivity metrics locally using `SharedPreferences`:
- **Session Count**: The total number of focus sessions initiated.
- **Total Focus Time**: The cumulative number of minutes spent in focus mode.
- **Completion Rate**: The percentage of sessions successfully completed versus paused/cancelled.
- **Focus Statistics**: Visual charts rendering daily and weekly trends.

## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## ASSIGNMENT QUESTIONS
## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**How did you structure the API calls to ensure the timer didn't freeze?**
We structured the Gemini API network requests using Dart's non-blocking `Future` and `async/await` patterns. By completely decoupling the timer's `Ticker` engine from the AI service layer, the countdown clock updates independently on the main UI thread. Checkpoint events trigger API requests asynchronously in the background, ensuring that network latency or timeouts never stall the timer's visual progress.

**If you used an AI assistant to help write this, what was the biggest mistake the AI made that you had to fix manually?**
The biggest mistake the AI made was generating a `BoxDecoration` that combined a non-uniform border (`Border.symmetric`) with a `borderRadius`. This is unsupported in Flutter and caused a severe rendering exception (`A borderRadius can only be given on borders with uniform colors`), which completely prevented the custom timer modal from painting on the screen. I had to manually diagnose the crash from the debug logs and refactor the code to use uniform borders (`Border.all`) to restore the UI.

## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## INSTALLATION
## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Clone the repository:
```bash
git clone https://github.com/Anxhhhh/ai-timer-clock.git
cd ai-timer-clock
```

2. Get Flutter dependencies:
```bash
flutter pub get
```

3. Create the environment configuration file:
Create a `.env` file in the project root.

4. Run the application:
```bash
flutter run
```

## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## ENVIRONMENT VARIABLES
## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The project requires a Google Gemini API key to run fully. Add the following to your `.env` file:

```env
GEMINI_API_KEY=YOUR_API_KEY
```

> [!WARNING]
> API keys should **never** be committed to version control. Make sure your `.env` file is added to your `.gitignore`.

## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## BUILD INSTRUCTIONS
## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

To compile a production-ready application for Android:

```bash
flutter build apk --release
```

The output APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## FUTURE IMPROVEMENTS
## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- **Cloud Sync**
- **User Accounts**
- **AI Productivity Insights**
- **Session History**
- **Notifications**
- **Cross Device Sync**

---
<div align="center">
  <i>Built with Flutter & Google Gemini</i>
</div>
