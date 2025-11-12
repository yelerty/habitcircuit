import SwiftUI
import GoogleMobileAds

struct AdBannerView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)

        // Ad Unit ID - Test for DEBUG, Production for RELEASE
        #if DEBUG
        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716" // Test Banner Ad Unit ID
        print("📱 AdBannerView: Using TEST ad unit ID")
        #else
        banner.adUnitID = "ca-app-pub-5836154231142926/3107940294" // Production Banner Ad Unit ID
        print("📱 AdBannerView: Using PRODUCTION ad unit ID")
        #endif

        // Set delegate for ad events
        banner.delegate = context.coordinator

        // Get the root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootViewController
            print("✅ AdBannerView: Root view controller set")
        } else {
            print("⚠️ AdBannerView: Could not get root view controller")
        }

        // Load ad
        print("🔄 AdBannerView: Loading ad...")
        banner.load(Request())

        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // No update needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, BannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("✅ AdBannerView: Ad loaded successfully")
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("❌ AdBannerView: Failed to load ad - \(error.localizedDescription)")
        }

        func bannerViewDidRecordImpression(_ bannerView: BannerView) {
            print("👁️ AdBannerView: Ad impression recorded")
        }

        func bannerViewWillPresentScreen(_ bannerView: BannerView) {
            print("📱 AdBannerView: Will present ad screen")
        }

        func bannerViewWillDismissScreen(_ bannerView: BannerView) {
            print("📱 AdBannerView: Will dismiss ad screen")
        }

        func bannerViewDidDismissScreen(_ bannerView: BannerView) {
            print("📱 AdBannerView: Did dismiss ad screen")
        }
    }
}

struct AdBannerView_Previews: PreviewProvider {
    static var previews: some View {
        AdBannerView()
            .frame(height: 50)
            .background(Color.gray.opacity(0.1))
    }
}
