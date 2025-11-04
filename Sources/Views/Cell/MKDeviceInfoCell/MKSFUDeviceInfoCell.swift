//
//  MKSFUDeviceInfoCell.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI

// MARK: - SwiftUI Data Model
public class MKSFUDeviceInfoCellModel: ObservableObject {
    @Published public var leftMsg: String = ""
    @Published public var rightMsg: String = ""
    
    public init() {}
    
    /// 便捷初始化方法
    public convenience init(leftMsg: String, rightMsg: String) {
        self.init()
        self.leftMsg = leftMsg
        self.rightMsg = rightMsg
    }
    
    /// 计算单元格高度（兼容UIKit）
    public func cellHeightWithContentWidth(_ width: CGFloat) -> CGFloat {
        let leftSize = leftMsg.size(withFont: UIFont.systemFont(ofSize: 15),
                                  maxSize: CGSize(width: (width / 2 - 15 - 5), height: .greatestFiniteMagnitude))
        
        let rightSize = rightMsg.size(withFont: UIFont.systemFont(ofSize: 15),
                                     maxSize: CGSize(width: (width / 2 - 15 - 5), height: .greatestFiniteMagnitude))
        
        let height = max(leftSize.height, rightSize.height)
        return max(44, height + 20)
    }
}

// MARK: - SwiftUI Device Info Cell
public struct MKSFUDeviceInfoCell: View {
    @ObservedObject public var dataModel: MKSFUDeviceInfoCellModel
    
    public init(dataModel: MKSFUDeviceInfoCellModel) {
        self.dataModel = dataModel
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Left message
            Text(dataModel.leftMsg)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Right message
            Text(dataModel.rightMsg)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 44)
    }
}

// MARK: - 可点击的设备信息单元格
public struct ClickableDeviceInfoCell: View {
    @ObservedObject public var dataModel: MKSFUDeviceInfoCellModel
    public var onCellTapped: (() -> Void)?
    
    public init(dataModel: MKSFUDeviceInfoCellModel, onCellTapped: (() -> Void)? = nil) {
        self.dataModel = dataModel
        self.onCellTapped = onCellTapped
    }
    
    public var body: some View {
        Button(action: {
            onCellTapped?()
        }) {
            HStack(alignment: .top, spacing: 10) {
                Text(dataModel.leftMsg)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(dataModel.rightMsg)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                // 点击指示器
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 支持 ObservableObject 的 ViewModel
public class DeviceInfoViewModel: ObservableObject {
    @Published public var deviceModels: [MKSFUDeviceInfoCellModel]
    
    public init(deviceModels: [MKSFUDeviceInfoCellModel] = []) {
        self.deviceModels = deviceModels
    }
    
    public func handleCellTap(at index: Int) {
        switch index {
        case 0:
            print("修改设备名称")
        case 1:
            print("设置设备位置")
        case 2:
            print("配置报警设置")
        default:
            break
        }
    }
}

// MARK: - 使用示例

// Example 1: 设备信息列表
struct DeviceInfoExampleView: View {
    @State private var deviceModels = [
        MKSFUDeviceInfoCellModel(leftMsg: "设备名称", rightMsg: "Smart Sensor Pro"),
        MKSFUDeviceInfoCellModel(leftMsg: "设备型号", rightMsg: "MK-2024"),
        MKSFUDeviceInfoCellModel(leftMsg: "MAC地址", rightMsg: "A1:B2:C3:D4:E5:F6"),
        MKSFUDeviceInfoCellModel(leftMsg: "固件版本", rightMsg: "v2.1.5"),
        MKSFUDeviceInfoCellModel(leftMsg: "硬件版本", rightMsg: "v1.0"),
        MKSFUDeviceInfoCellModel(leftMsg: "电池电量", rightMsg: "85%"),
        MKSFUDeviceInfoCellModel(leftMsg: "信号强度", rightMsg: "-45 dBm"),
        MKSFUDeviceInfoCellModel(leftMsg: "连接状态", rightMsg: "已连接"),
        MKSFUDeviceInfoCellModel(leftMsg: "最后在线时间", rightMsg: "2024-01-15 14:30:25"),
        MKSFUDeviceInfoCellModel(
            leftMsg: "设备描述",
            rightMsg: "这是一个多行文本的示例，用于展示设备详细信息和支持多行显示的功能"
        )
    ]
    
    var body: some View {
        List {
            ForEach(deviceModels.indices, id: \.self) { index in
                MKSFUDeviceInfoCell(dataModel: deviceModels[index])
                    .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(PlainListStyle())
    }
}

// Example 2: 分组设备信息
struct GroupedDeviceInfoView: View {
    var body: some View {
        VStack(spacing: 0) {
            // 基本信息组
            VStack(alignment: .leading, spacing: 0) {
                Text("基本信息")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                
                ForEach(0..<4) { index in
                    MKSFUDeviceInfoCell(dataModel: createBasicInfoModel(for: index))
                    if index < 3 {
                        Divider()
                            .padding(.leading, 15)
                    }
                }
            }
            .background(Color(.systemBackground))
            
            Divider()
            
            // 状态信息组
            VStack(alignment: .leading, spacing: 0) {
                Text("状态信息")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                
                ForEach(0..<3) { index in
                    MKSFUDeviceInfoCell(dataModel: createStatusInfoModel(for: index))
                    if index < 2 {
                        Divider()
                            .padding(.leading, 15)
                    }
                }
            }
            .background(Color(.systemBackground))
        }
    }
    
    private func createBasicInfoModel(for index: Int) -> MKSFUDeviceInfoCellModel {
        switch index {
        case 0:
            return MKSFUDeviceInfoCellModel(leftMsg: "设备名称", rightMsg: "Smart Sensor")
        case 1:
            return MKSFUDeviceInfoCellModel(leftMsg: "设备型号", rightMsg: "MK-Sensor-Pro")
        case 2:
            return MKSFUDeviceInfoCellModel(leftMsg: "序列号", rightMsg: "SN20240115001")
        case 3:
            return MKSFUDeviceInfoCellModel(leftMsg: "生产日期", rightMsg: "2024-01-15")
        default:
            return MKSFUDeviceInfoCellModel()
        }
    }
    
    private func createStatusInfoModel(for index: Int) -> MKSFUDeviceInfoCellModel {
        switch index {
        case 0:
            return MKSFUDeviceInfoCellModel(leftMsg: "连接状态", rightMsg: "在线")
        case 1:
            return MKSFUDeviceInfoCellModel(leftMsg: "信号强度", rightMsg: "优秀")
        case 2:
            return MKSFUDeviceInfoCellModel(leftMsg: "电池状态", rightMsg: "正常")
        default:
            return MKSFUDeviceInfoCellModel()
        }
    }
}

// Example 3: 可点击的设备信息单元格（使用 State）
struct ClickableDeviceInfoExample: View {
    @State private var deviceModels = [
        MKSFUDeviceInfoCellModel(leftMsg: "设备名称", rightMsg: "点击修改"),
        MKSFUDeviceInfoCellModel(leftMsg: "设备位置", rightMsg: "点击设置"),
        MKSFUDeviceInfoCellModel(leftMsg: "报警设置", rightMsg: "点击配置")
    ]
    
    var body: some View {
        List {
            ForEach(deviceModels.indices, id: \.self) { index in
                ClickableDeviceInfoCell(dataModel: deviceModels[index]) {
                    print("点击了第 \(index) 个单元格")
                    handleCellTap(at: index)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func handleCellTap(at index: Int) {
        switch index {
        case 0:
            print("修改设备名称")
        case 1:
            print("设置设备位置")
        case 2:
            print("配置报警设置")
        default:
            break
        }
    }
}

// Example 4: 可点击的设备信息单元格（使用 ViewModel）
struct ClickableDeviceInfoExampleWithViewModel: View {
    @StateObject private var viewModel = DeviceInfoViewModel(deviceModels: [
        MKSFUDeviceInfoCellModel(leftMsg: "设备名称", rightMsg: "点击修改"),
        MKSFUDeviceInfoCellModel(leftMsg: "设备位置", rightMsg: "点击设置"),
        MKSFUDeviceInfoCellModel(leftMsg: "报警设置", rightMsg: "点击配置")
    ])
    
    var body: some View {
        List {
            ForEach(viewModel.deviceModels.indices, id: \.self) { index in
                ClickableDeviceInfoCell(dataModel: viewModel.deviceModels[index]) {
                    print("点击了第 \(index) 个单元格")
                    viewModel.handleCellTap(at: index)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

// Example 5: 简单的可点击单元格（不使用数据模型）
struct SimpleClickableDeviceInfoExample: View {
    let deviceInfos = [
        ("设备名称", "点击修改"),
        ("设备位置", "点击设置"),
        ("报警设置", "点击配置")
    ]
    
    var body: some View {
        List {
            ForEach(deviceInfos.indices, id: \.self) { index in
                SimpleClickableCell(
                    leftMsg: deviceInfos[index].0,
                    rightMsg: deviceInfos[index].1
                ) {
                    handleCellTap(at: index)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func handleCellTap(at index: Int) {
        switch index {
        case 0:
            print("修改设备名称")
        case 1:
            print("设置设备位置")
        case 2:
            print("配置报警设置")
        default:
            break
        }
    }
}

struct SimpleClickableCell: View {
    let leftMsg: String
    let rightMsg: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(leftMsg)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(rightMsg)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 样式扩展
extension MKSFUDeviceInfoCell {
    /// 带背景色的单元格
    public func withBackground(_ color: Color) -> some View {
        self.background(color)
    }
    
    /// 带边框的单元格
    public func withBorder(_ color: Color = .gray, width: CGFloat = 0.5) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color, lineWidth: width)
        )
    }
}

extension ClickableDeviceInfoCell {
    /// 带背景色的可点击单元格
    public func withBackground(_ color: Color) -> some View {
        self.background(color)
    }
    
    /// 带边框的可点击单元格
    public func withBorder(_ color: Color = .gray, width: CGFloat = 0.5) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color, lineWidth: width)
        )
    }
}

// MARK: - Preview
struct MKSFUDeviceInfoCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DeviceInfoExampleView()
                .previewDisplayName("设备信息列表")
            
            GroupedDeviceInfoView()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("分组设备信息")
            
            ClickableDeviceInfoExample()
                .previewDisplayName("可点击设备信息（State）")
            
            ClickableDeviceInfoExampleWithViewModel()
                .previewDisplayName("可点击设备信息（ViewModel）")
            
            SimpleClickableDeviceInfoExample()
                .previewDisplayName("简单可点击设备信息")
            
            // 单个单元格预览
            VStack(spacing: 0) {
                MKSFUDeviceInfoCell(
                    dataModel: MKSFUDeviceInfoCellModel(
                        leftMsg: "设备名称",
                        rightMsg: "Smart Sensor Pro"
                    )
                )
                
                Divider()
                
                MKSFUDeviceInfoCell(
                    dataModel: MKSFUDeviceInfoCellModel(
                        leftMsg: "设备描述",
                        rightMsg: "这是一个多行文本的示例，用于展示设备详细信息和支持多行显示的功能"
                    )
                )
                .withBackground(Color.blue.opacity(0.1))
                
                Divider()
                
                ClickableDeviceInfoCell(
                    dataModel: MKSFUDeviceInfoCellModel(
                        leftMsg: "可点击项",
                        rightMsg: "点击我"
                    )
                ) {
                    print("单元格被点击")
                }
                .withBorder(Color.blue)
            }
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("单个单元格样式")
        }
    }
}
