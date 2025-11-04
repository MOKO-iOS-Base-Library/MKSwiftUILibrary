//
//  MKSFUNormalTextCell.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI

// MARK: - Cell Model
public class MKSFUNormalTextCellModel: ObservableObject, Identifiable {
    public let id = UUID()
    public var methodName: String = ""
    @Published public var contentColor: Color = .white
    
    // Left label and icon
    @Published public var leftIcon: String?
    @Published public var leftMsgTextFont: Font = .system(size: 15)
    @Published public var leftMsgTextColor: Color = .primary
    @Published public var leftMsg: String = ""
    
    // Right label
    @Published public var rightMsgTextFont: Font = .system(size: 13)
    @Published public var rightMsgTextColor: Color = .gray
    @Published public var rightMsg: String = ""
    @Published public var showRightIcon: Bool = false
    
    // Bottom label
    @Published public var noteMsg: String = ""
    @Published public var noteMsgColor: Color = .primary
    @Published public var noteMsgFont: Font = .system(size: 12)
    
    public init() {}
}

// MARK: - Cell Implementation
public struct MKSFUNormalTextCell: View {
    
    // MARK: - Properties
    @ObservedObject public var dataModel: MKSFUNormalTextCellModel
    
    // MARK: - Constants
    private let offset_X: CGFloat = 15
    
    // MARK: - Initialization
    public init(dataModel: MKSFUNormalTextCellModel) {
        self.dataModel = dataModel
    }
    
    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main content row
            HStack(alignment: .top, spacing: 3) {
                // Left icon
                if let leftIconName = dataModel.leftIcon {
                    Image(leftIconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: 20,
                            height: 20
                        )
                }
                
                // Left message label
                Text(dataModel.leftMsg)
                    .font(dataModel.leftMsgTextFont)
                    .foregroundColor(dataModel.leftMsgTextColor)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Right content
                HStack(spacing: 2) {
                    // Right message label
                    if !dataModel.rightMsg.isEmpty {
                        Text(dataModel.rightMsg)
                            .font(dataModel.rightMsgTextFont)
                            .foregroundColor(dataModel.rightMsgTextColor)
                            .multilineTextAlignment(.trailing)
                            .lineLimit(1)
                    }
                    
                    // Right icon
                    if dataModel.showRightIcon {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(width: 8, height: 14)
                    }
                }
            }
            .padding(.horizontal, offset_X)
            .padding(.vertical, hasNote ? offset_X : 0)
            .frame(minHeight: 50)
            
            // Note label
            if !dataModel.noteMsg.isEmpty {
                Text(dataModel.noteMsg)
                    .font(dataModel.noteMsgFont)
                    .foregroundColor(dataModel.noteMsgColor)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, offset_X)
                    .padding(.bottom, offset_X)
            }
        }
        .background(dataModel.contentColor)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Computed Properties
    private var hasNote: Bool {
        !dataModel.noteMsg.isEmpty
    }
}

// MARK: - 使用示例
struct MKSFUNormalTextCellExample: View {
    @StateObject private var cellModel1 = MKSFUNormalTextCellModel()
    @StateObject private var cellModel2 = MKSFUNormalTextCellModel()
    @StateObject private var cellModel3 = MKSFUNormalTextCellModel()
    @StateObject private var cellModel4 = MKSFUNormalTextCellModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 1) {
                MKSFUNormalTextCell(dataModel: cellModel1)
                    .background(Color.white)
                
                MKSFUNormalTextCell(dataModel: cellModel2)
                    .background(Color.white)
                
                MKSFUNormalTextCell(dataModel: cellModel3)
                    .background(Color.white)
                
                MKSFUNormalTextCell(dataModel: cellModel4)
                    .background(Color.white)
            }
            .cornerRadius(8)
            .shadow(radius: 2)
            .padding()
        }
        .onAppear {
            setupExampleData()
        }
    }
    
    private func setupExampleData() {
        // Cell 1: 基本样式
        cellModel1.leftMsg = "设备名称"
        cellModel1.rightMsg = "智能家居中心"
        cellModel1.showRightIcon = true
        
        // Cell 2: 带图标
        cellModel2.leftMsg = "Wi-Fi 设置"
        cellModel2.rightMsg = "已连接"
        cellModel2.leftIcon = "wifi"
        cellModel2.showRightIcon = true
        
        // Cell 3: 多行文本
        cellModel3.leftMsg = "这是一个比较长的标题文本，可能会显示多行内容"
        cellModel3.rightMsg = "状态"
        cellModel3.noteMsg = "这是底部说明文本，用于提供额外的信息或说明"
        
        // Cell 4: 带颜色样式
        cellModel4.leftMsg = "高级设置"
        cellModel4.rightMsg = "未配置"
        cellModel4.rightMsgTextColor = .orange
        cellModel4.showRightIcon = true
        cellModel4.noteMsg = "请点击进行配置"
        cellModel4.noteMsgColor = .orange
    }
}

// MARK: - 列表样式示例
struct MKSFUNormalTextCellListExample: View {
    // 修复：使用 @State 来存储对象数组
    @State private var cellModels: [MKSFUNormalTextCellModel] = []
    
    var body: some View {
        List {
            ForEach(cellModels) { model in
                MKSFUNormalTextCell(dataModel: model)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .background(Color.white)
            }
        }
        .listStyle(PlainListStyle())
        .onAppear {
            setupListData()
        }
    }
    
    private func setupListData() {
        let titles = [
            "通用设置",
            "网络配置",
            "安全选项",
            "关于设备"
        ]
        
        let subtitles = [
            "基本参数调整",
            "Wi-Fi 和网络",
            "密码和权限",
            "版本信息"
        ]
        
        // 创建模型数组
        cellModels = titles.enumerated().map { index, title in
            let model = MKSFUNormalTextCellModel()
            model.leftMsg = title
            model.rightMsg = subtitles[index]
            model.showRightIcon = true
            
            if index == 2 {
                model.noteMsg = "需要管理员权限"
                model.noteMsgColor = .red
            }
            
            return model
        }
    }
}

// MARK: - 使用 ObservableObject 容器管理数组
class MKSFUNormalTextCellListModel: ObservableObject {
    @Published var cellModels: [MKSFUNormalTextCellModel] = []
}

struct MKSFUNormalTextCellObservableExample: View {
    @StateObject private var listModel = MKSFUNormalTextCellListModel()
    
    var body: some View {
        List {
            ForEach(listModel.cellModels) { model in
                MKSFUNormalTextCell(dataModel: model)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .background(Color.white)
            }
        }
        .listStyle(PlainListStyle())
        .onAppear {
            setupObservableData()
        }
    }
    
    private func setupObservableData() {
        let titles = ["选项一", "选项二", "选项三"]
        let subtitles = ["值1", "值2", "值3"]
        
        listModel.cellModels = titles.enumerated().map { index, title in
            let model = MKSFUNormalTextCellModel()
            model.leftMsg = title
            model.rightMsg = subtitles[index]
            model.showRightIcon = true
            return model
        }
    }
}

// MARK: - 点击交互示例
struct MKSFUNormalTextCellInteractiveExample: View {
    @StateObject private var cellModel = MKSFUNormalTextCellModel()
    @State private var isActive = false
    
    var body: some View {
        VStack {
            Button(action: {
                // 模拟点击操作
                isActive.toggle()
                updateCellContent()
            }) {
                MKSFUNormalTextCell(dataModel: cellModel)
                    .background(isActive ? Color.blue.opacity(0.1) : Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            
            Text("点击单元格测试交互")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .onAppear {
            setupInteractiveData()
        }
    }
    
    private func setupInteractiveData() {
        cellModel.leftMsg = "可点击的单元格"
        cellModel.rightMsg = "点击试试"
        cellModel.showRightIcon = true
    }
    
    private func updateCellContent() {
        if isActive {
            cellModel.rightMsg = "已激活"
            cellModel.rightMsgTextColor = .green
            cellModel.noteMsg = "当前处于激活状态"
        } else {
            cellModel.rightMsg = "未激活"
            cellModel.rightMsgTextColor = .gray
            cellModel.noteMsg = ""
        }
    }
}

// MARK: - 预览
struct MKSFUNormalTextCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MKSFUNormalTextCellExample()
                .previewDisplayName("基本示例")
            
            MKSFUNormalTextCellListExample()
                .previewDisplayName("列表样式")
            
            MKSFUNormalTextCellObservableExample()
                .previewDisplayName("可观察列表")
            
            MKSFUNormalTextCellInteractiveExample()
                .previewDisplayName("交互示例")
        }
    }
}
