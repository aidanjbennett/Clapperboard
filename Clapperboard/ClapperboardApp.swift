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

            // Set tracesSampleRate to 0.1 to capture 10% of transactions for performance monitoring.
            options.tracesSampleRate = 0.1

            // Configure profiling. Visit https://docs.sentry.io/platforms/apple/profiling/ to learn more.
            options.configureProfiling = {
                $0.sessionSampleRate = 0.1
                $0.lifecycle = .trace
            }
            
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
