/// Global feature flags for the application.
///
/// Toggle AI features on/off across the entire app.
/// When [isAiEnabled] is false:
///   - All AI UI elements are hidden (not just disabled).
///   - No AI API calls are made.
///   - AI modules/services are not loaded.
///   - App behaves normally with keyword-based fallbacks.
const bool isAiEnabled = false;
