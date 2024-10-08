//
//  PointsView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 25.08.24.
//

import SwiftUI

struct PointsView: View {
#if os(iOS)
    static var pointsTextSize:CGFloat = 8
#elseif os(tvOS)
    static var pointsTextSize:CGFloat = 16
#endif

    @ObservedObject var points:Points
    var body: some View {
        ZStack {
            Text(points.pointsText)
                .foregroundStyle(points.pointsColor)
                .font(.custom("DonkeyKongClassicsNESExtended", size: PointsView.pointsTextSize))
                .frame(width: points.frameSize.width, height: points.frameSize.height)
                .background(.clear)
                    .frame(width: 1,height: 1,alignment: .center)
            }
    }
}
