//
//  MKSFUNavBarStyle.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/29.
//

import SwiftUI

import MKBaseSwiftModule

// 定义统一的导航栏样式
struct MKSFUNavBarStyle: ViewModifier {
    let title: String
    let titleFont: Font
    let showBackButton: Bool
    let saveButtonIcon: String? // 右侧按钮图标名称，为 nil 时不显示
    let backgroundColor: Color
    let onBack: (() -> Void)?
    let onSave: (() -> Void)?
    
    init(
        title: String,
        titleFont: Font = .headline,
        showBackButton: Bool = true,
        saveButtonIcon: String? = nil, // 默认不显示右侧按钮
        backgroundColor: Color = Color(MKColor.navBar),
        onBack: (() -> Void)? = nil,
        onSave: (() -> Void)? = nil
    ) {
        self.title = title
        self.titleFont = titleFont
        self.showBackButton = showBackButton
        self.saveButtonIcon = saveButtonIcon
        self.backgroundColor = backgroundColor
        self.onBack = onBack
        self.onSave = onSave
    }
    
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 使用 ToolbarItemGroup 来组织所有工具栏项目
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(titleFont)
                        .foregroundColor(.white)
                }
                
                // 左侧按钮
                ToolbarItem(placement: .navigationBarLeading) {
                    if showBackButton {
                        Button(action: {
                            onBack?()
                        }) {
                            Image("mk_swiftUI_back_button_white")
                                .frame(width: 11, height: 21)
                        }
                    }
                }
                
                // 右侧按钮
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let iconName = saveButtonIcon {
                        Button(action: {
                            onSave?()
                        }) {
                            Image(iconName)
                                .frame(width: 21, height: 21)
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                // 使用 UIKit 的方式设置导航栏外观
                setupNavigationBarAppearance()
            }
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(backgroundColor)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        // 设置导航栏按钮颜色为白色
        UINavigationBar.appearance().tintColor = .white
    }
}

// 使用扩展方便调用
extension View {
    func withNavBar(
        title: String,
        titleFont: Font = .headline,
        showBackButton: Bool = true,
        saveButtonIcon: String? = nil, // 默认不显示右侧按钮
        backgroundColor: Color = Color(MKColor.navBar),
        onBack: (() -> Void)? = nil,
        onSave: (() -> Void)? = nil
    ) -> some View {
        self.modifier(MKSFUNavBarStyle(
            title: title,
            titleFont: titleFont,
            showBackButton: showBackButton,
            saveButtonIcon: saveButtonIcon,
            backgroundColor: backgroundColor,
            onBack: onBack,
            onSave: onSave
        ))
    }
}

// 预览
struct MKSFUNavBarStyle_Preview: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("页面内容")
                    .padding()
            }
            .withNavBar(
                title: "预览页面",
                titleFont: .title2,
                showBackButton: true,
                saveButtonIcon: "mk_swiftUI_slotSaveIcon", // 设置图标名称，显示右侧按钮
                backgroundColor: .blue,
                onBack: {
                    print("返回按钮点击")
                },
                onSave: {
                    print("保存按钮点击")
                }
            )
        }
    }
}

#Preview {
    MKSFUNavBarStyle_Preview()
}
