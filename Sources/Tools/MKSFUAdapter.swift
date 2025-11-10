//
//  MKSFUAdapter.swift
//  MKSwiftUILibrary
//
//  Created by aa on 2025/11/10.
//

import SwiftUI
import UIKit

public class MKSFUAdapter {
    
    /// 最简单的 SwiftUI 转 UIViewController
    /// - Parameter swiftUIView: SwiftUI 视图
    /// - Returns: UIViewController
    @MainActor public static func toController(_ swiftUIView: some View) -> UIViewController {
        return UIHostingController(rootView: swiftUIView)
    }
    
    /// SwiftUI 转带导航的 UIViewController
    /// - Parameter swiftUIView: SwiftUI 视图
    /// - Returns: 带导航的 UIViewController
    @MainActor public static func toNavigationController(_ swiftUIView: some View) -> UIViewController {
        let hostingController = UIHostingController(rootView: swiftUIView)
        return UINavigationController(rootViewController: hostingController)
    }
}
