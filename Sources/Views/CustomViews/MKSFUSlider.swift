//
//  MKSFUSlider.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI
import MKBaseSwiftModule

// MARK: - SwiftUI Slider Data Model
public class MKSFUSliderModel: ObservableObject {
    @Published public var value: Double
    @Published public var range: ClosedRange<Double>
    @Published public var step: Double?
    
    public init(value: Double = 0.5, range: ClosedRange<Double> = 0...1, step: Double? = nil) {
        self.value = value
        self.range = range
        self.step = step
    }
}

// MARK: - SwiftUI Custom Slider (对应 MKSwiftSlider)
public struct MKSFUSlider: View {
    @ObservedObject public var dataModel: MKSFUSliderModel
    public var onValueChanged: (Double) -> Void
    public var onEditingChanged: (Bool) -> Void
    
    // 滑块图片和轨道颜色配置
    private let thumbImageName: String
    private let minimumTrackColor: Color
    private let maximumTrackColor: Color
    
    @State private var isEditing: Bool = false
    
    public init(
        dataModel: MKSFUSliderModel,
        thumbImageName: String = "mk_swiftUI_sliderThumbIcon",
        minimumTrackColor: Color = Color(MKColor.navBar),
        maximumTrackColor: Color = .gray.opacity(0.3),
        onValueChanged: @escaping (Double) -> Void = { _ in },
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.dataModel = dataModel
        self.thumbImageName = thumbImageName
        self.minimumTrackColor = minimumTrackColor
        self.maximumTrackColor = maximumTrackColor
        self.onValueChanged = onValueChanged
        self.onEditingChanged = onEditingChanged
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let totalWidth = max(1, geometry.size.width - 28)
            let progress = calculateProgress()
            let progressWidth = max(0, min(totalWidth, totalWidth * CGFloat(progress)))
            
            ZStack(alignment: .leading) {
                // Maximum track (背景轨道) - 使用颜色
                RoundedRectangle(cornerRadius: 2)
                    .fill(maximumTrackColor)
                    .frame(height: 4)
                
                // Minimum track (进度轨道) - 使用颜色
                RoundedRectangle(cornerRadius: 2)
                    .fill(minimumTrackColor)
                    .frame(width: progressWidth, height: 4)
                
                // Thumb (滑块) - 如果有图片使用图片，否则使用默认样式
                if UIImage(named: thumbImageName) != nil {
                    Image(thumbImageName)
                        .resizable()
                        .frame(width: 28, height: 28)
                        .offset(x: progressWidth)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    updateValue(from: value, in: geometry)
                                    if !isEditing {
                                        isEditing = true
                                        onEditingChanged(true)
                                    }
                                }
                                .onEnded { _ in
                                    isEditing = false
                                    onEditingChanged(false)
                                }
                        )
                } else {
                    // 图片不存在时使用默认滑块
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(minimumTrackColor, lineWidth: 2)
                        )
                        .offset(x: progressWidth)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    updateValue(from: value, in: geometry)
                                    if !isEditing {
                                        isEditing = true
                                        onEditingChanged(true)
                                    }
                                }
                                .onEnded { _ in
                                    isEditing = false
                                    onEditingChanged(false)
                                }
                        )
                }
            }
            .frame(height: 44)
        }
        .frame(height: 44)
        .onChange(of: dataModel.value) { newValue in
            onValueChanged(newValue)
        }
    }
    
    private func calculateProgress() -> Double {
        let rangeLength = dataModel.range.upperBound - dataModel.range.lowerBound
        guard rangeLength > 0 else { return 0 }
        return (dataModel.value - dataModel.range.lowerBound) / rangeLength
    }
    
    private func updateValue(from gesture: DragGesture.Value, in geometry: GeometryProxy) {
        let totalWidth = geometry.size.width - 28
        let locationX = max(0, min(gesture.location.x, geometry.size.width))
        let progress = max(0, min(1, (locationX - 14) / totalWidth))
        let rangeLength = dataModel.range.upperBound - dataModel.range.lowerBound
        let newValue = dataModel.range.lowerBound + Double(progress) * rangeLength
        
        if let step = dataModel.step, step > 0 {
            let steppedValue = round(newValue / step) * step
            dataModel.value = max(dataModel.range.lowerBound, min(dataModel.range.upperBound, steppedValue))
        } else {
            dataModel.value = max(dataModel.range.lowerBound, min(dataModel.range.upperBound, newValue))
        }
    }
}

// MARK: - 使用示例
struct MKSFUSliderExample: View {
    @StateObject private var sliderModel = MKSFUSliderModel(value: 0.5, range: 0...1)
    
    var body: some View {
        VStack(spacing: 20) {
            Text("SwiftUI 滑块: \(sliderModel.value, specifier: "%.2f")")
                .font(.headline)
            
            MKSFUSlider(
                dataModel: sliderModel,
                thumbImageName: "mk_swiftUI_sliderThumbIcon",
                maximumTrackColor: .gray.opacity(0.3)
            ) { newValue in
                print("滑块值变化: \(newValue)")
            } onEditingChanged: { editing in
                print("编辑状态: \(editing ? "开始" : "结束")")
            }
            .padding(.horizontal)
            
            HStack {
                Text("0")
                Spacer()
                Text("1")
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - 带步长的示例
struct SteppedMKSFUSliderExample: View {
    @StateObject private var sliderModel = MKSFUSliderModel(value: 50, range: 0...100, step: 10)
    
    var body: some View {
        VStack(spacing: 20) {
            Text("音量控制: \(Int(sliderModel.value))%")
                .font(.headline)
            
            MKSFUSlider(
                dataModel: sliderModel,
                minimumTrackColor: .orange,
                maximumTrackColor: .gray.opacity(0.2)
            ) { newValue in
                print("音量设置: \(Int(newValue))%")
            } onEditingChanged: { editing in
                if !editing {
                    print("最终音量: \(Int(sliderModel.value))%")
                }
            }
            .padding(.horizontal)
            
            HStack {
                Text("0%")
                Spacer()
                Text("100%")
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - 自定义颜色示例
struct CustomColorMKSFUSliderExample: View {
    @StateObject private var sliderModel = MKSFUSliderModel(value: 0.3, range: 0...1)
    
    var body: some View {
        VStack(spacing: 20) {
            Text("自定义颜色: \(sliderModel.value, specifier: "%.2f")")
                .font(.headline)
            
            MKSFUSlider(
                dataModel: sliderModel,
                minimumTrackColor: .purple,
                maximumTrackColor: .purple.opacity(0.2)
            ) { newValue in
                print("值变化: \(newValue)")
            } onEditingChanged: { editing in
                print("编辑状态: \(editing)")
            }
            .padding(.horizontal)
            
            HStack {
                Text("0")
                Spacer()
                Text("1")
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - 预览
struct MKSFUSlider_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            MKSFUSliderExample()
                .previewDisplayName("基础滑块")
            
            SteppedMKSFUSliderExample()
                .previewDisplayName("步长滑块")
            
            CustomColorMKSFUSliderExample()
                .previewDisplayName("自定义颜色")
        }
    }
}
