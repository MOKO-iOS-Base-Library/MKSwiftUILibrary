//
//  MKSFUButtonMsgCell.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI

import MKBaseSwiftModule

// MARK: - SwiftUI Data Model
public class MKSFUButtonMsgCellModel: ObservableObject {
    @Published public var index: Int = 0
    @Published public var contentColor: Color = .white
    @Published public var msg: String = ""
    @Published public var msgColor: Color = .black
    @Published public var msgFont: Font = .system(size: 15)
    @Published public var buttonEnable: Bool = true
    @Published public var buttonTitle: String = ""
    @Published public var buttonBackColor: Color = .blue
    @Published public var buttonTitleColor: Color = .white
    @Published public var buttonLabelFont: Font = .system(size: 15)
    @Published public var noteMsg: String = ""
    @Published public var noteMsgColor: Color = .gray
    @Published public var noteMsgFont: Font = .system(size: 12)
    
    public init() {}
    
    // 如果需要 UIKit 兼容性，保留 UIColor/UIFont 版本
    public var uiContentColor: UIColor { UIColor(contentColor) }
    public var uiMsgColor: UIColor { UIColor(msgColor) }
    public var uiMsgFont: UIFont { UIFont.systemFont(ofSize: 15) }
    public var uiButtonBackColor: UIColor { UIColor(buttonBackColor) }
    public var uiButtonTitleColor: UIColor { UIColor(buttonTitleColor) }
    public var uiButtonLabelFont: UIFont { UIFont.systemFont(ofSize: 15) }
    public var uiNoteMsgColor: UIColor { UIColor(noteMsgColor) }
    public var uiNoteMsgFont: UIFont { UIFont.systemFont(ofSize: 12) }
    
    // Helper method for UIKit compatibility
    public func cellHeightWithContentWidth(_ width: CGFloat) -> CGFloat {
        let maxMsgWidth = width - 3 * 15 - 130
        let msgSize = msg.size(withFont: uiMsgFont, maxSize: CGSize(width: maxMsgWidth, height: .greatestFiniteMagnitude))
        
        guard !noteMsg.isEmpty else {
            return max(msgSize.height + 2 * 15, 50)
        }
        
        let noteSize = noteMsg.size(withFont: uiNoteMsgFont, maxSize: CGSize(width: (width - 2 * 15), height: .greatestFiniteMagnitude))
        
        return max(msgSize.height + 2 * 15, 50) + noteSize.height + 10
    }
}

// MARK: - SwiftUI Button Message Cell
public struct MKSFUButtonMsgCell: View {
    @ObservedObject public var dataModel: MKSFUButtonMsgCellModel
    public var onButtonPressed: (Int) -> Void
    
    public init(dataModel: MKSFUButtonMsgCellModel, onButtonPressed: @escaping (Int) -> Void = { _ in }) {
        self.dataModel = dataModel
        self.onButtonPressed = onButtonPressed
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main content row
            HStack(alignment: .top) {
                // Message label
                Text(dataModel.msg)
                    .font(dataModel.msgFont)
                    .foregroundColor(dataModel.msgColor)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Action button
                Button(action: {
                    onButtonPressed(dataModel.index)
                }) {
                    Text(dataModel.buttonTitle)
                        .font(dataModel.buttonLabelFont)
                        .foregroundColor(dataModel.buttonTitleColor)
                        .frame(width: 130, height: 30)
                }
                .disabled(!dataModel.buttonEnable)
                .background(dataModel.buttonBackColor)
                .cornerRadius(15)
                .buttonStyle(PlainButtonStyle()) // 关键：使用 PlainButtonStyle
            }
            .padding(.horizontal, 15)
            .padding(.top, 15)
            .padding(.bottom, dataModel.noteMsg.isEmpty ? 15 : 10)
            
            // Note message (conditionally displayed)
            if !dataModel.noteMsg.isEmpty {
                Text(dataModel.noteMsg)
                    .font(dataModel.noteMsgFont)
                    .foregroundColor(dataModel.noteMsgColor)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 15)
                    .padding(.bottom, 15)
            }
        }
        .background(dataModel.contentColor)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        // 关键：添加一个空的 onTapGesture 来阻止 List 的点击事件
        .onTapGesture {}
    }
}

// MARK: - 便捷初始化方法扩展
public extension MKSFUButtonMsgCellModel {
    /// 便捷初始化方法
    convenience init(
        index: Int = 0,
        contentColor: Color = .white,
        msg: String,
        msgColor: Color = .black,
        msgFont: Font = .system(size: 15),
        buttonEnable: Bool = true,
        buttonTitle: String,
        buttonBackColor: Color = .blue,
        buttonTitleColor: Color = .white,
        buttonLabelFont: Font = .system(size: 15),
        noteMsg: String = "",
        noteMsgColor: Color = .gray,
        noteMsgFont: Font = .system(size: 12)
    ) {
        self.init()
        self.index = index
        self.contentColor = contentColor
        self.msg = msg
        self.msgColor = msgColor
        self.msgFont = msgFont
        self.buttonEnable = buttonEnable
        self.buttonTitle = buttonTitle
        self.buttonBackColor = buttonBackColor
        self.buttonTitleColor = buttonTitleColor
        self.buttonLabelFont = buttonLabelFont
        self.noteMsg = noteMsg
        self.noteMsgColor = noteMsgColor
        self.noteMsgFont = noteMsgFont
    }
}

// MARK: - 使用示例

// Example 1: Basic usage in a List
struct ExampleListView: View {
    @StateObject private var cellModel1 = MKSFUButtonMsgCellModel(
        index:0,
        msg: "扫描蓝牙设备",
        buttonTitle: "开始扫描",
        buttonBackColor: .blue,
        noteMsg: "点击按钮开始扫描附近的蓝牙设备"
    )
    
    @StateObject private var cellModel2 = MKSFUButtonMsgCellModel(
        index:1,
        msg: "设备连接",
        buttonTitle: "连接",
        buttonBackColor: .green
    )
    
    var body: some View {
        List {
            MKSFUButtonMsgCell(dataModel: cellModel1) { index in
                print("开始扫描设备，index: \(index)")
                // Handle scan action
            }
            .listRowInsets(EdgeInsets())
            .background(Color.white)
            
            MKSFUButtonMsgCell(dataModel: cellModel2) { index in
                print("连接设备，index: \(index)")
                // Handle connect action
            }
            .listRowInsets(EdgeInsets())
            .background(Color.white)
        }
        .listStyle(PlainListStyle())
    }
}

// Example 2: 动态更新示例
struct DynamicExampleView: View {
    @StateObject private var cellModel = MKSFUButtonMsgCellModel(
        msg: "设备状态",
        buttonTitle: "开始扫描",
        noteMsg: "准备扫描设备..."
    )
    
    @State private var isScanning = false
    
    var body: some View {
        VStack {
            MKSFUButtonMsgCell(dataModel: cellModel) { index in
                isScanning.toggle()
                updateUI()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 2)
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
    
    private func updateUI() {
        if isScanning {
            cellModel.buttonTitle = "停止扫描"
            cellModel.buttonBackColor = .red
            cellModel.noteMsg = "正在扫描设备..."
        } else {
            cellModel.buttonTitle = "开始扫描"
            cellModel.buttonBackColor = .blue
            cellModel.noteMsg = "准备扫描设备..."
        }
    }
}

// MARK: - Preview
struct MKSFUButtonMsgCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExampleListView()
                .previewDisplayName("List View")
            
            DynamicExampleView()
                .previewDisplayName("Dynamic Example")
            
            // 单个单元格预览
            MKSFUButtonMsgCell(
                dataModel: MKSFUButtonMsgCellModel(
                    msg: "预览单元格",
                    buttonTitle: "测试按钮",
                    noteMsg: "这是一个测试备注信息，用于预览显示效果"
                )
            ) { index in
                print("按钮点击: \(index)")
            }
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.white)
            .previewDisplayName("Single Cell")
        }
    }
}
