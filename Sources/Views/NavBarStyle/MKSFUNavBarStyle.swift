//
//  MKSFUNavBarStyle.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/29.
//

import SwiftUI
import MKBaseSwiftModule

// 专门为 SwiftUI 在 TabBar 中的导航栏样式
public struct MKSFUNavBarStyle: ViewModifier {
    let title: String
    let titleFont: Font
    let showBackButton: Bool
    let showRightButton: Bool
    let rightButtonIcon: String?
    let onBack: (() -> Void)?
    let onRightButton: (() -> Void)?
    
    @Environment(\.presentationMode) var presentationMode
    @State private var isFirstAppear = true
    
    public init(
        title: String,
        titleFont: Font = .headline,
        showBackButton: Bool = true,
        showRightButton: Bool = false,
        rightButtonIcon: String? = nil,
        onBack: (() -> Void)? = nil,
        onRightButton: (() -> Void)? = nil
    ) {
        self.title = title
        self.titleFont = titleFont
        self.showBackButton = showBackButton
        self.showRightButton = showRightButton
        self.rightButtonIcon = rightButtonIcon
        self.onBack = onBack
        self.onRightButton = onRightButton
    }
    
    public func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 标题
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(titleFont)
                        .foregroundColor(.white)
                        .bold()
                }
                
                // 返回按钮
                ToolbarItem(placement: .navigationBarLeading) {
                    if showBackButton && presentationMode.wrappedValue.isPresented {
                        Button(action: {
                            onBack?() ?? presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 4) {
                                if let backImage = UIImage(named: "mk_swiftUI_back_button_white", in: .module, compatibleWith: nil) {
                                    Image(uiImage: backImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 11, height: 21)
                                } else {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    } else if showBackButton {
                        EmptyView()
                    }
                }
                
                // 右侧按钮
                ToolbarItem(placement: .navigationBarTrailing) {
                    if showRightButton, let iconName = rightButtonIcon {
                        Button(action: {
                            onRightButton?()
                        }) {
                            if let rightImage = UIImage(named: iconName, in: .module, compatibleWith: nil) {
                                Image(uiImage: rightImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 21, height: 21)
                            } else {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .font(.system(size: 17, weight: .medium))
                            }
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                // SwiftUI 导航栏第一次显示时需要强制刷新
                if isFirstAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        forceNavigationBarRefresh()
                    }
                    isFirstAppear = false
                }
            }
    }
    
    private func forceNavigationBarRefresh() {
        // 找到当前活跃的导航控制器并强制刷新
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else { return }
        
        // 递归查找当前显示的导航控制器
        if let navController = findCurrentNavigationController(from: rootViewController) {
            // 强制导航栏重新应用样式
            navController.navigationBar.setNeedsLayout()
            navController.navigationBar.layoutIfNeeded()
            
            // 确保导航栏不透明
            navController.navigationBar.isTranslucent = false
        }
    }
    
    private func findCurrentNavigationController(from viewController: UIViewController) -> UINavigationController? {
        // 如果是导航控制器且正在显示
        if let navController = viewController as? UINavigationController,
           navController.viewIfLoaded?.window != nil {
            return navController
        }
        
        // 检查当前显示的子控制器
        if let presentedVC = viewController.presentedViewController {
            if let navController = findCurrentNavigationController(from: presentedVC) {
                return navController
            }
        }
        
        // 检查子控制器
        for child in viewController.children {
            if let navController = findCurrentNavigationController(from: child) {
                return navController
            }
        }
        
        // 如果是 TabBarController，检查选中的控制器
        if let tabBarController = viewController as? UITabBarController,
           let selectedVC = tabBarController.selectedViewController {
            return findCurrentNavigationController(from: selectedVC)
        }
        
        return nil
    }
}

// 专门用于 TabBar 中 SwiftUI 根页面的导航栏样式
public struct MKSFURootNavBarStyle: ViewModifier {
    let title: String
    let titleFont: Font
    let showRightButton: Bool
    let rightButtonIcon: String?
    let onRightButton: (() -> Void)?
    
    @State private var isFirstAppear = true
    
    public init(
        title: String,
        titleFont: Font = .headline,
        showRightButton: Bool = false,
        rightButtonIcon: String? = nil,
        onRightButton: (() -> Void)? = nil
    ) {
        self.title = title
        self.titleFont = titleFont
        self.showRightButton = showRightButton
        self.rightButtonIcon = rightButtonIcon
        self.onRightButton = onRightButton
    }
    
    public func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 标题
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(titleFont)
                        .foregroundColor(.white)
                        .bold()
                }
                
                // 右侧按钮
                ToolbarItem(placement: .navigationBarTrailing) {
                    if showRightButton, let iconName = rightButtonIcon {
                        Button(action: {
                            onRightButton?()
                        }) {
                            if let rightImage = UIImage(named: iconName, in: .module, compatibleWith: nil) {
                                Image(uiImage: rightImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 21, height: 21)
                            } else {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .font(.system(size: 17, weight: .medium))
                            }
                        }
                    }
                }
            }
            .onAppear {
                // SwiftUI 导航栏第一次显示时需要强制刷新
                if isFirstAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        forceNavigationBarRefresh()
                    }
                    isFirstAppear = false
                }
            }
    }
    
    private func forceNavigationBarRefresh() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else { return }
        
        if let navController = findCurrentNavigationController(from: rootViewController) {
            navController.navigationBar.setNeedsLayout()
            navController.navigationBar.layoutIfNeeded()
            navController.navigationBar.isTranslucent = false
        }
    }
    
    private func findCurrentNavigationController(from viewController: UIViewController) -> UINavigationController? {
        if let navController = viewController as? UINavigationController,
           navController.viewIfLoaded?.window != nil {
            return navController
        }
        
        if let presentedVC = viewController.presentedViewController {
            if let navController = findCurrentNavigationController(from: presentedVC) {
                return navController
            }
        }
        
        for child in viewController.children {
            if let navController = findCurrentNavigationController(from: child) {
                return navController
            }
        }
        
        if let tabBarController = viewController as? UITabBarController,
           let selectedVC = tabBarController.selectedViewController {
            return findCurrentNavigationController(from: selectedVC)
        }
        
        return nil
    }
}

// 使用扩展方便调用
public extension View {
    func withNavBar(
        title: String,
        titleFont: Font = .headline,
        showBackButton: Bool = true,
        showRightButton: Bool = false,
        rightButtonIcon: String? = nil,
        onBack: (() -> Void)? = nil,
        onRightButton: (() -> Void)? = nil
    ) -> some View {
        self.modifier(MKSFUNavBarStyle(
            title: title,
            titleFont: titleFont,
            showBackButton: showBackButton,
            showRightButton: showRightButton,
            rightButtonIcon: rightButtonIcon,
            onBack: onBack,
            onRightButton: onRightButton
        ))
    }
    
    func withRootNavBar(
        title: String,
        titleFont: Font = .headline,
        showRightButton: Bool = false,
        rightButtonIcon: String? = nil,
        onRightButton: (() -> Void)? = nil
    ) -> some View {
        self.modifier(MKSFURootNavBarStyle(
            title: title,
            titleFont: titleFont,
            showRightButton: showRightButton,
            rightButtonIcon: rightButtonIcon,
            onRightButton: onRightButton
        ))
    }
}

// 预览
struct MKSFUNavBarStyle_Preview: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink("跳转到子页面") {
                    VStack {
                        Text("子页面内容")
                            .padding()
                    }
                    .withNavBar(title: "子页面", showRightButton: true)
                }
                .padding()
            }
            .withRootNavBar(
                title: "首页",
                showRightButton: true,
                rightButtonIcon: "mk_swiftUI_slotSaveIcon"
            )
        }
    }
}

#Preview {
    MKSFUNavBarStyle_Preview()
}
