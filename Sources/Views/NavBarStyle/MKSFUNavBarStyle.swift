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
    let showRightButton: Bool // 新增：控制是否显示右上角按钮
    let rightButtonIcon: String? // 重命名：右上角按钮图标名称
    let backgroundColor: Color
    let onBack: (() -> Void)?
    let onRightButton: (() -> Void)? // 重命名：右上角按钮回调
    
    @Environment(\.presentationMode) var presentationMode
    
    public init(
        title: String,
        titleFont: Font = .headline,
        showBackButton: Bool = true, // 默认显示返回按钮
        showRightButton: Bool = false, // 默认隐藏右上角按钮
        rightButtonIcon: String? = nil, // 默认不显示右上角按钮
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
                // 标题 - 使用 .principal 确保居中
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(titleFont)
                        .foregroundColor(.white)
                        .bold()
                }
                
                // 左侧返回按钮 - 默认显示
                ToolbarItem(placement: .navigationBarLeading) {
                    if showBackButton && presentationMode.wrappedValue.isPresented {
                        Button(action: {
                            onBack?() ?? presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 4) {
                                // 使用模块中的图标，如果找不到则使用系统图标
                                if let backImage = UIImage(named: "mk_swiftUI_back_button_white", in: .module, compatibleWith: nil) {
                                    Image(uiImage: backImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 11, height: 21)
                                } else {
                                    // 备用系统图标
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    } else if showBackButton {
                        // 如果是根页面但需要显示返回按钮，可以显示其他内容或留空
                        EmptyView()
                    }
                }
                
                // 右侧按钮 - 默认隐藏，需要时显示
                ToolbarItem(placement: .navigationBarTrailing) {
                    if showRightButton, let iconName = rightButtonIcon {
                        Button(action: {
                            onRightButton?()
                        }) {
                            // 使用模块图标
                            if let rightImage = UIImage(named: iconName, in: .module, compatibleWith: nil) {
                                Image(uiImage: rightImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 21, height: 21)
                            } else {
                                // 备用系统图标
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

// 使用扩展方便调用
public extension View {
    func withNavBar(
        title: String,
        titleFont: Font = .headline,
        showBackButton: Bool = true, // 默认显示返回按钮
        showRightButton: Bool = false, // 默认隐藏右上角按钮
        rightButtonIcon: String? = nil, // 默认不显示右上角按钮
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
}

// 专门用于根页面的导航栏样式（没有返回按钮）
public struct MKSFURootNavBarStyle: ViewModifier {
    let title: String
    let titleFont: Font
    let showRightButton: Bool // 根页面也可以选择显示右上角按钮
    let rightButtonIcon: String?
    let backgroundColor: Color
    let onRightButton: (() -> Void)?
    
    public init(
        title: String,
        titleFont: Font = .headline,
        showRightButton: Bool = false, // 默认隐藏
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
                // 根页面只显示居中标题
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(titleFont)
                        .foregroundColor(.white)
                        .bold()
                }
                
                // 根页面的右上角按钮（可选）
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

public extension View {
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
                    // 子页面：默认显示返回按钮，隐藏右上角按钮
                    .withNavBar(title: "子页面",showRightButton: true)
                }
                .padding()
            }
            // 根页面：没有返回按钮
            .withRootNavBar(title: "首页",
                            showRightButton: true,
                            rightButtonIcon: "mk_swiftUI_slotSaveIcon")
        }
    }
}

#Preview {
    MKSFUNavBarStyle_Preview()
}
