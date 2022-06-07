//
//  File.swift
//  RMS
//
//  Created by Hung Lam on 06/05/2022.
//

import UIKit
import WebKit
import SwiftUI

struct RMSView: UIViewRepresentable {
    var webVC = WebViewController()

    func makeUIView(context: Context) -> UIView {
        webVC.view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

