//
//  MKSFUSettingTextCell.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI

// MARK: - Cell Model
public class MKSFUSettingTextCellModel: ObservableObject, Identifiable {
    public let id = UUID()
    @Published public var contentColor: Color = .white
    
    // Left label and icon
    @Published public var leftIcon: String?
    @Published public var leftMsgTextFont: Font = .system(size: 15)
    @Published public var leftMsgTextColor: Color = .primary
    @Published public var leftMsg: String = ""
    
    public init() {}
    
    public init(leftMsg: String, leftIcon: String? = nil) {
        self.leftMsg = leftMsg
        self.leftIcon = leftIcon
    }
}

// MARK: - Cell Implementation
public struct MKSFUSettingTextCell: View {
    
    // MARK: - Properties
    @ObservedObject public var dataModel: MKSFUSettingTextCellModel
    
    // 点击回调
    public var onCellTapped: (() -> Void)?
    
    // MARK: - Constants
    private let offset_X: CGFloat = 15
    
    // MARK: - Initialization
    public init(
        dataModel: MKSFUSettingTextCellModel,
        onCellTapped: (() -> Void)? = nil
    ) {
        self.dataModel = dataModel
        self.onCellTapped = onCellTapped
    }
    
    public var body: some View {
        Button(action: {
            onCellTapped?()
        }) {
            HStack(spacing: 3) {
                // Left icon
                if let leftIconName = dataModel.leftIcon {
                    if UIImage(systemName: leftIconName) != nil {
                        // 系统图标
                        Image(systemName: leftIconName)
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .frame(width: 20, height: 20)
                    } else {
                        // 自定义图标
                        Image(leftIconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                }
                
                // Left message label
                Text(dataModel.leftMsg)
                    .font(dataModel.leftMsgTextFont)
                    .foregroundColor(dataModel.leftMsgTextColor)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Right arrow icon
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, offset_X)
            .frame(height: 50)
            .background(dataModel.contentColor)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 简单预览版本
struct MKSFUSettingTextCellSimplePreview: View {
    var body: some View {
        VStack(spacing: 1) {
            MKSFUSettingTextCell(
                dataModel: MKSFUSettingTextCellModel(leftMsg: "通用设置")
            ) {
                print("通用设置被点击")
            }
            .background(Color.white)
            
            MKSFUSettingTextCell(
                dataModel: MKSFUSettingTextCellModel(
                    leftMsg: "Wi-Fi 设置",
                    leftIcon: "wifi"
                )
            ) {
                print("Wi-Fi 设置被点击")
            }
            .background(Color.white)
            
            MKSFUSettingTextCell(
                dataModel: MKSFUSettingTextCellModel(
                    leftMsg: "通知设置",
                    leftIcon: "bell"
                )
            ) {
                print("通知设置被点击")
            }
            .background(Color.white)
        }
        .padding()
    }
}

// MARK: - 列表预览版本
struct MKSFUSettingTextCellListPreview: View {
    let settings = [
        ("个人资料", "person"),
        ("账户安全", "shield"),
        ("隐私设置", "lock"),
        ("语言设置", "globe"),
        ("关于我们", "info.circle")
    ]
    
    var body: some View {
        List {
            ForEach(settings, id: \.0) { title, icon in
                MKSFUSettingTextCell(
                    dataModel: MKSFUSettingTextCellModel(
                        leftMsg: title,
                        leftIcon: icon
                    )
                ) {
                    print("\(title) 被点击")
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - 基础使用示例
struct MKSFUSettingTextCellBasicUsage: View {
    var body: some View {
        VStack {
            Text("设置单元格示例")
                .font(.title2)
                .padding()
            
            VStack(spacing: 1) {
                // 基本用法
                MKSFUSettingTextCell(
                    dataModel: MKSFUSettingTextCellModel(leftMsg: "基础设置项")
                ) {
                    print("基础设置项被点击")
                }
                .background(Color.white)
                
                // 带图标的用法
                MKSFUSettingTextCell(
                    dataModel: MKSFUSettingTextCellModel(
                        leftMsg: "带图标的设置项",
                        leftIcon: "gear"
                    )
                ) {
                    print("带图标的设置项被点击")
                }
                .background(Color.white)
                
                // 自定义颜色的用法
                MKSFUSettingTextCell(
                    dataModel: {
                        let model = MKSFUSettingTextCellModel(leftMsg: "自定义颜色")
                        model.leftMsgTextColor = .blue
                        model.contentColor = Color.blue.opacity(0.1)
                        return model
                    }()
                ) {
                    print("自定义颜色设置项被点击")
                }
            }
            .cornerRadius(8)
            .shadow(radius: 2)
            .padding()
            
            Spacer()
        }
    }
}

// MARK: - 预览提供器
struct MKSFUSettingTextCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MKSFUSettingTextCellSimplePreview()
                .previewDisplayName("简单预览")
            
            MKSFUSettingTextCellListPreview()
                .previewDisplayName("列表预览")
            
            MKSFUSettingTextCellBasicUsage()
                .previewDisplayName("基础使用")
        }
    }
}

// MARK: - 实际使用示例
extension MKSFUSettingTextCell {
    // 快速创建方法
    public static func createCell(
        title: String,
        icon: String? = nil,
        backgroundColor: Color = .white,
        textColor: Color = .primary,
        onTap: @escaping () -> Void
    ) -> some View {
        let model = MKSFUSettingTextCellModel(leftMsg: title, leftIcon: icon)
        model.contentColor = backgroundColor
        model.leftMsgTextColor = textColor
        
        return MKSFUSettingTextCell(dataModel: model, onCellTapped: onTap)
    }
}

// 使用快速创建方法的示例
struct QuickCreateExample: View {
    var body: some View {
        VStack(spacing: 1) {
            MKSFUSettingTextCell.createCell(
                title: "快速创建1",
                onTap: { print("快速1") }
            )
            
            MKSFUSettingTextCell.createCell(
                title: "快速创建2",
                icon: "star",
                onTap: { print("快速2") }
            )
            
            MKSFUSettingTextCell.createCell(
                title: "快速创建3",
                icon: "heart",
                backgroundColor: .red.opacity(0.1),
                textColor: .red,
                onTap: { print("快速3") }
            )
        }
        .background(Color.white)
        .cornerRadius(8)
        .padding()
    }
}
