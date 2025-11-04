//
//  MKSFUTextButtonCell.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI

// MARK: - Model
public class MKSFUTextButtonCellModel: ObservableObject, Identifiable {
    public let id = UUID()
    
    // MARK: Cell Top Configuration
    @Published public var index: Int = 0
    @Published public var contentColor: Color = .white
    
    // MARK: Left Label Configuration
    @Published public var msg: String = ""
    @Published public var msgColor: Color = .primary
    @Published public var msgFont: Font = .system(size: 15)
    
    // MARK: Right Button Configuration
    @Published public var buttonEnable: Bool = true
    @Published public var dataList: [String] = []
    @Published public var dataListIndex: Int = 0
    @Published public var buttonBackColor: Color = .blue
    @Published public var buttonTitleColor: Color = .white
    @Published public var buttonLabelFont: Font = .system(size: 15)
    
    // MARK: Bottom Label Configuration
    @Published public var noteMsg: String = ""
    @Published public var noteMsgColor: Color = .primary
    @Published public var noteMsgFont: Font = .system(size: 12)
    
    public init() {}
    
    // 当前选中的值
    public var selectedValue: String {
        guard dataList.indices.contains(dataListIndex) else {
            return dataList.first ?? "请选择"
        }
        return dataList[dataListIndex]
    }
}

// MARK: - Cell
public struct MKSFUTextButtonCell: View {
    
    // MARK: - Properties
    @ObservedObject public var dataModel: MKSFUTextButtonCellModel
    
    // SwiftUI 回调方式
    public var onValueSelected: ((Int, Int, String) -> Void)?
    
    // MARK: - State
    @State private var showPicker = false
    
    // MARK: - Constants
    private let offsetX: CGFloat = 15
    private let selectButtonWidth: CGFloat = 130
    private let selectButtonHeight: CGFloat = 30
    
    // MARK: - Initialization
    public init(
        dataModel: MKSFUTextButtonCellModel,
        onValueSelected: ((Int, Int, String) -> Void)? = nil
    ) {
        self.dataModel = dataModel
        self.onValueSelected = onValueSelected
    }
    
    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main content row
            HStack(alignment: .top, spacing: offsetX) {
                // Left message label
                Text(dataModel.msg)
                    .font(dataModel.msgFont)
                    .foregroundColor(dataModel.msgColor)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Right button
                Button(action: {
                    if dataModel.buttonEnable && !dataModel.dataList.isEmpty {
                        showPicker = true
                    }
                }) {
                    Text(selectedValue)
                        .font(dataModel.buttonLabelFont)
                        .foregroundColor(dataModel.buttonTitleColor)
                        .frame(width: selectButtonWidth, height: selectButtonHeight)
                        .background(dataModel.buttonBackColor)
                        .cornerRadius(6)
                }
                .disabled(!dataModel.buttonEnable || dataModel.dataList.isEmpty)
                .opacity((!dataModel.buttonEnable || dataModel.dataList.isEmpty) ? 0.6 : 1.0)
            }
            .padding(.horizontal, offsetX)
            .padding(.top, offsetX)
            .padding(.bottom, dataModel.noteMsg.isEmpty ? offsetX : 10)
            
            // Bottom note label
            if !dataModel.noteMsg.isEmpty {
                Text(dataModel.noteMsg)
                    .font(dataModel.noteMsgFont)
                    .foregroundColor(dataModel.noteMsgColor)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, offsetX)
                    .padding(.bottom, offsetX)
            }
        }
        .background(dataModel.contentColor)
        .sheet(isPresented: $showPicker) {
            PickerView(
                dataList: dataModel.dataList,
                selectedIndex: dataModel.dataListIndex,
                onValueSelected: { selectedIndex in
                    dataModel.dataListIndex = selectedIndex
                    onValueSelected?(
                        dataModel.index,
                        selectedIndex,
                        dataModel.dataList[selectedIndex]
                    )
                }
            )
        }
    }
    
    private var selectedValue: String {
        guard dataModel.dataList.indices.contains(dataModel.dataListIndex) else {
            return dataModel.dataList.first ?? "请选择"
        }
        return dataModel.dataList[dataModel.dataListIndex]
    }
}

// MARK: - Picker View
private struct PickerView: View {
    let dataList: [String]
    let selectedIndex: Int
    let onValueSelected: (Int) -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    @State private var currentSelection: Int
    
    init(dataList: [String], selectedIndex: Int, onValueSelected: @escaping (Int) -> Void) {
        self.dataList = dataList
        self.selectedIndex = selectedIndex
        self.onValueSelected = onValueSelected
        self._currentSelection = State(initialValue: selectedIndex)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
                
                Spacer()
                
                Text("请选择")
                    .font(.headline)
                
                Spacer()
                
                Button("确定") {
                    onValueSelected(currentSelection)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
            
            Picker("选择", selection: $currentSelection) {
                ForEach(0..<dataList.count, id: \.self) { index in
                    Text(dataList[index])
                        .tag(index)
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            Spacer()
        }
    }
}

// MARK: - 简单预览版本
struct MKSFUTextButtonCellSimplePreview: View {
    var body: some View {
        VStack(spacing: 1) {
            MKSFUTextButtonCell(
                dataModel: {
                    let model = MKSFUTextButtonCellModel()
                    model.msg = "设备类型"
                    model.dataList = ["智能灯", "智能插座", "智能开关"]
                    model.dataListIndex = 0
                    return model
                }()
            ) { index, dataListIndex, value in
                print("选择了: \(value)")
            }
            .background(Color.white)
            
            MKSFUTextButtonCell(
                dataModel: {
                    let model = MKSFUTextButtonCellModel()
                    model.msg = "信号强度"
                    model.dataList = ["强", "中", "弱"]
                    model.dataListIndex = 1
                    model.buttonBackColor = .orange
                    return model
                }()
            ) { index, dataListIndex, value in
                print("选择了: \(value)")
            }
            .background(Color.white)
        }
        .padding()
    }
}

// MARK: - 基础使用示例
struct MKSFUTextButtonCellBasicUsage: View {
    @StateObject private var cellModel = MKSFUTextButtonCellModel()
    
    var body: some View {
        VStack {
            Text("文本按钮单元格")
                .font(.title2)
                .padding()
            
            MKSFUTextButtonCell(dataModel: cellModel) { index, dataListIndex, value in
                print("选择了: \(value)")
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
        cellModel.msg = "工作模式"
        cellModel.dataList = ["自动模式", "手动模式", "定时模式", "节能模式"]
        cellModel.dataListIndex = 0
        cellModel.noteMsg = "选择设备的工作模式"
    }
}

// MARK: - 预览提供器
struct MKSFUTextButtonCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MKSFUTextButtonCellSimplePreview()
                .previewDisplayName("简单预览")
            
            MKSFUTextButtonCellBasicUsage()
                .previewDisplayName("基础使用")
        }
    }
}
