//
//  MKSFUNormalSliderCell.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI

import MKBaseSwiftModule

// MARK: - Cell Model
public class MKSFUNormalSliderCellModel: ObservableObject {
    // Cell top configuration
    @Published public var index: Int = 0
    @Published public var msg: NSAttributedString = NSAttributedString()
    @Published public var contentColor: Color = .white
    
    // Right unit label configuration
    @Published public var unit: String = "dBm"
    @Published public var unitColor: Color = .primary
    @Published public var unitFont: Font = .system(size: 11)
    
    // Slider configuration
    @Published public var sliderEnable: Bool = true
    @Published public var sliderMinValue: Int = -127
    @Published public var sliderMaxValue: Int = 0
    @Published public var sliderValue: Int = 0 {
        didSet {
            // 当 sliderValue 变化时更新显示文本
            updateNoteText()
        }
    }
    
    // Bottom label configuration
    @Published public var changed: Bool = false
    @Published public var noteMsg: String = ""
    @Published public var leftNoteMsg: String = ""
    @Published public var rightNoteMsg: String = ""
    @Published public var noteMsgColor: Color = .primary
    @Published public var noteMsgFont: Font = .system(size: 12)
    
    // 计算属性：显示在底部的文本
    public var displayNoteText: String {
        if changed {
            return "\(leftNoteMsg) \(sliderValue)\(unit) \(rightNoteMsg)"
        } else {
            return noteMsg
        }
    }
    
    public init() {}
    
    private func updateNoteText() {
        // 这里可以添加其他需要更新的逻辑
        objectWillChange.send()
    }
}

// MARK: - Cell Implementation
public struct MKSFUNormalSliderCell: View {
    // MARK: - Properties
    @ObservedObject public var dataModel: MKSFUNormalSliderCellModel
    
    // SwiftUI 常用的回调方式
    public var onSliderValueChanged: ((Int, Int) -> Void)?
    
    // 内部使用的滑块数据模型
    @StateObject private var sliderDataModel: MKSFUSliderModel
    
    // MARK: - Constants
    private let offset_X: CGFloat = 15
    private let offset_Y: CGFloat = 10
    
    // MARK: - Initialization
    public init(
        dataModel: MKSFUNormalSliderCellModel,
        onSliderValueChanged: ((Int, Int) -> Void)? = nil
    ) {
        self.dataModel = dataModel
        self.onSliderValueChanged = onSliderValueChanged
        
        // 初始化滑块数据模型
        let sliderModel = MKSFUSliderModel(
            value: Double(dataModel.sliderValue),
            range: Double(dataModel.sliderMinValue)...Double(dataModel.sliderMaxValue)
        )
        _sliderDataModel = StateObject(wrappedValue: sliderModel)
    }
    
    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Message Label
            if !dataModel.msg.string.isEmpty {
                AttributedText(dataModel.msg)
                    .padding(.horizontal, offset_X)
                    .padding(.top, offset_Y)
            }
            
            // Slider Row
            HStack(spacing: 5) {
                // Slider
                MKSFUSlider(
                    dataModel: sliderDataModel,
                    minimumTrackColor: .blue,
                    maximumTrackColor: .gray.opacity(0.3)
                ) { newValue in
                    // 实时值变化时更新数据模型
                    let intValue = Int(round(newValue))
                    if dataModel.sliderValue != intValue {
                        dataModel.sliderValue = intValue
                    }
                } onEditingChanged: { editing in
                    if !editing {
                        // 编辑结束时触发回调
                        let intValue = Int(round(sliderDataModel.value))
                        onSliderValueChanged?(intValue, dataModel.index)
                    }
                }
                .disabled(!dataModel.sliderEnable)
                .frame(height: 44)
                
                // Value Label
                Text("\(dataModel.sliderValue)\(dataModel.unit)")
                    .font(dataModel.unitFont)
                    .foregroundColor(dataModel.unitColor)
                    .frame(width: 70, alignment: .trailing)
            }
            .padding(.horizontal, offset_X)
            .padding(.top, 5)
            
            // Note Label
            if !dataModel.displayNoteText.isEmpty {
                Text(dataModel.displayNoteText)
                    .font(dataModel.noteMsgFont)
                    .foregroundColor(dataModel.noteMsgColor)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, offset_X)
                    .padding(.top, 5)
                    .padding(.bottom, offset_Y)
            } else {
                Spacer(minLength: offset_Y)
            }
        }
        .background(dataModel.contentColor)
        .onChange(of: dataModel.sliderValue) { newValue in
            // 当外部修改 sliderValue 时更新滑块数据模型
            if sliderDataModel.value != Double(newValue) {
                sliderDataModel.value = Double(newValue)
            }
        }
        .onChange(of: dataModel.sliderMinValue) { newValue in
            // 当最小值变化时更新滑块范围
            sliderDataModel.range = Double(newValue)...Double(dataModel.sliderMaxValue)
        }
        .onChange(of: dataModel.sliderMaxValue) { newValue in
            // 当最大值变化时更新滑块范围
            sliderDataModel.range = Double(dataModel.sliderMinValue)...Double(newValue)
        }
    }
}

// MARK: - AttributedText Helper (用于显示 NSAttributedString)
public struct AttributedText: View {
    private let attributedString: NSAttributedString
    
    public init(_ attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }
    
    public var body: some View {
        if #available(iOS 15.0, *) {
            Text(AttributedString(attributedString))
        } else {
            Text(attributedString.string)
                .font(.system(size: 15))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - 使用示例
struct MKSFUNormalSliderCellExample: View {
    @StateObject private var cellModel = MKSFUNormalSliderCellModel()
    
    var body: some View {
        VStack {
            MKSFUNormalSliderCell(dataModel: cellModel) { value, index in
                print("滑块值变化: \(value), 索引: \(index)")
                
                // 更新数据模型
                cellModel.sliderValue = value
                cellModel.changed = true
            }
            .frame(height: 120)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 2)
            .padding()
            
            // 显示当前值
            Text("当前值: \(cellModel.sliderValue)\(cellModel.unit)")
                .font(.headline)
            
            // 控制按钮示例
            HStack {
                Button("设置为-50") {
                    cellModel.sliderValue = -50
                    cellModel.changed = true
                }
                
                Button("设置为-100") {
                    cellModel.sliderValue = -100
                    cellModel.changed = true
                }
                
                Button("重置") {
                    cellModel.sliderValue = -80
                    cellModel.changed = true
                }
            }
            .buttonStyle(.bordered)
        }
        .onAppear {
            setupExampleData()
        }
    }
    
    private func setupExampleData() {
        // 设置示例数据 - 使用正确的 UIColor
        let attributedString = NSAttributedString(
            string: "信号强度设置",
            attributes: [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: MKColor.defaultText
            ]
        )
        
        cellModel.msg = attributedString
        cellModel.sliderMinValue = -127
        cellModel.sliderMaxValue = 0
        cellModel.sliderValue = -80
        cellModel.unit = "dBm"
        cellModel.leftNoteMsg = "当前信号强度:"
        cellModel.rightNoteMsg = "建议设置在-90以上"
        cellModel.changed = true
    }
}

// MARK: - 多个滑块单元格示例
struct MultipleSliderCellsExample: View {
    @StateObject private var cellModel1 = MKSFUNormalSliderCellModel()
    @StateObject private var cellModel2 = MKSFUNormalSliderCellModel()
    @StateObject private var cellModel3 = MKSFUNormalSliderCellModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach([cellModel1, cellModel2, cellModel3], id: \.index) { model in
                    MKSFUNormalSliderCell(dataModel: model) { value, index in
                        print("单元格 \(index) 值变化: \(value)")
                        model.sliderValue = value
                        model.changed = true
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                }
            }
            .padding()
        }
        .onAppear {
            setupCellData()
        }
    }
    
    private func setupCellData() {
        let titles = ["2.4GHz 信号强度", "5GHz 信号强度", "蓝牙信号强度"]
        let values = [-60, -70, -80]
        
        for (index, model) in [cellModel1, cellModel2, cellModel3].enumerated() {
            let attributedString = NSAttributedString(
                string: titles[index],
                attributes: [
                    .font: UIFont.systemFont(ofSize: 15),
                    .foregroundColor: MKColor.defaultText
                ]
            )
            
            model.msg = attributedString
            model.index = index
            model.sliderMinValue = -127
            model.sliderMaxValue = 0
            model.sliderValue = values[index]
            model.unit = "dBm"
            model.leftNoteMsg = "当前值:"
            model.rightNoteMsg = ""
            model.changed = true
        }
    }
}

// MARK: - 预览
struct MKSFUNormalSliderCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MKSFUNormalSliderCellExample()
                .previewDisplayName("单个滑块单元格")
            
            MultipleSliderCellsExample()
                .previewDisplayName("多个滑块单元格")
        }
    }
}
