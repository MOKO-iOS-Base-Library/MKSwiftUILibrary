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

// MARK: - SwiftUI Text Field
public struct MKSFUTextField: View {
    @Binding private var text: String
    private let placeholder: String
    private let textType: MKSFUTextFieldType
    private let maxLength: Int
    private let onTextChanged: ((String) -> Void)?
    
    // State management
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

// MARK: - Preview
struct MKSFUTextField_Preview: View {
    @State private var normalText = ""
    @State private var numberText = ""
    @State private var uuidText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Normal text input
            VStack(alignment: .leading) {
                Text("Normal Input:")
                    .font(.caption)
                MKSFUTextField(
                    text: $normalText,
                    placeholder: "Enter text",
                    textType: .normal,
                    maxLength: 20
                ) { newText in
                    print("Normal text: \(newText)")
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Number input
            VStack(alignment: .leading) {
                Text("Number Input:")
                    .font(.caption)
                MKSFUTextField(
                    text: $numberText,
                    placeholder: "Enter number",
                    textType: .realNumberOnly,
                    maxLength: 10
                ) { newText in
                    print("Number: \(newText)")
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // UUID input
            VStack(alignment: .leading) {
                Text("UUID Input:")
                    .font(.caption)
                MKSFUTextField(
                    text: $uuidText,
                    placeholder: "Enter UUID",
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

// MARK: - Usage Extension
extension View {
    /// Quick creation of text field
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
