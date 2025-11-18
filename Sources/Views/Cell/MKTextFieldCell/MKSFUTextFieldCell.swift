//
//  MKSFUTextFieldCell.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI

import MKBaseSwiftModule

// MARK: - Enums
public enum MKSFUTextFieldCellType {
    case normal
    case topLine
}

// MARK: - Model
public class MKSFUTextFieldCellModel: ObservableObject, Identifiable {
    public let id = UUID()
    
    // MARK: Cell Top Configuration
    @Published public var index: Int = 0
    @Published public var contentColor: Color = .white
    
    // MARK: Left Label Configuration
    @Published public var msg: String = ""
    @Published public var msgColor: Color = .primary
    @Published public var msgFont: Font = .system(size: 15)
    
    // MARK: Right Label Configuration
    @Published public var unit: String = ""
    @Published public var unitColor: Color = .primary
    @Published public var unitFont: Font = .system(size: 13)
    
    // MARK: TextField Configuration
    @Published public var textEnable: Bool = true
    @Published public var cellType: MKSFUTextFieldCellType = .normal
    @Published public var textFieldValue: String = ""
    @Published public var textPlaceholder: String = ""
    @Published public var textFieldTextColor: Color = .primary
    @Published public var textFieldTextFont: Font = .system(size: 15)
    @Published public var textFieldType: MKSFUTextFieldType = .normal
    @Published public var maxLength: Int = 0
    @Published public var borderColor: Color = .gray.opacity(0.3)
    
    // MARK: TextField Toolbar Configuration
    @Published public var showToolbar: Bool = true
    @Published public var toolbarTitle: String = "Done"
    @Published public var toolbarColor: Color = Color(MKColor.navBar)
    
    // MARK: Bottom Label Configuration
    @Published public var noteMsg: String = ""
    @Published public var noteMsgColor: Color = .primary
    @Published public var noteMsgFont: Font = .system(size: 12)
    
    public init() {}
}

// MARK: - Cell
public struct MKSFUTextFieldCell: View {
    
    // MARK: - Properties
    @ObservedObject public var dataModel: MKSFUTextFieldCellModel
    
    // SwiftUI 回调方式
    public var onTextValueChanged: ((Int, String) -> Void)?
    
    // MARK: - State
    @State private var textValue: String = ""
    
    // MARK: - Constants
    private let offsetX: CGFloat = 15
    private let textFieldHeight: CGFloat = 35
    private let unitLabelWidth: CGFloat = 70
    
    // MARK: - Initialization
    public init(
        dataModel: MKSFUTextFieldCellModel,
        onTextValueChanged: ((Int, String) -> Void)? = nil
    ) {
        self.dataModel = dataModel
        self.onTextValueChanged = onTextValueChanged
        self._textValue = State(initialValue: dataModel.textFieldValue)
    }
    
    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 主内容行 - msg、输入框、unit 水平对齐
            HStack(alignment: .center, spacing: 10) {
                // 左侧消息标签
                Text(dataModel.msg)
                    .font(dataModel.msgFont)
                    .foregroundColor(dataModel.msgColor)
                    .lineLimit(2)
                    .frame(minWidth: 80, alignment: .leading)
                
                Spacer()
                
                // 输入框区域
                textFieldView
                    .frame(width: 120, height: textFieldHeight)
                
                // 单位标签
                if !dataModel.unit.isEmpty {
                    Text(dataModel.unit)
                        .font(dataModel.unitFont)
                        .foregroundColor(dataModel.unitColor)
                        .frame(width: 40, alignment: .leading)
                }
            }
            .padding(.horizontal, offsetX)
            .padding(.vertical, 12)
            
            // 底部说明标签 - 单独一行
            if !dataModel.noteMsg.isEmpty {
                Text(dataModel.noteMsg)
                    .font(dataModel.noteMsgFont)
                    .foregroundColor(dataModel.noteMsgColor)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, offsetX)
                    .padding(.bottom, 12)
            }
        }
        .background(dataModel.contentColor)
        .onChange(of: dataModel.textFieldValue) { newValue in
            if textValue != newValue {
                textValue = newValue
            }
        }
        .onChange(of: textValue) { newValue in
            if dataModel.textFieldValue != newValue {
                dataModel.textFieldValue = newValue
                onTextValueChanged?(dataModel.index, newValue)
            }
        }
    }
    
    // MARK: - TextField View
    private var textFieldView: some View {
        ZStack {
            // 使用 MKSFUTextField
            MKSFUTextField(
                text: Binding(
                    get: { textValue },
                    set: { newValue in
                        textValue = newValue
                        dataModel.textFieldValue = newValue
                        onTextValueChanged?(dataModel.index, newValue)
                    }
                ),
                placeholder: dataModel.textPlaceholder,
                textType: dataModel.textFieldType,
                maxLength: dataModel.maxLength,
                onTextChanged: { newValue in
                    // 这里可以添加额外的文本变化处理逻辑
                },
                toolbarConfig: dataModel.showToolbar ?
                    MKSFUTextFieldToolbarConfig(
                        showToolbar: true,
                        doneButtonTitle: dataModel.toolbarTitle,
                        doneButtonColor: dataModel.toolbarColor
                    ) : nil
            )
            .disabled(!dataModel.textEnable)
            .padding(.horizontal, 8)
        }
    }
}

// MARK: - 便捷初始化方法扩展
public extension MKSFUTextFieldCellModel {
    /// 便捷初始化方法
    convenience init(
        index: Int = 0,
        contentColor: Color = .white,
        msg: String,
        msgColor: Color = .primary,
        msgFont: Font = .system(size: 15),
        unit: String = "",
        unitColor: Color = .primary,
        unitFont: Font = .system(size: 13),
        textEnable: Bool = true,
        cellType: MKSFUTextFieldCellType = .normal,
        textFieldValue: String = "",
        textPlaceholder: String = "",
        textFieldTextColor: Color = .primary,
        textFieldTextFont: Font = .system(size: 15),
        textFieldType: MKSFUTextFieldType = .normal,
        maxLength: Int = 0,
        borderColor: Color = .gray.opacity(0.3),
        showToolbar: Bool = true,
        toolbarTitle: String = "Done",
        toolbarColor: Color = Color(MKColor.navBar),
        noteMsg: String = "",
        noteMsgColor: Color = .primary,
        noteMsgFont: Font = .system(size: 12)
    ) {
        self.init()
        self.index = index
        self.contentColor = contentColor
        self.msg = msg
        self.msgColor = msgColor
        self.msgFont = msgFont
        self.unit = unit
        self.unitColor = unitColor
        self.unitFont = unitFont
        self.textEnable = textEnable
        self.cellType = cellType
        self.textFieldValue = textFieldValue
        self.textPlaceholder = textPlaceholder
        self.textFieldTextColor = textFieldTextColor
        self.textFieldTextFont = textFieldTextFont
        self.textFieldType = textFieldType
        self.maxLength = maxLength
        self.borderColor = borderColor
        self.showToolbar = showToolbar
        self.toolbarTitle = toolbarTitle
        self.toolbarColor = toolbarColor
        self.noteMsg = noteMsg
        self.noteMsgColor = noteMsgColor
        self.noteMsgFont = noteMsgFont
    }
}

// MARK: - 简单预览版本
struct MKSFUTextFieldCellSimplePreview: View {
    var body: some View {
        VStack(spacing: 1) {
            MKSFUTextFieldCell(
                dataModel: {
                    let model = MKSFUTextFieldCellModel()
                    model.msg = "设备名称"
                    model.textPlaceholder = "请输入"
                    model.textFieldValue = "测试设备"
                    model.textFieldType = .normal
                    return model
                }()
            ) { index, text in
                print("输入: \(text)")
            }
            .background(Color.white)
            
            MKSFUTextFieldCell(
                dataModel: {
                    let model = MKSFUTextFieldCellModel()
                    model.msg = "信号强度"
                    model.unit = "dBm"
                    model.textPlaceholder = "请输入"
                    model.textFieldValue = "-65"
                    model.textFieldType = .realNumberOnly
                    model.maxLength = 3
                    model.noteMsg = "信号强度说明信号强度说明信号强度说明信号强度说明信号强度说明信号强度说明信号强度说明信号强度说明信号强度说明信号强度说明信号强度说明信号强度说明信号强度说明信号强度说明信号强度说明"
                    return model
                }()
            ) { index, text in
                print("输入: \(text)")
            }
            .background(Color.white)
            
            MKSFUTextFieldCell(
                dataModel: {
                    let model = MKSFUTextFieldCellModel()
                    model.msg = "MAC地址"
                    model.textPlaceholder = "输入MAC"
                    model.textFieldValue = "A1B2C3"
                    model.textFieldType = .hexCharOnly
                    model.maxLength = 12
                    model.showToolbar = false
                    return model
                }()
            ) { index, text in
                print("输入: \(text)")
            }
            .background(Color.white)
        }
        .padding()
    }
}

// MARK: - 基础使用示例
struct MKSFUTextFieldCellBasicUsage: View {
    @StateObject private var cellModel = MKSFUTextFieldCellModel()
    
    var body: some View {
        VStack {
            Text("文本框单元格示例")
                .font(.title2)
                .padding()
            
            MKSFUTextFieldCell(dataModel: cellModel) { index, text in
                print("输入了: \(text)")
            }
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 2)
            .padding()
            
            Spacer()
        }
        .onAppear {
            setupData()
        }
    }
    
    private func setupData() {
        cellModel.msg = "设备名称"
        cellModel.unit = "个"
        cellModel.textPlaceholder = "请输入名称"
        cellModel.textFieldValue = "默认设备"
        cellModel.textFieldType = .normal
        cellModel.noteMsg = "请输入有效的设备名称"
    }
}

// MARK: - 不同类型输入框示例
struct TextFieldTypesExample: View {
    var body: some View {
        VStack(spacing: 1) {
            MKSFUTextFieldCell(
                dataModel: {
                    let model = MKSFUTextFieldCellModel()
                    model.msg = "普通文本"
                    model.textPlaceholder = "可输入任意字符"
                    model.textFieldType = .normal
                    return model
                }()
            ) { index, text in
                print("普通文本: \(text)")
            }
            .background(Color.white)
            
            MKSFUTextFieldCell(
                dataModel: {
                    let model = MKSFUTextFieldCellModel()
                    model.msg = "纯数字"
                    model.textPlaceholder = "只能输入数字"
                    model.textFieldType = .realNumberOnly
                    model.maxLength = 5
                    return model
                }()
            ) { index, text in
                print("数字: \(text)")
            }
            .background(Color.white)
            
            MKSFUTextFieldCell(
                dataModel: {
                    let model = MKSFUTextFieldCellModel()
                    model.msg = "十六进制"
                    model.textPlaceholder = "0-9,A-F"
                    model.textFieldType = .hexCharOnly
                    model.maxLength = 6
                    return model
                }()
            ) { index, text in
                print("十六进制: \(text)")
            }
            .background(Color.white)
            
            MKSFUTextFieldCell(
                dataModel: {
                    let model = MKSFUTextFieldCellModel()
                    model.msg = "UUID"
                    model.textPlaceholder = "自动格式化"
                    model.textFieldType = .uuidMode
                    return model
                }()
            ) { index, text in
                print("UUID: \(text)")
            }
            .background(Color.white)
        }
        .padding()
    }
}

// MARK: - 预览提供器
struct MKSFUTextFieldCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MKSFUTextFieldCellSimplePreview()
                .previewDisplayName("简单预览")
            
            MKSFUTextFieldCellBasicUsage()
                .previewDisplayName("基础使用")
            
            TextFieldTypesExample()
                .previewDisplayName("不同类型输入框")
        }
    }
}
