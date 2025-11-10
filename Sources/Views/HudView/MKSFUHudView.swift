//
//  MKSFUHudView.swift
//  MKSwiftUILibrary
//
//  Created by aa on 2025/11/10.
//

import SwiftUI

public struct MKSFUHudView: View {
    let message: String
    let isPenetration: Bool
    
    public init(message: String, isPenetration: Bool = false) {
        self.message = message
        self.isPenetration = isPenetration
    }
    
    public var body: some View {
        ZStack {
            // 背景遮罩层 - 始终显示
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .allowsHitTesting(!isPenetration) // 根据 isPenetration 决定是否拦截触摸
            
            // HUD 内容
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.primary)
                
                Text(message)
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            )
        }
    }
}

public extension View {
    public func showHUD(_ isShowing: Binding<Bool>, message: String, isPenetration: Bool = false) -> some View {
        self.overlay(
            Group {
                if isShowing.wrappedValue {
                    MKSFUHudView(message: message, isPenetration: isPenetration)
                        .transition(.opacityScale(scale: 0.9))
                        .zIndex(999) // 确保在最上层
                }
            }
        )
    }
}

// 自定义修饰符
struct OpacityScaleModifier: ViewModifier {
    let scale: CGFloat
    let opacity: Double
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
    }
}

// 扩展自定义过渡
extension AnyTransition {
    static func opacityScale(scale: CGFloat) -> AnyTransition {
        .modifier(
            active: OpacityScaleModifier(scale: scale, opacity: 0),
            identity: OpacityScaleModifier(scale: 1.0, opacity: 1.0)
        )
    }
}

// 预览：完整的测试界面
#Preview {
    HudTestView()
}

struct HudTestView: View {
    @State private var showHUD = false
    @State private var hudMessage = "加载中..."
    @State private var isPenetration = false
    @State private var tapCount = 0
    
    var body: some View {
        ZStack {
            // 主内容
            VStack(spacing: 30) {
                Text("HUD 测试界面")
                    .font(.title)
                    .bold()
                
                Text("点击计数: \(tapCount)")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                VStack(spacing: 15) {
                    Button("点击我测试穿透") {
                        tapCount += 1
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("显示不可穿透 HUD") {
                        showHUD(type: false)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("显示可穿透 HUD") {
                        showHUD(type: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("隐藏 HUD") {
                        hideHUD()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("自动隐藏 HUD (3秒)") {
                        showHUD(type: isPenetration)
                        
                        // 3秒后自动隐藏
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            hideHUD()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                
                Text("提示：可穿透模式下，即使显示HUD也能点击上方按钮")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.top, 50)
            
            // HUD 层
        }
        .showHUD($showHUD, message: hudMessage, isPenetration: isPenetration)
    }
    
    private func showHUD(type: Bool) {
        isPenetration = type
        hudMessage = type ? "可穿透加载中..." : "不可穿透加载中..."
        withAnimation(.spring(duration: 0.3)) {
            showHUD = true
        }
    }
    
    private func hideHUD() {
        withAnimation(.spring(duration: 0.3)) {
            showHUD = false
        }
    }
}

// 单独预览 HUD 组件
#Preview("HUD 组件") {
    VStack(spacing: 20) {
        MKSFUHudView(message: "不可穿透", isPenetration: false)
            .frame(height: 200)
        
        MKSFUHudView(message: "可穿透", isPenetration: true)
            .frame(height: 200)
    }
    .padding()
}
