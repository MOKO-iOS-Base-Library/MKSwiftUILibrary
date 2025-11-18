//
//  MKSFUFilterByRawDataCell.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI
import Combine

import MKBaseSwiftModule

// MARK: - SwiftUI Data Model
public class MKSFUFilterByRawDataCellModel: ObservableObject {
    @Published public var index: Int = 0
    @Published public var msg: String = ""
    @Published public var contentColor: Color = .white
    @Published public var dataType: String = ""
    @Published public var minIndex: String = ""
    @Published public var maxIndex: String = ""
    @Published public var rawData: String = ""
    @Published public var rawDataMaxBytes: Int = 29
    @Published public var dataTypePlaceHolder: String = ""
    @Published public var minTextFieldPlaceHolder: String = ""
    @Published public var maxTextFieldPlaceHolder: String = ""
    @Published public var rawTextFieldPlaceHolder: String = ""
    
    public init() {}
    
    public func validParamsSuccess() -> Bool {
        // 验证数据类型：2位十六进制
        guard dataType.count == 2, dataType.matchesRegex(String.isHexadecimal) else {
            return false
        }
        
        if minIndex.isEmpty && maxIndex.isEmpty {
            return validRawDatas()
        }
        
        // 验证最小索引：0-2位数字，0~rawDataMaxBytes
        guard !minIndex.isEmpty, minIndex.count <= 2, minIndex.matchesRegex(String.isRealNumbers),
              let minValue = Int(minIndex), minValue >= 0, minValue <= rawDataMaxBytes else {
            return false
        }
        
        if minValue == 0 {
            if (maxIndex.isEmpty || (Int(maxIndex) == 0)) && validRawDatas() {
                return true
            }
            return false
        }
        
        // 验证最大索引：0-2位数字，0~rawDataMaxBytes，且 >= 最小索引
        guard !maxIndex.isEmpty, maxIndex.count <= 2, maxIndex.matchesRegex(String.isRealNumbers),
              let maxValue = Int(maxIndex), maxValue >= 0, maxValue <= rawDataMaxBytes,
              maxValue >= minValue else {
            return false
        }
        
        // 验证原始数据：十六进制，长度不超过最大字节数*2
        guard MKValid.isStringValid(rawData), rawData.count <= rawDataMaxBytes * 2,
              rawData.matchesRegex(String.isHexadecimal) else {
            return false
        }
        
        let totalLen = (maxValue - minValue + 1) * 2
        return rawData.count == totalLen
    }
    
    public func validRawDatas() -> Bool {
        guard MKValid.isStringValid(rawData), rawData.count <= rawDataMaxBytes * 2,
              rawData.matchesRegex(String.isHexadecimal) else {
            return false
        }
        return rawData.count % 2 == 0
    }
}

// MARK: - Text Type Enum
public enum MKSFUFilterByRawDataTextType: Int {
    case dataType
    case minIndex
    case maxIndex
    case rawDataType
}

// MARK: - SwiftUI Filter By Raw Data Cell
public struct MKSFUFilterByRawDataCell: View {
    @ObservedObject public var dataModel: MKSFUFilterByRawDataCellModel
    
    // Closure callbacks instead of delegate
    public var onDataTypeChanged: (String, Int) -> Void
    public var onMinIndexChanged: (String, Int) -> Void
    public var onMaxIndexChanged: (String, Int) -> Void
    public var onRawDataChanged: (String, Int) -> Void
    
    // 固定的底部线条样式
    private let bottomLineColor: Color = Color(red: 238/255, green: 238/255, blue: 238/255)
    private let bottomLineHeight: CGFloat = 0.5
    
    public init(
        dataModel: MKSFUFilterByRawDataCellModel,
        onDataTypeChanged: @escaping (String, Int) -> Void = { _, _ in },
        onMinIndexChanged: @escaping (String, Int) -> Void = { _, _ in },
        onMaxIndexChanged: @escaping (String, Int) -> Void = { _, _ in },
        onRawDataChanged: @escaping (String, Int) -> Void = { _, _ in }
    ) {
        self.dataModel = dataModel
        self.onDataTypeChanged = onDataTypeChanged
        self.onMinIndexChanged = onMinIndexChanged
        self.onMaxIndexChanged = onMaxIndexChanged
        self.onRawDataChanged = onRawDataChanged
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main content
            VStack(alignment: .leading, spacing: 5) {
                // Message label
                Text(dataModel.msg)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 15)
                
                // Data type and index row
                HStack(spacing: 5) {
                    // Data type field - 2位十六进制
                    MKSFUTextField(
                        text: Binding(
                            get: { dataModel.dataType },
                            set: { newValue in
                                dataModel.dataType = newValue
                                onDataTypeChanged(newValue, dataModel.index)
                            }
                        ),
                        placeholder: dataModel.dataTypePlaceHolder,
                        textType: .hexCharOnly,
                        maxLength: 2
                    )
                    .frame(width: 70)
                    
                    Spacer().frame(width: 20)
                    
                    // Min index field - 2位数字
                    MKSFUTextField(
                        text: Binding(
                            get: { dataModel.minIndex },
                            set: { newValue in
                                dataModel.minIndex = newValue
                                onMinIndexChanged(newValue, dataModel.index)
                            }
                        ),
                        placeholder: dataModel.minTextFieldPlaceHolder,
                        textType: .realNumberOnly,
                        maxLength: 2
                    )
                    .frame(width: 40)
                    
                    Text("~")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                        .frame(width: 20)
                    
                    // Max index field - 2位数字
                    MKSFUTextField(
                        text: Binding(
                            get: { dataModel.maxIndex },
                            set: { newValue in
                                dataModel.maxIndex = newValue
                                onMaxIndexChanged(newValue, dataModel.index)
                            }
                        ),
                        placeholder: dataModel.maxTextFieldPlaceHolder,
                        textType: .realNumberOnly,
                        maxLength: 2
                    )
                    .frame(width: 40)
                    
                    Text("Byte")
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                        .frame(width: 40)
                    
                    Spacer()
                }
                .padding(.horizontal, 15)
                
                // Raw data field - 十六进制数据
                MKSFUTextField(
                    text: Binding(
                        get: { dataModel.rawData },
                        set: { newValue in
                            dataModel.rawData = newValue
                            onRawDataChanged(newValue, dataModel.index)
                        }
                    ),
                    placeholder: dataModel.rawTextFieldPlaceHolder,
                    textType: .hexCharOnly,
                    maxLength: dataModel.rawDataMaxBytes * 2
                )
                .padding(.horizontal, 15)
            }
            .padding(.vertical, 5)
            .background(dataModel.contentColor)
            
            // 固定的底部线条，使用 GeometryReader 确保准确的左右间距
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Spacer().frame(width: 15)
                    
                    Rectangle()
                        .fill(bottomLineColor)
                        .frame(height: bottomLineHeight)
                    
                    Spacer().frame(width: 15)
                }
            }
            .frame(height: bottomLineHeight)
        }
    }
}

// MARK: - 便捷初始化方法扩展
public extension MKSFUFilterByRawDataCellModel {
    /// 便捷初始化方法
    convenience init(
        index: Int = 0,
        msg: String = "",
        contentColor: Color = .white,
        dataType: String = "",
        minIndex: String = "",
        maxIndex: String = "",
        rawData: String = "",
        rawDataMaxBytes: Int = 29,
        dataTypePlaceHolder: String = "DataType",
        minTextFieldPlaceHolder: String = "Min",
        maxTextFieldPlaceHolder: String = "Max",
        rawTextFieldPlaceHolder: String = "Raw Data"
    ) {
        self.init()
        self.index = index
        self.msg = msg
        self.contentColor = contentColor
        self.dataType = dataType
        self.minIndex = minIndex
        self.maxIndex = maxIndex
        self.rawData = rawData
        self.rawDataMaxBytes = rawDataMaxBytes
        self.dataTypePlaceHolder = dataTypePlaceHolder
        self.minTextFieldPlaceHolder = minTextFieldPlaceHolder
        self.maxTextFieldPlaceHolder = maxTextFieldPlaceHolder
        self.rawTextFieldPlaceHolder = rawTextFieldPlaceHolder
    }
}

// MARK: - 使用示例

// Example 1: 在列表中使用
struct FilterByRawDataExampleView: View {
    @StateObject private var rawDataModel1 = MKSFUFilterByRawDataCellModel(
        index: 0,
        msg: "主要数据过滤",
        dataType: "01",
        minIndex: "0",
        maxIndex: "5",
        rawData: "A1B2C3D4E5F6",
        dataTypePlaceHolder: "输入类型",
        minTextFieldPlaceHolder: "最小",
        maxTextFieldPlaceHolder: "最大",
        rawTextFieldPlaceHolder: "输入原始数据"
    )
    
    @StateObject private var rawDataModel2 = MKSFUFilterByRawDataCellModel(
        index: 1,
        msg: "次要数据过滤",
        dataType: "FF",
        minIndex: "10",
        maxIndex: "15",
        rawData: "123456789ABC",
        rawDataMaxBytes: 20
    )
    
    var body: some View {
        List {
            MKSFUFilterByRawDataCell(
                dataModel: rawDataModel1,
                onDataTypeChanged: { value, index in
                    print("数据类型变化: \(value) at index: \(index)")
                    validateModel(rawDataModel1)
                },
                onMinIndexChanged: { value, index in
                    print("最小索引变化: \(value) at index: \(index)")
                    validateModel(rawDataModel1)
                },
                onMaxIndexChanged: { value, index in
                    print("最大索引变化: \(value) at index: \(index)")
                    validateModel(rawDataModel1)
                },
                onRawDataChanged: { value, index in
                    print("原始数据变化: \(value) at index: \(index)")
                    validateModel(rawDataModel1)
                }
            )
            .listRowSeparator(.hidden) // 隐藏系统分隔线
            .listRowInsets(EdgeInsets()) // 移除列表默认的内边距
            
            MKSFUFilterByRawDataCell(
                dataModel: rawDataModel2,
                onDataTypeChanged: { value, index in
                    print("数据类型变化: \(value) at index: \(index)")
                    validateModel(rawDataModel2)
                },
                onMinIndexChanged: { value, index in
                    print("最小索引变化: \(value) at index: \(index)")
                    validateModel(rawDataModel2)
                },
                onMaxIndexChanged: { value, index in
                    print("最大索引变化: \(value) at index: \(index)")
                    validateModel(rawDataModel2)
                },
                onRawDataChanged: { value, index in
                    print("原始数据变化: \(value) at index: \(index)")
                    validateModel(rawDataModel2)
                }
            )
            .listRowSeparator(.hidden) // 隐藏系统分隔线
            .listRowInsets(EdgeInsets()) // 移除列表默认的内边距
        }
        .listStyle(PlainListStyle())
    }
    
    private func validateModel(_ model: MKSFUFilterByRawDataCellModel) {
        if model.validParamsSuccess() {
            print("✅ 参数验证通过")
        } else {
            print("❌ 参数验证失败")
        }
    }
}

// MARK: - 验证状态显示扩展
extension MKSFUFilterByRawDataCell {
    /// 带验证状态显示的单元格
    func withValidationStatus() -> some View {
        VStack(alignment: .leading, spacing: 2) {
            self
            
            // 验证状态显示
            HStack {
                Spacer()
                Text(dataModel.validParamsSuccess() ? "✅ 验证通过" : "❌ 验证失败")
                    .font(.system(size: 11))
                    .foregroundColor(dataModel.validParamsSuccess() ? .green : .red)
                    .padding(.horizontal, 15)
            }
        }
    }
}

// MARK: - Preview
struct MKSFUFilterByRawDataCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FilterByRawDataExampleView()
                .previewDisplayName("列表示例")
            
            VStack(spacing: 0) {
                MKSFUFilterByRawDataCell(
                    dataModel: MKSFUFilterByRawDataCellModel(
                        msg: "带固定底部线条的单元格",
                        dataType: "AB",
                        minIndex: "1",
                        maxIndex: "8",
                        rawData: "DEADBEEF12345678"
                    )
                ) { dataType, index in
                    print("DataType: \(dataType)")
                } onMinIndexChanged: { minIndex, index in
                    print("MinIndex: \(minIndex)")
                } onMaxIndexChanged: { maxIndex, index in
                    print("MaxIndex: \(maxIndex)")
                } onRawDataChanged: { rawData, index in
                    print("RawData: \(rawData)")
                }
                
                MKSFUFilterByRawDataCell(
                    dataModel: MKSFUFilterByRawDataCellModel(
                        msg: "另一个单元格",
                        dataType: "CD",
                        minIndex: "2",
                        maxIndex: "5",
                        rawData: "AABBCCDD"
                    )
                ) { dataType, index in
                    print("DataType: \(dataType)")
                } onMinIndexChanged: { minIndex, index in
                    print("MinIndex: \(minIndex)")
                } onMaxIndexChanged: { maxIndex, index in
                    print("MaxIndex: \(maxIndex)")
                } onRawDataChanged: { rawData, index in
                    print("RawData: \(rawData)")
                }
            }
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("底部线条展示")
        }
    }
}
