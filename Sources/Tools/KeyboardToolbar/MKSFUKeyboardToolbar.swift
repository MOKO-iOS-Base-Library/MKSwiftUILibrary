//
//  MKSFUKeyboardToolbar.swift
//  MKSwiftUILibrary
//
//  Created by aa on 2025/11/17.
//

import SwiftUI
import UIKit

import MKBaseSwiftModule

// MARK: - 键盘工具栏修饰符
public struct MKSFUKeyboardToolbar: ViewModifier {
    private let doneButtonTitle: String
    private let doneButtonColor: Color
    private let showSpacer: Bool
    
    /// 初始化方法
    /// - Parameters:
    ///   - doneButtonTitle: 完成按钮标题，默认为"完成"
    ///   - doneButtonColor: 完成按钮颜色，默认为蓝色
    ///   - showSpacer: 是否显示弹簧空间，默认为true
    public init(
        doneButtonTitle: String = "Done",
        doneButtonColor: Color = Color(MKColor.navBar),
        showSpacer: Bool = true
    ) {
        self.doneButtonTitle = doneButtonTitle
        self.doneButtonColor = doneButtonColor
        self.showSpacer = showSpacer
    }
    
    public func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if showSpacer {
                        Spacer()
                    }
                    
                    Button(doneButtonTitle) {
                        hideKeyboard()
                    }
                    .foregroundColor(doneButtonColor)
                    .font(.system(size: 16, weight: .medium))
                }
            }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - View 扩展
public extension View {
    /// 添加键盘完成按钮
    /// - Parameters:
    ///   - title: 按钮标题，默认为"完成"
    ///   - color: 按钮颜色，默认为蓝色
    ///   - showSpacer: 是否显示弹簧空间，默认为true
    /// - Returns: 带有键盘工具栏的视图
    func smp_addKeyboardDoneButton(
        title: String = "Done",
        color: Color = Color(MKColor.navBar),
        showSpacer: Bool = true
    ) -> some View {
        self.modifier(
            MKSFUKeyboardToolbar(
                doneButtonTitle: title,
                doneButtonColor: color,
                showSpacer: showSpacer
            )
        )
    }
    
    /// 快速添加键盘完成按钮（使用默认配置）
    /// - Returns: 带有键盘工具栏的视图
    func smp_addKeyboardDoneButton() -> some View {
        self.modifier(MKSFUKeyboardToolbar())
    }
}
