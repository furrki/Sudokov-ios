//
//  AdView.swift
//  Sudokov
//
//  Created by furrki on 5.10.2022.
//

import GoogleMobileAds
import SwiftUI
import UIKit

struct AdView: UIViewRepresentable {
    @State private var banner: GADBannerView = GADBannerView(adSize: GADAdSizeBanner)

    func makeUIView(context: UIViewRepresentableContext<AdView>) -> GADBannerView {
        #if DEBUG
        banner.adUnitID = KeysConfiguration.testBannerAdId
        #else
        banner.adUnitID = KeysConfiguration.bannerAdId
        #endif

        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return banner
        }

        banner.rootViewController = rootViewController

        let frame = { () -> CGRect in
            return rootViewController.view.frame.inset(by: rootViewController.view.safeAreaInsets)
        }()
        
        let viewWidth = frame.size.width

        banner.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        banner.load(GADRequest())
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: UIViewRepresentableContext<AdView>) {
    }
}
