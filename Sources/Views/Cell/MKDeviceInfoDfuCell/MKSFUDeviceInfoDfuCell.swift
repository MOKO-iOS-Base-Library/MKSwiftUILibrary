//
//  MKSFUDeviceInfoDfuCell.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI

// MARK: - SwiftUI Data Model
public class MKSFUDeviceInfoDfuCellModel: ObservableObject {
    @Published public var index: Int = 0
    @Published public var leftMsg: String = ""
    @Published public var rightMsg: String = ""
    @Published public var rightButtonTitle: String = ""
    
    public init() {}
    
    /// 便捷初始化方法
    public convenience init(index: Int = 0, leftMsg: String = "", rightMsg: String = "", rightButtonTitle: String = "") {
        self.init()
        self.index = index
        self.leftMsg = leftMsg
        self.rightMsg = rightMsg
        self.rightButtonTitle = rightButtonTitle
    }
}

// MARK: - SwiftUI Device Info DFU Cell
public struct MKSFUDeviceInfoDfuCell: View {
    @ObservedObject public var dataModel: MKSFUDeviceInfoDfuCellModel
    public var onButtonAction: (Int) -> Void
    
    // 固定的底部线条样式
    private let bottomLineColor: Color = Color(red: 238/255, green: 238/255, blue: 238/255)
    private let bottomLineHeight: CGFloat = 0.5
    
    public init(
        dataModel: MKSFUDeviceInfoDfuCellModel,
        onButtonAction: @escaping (Int) -> Void = { _ in }
    ) {
        self.dataModel = dataModel
        self.onButtonAction = onButtonAction
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main content
            HStack(spacing: 10) {
                // Left message
                Text(dataModel.leftMsg)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Right message
                Text(dataModel.rightMsg)
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5)) // #808080
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                // Right button - 只有这个按钮会触发点击回调
                Button(action: {
                    onButtonAction(dataModel.index)
                }) {
                    Text(dataModel.rightButtonTitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 35)
                }
                .background(Color.blue)
                .cornerRadius(8)
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 44)
            
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
        // 关键：添加空的 onTapGesture 来阻止 List 的点击事件
        .onTapGesture {}
    }
}

// MARK: - 支持 ObservableObject 的 ViewModel
public class DeviceInfoDfuViewModel: ObservableObject {
    @Published public var deviceModels: [MKSFUDeviceInfoDfuCellModel]
    
    public init(deviceModels: [MKSFUDeviceInfoDfuCellModel] = []) {
        self.deviceModels = deviceModels
    }
    
    public func handleButtonAction(at index: Int) {
        print("DFU按钮点击，索引: \(index)")
        // 这里可以添加具体的DFU逻辑
        switch index {
        case 0:
            print("开始DFU升级")
        case 1:
            print("检查固件更新")
        case 2:
            print("恢复出厂设置")
        default:
            print("未知操作")
        }
    }
}

// MARK: - 使用示例

// Example 1: DFU设备信息列表
struct DeviceInfoDfuExampleView: View {
    @State private var deviceModels: [MKSFUDeviceInfoDfuCellModel] = [
        MKSFUDeviceInfoDfuCellModel(
            index: 0,
            leftMsg: "固件版本",
            rightMsg: "v2.1.5",
            rightButtonTitle: "升级"
        ),
        MKSFUDeviceInfoDfuCellModel(
            index: 1,
            leftMsg: "硬件版本",
            rightMsg: "v1.0",
            rightButtonTitle: "检查"
        ),
        MKSFUDeviceInfoDfuCellModel(
            index: 2,
            leftMsg: "设备状态",
            rightMsg: "正常运行",
            rightButtonTitle: "重置"
        ),
        MKSFUDeviceInfoDfuCellModel(
            index: 3,
            leftMsg: "Bootloader版本",
            rightMsg: "v1.2.0",
            rightButtonTitle: "更新"
        )
    ]
    
    var body: some View {
        List {
            ForEach(deviceModels.indices, id: \.self) { index in
                MKSFUDeviceInfoDfuCell(dataModel: deviceModels[index]) { cellIndex in
                    print("DFU按钮点击，单元格索引: \(cellIndex)")
                    handleDfuAction(at: cellIndex)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func handleDfuAction(at index: Int) {
        switch index {
        case 0:
            print("开始固件升级流程")
        case 1:
            print("检查固件更新")
        case 2:
            print("设备重置")
        case 3:
            print("Bootloader更新")
        default:
            break
        }
    }
}

// MARK: - 带状态的DFU单元格
public struct MKSFUDeviceInfoDfuCellWithState: View {
    @ObservedObject public var dataModel: MKSFUDeviceInfoDfuCellModel
    public var onButtonAction: (Int) -> Void
    
    @State private var isUpdating: Bool = false
    
    // 固定的底部线条样式
    private let bottomLineColor: Color = Color(red: 238/255, green: 238/255, blue: 238/255)
    private let bottomLineHeight: CGFloat = 0.5
    
    public init(
        dataModel: MKSFUDeviceInfoDfuCellModel,
        onButtonAction: @escaping (Int) -> Void = { _ in }
    ) {
        self.dataModel = dataModel
        self.onButtonAction = onButtonAction
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main content
            HStack(spacing: 10) {
                // Left message
                Text(dataModel.leftMsg)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Right message
                Text(dataModel.rightMsg)
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                // Right button with state - 只有这个按钮会触发点击回调
                Button(action: {
                    isUpdating = true
                    onButtonAction(dataModel.index)
                    // 模拟更新完成
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isUpdating = false
                    }
                }) {
                    Group {
                        if isUpdating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text(dataModel.rightButtonTitle)
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 50, height: 35)
                }
                .background(isUpdating ? Color.gray : Color.blue)
                .cornerRadius(8)
                .disabled(isUpdating)
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 44)
            
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
        // 关键：添加空的 onTapGesture 来阻止 List 的点击事件
        .onTapGesture {}
    }
}

// MARK: - 样式扩展
public extension MKSFUDeviceInfoDfuCell {
    /// 自定义按钮颜色
    func withButtonColor(_ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Text(dataModel.leftMsg)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(dataModel.rightMsg)
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                Button(action: {
                    onButtonAction(dataModel.index)
                }) {
                    Text(dataModel.rightButtonTitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 35)
                }
                .background(color)
                .cornerRadius(8)
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 44)
            
            // 固定的底部线条
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
        // 关键：添加空的 onTapGesture 来阻止 List 的点击事件
        .onTapGesture {}
    }
}

// MARK: - 预览
struct MKSFUDeviceInfoDfuCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 示例1: DFU设备信息列表
            DeviceInfoDfuExampleView()
                .previewDisplayName("DFU设备信息列表")
            
            // 单个单元格预览
            VStack(spacing: 0) {
                MKSFUDeviceInfoDfuCell(
                    dataModel: MKSFUDeviceInfoDfuCellModel(
                        leftMsg: "固件版本",
                        rightMsg: "v2.1.5",
                        rightButtonTitle: "升级"
                    )
                ) { index in
                    print("按钮点击: \(index)")
                }
                
                MKSFUDeviceInfoDfuCell(
                    dataModel: MKSFUDeviceInfoDfuCellModel(
                        leftMsg: "设备信息",
                        rightMsg: "需要更新",
                        rightButtonTitle: "更新"
                    )
                ) { index in
                    print("按钮点击: \(index)")
                }
            }
            .previewLayout(.fixed(width: 375, height: 130))
            .previewDisplayName("单个DFU单元格样式")
        }
    }
}
