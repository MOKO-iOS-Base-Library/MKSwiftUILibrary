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
    
    public init(
        dataModel: MKSFUDeviceInfoDfuCellModel,
        onButtonAction: @escaping (Int) -> Void = { _ in }
    ) {
        self.dataModel = dataModel
        self.onButtonAction = onButtonAction
    }
    
    public var body: some View {
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
            
            // Right button
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
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 44)
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
            ForEach(0..<deviceModels.count, id: \.self) { index in
                MKSFUDeviceInfoDfuCell(dataModel: deviceModels[index]) { cellIndex in
                    print("DFU按钮点击，单元格索引: \(cellIndex)")
                    handleDfuAction(at: cellIndex)
                }
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

// Example 2: 使用ViewModel管理的DFU列表
struct DeviceInfoDfuWithViewModelView: View {
    @StateObject private var viewModel: DeviceInfoDfuViewModel = DeviceInfoDfuViewModel(deviceModels: [
        MKSFUDeviceInfoDfuCellModel(
            index: 0,
            leftMsg: "主控制器固件",
            rightMsg: "v3.0.1",
            rightButtonTitle: "DFU"
        ),
        MKSFUDeviceInfoDfuCellModel(
            index: 1,
            leftMsg: "蓝牙模块固件",
            rightMsg: "v2.5.0",
            rightButtonTitle: "更新"
        ),
        MKSFUDeviceInfoDfuCellModel(
            index: 2,
            leftMsg: "传感器固件",
            rightMsg: "v1.8.2",
            rightButtonTitle: "升级"
        )
    ])
    
    var body: some View {
        List {
            ForEach(0..<viewModel.deviceModels.count, id: \.self) { index in
                MKSFUDeviceInfoDfuCell(dataModel: viewModel.deviceModels[index]) { cellIndex in
                    viewModel.handleButtonAction(at: cellIndex)
                }
                .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(PlainListStyle())
    }
}

// Example 3: 分组DFU设备信息
struct GroupedDeviceInfoDfuView: View {
    @State private var mainDeviceModels: [MKSFUDeviceInfoDfuCellModel] = [
        MKSFUDeviceInfoDfuCellModel(
            index: 0,
            leftMsg: "主设备固件",
            rightMsg: "v3.2.1 (最新)",
            rightButtonTitle: "升级"
        ),
        MKSFUDeviceInfoDfuCellModel(
            index: 1,
            leftMsg: "安全补丁",
            rightMsg: "2024-01",
            rightButtonTitle: "安装"
        )
    ]
    
    @State private var moduleModels: [MKSFUDeviceInfoDfuCellModel] = [
        MKSFUDeviceInfoDfuCellModel(
            index: 2,
            leftMsg: "通信模块",
            rightMsg: "v2.1.0 (需更新)",
            rightButtonTitle: "更新"
        ),
        MKSFUDeviceInfoDfuCellModel(
            index: 3,
            leftMsg: "传感器模块",
            rightMsg: "v1.5.3",
            rightButtonTitle: "检查"
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 主设备固件组
            VStack(alignment: .leading, spacing: 0) {
                Text("主设备固件")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                
                ForEach(0..<mainDeviceModels.count, id: \.self) { index in
                    MKSFUDeviceInfoDfuCell(dataModel: mainDeviceModels[index]) { cellIndex in
                        handleMainDeviceAction(at: cellIndex)
                    }
                    if index < mainDeviceModels.count - 1 {
                        Divider()
                            .padding(.leading, 15)
                    }
                }
            }
            .background(Color(.systemBackground))
            
            Divider()
            
            // 模块固件组
            VStack(alignment: .leading, spacing: 0) {
                Text("模块固件")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                
                ForEach(0..<moduleModels.count, id: \.self) { index in
                    MKSFUDeviceInfoDfuCell(dataModel: moduleModels[index]) { cellIndex in
                        handleModuleAction(at: cellIndex)
                    }
                    if index < moduleModels.count - 1 {
                        Divider()
                            .padding(.leading, 15)
                    }
                }
            }
            .background(Color(.systemBackground))
        }
    }
    
    private func handleMainDeviceAction(at index: Int) {
        switch index {
        case 0:
            print("开始主设备固件升级")
        case 1:
            print("安装安全补丁")
        default:
            break
        }
    }
    
    private func handleModuleAction(at index: Int) {
        switch index {
        case 2:
            print("更新通信模块固件")
        case 3:
            print("检查传感器模块更新")
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
    
    public init(
        dataModel: MKSFUDeviceInfoDfuCellModel,
        onButtonAction: @escaping (Int) -> Void = { _ in }
    ) {
        self.dataModel = dataModel
        self.onButtonAction = onButtonAction
    }
    
    public var body: some View {
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
            
            // Right button with state
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
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 44)
    }
}

// Example 4: 带状态的DFU示例
struct DeviceInfoDfuWithStateExample: View {
    @State private var deviceModels: [MKSFUDeviceInfoDfuCellModel] = [
        MKSFUDeviceInfoDfuCellModel(
            index: 0,
            leftMsg: "系统固件",
            rightMsg: "v4.0.0",
            rightButtonTitle: "升级"
        )
    ]
    
    var body: some View {
        List {
            ForEach(0..<deviceModels.count, id: \.self) { index in
                MKSFUDeviceInfoDfuCellWithState(dataModel: deviceModels[index]) { cellIndex in
                    print("开始升级固件，索引: \(cellIndex)")
                }
                .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - 样式扩展
public extension MKSFUDeviceInfoDfuCell {
    /// 自定义按钮颜色
    func withButtonColor(_ color: Color) -> some View {
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
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 44)
    }
    
    /// 带边框的单元格
    func withBorder(_ color: Color = .gray, width: CGFloat = 0.5) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color, lineWidth: width)
        )
    }
}

// MARK: - 预览
struct MKSFUDeviceInfoDfuCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 示例1: DFU设备信息列表
            DeviceInfoDfuExampleView()
                .previewDisplayName("DFU设备信息列表")
        }
        
        Group {
            // 示例2: 使用ViewModel的DFU列表
            DeviceInfoDfuWithViewModelView()
                .previewDisplayName("使用ViewModel的DFU列表")
        }
        
        Group {
            // 示例3: 分组DFU设备信息
            GroupedDeviceInfoDfuView()
                .previewLayout(.fixed(width: 375, height: 300))
                .previewDisplayName("分组DFU设备信息")
        }
        
        Group {
            // 示例4: 带状态的DFU单元格
            DeviceInfoDfuWithStateExample()
                .previewDisplayName("带状态的DFU单元格")
        }
        
        Group {
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
                .frame(height: 60)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                
                MKSFUDeviceInfoDfuCell(
                    dataModel: MKSFUDeviceInfoDfuCellModel(
                        leftMsg: "设备信息",
                        rightMsg: "需要更新",
                        rightButtonTitle: "更新"
                    )
                ) { index in
                    print("按钮点击: \(index)")
                }
                .frame(height: 60)
            }
            .previewLayout(.fixed(width: 375, height: 130))
            .previewDisplayName("单个DFU单元格样式")
        }
    }
}

// MARK: - 简化预览版本（如果上面的还有问题，使用这个）
struct MKSFUDeviceInfoDfuCell_SimplePreview: PreviewProvider {
    static var previews: some View {
        // 只预览单个单元格
        VStack {
            MKSFUDeviceInfoDfuCell(
                dataModel: MKSFUDeviceInfoDfuCellModel(
                    leftMsg: "固件版本",
                    rightMsg: "v2.1.5",
                    rightButtonTitle: "升级"
                )
            ) { _ in }
            
            MKSFUDeviceInfoDfuCell(
                dataModel: MKSFUDeviceInfoDfuCellModel(
                    leftMsg: "设备信息",
                    rightMsg: "需要更新",
                    rightButtonTitle: "更新"
                )
            ) { _ in }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

// MARK: - 分离的预览组
struct DeviceInfoDfuExampleView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceInfoDfuExampleView()
    }
}

struct DeviceInfoDfuWithViewModelView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceInfoDfuWithViewModelView()
    }
}

struct GroupedDeviceInfoDfuView_Previews: PreviewProvider {
    static var previews: some View {
        GroupedDeviceInfoDfuView()
    }
}

struct DeviceInfoDfuWithStateExample_Previews: PreviewProvider {
    static var previews: some View {
        DeviceInfoDfuWithStateExample()
    }
}
