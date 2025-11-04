//
//  MKSFUTextSwitchCell.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI

// MARK: - Model
public class MKSFUTextSwitchCellModel: ObservableObject, Identifiable {
    public let id = UUID()
    
    // MARK: Cell Top Configuration
    @Published public var index: Int = 0
    @Published public var contentColor: Color = .white
    
    // MARK: Left Label and Icon Configuration
    @Published public var leftIcon: String?
    @Published public var msg: String = ""
    @Published public var msgColor: Color = .primary
    @Published public var msgFont: Font = .system(size: 15)
    
    // MARK: Switch Configuration
    @Published public var isOn: Bool = false
    @Published public var switchEnable: Bool = true
    
    // MARK: Bottom Label Configuration
    @Published public var noteMsg: String = ""
    @Published public var noteMsgColor: Color = .primary
    @Published public var noteMsgFont: Font = .system(size: 12)
    
    public init() {}
}

// MARK: - Settings Manager (修复数组问题)
class SettingsManager: ObservableObject {
    @Published var settings: [MKSFUTextSwitchCellModel] = []
}

// MARK: - Cell
public struct MKSFUTextSwitchCell: View {
    
    // MARK: - Properties
    @ObservedObject public var dataModel: MKSFUTextSwitchCellModel
    
    // SwiftUI 回调方式
    public var onSwitchValueChanged: ((Int, Bool) -> Void)?
    
    // MARK: - Constants
    private let offsetX: CGFloat = 15
    
    // MARK: - Initialization
    public init(
        dataModel: MKSFUTextSwitchCellModel,
        onSwitchValueChanged: ((Int, Bool) -> Void)? = nil
    ) {
        self.dataModel = dataModel
        self.onSwitchValueChanged = onSwitchValueChanged
    }
    
    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 主内容行 - 图标、消息、开关水平对齐
            HStack(alignment: .center, spacing: 10) {
                // 左侧图标
                if let leftIcon = dataModel.leftIcon {
                    Image(leftIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                
                // 消息标签
                Text(dataModel.msg)
                    .font(dataModel.msgFont)
                    .foregroundColor(dataModel.msgColor)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // 原生 Toggle 开关
                Toggle("", isOn: Binding(
                    get: { dataModel.isOn },
                    set: { newValue in
                        guard dataModel.switchEnable else { return }
                        dataModel.isOn = newValue
                        onSwitchValueChanged?(dataModel.index, newValue)
                    }
                ))
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .labelsHidden()
                .disabled(!dataModel.switchEnable)
                .opacity(dataModel.switchEnable ? 1.0 : 0.6)
            }
            .padding(.horizontal, offsetX)
            .padding(.vertical, 12)
            
            // 底部说明标签 - 单独一行
            if !dataModel.noteMsg.isEmpty {
                Text(dataModel.noteMsg)
                    .font(dataModel.noteMsgFont)
                    .foregroundColor(dataModel.noteMsgColor)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, offsetX)
                    .padding(.bottom, 12)
            }
        }
        .background(dataModel.contentColor)
        .contentShape(Rectangle())
        .onTapGesture {
            // 支持点击整行切换开关
            guard dataModel.switchEnable else { return }
            dataModel.isOn.toggle()
            onSwitchValueChanged?(dataModel.index, dataModel.isOn)
        }
    }
}

// MARK: - 简单预览版本
struct MKSFUTextSwitchCellSimplePreview: View {
    var body: some View {
        VStack(spacing: 1) {
            MKSFUTextSwitchCell(
                dataModel: {
                    let model = MKSFUTextSwitchCellModel()
                    model.msg = "Wi-Fi 设置"
                    model.isOn = true
                    model.switchEnable = true
                    return model
                }()
            ) { index, isOn in
                print("Wi-Fi 开关状态: \(isOn)")
            }
            .background(Color.white)
            
            MKSFUTextSwitchCell(
                dataModel: {
                    let model = MKSFUTextSwitchCellModel()
                    model.msg = "蓝牙功能"
                    model.leftIcon = "bluetooth"
                    model.isOn = false
                    model.switchEnable = true
                    model.noteMsg = "启用蓝牙功能以连接外部设备"
                    return model
                }()
            ) { index, isOn in
                print("蓝牙开关状态: \(isOn)")
            }
            .background(Color.white)
            
            MKSFUTextSwitchCell(
                dataModel: {
                    let model = MKSFUTextSwitchCellModel()
                    model.msg = "禁用功能"
                    model.isOn = true
                    model.switchEnable = false
                    model.noteMsg = "此功能当前不可用，请联系管理员"
                    return model
                }()
            ) { index, isOn in
                print("禁用功能开关状态: \(isOn)")
            }
            .background(Color.white)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

// MARK: - 基础使用示例
struct MKSFUTextSwitchCellBasicUsage: View {
    @StateObject private var cellModel1 = MKSFUTextSwitchCellModel()
    @StateObject private var cellModel2 = MKSFUTextSwitchCellModel()
    
    var body: some View {
        VStack {
            Text("开关单元格示例")
                .font(.title2)
                .padding()
            
            VStack(spacing: 1) {
                MKSFUTextSwitchCell(dataModel: cellModel1) { index, isOn in
                    print("通知设置: \(isOn)")
                    // 可以根据开关状态更新其他UI
                    if isOn {
                        cellModel2.switchEnable = true
                    }
                }
                .background(Color.white)
                
                MKSFUTextSwitchCell(dataModel: cellModel2) { index, isOn in
                    print("高级功能: \(isOn)")
                }
                .background(Color.white)
            }
            .cornerRadius(8)
            .shadow(radius: 2)
            .padding()
            
            // 控制按钮
            HStack {
                Button("开启所有") {
                    cellModel1.isOn = true
                    cellModel2.isOn = true
                }
                .buttonStyle(.borderedProminent)
                
                Button("关闭所有") {
                    cellModel1.isOn = false
                    cellModel2.isOn = false
                }
                .buttonStyle(.bordered)
                
                Button("切换使能") {
                    cellModel2.switchEnable.toggle()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            
            Spacer()
        }
        .onAppear {
            setupData()
        }
    }
    
    private func setupData() {
        cellModel1.msg = "通知设置"
        cellModel1.leftIcon = "bell"
        cellModel1.isOn = true
        cellModel1.switchEnable = true
        cellModel1.noteMsg = "开启后接收系统通知消息"
        
        cellModel2.msg = "高级功能"
        cellModel2.isOn = false
        cellModel2.switchEnable = true
        cellModel2.noteMsg = "需要先开启通知设置才能使用此功能"
    }
}

// MARK: - 列表使用示例 (修复版本)
struct MKSFUTextSwitchCellListUsage: View {
    // 方案1: 使用 StateObject 管理单个管理器
    @StateObject private var settingsManager = SettingsManager()
    
    // 或者方案2: 直接使用 State (推荐)
    @State private var settings: [MKSFUTextSwitchCellModel] = createDefaultSettings()
    
    private static func createDefaultSettings() -> [MKSFUTextSwitchCellModel] {
        return [
            {
                let model = MKSFUTextSwitchCellModel()
                model.msg = "夜间模式"
                model.isOn = false
                model.index = 0
                return model
            }(),
            {
                let model = MKSFUTextSwitchCellModel()
                model.msg = "自动同步"
                model.isOn = true
                model.index = 1
                model.noteMsg = "在Wi-Fi环境下自动同步数据"
                return model
            }(),
            {
                let model = MKSFUTextSwitchCellModel()
                model.msg = "位置服务"
                model.isOn = true
                model.index = 2
                model.switchEnable = false
                model.noteMsg = "需要在系统设置中启用位置权限"
                return model
            }()
        ]
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(settings) { setting in
                    MKSFUTextSwitchCell(dataModel: setting) { index, isOn in
                        print("设置 \(index) 状态: \(isOn)")
                        // 处理设置变更
                        handleSettingChange(index: index, isOn: isOn)
                    }
                    .listRowInsets(EdgeInsets())
                    .background(Color.white)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("设置")
        }
    }
    
    private func handleSettingChange(index: Int, isOn: Bool) {
        // 根据业务逻辑处理设置变更
        switch index {
        case 0:
            print("夜间模式: \(isOn ? "开启" : "关闭")")
        case 1:
            print("自动同步: \(isOn ? "开启" : "关闭")")
        case 2:
            print("位置服务: \(isOn ? "开启" : "关闭")")
        default:
            break
        }
    }
}

// MARK: - 更简洁的列表使用示例
struct MKSFUTextSwitchCellSimpleListUsage: View {
    @State private var settings: [MKSFUTextSwitchCellModel] = [
        createSetting(msg: "Wi-Fi", isOn: true, index: 0),
        createSetting(msg: "蓝牙", isOn: false, index: 1, noteMsg: "蓝牙设置说明"),
        createSetting(msg: "定位", isOn: true, index: 2, switchEnable: false)
    ]
    
    private static func createSetting(
        msg: String,
        isOn: Bool,
        index: Int,
        noteMsg: String = "",
        switchEnable: Bool = true
    ) -> MKSFUTextSwitchCellModel {
        let model = MKSFUTextSwitchCellModel()
        model.msg = msg
        model.isOn = isOn
        model.index = index
        model.noteMsg = noteMsg
        model.switchEnable = switchEnable
        return model
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(settings) { setting in
                    MKSFUTextSwitchCell(dataModel: setting) { index, isOn in
                        print("索引 \(index): \(isOn)")
                    }
                    .listRowInsets(EdgeInsets())
                    .background(Color.white)
                }
            }
            .navigationTitle("系统设置")
        }
    }
}

// MARK: - 预览提供器
struct MKSFUTextSwitchCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MKSFUTextSwitchCellSimplePreview()
                .previewDisplayName("简单预览")
            
            MKSFUTextSwitchCellBasicUsage()
                .previewDisplayName("基础使用")
            
            MKSFUTextSwitchCellListUsage()
                .previewDisplayName("列表使用")
            
            MKSFUTextSwitchCellSimpleListUsage()
                .previewDisplayName("简洁列表")
        }
    }
}
