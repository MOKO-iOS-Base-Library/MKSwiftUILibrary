//
//  MKSFUAlertView.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI

// MARK: - Action Model
public struct MKSFUAlertViewAction {
    public let title: String
    public let handler: (() -> Void)
    
    public init(title: String, handler: @escaping () -> Void) {
        self.title = title
        self.handler = handler
    }
}

// MARK: - TextField Model
public struct MKSFUAlertViewTextField {
    public let textValue: String
    public let placeholder: String
    public let textFieldType: MKSFUTextFieldType
    public let maxLength: Int
    public let onTextChanged: ((String) -> Void)?
    
    public init(
        textValue: String = "",
        placeholder: String = "",
        textFieldType: MKSFUTextFieldType = .normal,
        maxLength: Int = 0,
        onTextChanged: ((String) -> Void)? = nil
    ) {
        self.textValue = textValue
        self.placeholder = placeholder
        self.textFieldType = textFieldType
        self.maxLength = maxLength
        self.onTextChanged = onTextChanged
    }
}

// MARK: - Alert View
public struct MKSFUAlertView: View {
    // MARK: - Properties
    private let title: String
    private let message: String
    private let actions: [MKSFUAlertViewAction]
    private let textFields: [MKSFUAlertViewTextField]
    
    // SwiftUI 回调方式
    public var onDismiss: (() -> Void)?
    
    // MARK: - Binding
    @Binding private var isPresented: Bool
    
    // MARK: - State
    @State private var textFieldValues: [String]
    
    // MARK: - Constants
    private let cornerRadius: CGFloat = 8
    private let buttonHeight: CGFloat = 44
    private let textFieldHeight: CGFloat = 40
    private let lineHeight: CGFloat = 0.5
    
    // MARK: - Initialization
    public init(
        isPresented: Binding<Bool>,
        title: String = "",
        message: String = "",
        actions: [MKSFUAlertViewAction] = [],
        textFields: [MKSFUAlertViewTextField] = [],
        onDismiss: (() -> Void)? = nil
    ) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.actions = Array(actions.prefix(2)) // 最多2个按钮
        self.textFields = Array(textFields.prefix(2)) // 最多2个文本框
        self.onDismiss = onDismiss
        self._textFieldValues = State(initialValue: textFields.map { $0.textValue })
    }
    
    // MARK: - Body
    public var body: some View {
        if isPresented {
            ZStack {
                // 半透明背景
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        dismiss()
                    }
                
                // 中心弹窗
                VStack(spacing: 0) {
                    // 标题
                    if !title.isEmpty {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                            .padding(.horizontal, 5)
                    }
                    
                    // 消息
                    if !message.isEmpty {
                        Text(message)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.top, title.isEmpty ? 20 : 10)
                    }
                    
                    // 文本框区域
                    if !textFields.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(0..<textFields.count, id: \.self) { index in
                                textFieldView(for: index)
                                
                                if index < textFields.count - 1 {
                                    Divider()
                                        .background(Color.gray)
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray, lineWidth: lineHeight)
                        )
                        .padding(.horizontal, 15)
                        .padding(.top, (!title.isEmpty || !message.isEmpty) ? 10 : 20)
                    }
                    
                    // 按钮区域
                    HStack(spacing: 0) {
                        ForEach(0..<actions.count, id: \.self) { index in
                            buttonView(for: index)
                            
                            if index < actions.count - 1 {
                                Divider()
                                    .frame(width: lineHeight)
                                    .background(Color.gray)
                            }
                        }
                    }
                    .frame(height: buttonHeight)
                    .padding(.top, 10)
                }
                .background(Color(red: 234/255, green: 234/255, blue: 234/255))
                .cornerRadius(cornerRadius)
                .padding(.horizontal, 40)
            }
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPresented)
            .zIndex(999) // 确保在最上层
        }
    }
    
    // MARK: - Text Field View
    private func textFieldView(for index: Int) -> some View {
        let textFieldModel = textFields[index]
        
        return MKSFUTextField(
            text: Binding(
                get: {
                    guard index < textFieldValues.count else { return "" }
                    return textFieldValues[index]
                },
                set: { newValue in
                    guard index < textFieldValues.count else { return }
                    textFieldValues[index] = newValue
                    textFieldModel.onTextChanged?(newValue)
                }
            ),
            placeholder: textFieldModel.placeholder,
            textType: textFieldModel.textFieldType,
            maxLength: textFieldModel.maxLength,
            onTextChanged: textFieldModel.onTextChanged
        )
        .frame(height: textFieldHeight)
        .padding(.horizontal, 8)
    }
    
    // MARK: - Button View
    private func buttonView(for index: Int) -> some View {
        let action = actions[index]
        
        return Button(action: {
            action.handler()
            dismiss()
        }) {
            Text(action.title)
                .font(.headline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Private Methods
    private func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isPresented = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss?()
        }
    }
}

// MARK: - View Modifier for Presentation
public struct MKSFUAlertViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let actions: [MKSFUAlertViewAction]
    let textFields: [MKSFUAlertViewTextField]
    let onDismiss: (() -> Void)?
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            MKSFUAlertView(
                isPresented: $isPresented,
                title: title,
                message: message,
                actions: actions,
                textFields: textFields,
                onDismiss: onDismiss
            )
        }
    }
}

// MARK: - View Extension for Easy Usage
public extension View {
    /// 显示自定义弹窗
    func mkAlertView(
        isPresented: Binding<Bool>,
        title: String = "",
        message: String = "",
        actions: [MKSFUAlertViewAction] = [],
        textFields: [MKSFUAlertViewTextField] = [],
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        self.modifier(
            MKSFUAlertViewModifier(
                isPresented: isPresented,
                title: title,
                message: message,
                actions: actions,
                textFields: textFields,
                onDismiss: onDismiss
            )
        )
    }
}

// MARK: - 使用示例
struct MKSFUAlertViewExamples: View {
    @State private var showSimpleAlert = false
    @State private var showTextFieldAlert = false
    @State private var showTwoButtonAlert = false
    
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Alert View 示例")
                .font(.title)
                .padding()
            
            Button("简单弹窗") {
                showSimpleAlert = true
            }
            .buttonStyle(.borderedProminent)
            
            Button("带输入框弹窗") {
                showTextFieldAlert = true
                // 重置输入框内容
                username = ""
                password = ""
            }
            .buttonStyle(.borderedProminent)
            
            Button("双按钮弹窗") {
                showTwoButtonAlert = true
            }
            .buttonStyle(.borderedProminent)
            
            // 显示当前状态
            VStack {
                Text("当前状态:")
                    .font(.headline)
                Text("简单弹窗: \(showSimpleAlert ? "显示" : "隐藏")")
                Text("输入框弹窗: \(showTextFieldAlert ? "显示" : "隐藏")")
                Text("双按钮弹窗: \(showTwoButtonAlert ? "显示" : "隐藏")")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
        // 简单弹窗
        .mkAlertView(
            isPresented: $showSimpleAlert,
            title: "提示",
            message: "这是一个简单的提示弹窗",
            actions: [
                MKSFUAlertViewAction(title: "确定", handler: {
                    print("确定按钮点击")
                })
            ],
            onDismiss: {
                print("简单弹窗已关闭")
            }
        )
        // 带输入框弹窗
        .mkAlertView(
            isPresented: $showTextFieldAlert,
            title: "登录",
            message: "请输入用户名和密码",
            actions: [
                MKSFUAlertViewAction(title: "取消", handler: {
                    print("取消登录")
                }),
                MKSFUAlertViewAction(title: "登录", handler: {
                    print("尝试登录 - 用户名: \(username), 密码: \(password)")
                })
            ], textFields: [
                MKSFUAlertViewTextField(
                    textValue: username,
                    placeholder: "用户名",
                    textFieldType: .normal,
                    maxLength: 20,
                    onTextChanged: { newValue in
                        username = newValue
                        print("用户名: \(newValue)")
                    }
                ),
                MKSFUAlertViewTextField(
                    textValue: password,
                    placeholder: "密码",
                    textFieldType: .normal,
                    maxLength: 16,
                    onTextChanged: { newValue in
                        password = newValue
                        print("密码: \(newValue)")
                    }
                )
            ],
            onDismiss: {
                print("登录弹窗已关闭")
            }
        )
        // 双按钮弹窗
        .mkAlertView(
            isPresented: $showTwoButtonAlert,
            title: "确认操作",
            message: "您确定要执行此操作吗？",
            actions: [
                MKSFUAlertViewAction(title: "取消", handler: {
                    print("取消操作")
                }),
                MKSFUAlertViewAction(title: "确定", handler: {
                    print("确认操作")
                })
            ],
            onDismiss: {
                print("确认弹窗已关闭")
            }
        )
    }
}

// MARK: - 预览
struct MKSFUAlertView_Previews: PreviewProvider {
    static var previews: some View {
        MKSFUAlertViewExamples()
    }
}

// MARK: - 便捷创建方法
public extension View {
    /// 创建简单提示弹窗
    func mkSimpleAlert(
        isPresented: Binding<Bool>,
        title: String = "",
        message: String,
        confirmTitle: String = "确定",
        onConfirm: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        self.mkAlertView(
            isPresented: isPresented,
            title: title,
            message: message,
            actions: [
                MKSFUAlertViewAction(title: confirmTitle, handler: {
                    onConfirm?()
                })
            ],
            onDismiss: onDismiss
        )
    }
    
    /// 创建确认弹窗
    func mkConfirmAlert(
        isPresented: Binding<Bool>,
        title: String = "",
        message: String,
        cancelTitle: String = "取消",
        confirmTitle: String = "确定",
        onCancel: (() -> Void)? = nil,
        onConfirm: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        self.mkAlertView(
            isPresented: isPresented,
            title: title,
            message: message,
            actions: [
                MKSFUAlertViewAction(title: cancelTitle, handler: {
                    onCancel?()
                }),
                MKSFUAlertViewAction(title: confirmTitle, handler: {
                    onConfirm?()
                })
            ],
            onDismiss: onDismiss
        )
    }
}
