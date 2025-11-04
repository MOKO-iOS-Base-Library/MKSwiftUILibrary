//
//  MKSFUPickerView.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI

// MARK: - Picker View
public struct MKSFUPickerView: View {
    // MARK: - Properties
    @Binding private var isPresented: Bool
    private let dataList: [String]
    private let selectedRow: Int
    private let onSelectionChanged: (Int) -> Void
    
    // MARK: - State
    @State private var currentRow: Int
    
    // MARK: - Constants
    private let pickerViewHeight: CGFloat = 270
    private let pickerViewRowHeight: CGFloat = 30
    
    // MARK: - Initialization
    public init(
        isPresented: Binding<Bool>,
        dataList: [String],
        selectedRow: Int = 0,
        onSelectionChanged: @escaping (Int) -> Void
    ) {
        self._isPresented = isPresented
        self.dataList = dataList
        self.selectedRow = selectedRow
        self.onSelectionChanged = onSelectionChanged
        self._currentRow = State(initialValue: selectedRow)
    }
    
    // MARK: - Body
    public var body: some View {
        if isPresented {
            ZStack {
                // 半透明背景
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        dismiss()
                    }
                
                // 底部选择器
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // 顶部工具栏
                        HStack {
                            Button("Cancel") {
                                dismiss()
                            }
                            .foregroundColor(.primary)
                            .font(.system(size: 16, weight: .regular))
                            
                            Spacer()
                            
                            Button("Confirm") {
                                confirmSelection()
                            }
                            .foregroundColor(.primary)
                            .font(.system(size: 16, weight: .regular))
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                        .background(Color.white)
                        
                        // 选择器
                        Picker("", selection: $currentRow) {
                            ForEach(0..<dataList.count, id: \.self) { index in
                                Text(dataList[index])
                                    .tag(index)
                                    .foregroundColor(.primary)
                                    .font(.system(size: 15))
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 216)
                        .background(Color(red: 244/255, green: 244/255, blue: 244/255))
                    }
                    .frame(height: pickerViewHeight)
                    .background(Color(red: 244/255, green: 244/255, blue: 244/255))
                }
            }
            .transition(.move(edge: .bottom))
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented)
            .onAppear {
                currentRow = selectedRow
            }
        }
    }
    
    // MARK: - Private Methods
    private func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isPresented = false
        }
    }
    
    private func confirmSelection() {
        onSelectionChanged(currentRow)
        dismiss()
    }
}

// MARK: - View Modifier for Presentation
public struct MKSFUPickerViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    let dataList: [String]
    let selectedRow: Int
    let onSelectionChanged: (Int) -> Void
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            MKSFUPickerView(
                isPresented: $isPresented,
                dataList: dataList,
                selectedRow: selectedRow,
                onSelectionChanged: onSelectionChanged
            )
        }
    }
}

// MARK: - View Extension for Easy Usage
public extension View {
    /// 显示自定义选择器
    func mkPickerView(
        isPresented: Binding<Bool>,
        dataList: [String],
        selectedRow: Int = 0,
        onSelectionChanged: @escaping (Int) -> Void
    ) -> some View {
        self.modifier(
            MKSFUPickerViewModifier(
                isPresented: isPresented,
                dataList: dataList,
                selectedRow: selectedRow,
                onSelectionChanged: onSelectionChanged
            )
        )
    }
}

// MARK: - 使用示例
struct MKSFUPickerViewExamples: View {
    @State private var showPicker = false
    @State private var selectedIndex = 0
    @State private var selectedValue = "选项1"
    
    let sampleData = ["选项1", "选项2", "选项3", "选项4", "选项5", "选项6", "选项7"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Picker View 示例")
                .font(.title)
                .padding()
            
            VStack(spacing: 10) {
                Text("当前选择: \(selectedValue)")
                    .font(.headline)
                
                Text("选中索引: \(selectedIndex)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Button("显示选择器") {
                showPicker = true
            }
            .buttonStyle(.borderedProminent)
            
            Button("重置选择") {
                selectedIndex = 0
                selectedValue = sampleData[0]
            }
            .buttonStyle(.bordered)
            
            Spacer()
        }
        .padding()
        .mkPickerView(
            isPresented: $showPicker,
            dataList: sampleData,
            selectedRow: selectedIndex
        ) { newIndex in
            selectedIndex = newIndex
            selectedValue = sampleData[newIndex]
            print("选择了: \(sampleData[newIndex]) - 索引: \(newIndex)")
        }
    }
}

// MARK: - 高级使用示例
struct MKSFUPickerViewAdvancedExamples: View {
    @State private var showCountryPicker = false
    @State private var showDatePicker = false
    @State private var selectedCountryIndex = 0
    @State private var selectedDateIndex = 0
    
    let countries = ["中国", "美国", "日本", "韩国", "英国", "法国", "德国", "加拿大", "澳大利亚"]
    let dates = ["今天", "明天", "本周", "本月", "今年"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("高级选择器示例")
                .font(.title)
                .padding()
            
            // 国家选择
            VStack(alignment: .leading, spacing: 8) {
                Text("选择国家")
                    .font(.headline)
                
                Button(action: {
                    showCountryPicker = true
                }) {
                    HStack {
                        Text(countries[selectedCountryIndex])
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            // 日期选择
            VStack(alignment: .leading, spacing: 8) {
                Text("选择日期范围")
                    .font(.headline)
                
                Button(action: {
                    showDatePicker = true
                }) {
                    HStack {
                        Text(dates[selectedDateIndex])
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        // 国家选择器
        .mkPickerView(
            isPresented: $showCountryPicker,
            dataList: countries,
            selectedRow: selectedCountryIndex
        ) { newIndex in
            selectedCountryIndex = newIndex
            print("选择了国家: \(countries[newIndex])")
        }
        // 日期选择器
        .mkPickerView(
            isPresented: $showDatePicker,
            dataList: dates,
            selectedRow: selectedDateIndex
        ) { newIndex in
            selectedDateIndex = newIndex
            print("选择了日期范围: \(dates[newIndex])")
        }
    }
}

// MARK: - 表单中使用示例
struct MKSFUPickerViewFormExample: View {
    @State private var showGenderPicker = false
    @State private var showEducationPicker = false
    @State private var genderIndex = 0
    @State private var educationIndex = 0
    
    let genders = ["男", "女", "其他"]
    let educations = ["高中", "大专", "本科", "硕士", "博士"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("个人信息")) {
                    // 性别选择
                    HStack {
                        Text("性别")
                        Spacer()
                        Button(genders[genderIndex]) {
                            showGenderPicker = true
                        }
                        .foregroundColor(.blue)
                    }
                    
                    // 学历选择
                    HStack {
                        Text("学历")
                        Spacer()
                        Button(educations[educationIndex]) {
                            showEducationPicker = true
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("表单示例")
        }
        // 性别选择器
        .mkPickerView(
            isPresented: $showGenderPicker,
            dataList: genders,
            selectedRow: genderIndex
        ) { newIndex in
            genderIndex = newIndex
        }
        // 学历选择器
        .mkPickerView(
            isPresented: $showEducationPicker,
            dataList: educations,
            selectedRow: educationIndex
        ) { newIndex in
            educationIndex = newIndex
        }
    }
}

// MARK: - 预览
struct MKSFUPickerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MKSFUPickerViewExamples()
                .previewDisplayName("基础示例")
            
            MKSFUPickerViewAdvancedExamples()
                .previewDisplayName("高级示例")
            
            MKSFUPickerViewFormExample()
                .previewDisplayName("表单示例")
        }
    }
}

// MARK: - 便捷方法
public extension View {
    /// 快速创建选择器绑定
    func mkPickerBinding<T: Hashable>(
        isPresented: Binding<Bool>,
        dataList: [T],
        selectedValue: Binding<T>,
        displayText: @escaping (T) -> String = { "\($0)" }
    ) -> some View {
        self.modifier(
            MKSFUPickerBindingModifier(
                isPresented: isPresented,
                dataList: dataList,
                selectedValue: selectedValue,
                displayText: displayText
            )
        )
    }
}

// MARK: - 绑定修饰符
public struct MKSFUPickerBindingModifier<T: Hashable>: ViewModifier {
    @Binding var isPresented: Bool
    let dataList: [T]
    @Binding var selectedValue: T
    let displayText: (T) -> String
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                MKSFUPickerView(
                    isPresented: $isPresented,
                    dataList: dataList.map { displayText($0) },
                    selectedRow: dataList.firstIndex(of: selectedValue) ?? 0
                ) { newIndex in
                    if newIndex < dataList.count {
                        selectedValue = dataList[newIndex]
                    }
                }
            }
        }
    }
}
