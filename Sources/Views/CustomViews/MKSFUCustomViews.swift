//
//  MKCustomViews.swift
//  MKSFUISeriesSlathf
//
//  Created by aa on 2025/10/30.
//

import SwiftUI

import MKBaseSwiftModule

struct MKSFURoundBtn: View {
    let title: String
    let action: () ->Void
    let fontSize: CGFloat
    init(title: String, action: @escaping () -> Void, fontSize: CGFloat) {
        self.title = title
        self.action = action
        self.fontSize = fontSize
    }
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: fontSize))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(MKColor.navBar))
                .cornerRadius(6)
            
        }
    }
}

struct MKSFUNormalText: View {
    let text: String
    let fontSize: CGFloat
    init(text: String = "", fontSize: CGFloat = 15) {
        self.text = text
        self.fontSize = fontSize
    }
    var body: some View {
        Text(text)
            .font(.system(size: fontSize))
            .foregroundStyle(Color(MKColor.defaultText))
            .multilineTextAlignment(.leading)
    }
}

#Preview {
    MKSFUNormalText(text: "Here")
}
