//
//  MKSFUFilterNormalTextFieldCell.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI

import MKBaseSwiftModule

// MARK: - SwiftUI Data Model
public class MKSFUFilterNormalTextFieldCellModel: ObservableObject {
    @Published public var index: Int = 0
    @Published public var msg: String = ""
    @Published public var textFieldValue: String = ""
    @Published public var textPlaceholder: String = ""
    @Published public var textFieldType: MKSFUTextFieldType = .normal
    @Published public var maxLength: Int = 0
    
    public init() {}
}

// MARK: - SwiftUI Normal Text Field Cell
public struct MKSFUFilterNormalTextFieldCell: View {
    @ObservedObject public var dataModel: MKSFUFilterNormalTextFieldCellModel
    public var onTextValueChanged: (String, Int) -> Void
    
    public init(
        dataModel: MKSFUFilterNormalTextFieldCellModel,
        onTextValueChanged: @escaping (String, Int) -> Void = { _, _ in }
    ) {
        self.dataModel = dataModel
        self.onTextValueChanged = onTextValueChanged
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Message label
            Text(dataModel.msg)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .padding(.horizontal, 15)
            
            // Text field
            MKSFUTextField(
                text: Binding(
                    get: { dataModel.textFieldValue },
                    set: { newValue in
                        dataModel.textFieldValue = newValue
                        onTextValueChanged(newValue, dataModel.index)
                    }
                ),
                placeholder: dataModel.textPlaceholder,
                textType: dataModel.textFieldType,
                maxLength: dataModel.maxLength
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal, 15)
        }
        .padding(.vertical, 5)
    }
}

// MARK: - 便捷初始化方法扩展
public extension MKSFUFilterNormalTextFieldCellModel {
    /// 便捷初始化方法
    convenience init(
        index: Int = 0,
        msg: String = "",
        textFieldValue: String = "",
        textPlaceholder: String = "",
        textFieldType: MKSFUTextFieldType = .normal,
        maxLength: Int = 0
    ) {
        self.init()
        self.index = index
        self.msg = msg
        self.textFieldValue = textFieldValue
        self.textPlaceholder = textPlaceholder
        self.textFieldType = textFieldType
        self.maxLength = maxLength
    }
}

// MARK: - 使用示例

// Example 1: 在列表中使用
struct NormalTextFieldExampleView: View {
    @StateObject private var textFieldModel1 = MKSFUFilterNormalTextFieldCellModel(
        index: 0,
        msg: "设备名称",
        textFieldValue: "My Device",
        textPlaceholder: "请输入设备名称",
        textFieldType: .normal,
        maxLength: 20
    )
    
    @StateObject private var textFieldModel2 = MKSFUFilterNormalTextFieldCellModel(
        index: 1,
        msg: "设备编号",
        textFieldValue: "12345",
        textPlaceholder: "请输入数字编号",
        textFieldType: .realNumberOnly,
        maxLength: 10
    )
    
    @StateObject private var textFieldModel3 = MKSFUFilterNormalTextFieldCellModel(
        index: 2,
        msg: "MAC地址",
        textFieldValue: "A1B2C3",
        textPlaceholder: "请输入十六进制MAC",
        textFieldType: .hexCharOnly,
        maxLength: 12
    )
    
    var body: some View {
        List {
            MKSFUFilterNormalTextFieldCell(dataModel: textFieldModel1) { text, index in
                print("设备名称变化: \(text) at index: \(index)")
            }
            
            MKSFUFilterNormalTextFieldCell(dataModel: textFieldModel2) { text, index in
                print("设备编号变化: \(text) at index: \(index)")
            }
            
            MKSFUFilterNormalTextFieldCell(dataModel: textFieldModel3) { text, index in
                print("MAC地址变化: \(text) at index: \(index)")
            }
        }
        .listStyle(PlainListStyle())
    }
}

// Example 2: 不同类型输入框示例
struct TextFieldTypesExampleView: View {
    @StateObject private var normalModel = MKSFUFilterNormalTextFieldCellModel(
        msg: "普通文本",
        textPlaceholder: "可输入任意字符",
        textFieldType: .normal
    )
    
    @StateObject private var numberModel = MKSFUFilterNormalTextFieldCellModel(
        msg: "纯数字",
        textPlaceholder: "只能输入数字",
        textFieldType: .realNumberOnly
    )
    
    @StateObject private var letterModel = MKSFUFilterNormalTextFieldCellModel(
        msg: "纯字母",
        textPlaceholder: "只能输入字母",
        textFieldType: .letterOnly
    )
    
    @StateObject private var hexModel = MKSFUFilterNormalTextFieldCellModel(
        msg: "十六进制",
        textPlaceholder: "只能输入0-9,A-F",
        textFieldType: .hexCharOnly
    )
    
    @StateObject private var uuidModel = MKSFUFilterNormalTextFieldCellModel(
        msg: "UUID格式",
        textPlaceholder: "自动格式化UUID",
        textFieldType: .uuidMode
    )
    
    var body: some View {
        VStack(spacing: 0) {
            MKSFUFilterNormalTextFieldCell(dataModel: normalModel) { text, _ in
                print("普通文本: \(text)")
            }
            
            Divider()
            
            MKSFUFilterNormalTextFieldCell(dataModel: numberModel) { text, _ in
                print("数字: \(text)")
            }
            
            Divider()
            
            MKSFUFilterNormalTextFieldCell(dataModel: letterModel) { text, _ in
                print("字母: \(text)")
            }
            
            Divider()
            
            MKSFUFilterNormalTextFieldCell(dataModel: hexModel) { text, _ in
                print("十六进制: \(text)")
            }
            
            Divider()
            
            MKSFUFilterNormalTextFieldCell(dataModel: uuidModel) { text, _ in
                print("UUID: \(text)")
            }
        }
        .background(Color(.systemBackground))
    }
}

// Example 3: 动态配置示例
struct DynamicTextFieldExampleView: View {
    @StateObject private var textFieldModel = MKSFUFilterNormalTextFieldCellModel()
    @State private var selectedType: MKSFUTextFieldType = .normal
    
    let textFieldTypes: [(type: MKSFUTextFieldType, name: String)] = [
        (.normal, "普通文本"),
        (.realNumberOnly, "纯数字"),
        (.letterOnly, "纯字母"),
        (.realNumberOrLetter, "数字或字母"),
        (.hexCharOnly, "十六进制"),
        (.uuidMode, "UUID模式")
    ]
    
    var body: some View {
        VStack {
            // 类型选择器
            Picker("输入类型", selection: $selectedType) {
                ForEach(textFieldTypes, id: \.type) { type, name in
                    Text(name).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: selectedType) { newType in
                textFieldModel.textFieldType = newType
                updatePlaceholder(for: newType)
            }
            
            // 文本输入单元格
            MKSFUFilterNormalTextFieldCell(
                dataModel: textFieldModel,
                onTextValueChanged: { text, index in
                    print("输入内容: \(text), 类型: \(selectedType)")
                }
            )
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(color: .gray.opacity(0.2), radius: 2)
            .padding()
            
            // 当前输入信息
            VStack(alignment: .leading) {
                Text("当前输入: \(textFieldModel.textFieldValue)")
                    .font(.caption)
                Text("输入类型: \(textFieldTypes.first { $0.type == selectedType }?.name ?? "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Spacer()
        }
        .onAppear {
            updatePlaceholder(for: selectedType)
        }
    }
    
    private func updatePlaceholder(for type: MKSFUTextFieldType) {
        switch type {
        case .normal:
            textFieldModel.msg = "普通文本输入"
            textFieldModel.textPlaceholder = "可输入任意字符"
        case .realNumberOnly:
            textFieldModel.msg = "纯数字输入"
            textFieldModel.textPlaceholder = "只能输入数字0-9"
        case .letterOnly:
            textFieldModel.msg = "纯字母输入"
            textFieldModel.textPlaceholder = "只能输入字母A-Z,a-z"
        case .realNumberOrLetter:
            textFieldModel.msg = "数字或字母"
            textFieldModel.textPlaceholder = "可输入数字或字母"
        case .hexCharOnly:
            textFieldModel.msg = "十六进制输入"
            textFieldModel.textPlaceholder = "只能输入0-9,A-F,a-f"
        case .uuidMode:
            textFieldModel.msg = "UUID输入"
            textFieldModel.textPlaceholder = "自动格式化为UUID"
        }
    }
}

// MARK: - Preview
struct MKSFUFilterNormalTextFieldCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NormalTextFieldExampleView()
                .previewDisplayName("列表示例")
            
            TextFieldTypesExampleView()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("不同类型示例")
            
            DynamicTextFieldExampleView()
                .previewDisplayName("动态配置示例")
            
            // 单个单元格预览
            MKSFUFilterNormalTextFieldCell(
                dataModel: MKSFUFilterNormalTextFieldCellModel(
                    msg: "预览单元格",
                    textFieldValue: "测试内容",
                    textPlaceholder: "请输入内容"
                )
            ) { text, index in
                print("文本变化: \(text)")
            }
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("单个单元格")
        }
    }
}
