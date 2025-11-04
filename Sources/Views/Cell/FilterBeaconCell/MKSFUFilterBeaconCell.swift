//
//  MKSFUFilterBeaconCell.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI
import Combine

// MARK: - SwiftUI Data Model
public class MKSFUFilterBeaconCellModel: ObservableObject {
    @Published public var index: Int = 0
    @Published public var msg: String = ""
    @Published public var minValue: String = ""
    @Published public var maxValue: String = ""
    
    public init() {}
}

// MARK: - SwiftUI Filter Beacon Cell
public struct MKSFUFilterBeaconCell: View {
    @ObservedObject public var dataModel: MKSFUFilterBeaconCellModel
    public var onMinValueChanged: (String, Int) -> Void
    public var onMaxValueChanged: (String, Int) -> Void
    
    @State private var minText: String = ""
    @State private var maxText: String = ""
    
    public init(
        dataModel: MKSFUFilterBeaconCellModel,
        onMinValueChanged: @escaping (String, Int) -> Void = { _, _ in },
        onMaxValueChanged: @escaping (String, Int) -> Void = { _, _ in }
    ) {
        self.dataModel = dataModel
        self.onMinValueChanged = onMinValueChanged
        self.onMaxValueChanged = onMaxValueChanged
        self._minText = State(initialValue: dataModel.minValue)
        self._maxText = State(initialValue: dataModel.maxValue)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Message label
            Text(dataModel.msg)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .padding(.horizontal, 15)
            
            // Min/Max input row
            HStack(spacing: 5) {
                Text("Min")
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .frame(width: 50, alignment: .leading)
                
                TextField("0~65535", text: $minText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
                    .onChange(of: minText) { newValue in
                        // 数字验证
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue {
                            minText = filtered
                        }
                        
                        // 长度限制
                        if minText.count > 5 {
                            minText = String(minText.prefix(5))
                        }
                        
                        dataModel.minValue = minText
                        onMinValueChanged(minText, dataModel.index)
                    }
                
                Text("~")
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .frame(width: 30)
                
                Text("Max")
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .frame(width: 50, alignment: .leading)
                
                TextField("0~65535", text: $maxText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
                    .onChange(of: maxText) { newValue in
                        // 数字验证
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue {
                            maxText = filtered
                        }
                        
                        // 长度限制
                        if maxText.count > 5 {
                            maxText = String(maxText.prefix(5))
                        }
                        
                        dataModel.maxValue = maxText
                        onMaxValueChanged(maxText, dataModel.index)
                    }
                
                Spacer()
            }
            .padding(.horizontal, 15)
        }
        .padding(.vertical, 5)
        .onReceive(dataModel.$minValue) { newValue in
            if newValue != minText {
                minText = newValue
            }
        }
        .onReceive(dataModel.$maxValue) { newValue in
            if newValue != maxText {
                maxText = newValue
            }
        }
    }
}

// MARK: - 便捷初始化方法扩展
public extension MKSFUFilterBeaconCellModel {
    /// 便捷初始化方法
    convenience init(
        index: Int = 0,
        msg: String = "",
        minValue: String = "",
        maxValue: String = ""
    ) {
        self.init()
        self.index = index
        self.msg = msg
        self.minValue = minValue
        self.maxValue = maxValue
    }
}

// MARK: - 使用示例

// Example 1: 在列表中使用
struct FilterBeaconExampleView: View {
    @StateObject private var beaconModel1 = MKSFUFilterBeaconCellModel(
        index: 0,
        msg: "主要信标过滤",
        minValue: "100",
        maxValue: "1000"
    )
    
    @StateObject private var beaconModel2 = MKSFUFilterBeaconCellModel(
        index: 1,
        msg: "次要信标范围",
        minValue: "0",
        maxValue: "500"
    )
    
    var body: some View {
        List {
            MKSFUFilterBeaconCell(
                dataModel: beaconModel1,
                onMinValueChanged: { value, index in
                    print("主要信标最小值变化: \(value) at index: \(index)")
                    validateRange(for: beaconModel1)
                },
                onMaxValueChanged: { value, index in
                    print("主要信标最大值变化: \(value) at index: \(index)")
                    validateRange(for: beaconModel1)
                }
            )
            
            MKSFUFilterBeaconCell(
                dataModel: beaconModel2,
                onMinValueChanged: { value, index in
                    print("次要信标最小值变化: \(value) at index: \(index)")
                    validateRange(for: beaconModel2)
                },
                onMaxValueChanged: { value, index in
                    print("次要信标最大值变化: \(value) at index: \(index)")
                    validateRange(for: beaconModel2)
                }
            )
        }
        .listStyle(PlainListStyle())
    }
    
    private func validateRange(for model: MKSFUFilterBeaconCellModel) {
        guard let minVal = Int(model.minValue),
              let maxVal = Int(model.maxValue) else { return }
        
        if minVal > maxVal {
            print("警告: 最小值 \(minVal) 大于最大值 \(maxVal)")
        }
        
        // 范围验证 0~65535
        if minVal < 0 || minVal > 65535 {
            print("警告: 最小值 \(minVal) 超出范围 0~65535")
        }
        
        if maxVal < 0 || maxVal > 65535 {
            print("警告: 最大值 \(maxVal) 超出范围 0~65535")
        }
    }
}

// Example 2: 独立使用
struct SingleFilterBeaconView: View {
    @StateObject private var beaconModel = MKSFUFilterBeaconCellModel(
        msg: "信号强度过滤",
        minValue: "-80",
        maxValue: "-40"
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("信标过滤设置")
                .font(.headline)
            
            MKSFUFilterBeaconCell(
                dataModel: beaconModel,
                onMinValueChanged: { value, index in
                    print("最小值更新: \(value)")
                    updateDisplay()
                },
                onMaxValueChanged: { value, index in
                    print("最大值更新: \(value)")
                    updateDisplay()
                }
            )
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(color: .gray.opacity(0.2), radius: 2)
            
            // 显示当前设置
            VStack(alignment: .leading) {
                Text("当前范围: \(beaconModel.minValue) ~ \(beaconModel.maxValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    private func updateDisplay() {
        print("当前过滤范围: \(beaconModel.minValue) ~ \(beaconModel.maxValue)")
    }
}

// MARK: - Preview
struct MKSFUFilterBeaconCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FilterBeaconExampleView()
                .previewDisplayName("列表示例")
            
            SingleFilterBeaconView()
                .previewDisplayName("独立使用")
            
            // 单个单元格预览
            MKSFUFilterBeaconCell(
                dataModel: MKSFUFilterBeaconCellModel(
                    msg: "预览信标单元格",
                    minValue: "100",
                    maxValue: "200"
                )
            ) { minValue, index in
                print("Min: \(minValue)")
            } onMaxValueChanged: { maxValue, index in
                print("Max: \(maxValue)")
            }
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("单个单元格")
        }
    }
}
