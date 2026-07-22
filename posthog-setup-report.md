<wizard-report>
# PostHog post-wizard report

The wizard has completed a deep integration of PostHog analytics into the Clapperboard iOS app. The PostHog iOS SDK (v3.67.0) was added to both the main Clapperboard target and the PhotoExtension target via Swift Package Manager. PostHog is initialized in `ClapperboardApp.init()` with lifecycle event capture enabled. The extension initializes PostHog independently with the shared app group (`group.com.aidanjbennett.clapperboard`) so both processes share identity. Eleven events are tracked across four files, covering the complete video export funnel, settings actions, and Photos extension usage.

| Event | Description | File |
|-------|-------------|------|
| `video_selected` | User selects a video from their photo library to add a clapperboard overlay. | `Clapperboard/ViewModels/AddClapperboardViewModel.swift` |
| `video_exported` | User successfully exports a video with the clapperboard overlay. | `Clapperboard/ViewModels/AddClapperboardViewModel.swift` |
| `export_failed` | A video export attempt failed with an error. | `Clapperboard/ViewModels/AddClapperboardViewModel.swift` |
| `video_shared` | User taps the share button to share the exported video. | `Clapperboard/Views/AddClapperboard/AddClapperboardView.swift` |
| `video_changed` | User discards the current video and starts over with a new selection. | `Clapperboard/ViewModels/AddClapperboardViewModel.swift` |
| `settings_reset` | User resets all settings to their default values. | `Clapperboard/ViewModels/SettingsViewModel.swift` |
| `feedback_sent` | User opens the feedback email composer. | `Clapperboard/ViewModels/SettingsViewModel.swift` |
| `scene_count_reset` | User resets the scene counter back to 1. | `Clapperboard/ViewModels/SettingsViewModel.swift` |
| `take_count_reset` | User resets the take counter back to 1. | `Clapperboard/ViewModels/SettingsViewModel.swift` |
| `extension_export_completed` | User successfully exports a clapperboard video from the Photos extension. | `PhotoExtension/ViewModels/ClapperboardViewModel.swift` |
| `extension_export_failed` | A clapperboard export from the Photos extension failed with an error. | `PhotoExtension/ViewModels/ClapperboardViewModel.swift` |

## Next steps

We've built some insights and a dashboard for you to keep an eye on user behavior, based on the events we just instrumented:

- [Analytics basics (wizard) — Dashboard](https://eu.posthog.com/project/230000/dashboard/840434)
- [Export conversion funnel (wizard)](https://eu.posthog.com/project/230000/insights/L5v938lp)
- [Video exports over time (wizard)](https://eu.posthog.com/project/230000/insights/RLqec51z)
- [Export failures (wizard)](https://eu.posthog.com/project/230000/insights/5mIqdtTv)
- [Settings resets (wizard)](https://eu.posthog.com/project/230000/insights/px0jVdU1)
- [Photos extension exports (wizard)](https://eu.posthog.com/project/230000/insights/snNfkryM)

## Verify before merging

- [ ] Run a full production build (the wizard only verified the files it touched) and fix any lint or type errors introduced by the generated code.
- [ ] Run the test suite — call sites that were rewritten or instrumented may need updated mocks or fixtures.
- [ ] Open the project in Xcode and let it resolve the new `posthog-ios` SPM package. Confirm the build succeeds on both the `Clapperboard` and `PhotoExtension` targets.
- [ ] Launch the app on device or simulator, perform a video export, and confirm `video_selected`, `video_exported`, and `video_shared` appear in PostHog's Live Events view.

### Agent skill

We've left an agent skill folder in your project. You can use this context for further agent development when using Claude Code. This will help ensure the model provides the most up-to-date approaches for integrating PostHog.

</wizard-report>
