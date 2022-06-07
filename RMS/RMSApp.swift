//
//  RMSApp.swift
//  RMS
//
//  Created by Hung Lam on 05/05/2022.
//

import SwiftUI

@main
struct RMSApp: App {
    var body: some Scene {
        WindowGroup {
            RMSView().edgesIgnoringSafeArea(.bottom).statusBar(hidden: false).background(.black)
        }
    }
}

// xcodebuild -scheme RMS build
// xcrun simctl list
// xcrun simctl boot "iPhone 13"
// xcrun simctl shutdown "iPhone 13"
// xcrun simctl install "iPhone 13" <Path to App>
// open -a simulator
// xcrun simctl launch booted EvidenceMobile.RMS
