//
//  BannerView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 25/06/2026.
//

import SwiftUI
import GoogleMobileAds

final class BannerCoordinator: NSObject, BannerViewDelegate {
    var onAdLoaded: (() -> Void)?
    var onAdFailed: ((Error) -> Void)?

    private var retryCount = 0
    private let maxRetries = 3
    private weak var bannerView: BannerView?

    func attach(to bannerView: BannerView) {
        self.bannerView = bannerView
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            print("Ad failed to load: \(error.localizedDescription)")
            self.onAdFailed?(error)

            // "Invalid ad width or height" means the AdSize itself is broken,
            // not a transient network/no-fill issue. Retrying will just repeat
            // the same failure forever, so bail out immediately in that case.
            if error.localizedDescription.contains("Invalid ad width or height") {
                print("Ad size is invalid, not retrying (this is a sizing bug, not a network issue)")
                return
            }

            self.scheduleRetryIfNeeded()
        }
    }

    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        DispatchQueue.main.async { [weak self] in
            self?.retryCount = 0
            self?.onAdLoaded?()
        }
    }

    private func scheduleRetryIfNeeded() {
        guard retryCount < maxRetries else {
            print("Ad load retries exhausted, giving up for this session")
            return
        }
        retryCount += 1
        // Exponential backoff: 5s, 10s, 20s
        let delay = 5.0 * pow(2.0, Double(retryCount - 1))
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self, let bannerView = self.bannerView else { return }
            bannerView.load(Request())
        }
    }
}

struct AdBannerView: UIViewRepresentable {
    let adUnitID: String
    let adSize: AdSize

    /// Called on the main thread when the ad successfully loads or fails,
    /// so the parent view can decide whether to reserve space for it.
    var onStateChange: ((Bool) -> Void)? = nil

    func makeCoordinator() -> BannerCoordinator {
        BannerCoordinator()
    }

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = adUnitID
        banner.delegate = context.coordinator
        context.coordinator.attach(to: banner)

        context.coordinator.onAdLoaded = {
            onStateChange?(true)
        }
        context.coordinator.onAdFailed = { _ in
            onStateChange?(false)
        }

        loadAd(into: banner)
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // If the root VC wasn't available at creation time, try again here,
        // since updateUIView is called again once SwiftUI re-evaluates the tree.
        if uiView.rootViewController == nil {
            attachRootViewController(to: uiView)
        }
    }

    private func loadAd(into banner: BannerView) {
        attachRootViewController(to: banner)

        // Defend against a zero/invalid size making it this far — the SDK
        // will otherwise fail the load with "Invalid ad width or height"
        // every single time, which is not a transient/network issue and
        // will not be fixed by retrying.
        guard adSize.size.width > 0, adSize.size.height > 0 else {
            print("AdBannerView: refusing to load, adSize is invalid (\(adSize.size))")
            return
        }

        banner.load(Request())
    }

    private func attachRootViewController(to banner: BannerView) {
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?.rootViewController else {
            print("AdBannerView: no root view controller available yet")
            return
        }
        banner.rootViewController = rootVC
    }
}

private enum LoadState {
    case pending   // not yet attempted — reserve space so layout can happen
    case loaded    // ad showing — keep the space
    case failed    // gave up — collapse to nothing
}

/// Wrapper that collapses to zero height if the ad fails to load,
/// so you never end up with dead blank space in a fixed-height List/VStack.
struct CollapsibleAdBannerView: View {
    let adUnitID: String
    
    @State private var loadState: LoadState = .pending

    private var reservesSpace: Bool {
        loadState != .failed
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            if width > 0 {
                AdBannerView(
                    adUnitID: adUnitID,
                    adSize: largeAnchoredAdaptiveBanner(width: width)
                ) { loaded in
                    loadState = loaded ? .loaded : .failed
                }
            } else {
                Color.clear
            }
        }
        .frame(height: reservesSpace ? 60 : 0)
        .opacity(loadState == .failed ? 0 : 1)
        .animation(.easeInOut(duration: 0.2), value: loadState == .failed)
    }
}

extension LoadState: Equatable {}
