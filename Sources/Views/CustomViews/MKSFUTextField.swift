//
//  MKSFUTextField.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI
import Combine

import MKBaseSwiftModule

// MARK: - Text Field Type
public enum MKSFUTextFieldType: Int {
    case normal
    case realNumberOnly
    case realNumberOrLetter
    case letterOnly
    case hexCharOnly
    case uuidMode
}

// MARK: - 键盘工具栏配置
public struct MKSFUTextFieldToolbarConfig {
    public let showToolbar: Bool
    public let doneButtonTitle: String
    public let doneButtonColor: Color
    public let showSpacer: Bool
    
    public init(
        showToolbar: Bool = true,
        doneButtonTitle: String = "Done",
        doneButtonColor: Color = Color(MKColor.navBar),
        showSpacer: Bool = true
    ) {
        self.showToolbar = showToolbar
        self.doneButtonTitle = doneButtonTitle
        self.doneButtonColor = doneButtonColor
        self.showSpacer = showSpacer
    }
}

// MARK: - SwiftUI Text Field
public struct MKSFUTextField: View {
    @Binding private var text: String
    private let placeholder: String
    private let textType: MKSFUTextFieldType
    private let maxLength: Int
    private let onTextChanged: ((String) -> Void)?
    private let toolbarConfig: MKSFUTextFieldToolbarConfig?
    
    // State management
    @State private var inputLen: Int = 0
    @FocusState private var isFocused: Bool
    
    public init(
        text: Binding<String>,
        placeholder: String = "",
        textType: MKSFUTextFieldType = .normal,
        maxLength: Int = 0,
        onTextChanged: ((String) -> Void)? = nil,
        toolbarConfig: MKSFUTextFieldToolbarConfig? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.textType = textType
        self.maxLength = maxLength
        self.onTextChanged = onTextChanged
        self.toolbarConfig = toolbarConfig
    }
    
    public var body: some View {
        // 基础 TextField
        let textField = TextField(placeholder, text: $text)
            .focused($isFocused)
            .keyboardType(getKeyboardType())
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .foregroundColor(Color(MKColor.defaultText))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .submitLabel(.done)
            .onSubmit {
                // Hide keyboard when Done is pressed
                isFocused = false
            }
            .onChange(of: text) { newValue in
                handleTextChange(newValue)
            }
            .onAppear {
                // Initial text processing
                if !text.isEmpty {
                    handleTextChange(text)
                }
            }
        
        // 根据配置应用键盘工具栏
        if let config = toolbarConfig, config.showToolbar {
            textField
                .smp_addKeyboardDoneButton(
                    title: config.doneButtonTitle,
                    color: config.doneButtonColor,
                    showSpacer: config.showSpacer
                )
        } else {
            textField
        }
    }
    
    // MARK: - Text Change Handling
    private func handleTextChange(_ newText: String) {
        guard !newText.isEmpty else {
            onTextChanged?("")
            inputLen = 0
            return
        }
        
        // Max length restriction
        if maxLength > 0 && newText.count > maxLength && textType != .uuidMode {
            text = String(newText.prefix(maxLength))
            onTextChanged?(text)
            return
        }
        
        // Input validation
        if !newText.isEmpty {
            let lastChar = String(newText.suffix(1))
            if !validation(lastChar) {
                text = String(newText.dropLast())
                onTextChanged?(text)
                return
            }
        }
        
        // UUID mode special handling
        if textType == .uuidMode {
            handleUUIDMode(newText)
        } else {
            onTextChanged?(text)
        }
    }
    
    // MARK: - UUID Mode Handling
    private func handleUUIDMode(_ newText: String) {
        var processedText = newText.uppercased()
        
        // Auto-insert separators
        let positions = [8, 13, 18, 23]
        for position in positions {
            if processedText.count == position && !processedText.hasSuffix("-") {
                processedText.insert("-", at: processedText.index(processedText.startIndex, offsetBy: position))
            }
        }
        
        // Remove extra separators (when deleting)
        if processedText.count < inputLen {
            let positions = [8, 13, 18, 23]
            if positions.contains(processedText.count) && processedText.hasSuffix("-") {
                processedText = String(processedText.dropLast())
            }
        }
        
        // Length restriction
        if processedText.count > 36 {
            processedText = String(processedText.prefix(36))
        }
        
        text = processedText
        inputLen = processedText.count
        onTextChanged?(text)
    }
    
    // MARK: - Input Validation
    private func validation(_ inputString: String) -> Bool {
        guard !inputString.isEmpty else { return false }
        
        switch textType {
        case .normal:
            return true
        case .realNumberOnly:
            return inputString.range(of: "^[0-9]*$", options: .regularExpression) != nil
        case .letterOnly:
            return inputString.range(of: "^[a-zA-Z]*$", options: .regularExpression) != nil
        case .realNumberOrLetter:
            return inputString.range(of: "^[a-zA-Z0-9]*$", options: .regularExpression) != nil
        case .hexCharOnly, .uuidMode:
            return inputString.range(of: "^[a-fA-F0-9]*$", options: .regularExpression) != nil
        }
    }
    
    // MARK: - Keyboard Type
    private func getKeyboardType() -> UIKeyboardType {
        switch textType {
        case .realNumberOnly:
            return .numberPad
        default:
            return .asciiCapable
        }
    }
}

// MARK: - 便捷初始化方法扩展
public extension MKSFUTextField {
    /// 便捷初始化方法 - 不显示工具栏
    static func withoutToolbar(
        text: Binding<String>,
        placeholder: String = "",
        textType: MKSFUTextFieldType = .normal,
        maxLength: Int = 0,
        onTextChanged: ((String) -> Void)? = nil
    ) -> MKSFUTextField {
        MKSFUTextField(
            text: text,
            placeholder: placeholder,
            textType: textType,
            maxLength: maxLength,
            onTextChanged: onTextChanged,
            toolbarConfig: MKSFUTextFieldToolbarConfig(showToolbar: false)
        )
    }
    
    /// 便捷初始化方法 - 自定义工具栏
    static func withCustomToolbar(
        text: Binding<String>,
        placeholder: String = "",
        textType: MKSFUTextFieldType = .normal,
        maxLength: Int = 0,
        toolbarTitle: String = "Done",
        toolbarColor: Color = Color(MKColor.navBar),
        onTextChanged: ((String) -> Void)? = nil
    ) -> MKSFUTextField {
        MKSFUTextField(
            text: text,
            placeholder: placeholder,
            textType: textType,
            maxLength: maxLength,
            onTextChanged: onTextChanged,
            toolbarConfig: MKSFUTextFieldToolbarConfig(
                showToolbar: true,
                doneButtonTitle: toolbarTitle,
                doneButtonColor: toolbarColor
            )
        )
    }
    
    /// 便捷初始化方法 - 带默认工具栏
    static func withDefaultToolbar(
        text: Binding<String>,
        placeholder: String = "",
        textType: MKSFUTextFieldType = .normal,
        maxLength: Int = 0,
        onTextChanged: ((String) -> Void)? = nil
    ) -> MKSFUTextField {
        MKSFUTextField(
            text: text,
            placeholder: placeholder,
            textType: textType,
            maxLength: maxLength,
            onTextChanged: onTextChanged,
            toolbarConfig: MKSFUTextFieldToolbarConfig(showToolbar: true)
        )
    }
}

// MARK: - Usage Extension (保持向后兼容)
public extension View {
    /// Quick creation of text field (向后兼容版本)
    func mkTextField(
        _ text: Binding<String>,
        placeholder: String = "",
        type: MKSFUTextFieldType = .normal,
        maxLength: Int = 0,
        onTextChanged: ((String) -> Void)? = nil
    ) -> some View {
        MKSFUTextField(
            text: text,
            placeholder: placeholder,
            textType: type,
            maxLength: maxLength,
            onTextChanged: onTextChanged,
            toolbarConfig: nil  // 保持原有行为，不显示工具栏
        )
    }
    
    /// Quick creation of text field with keyboard toolbar (新版本)
    func mkTextFieldWithToolbar(
        _ text: Binding<String>,
        placeholder: String = "",
        type: MKSFUTextFieldType = .normal,
        maxLength: Int = 0,
        toolbarTitle: String = "Done",
        toolbarColor: Color = Color(MKColor.navBar),
        onTextChanged: ((String) -> Void)? = nil
    ) -> some View {
        MKSFUTextField(
            text: text,
            placeholder: placeholder,
            textType: type,
            maxLength: maxLength,
            onTextChanged: onTextChanged,
            toolbarConfig: MKSFUTextFieldToolbarConfig(
                showToolbar: true,
                doneButtonTitle: toolbarTitle,
                doneButtonColor: toolbarColor
            )
        )
    }
}

// MARK: - Preview
struct MKSFUTextField_Preview: View {
    @State private var normalText = ""
    @State private var numberText = ""
    @State private var uuidText = ""
    @State private var customToolbarText = ""
    @State private var noToolbarText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 默认工具栏示例
                VStack(alignment: .leading) {
                    Text("Default Toolbar (默认工具栏):")
                        .font(.caption)
                        .foregroundColor(.gray)
                    MKSFUTextField.withDefaultToolbar(
                        text: $normalText,
                        placeholder: "Enter text with default toolbar",
                        textType: .normal,
                        maxLength: 20,
                        onTextChanged: { newText in
                            print("Normal text: \(newText)")
                        }
                    )
                }
                
                // 数字输入带自定义工具栏
                VStack(alignment: .leading) {
                    Text("Number Input (自定义工具栏):")
                        .font(.caption)
                        .foregroundColor(.gray)
                    MKSFUTextField.withCustomToolbar(
                        text: $numberText,
                        placeholder: "Enter number",
                        textType: .realNumberOnly,
                        maxLength: 10,
                        toolbarTitle: "Close",
                        toolbarColor: .red,
                        onTextChanged: { newText in
                            print("Number: \(newText)")
                        }
                    )
                }
                
                // UUID 输入带默认工具栏
                VStack(alignment: .leading) {
                    Text("UUID Input (默认工具栏):")
                        .font(.caption)
                        .foregroundColor(.gray)
                    MKSFUTextField.withDefaultToolbar(
                        text: $uuidText,
                        placeholder: "Enter UUID",
                        textType: .uuidMode,
                        onTextChanged: { newText in
                            print("UUID: \(newText)")
                        }
                    )
                }
                
                // 自定义工具栏示例 - 修复后的调用方式
                VStack(alignment: .leading) {
                    Text("Custom Toolbar (完全自定义):")
                        .font(.caption)
                        .foregroundColor(.gray)
                    MKSFUTextField(
                        text: $customToolbarText,
                        placeholder: "Custom toolbar configuration",
                        textType: .normal,
                        maxLength: 0,
                        onTextChanged: { newText in
                            print("Custom toolbar text: \(newText)")
                        },
                        toolbarConfig: MKSFUTextFieldToolbarConfig(
                            showToolbar: true,
                            doneButtonTitle: "Confirm",
                            doneButtonColor: .green,
                            showSpacer: true
                        )
                    )
                }
                
                // 无工具栏示例
                VStack(alignment: .leading) {
                    Text("Without Toolbar (无工具栏):")
                        .font(.caption)
                        .foregroundColor(.gray)
                    MKSFUTextField.withoutToolbar(
                        text: $noToolbarText,
                        placeholder: "No toolbar input field",
                        textType: .normal,
                        onTextChanged: { newText in
                            print("No toolbar text: \(newText)")
                        }
                    )
                }
                
                Spacer()
                
                // 说明文本
                VStack(alignment: .leading, spacing: 8) {
                    Text("说明:")
                        .font(.headline)
                    Text("• 点击输入框查看键盘工具栏效果")
                    Text("• 不同输入类型自动适配不同键盘")
                    Text("• 工具栏按钮点击后可隐藏键盘")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("MKSFUTextField + KeyboardToolbar")
        }
    }
}

#Preview {
    MKSFUTextField_Preview()
}
