//
//  ClapperboardApp.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 15/10/2025.
//

import SwiftUI
import Sentry
import GoogleMobileAds
import ClapperboardCore

@main
struct ClapperboardApp: App {
    
    @AppStorage(UserDefaults.Keys.appearanceMode, store: UserDefaults.appGroup)
    private var appearanceModeRaw: String = AppearanceMode.system.rawValue
    
    private var appearanceMode: AppearanceMode {
        AppearanceMode(rawValue: appearanceModeRaw) ?? .system
    }
    
    init() {
        
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
            "5AF1DB3B-AA9A-439D-8C60-D66304E7E725"
        ]
        
        SentrySDK.start { options in
            options.dsn = "https://0e62762dba491e3da941388f48e6a958@o4509298667094016.ingest.de.sentry.io/4511089404608592"
            
            // Adds IP for users.
            // For more information, visit: https://docs.sentry.io/platforms/apple/data-management/data-collected/
            options.sendDefaultPii = true
            
#if DEBUG
            options.debug = true
            options.diagnosticLevel = .debug
            
            options.tracesSampleRate = 1
            
            options.configureProfiling = {
                $0.sessionSampleRate = 1
                $0.lifecycle = .trace
            }
            
#else
            options.debug = false
            options.diagnosticLevel = .error
            
            // Set tracesSampleRate to 0.1 to capture 10% of transactions for performance monitoring.
            options.tracesSampleRate = 0.1
            
            // Configure profiling. Visit https://docs.sentry.io/platforms/apple/profiling/ to learn more.
            options.configureProfiling = {
                $0.sessionSampleRate = 0.1
                $0.lifecycle = .trace
            }
            
#endif
        }
        
        MobileAds.shared.start { status in
            print("Adapter statuses: \(status.adapterStatusesByClassName)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(appearanceMode.colorScheme)
        }
    }
}
