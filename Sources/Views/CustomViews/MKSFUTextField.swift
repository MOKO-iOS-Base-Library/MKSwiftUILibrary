//
//  MKSFUTextField.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI
import Combine

import MKBaseSwiftModule

// MARK: - 输入框类型
public enum MKSFUTextFieldType: Int {
    case normal
    case realNumberOnly
    case realNumberOrLetter
    case letterOnly
    case hexCharOnly
    case uuidMode
}

// MARK: - SwiftUI 文本输入框
public struct MKSFUTextField: View {
    @Binding private var text: String
    private let placeholder: String
    private let textType: MKSFUTextFieldType
    private let maxLength: Int
    private let onTextChanged: ((String) -> Void)?
    
    // 状态管理
    @State private var inputLen: Int = 0
    @FocusState private var isFocused: Bool
    
    public init(
        text: Binding<String>,
        placeholder: String = "",
        textType: MKSFUTextFieldType = .normal,
        maxLength: Int = 0,
        onTextChanged: ((String) -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.textType = textType
        self.maxLength = maxLength
        self.onTextChanged = onTextChanged
    }
    
    public var body: some View {
        TextField(placeholder, text: $text)
            .focused($isFocused)
            .keyboardType(getKeyboardType())
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .foregroundColor(Color(MKColor.defaultText))
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        // 隐藏键盘
                        isFocused = false
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .medium))
                }
            }
            .onChange(of: text) { newValue in
                handleTextChange(newValue)
            }
            .onAppear {
                // 初始文本处理
                if !text.isEmpty {
                    handleTextChange(text)
                }
            }
    }
    
    // MARK: - 文本变化处理
    private func handleTextChange(_ newText: String) {
        guard !newText.isEmpty else {
            onTextChanged?("")
            inputLen = 0
            return
        }
        
        // 最大长度限制
        if maxLength > 0 && newText.count > maxLength && textType != .uuidMode {
            text = String(newText.prefix(maxLength))
            onTextChanged?(text)
            return
        }
        
        // 输入验证
        if !newText.isEmpty {
            let lastChar = String(newText.suffix(1))
            if !validation(lastChar) {
                text = String(newText.dropLast())
                onTextChanged?(text)
                return
            }
        }
        
        // UUID 模式特殊处理
        if textType == .uuidMode {
            handleUUIDMode(newText)
        } else {
            onTextChanged?(text)
        }
    }
    
    // MARK: - UUID 模式处理
    private func handleUUIDMode(_ newText: String) {
        var processedText = newText.uppercased()
        
        // 自动插入分隔符
        let positions = [8, 13, 18, 23]
        for position in positions {
            if processedText.count == position && !processedText.hasSuffix("-") {
                processedText.insert("-", at: processedText.index(processedText.startIndex, offsetBy: position))
            }
        }
        
        // 移除多余的分隔符（在删除时）
        if processedText.count < inputLen {
            let positions = [8, 13, 18, 23]
            if positions.contains(processedText.count) && processedText.hasSuffix("-") {
                processedText = String(processedText.dropLast())
            }
        }
        
        // 长度限制
        if processedText.count > 36 {
            processedText = String(processedText.prefix(36))
        }
        
        text = processedText
        inputLen = processedText.count
        onTextChanged?(text)
    }
    
    // MARK: - 输入验证
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
    
    // MARK: - 键盘类型
    private func getKeyboardType() -> UIKeyboardType {
        switch textType {
        case .realNumberOnly:
            return .numberPad
        default:
            return .asciiCapable
        }
    }
}

// MARK: - 预览
struct MKSFUTextField_Preview: View {
    @State private var normalText = ""
    @State private var numberText = ""
    @State private var uuidText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // 普通文本输入
            VStack(alignment: .leading) {
                Text("普通输入:")
                    .font(.caption)
                MKSFUTextField(
                    text: $normalText,
                    placeholder: "请输入文本",
                    textType: .normal,
                    maxLength: 20
                ) { newText in
                    print("普通文本: \(newText)")
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // 数字输入
            VStack(alignment: .leading) {
                Text("数字输入:")
                    .font(.caption)
                MKSFUTextField(
                    text: $numberText,
                    placeholder: "请输入数字",
                    textType: .realNumberOnly,
                    maxLength: 10
                ) { newText in
                    print("数字: \(newText)")
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // UUID 输入
            VStack(alignment: .leading) {
                Text("UUID 输入:")
                    .font(.caption)
                MKSFUTextField(
                    text: $uuidText,
                    placeholder: "请输入 UUID",
                    textType: .uuidMode
                ) { newText in
                    print("UUID: \(newText)")
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    MKSFUTextField_Preview()
}

// MARK: - 使用示例扩展
extension View {
    /// 快速创建文本输入框
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
            onTextChanged: onTextChanged
        )
    }
}
