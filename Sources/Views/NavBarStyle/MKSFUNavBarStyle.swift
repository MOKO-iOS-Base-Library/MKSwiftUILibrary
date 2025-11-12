//
//  MKSFUNavBarStyle.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/29.
//

import SwiftUI
import MKBaseSwiftModule

// 定义统一的导航栏样式
public struct MKSFUNavBarStyle: ViewModifier {
    let title: String
    let titleFont: Font
    let showBackButton: Bool
    let showRightButton: Bool
    let rightButtonIcon: String?
    let backgroundColor: Color
    let onBack: (() -> Void)?
    let onRightButton: (() -> Void)?
    
    @Environment(\.presentationMode) var presentationMode
    
    public init(
        title: String,
        titleFont: Font = .headline,
        showBackButton: Bool = true,
        showRightButton: Bool = false,
        rightButtonIcon: String? = nil,
        backgroundColor: Color = Color(MKColor.navBar),
        onBack: (() -> Void)? = nil,
        onRightButton: (() -> Void)? = nil
    ) {
        self.title = title
        self.titleFont = titleFont
        self.showBackButton = showBackButton
        self.showRightButton = showRightButton
        self.rightButtonIcon = rightButtonIcon
        self.backgroundColor = backgroundColor
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
                setupNavigationBarAppearance()
            }
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(backgroundColor)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        
        // 设置按钮样式
        appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
    }
}

// 专门用于根页面的导航栏样式（没有返回按钮）
public struct MKSFURootNavBarStyle: ViewModifier {
    let title: String
    let titleFont: Font
    let showRightButton: Bool
    let rightButtonIcon: String?
    let backgroundColor: Color
    let onRightButton: (() -> Void)?
    
    public init(
        title: String,
        titleFont: Font = .headline,
        showRightButton: Bool = false,
        rightButtonIcon: String? = nil,
        backgroundColor: Color = Color(MKColor.navBar),
        onRightButton: (() -> Void)? = nil
    ) {
        self.title = title
        self.titleFont = titleFont
        self.showRightButton = showRightButton
        self.rightButtonIcon = rightButtonIcon
        self.backgroundColor = backgroundColor
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
                setupNavigationBarAppearance()
            }
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(backgroundColor)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
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
        backgroundColor: Color = Color(MKColor.navBar),
        onBack: (() -> Void)? = nil,
        onRightButton: (() -> Void)? = nil
    ) -> some View {
        self.modifier(MKSFUNavBarStyle(
            title: title,
            titleFont: titleFont,
            showBackButton: showBackButton,
            showRightButton: showRightButton,
            rightButtonIcon: rightButtonIcon,
            backgroundColor: backgroundColor,
            onBack: onBack,
            onRightButton: onRightButton
        ))
    }
    
    func withRootNavBar(
        title: String,
        titleFont: Font = .headline,
        showRightButton: Bool = false,
        rightButtonIcon: String? = nil,
        backgroundColor: Color = Color(MKColor.navBar),
        onRightButton: (() -> Void)? = nil
    ) -> some View {
        self.modifier(MKSFURootNavBarStyle(
            title: title,
            titleFont: titleFont,
            showRightButton: showRightButton,
            rightButtonIcon: rightButtonIcon,
            backgroundColor: backgroundColor,
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
