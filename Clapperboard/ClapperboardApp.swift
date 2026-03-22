//
//  ClapperboardApp.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 15/10/2025.
//

import SwiftUI
import Sentry


@main
struct ClapperboardApp: App {
    init() {
        SentrySDK.start { options in
            options.dsn = "https://0e62762dba491e3da941388f48e6a958@o4509298667094016.ingest.de.sentry.io/4511089404608592"

            // Adds IP for users.
            // For more information, visit: https://docs.sentry.io/platforms/apple/data-management/data-collected/
            options.sendDefaultPii = true

            // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
            // We recommend adjusting this value in production.
            options.tracesSampleRate = 1.0

            // Configure profiling. Visit https://docs.sentry.io/platforms/apple/profiling/ to learn more.
            options.configureProfiling = {
                $0.sessionSampleRate = 1.0 // We recommend adjusting this value in production.
                $0.lifecycle = .trace
            }

            // Uncomment the following lines to add more data to your events
            // options.attachScreenshot = true // This adds a screenshot to the error events
            // options.attachViewHierarchy = true // This adds the view hierarchy to the error events
            
            // Enable experimental logging features
            options.experimental.enableLogs = true
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
