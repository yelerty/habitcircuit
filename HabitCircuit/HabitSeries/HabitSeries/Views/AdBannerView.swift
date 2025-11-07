import SwiftUI
import GoogleMobileAds

struct AdBannerView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)

        // Test Ad Unit ID - Replace with your actual Ad Unit ID in production
        #if DEBUG
        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716" // Test Banner Ad Unit ID
        #else
        banner.adUnitID = "YOUR_PRODUCTION_AD_UNIT_ID" // Replace with your actual Ad Unit ID
        #endif

        // Get the root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootViewController
        }

        // Load ad
        banner.load(Request())

        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // No update needed
    }
}

struct AdBannerView_Previews: PreviewProvider {
    static var previews: some View {
        AdBannerView()
            .frame(height: 50)
            .background(Color.gray.opacity(0.1))
    }
}
