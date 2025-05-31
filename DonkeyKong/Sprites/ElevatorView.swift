//
//  ElevatorView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 31.08.24.
//

import SwiftUI

struct ElevatorView: View {
    @ObservedObject var elevator:Elevator
    var body: some View {
        ZStack {
            if elevator.part == .lift {
                HStack(spacing: 0){
                    Image(ImageResource(name: "Girder", bundle: .main))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: elevator.frameSize.width / 2, height: elevator.frameSize.height)
                        .background(.clear)
                    .zIndex(2.1)
                        .padding([.leading])
                    Image(ImageResource(name: "Girder", bundle: .main))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: elevator.frameSize.width / 2, height: elevator.frameSize.height)
                        .background(.clear)
                        .padding([.trailing])
                    .zIndex(2.1)
                }
            } else {
                HStack(spacing: 0){
                    Image(elevator.direction == .down ? ImageResource(name: "LiftTopBL", bundle: .main) : ImageResource(name: "LiftBottomTL", bundle: .main))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: elevator.frameSize.width / 2, height: elevator.frameSize.height)
                        .background(.clear)
                    .zIndex(2.2)
                        .padding([.leading])
                    Image(elevator.direction == .down ? ImageResource(name: "LiftTopBR", bundle: .main) : ImageResource(name: "LiftBottomTR", bundle: .main))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: elevator.frameSize.width / 2, height: elevator.frameSize.height)
                        .background(.clear)
                        .padding([.trailing])
                    .zIndex(2.2)
                }
            }
        }
        .background(.clear)
        .frame(width: 1,height: 1,alignment: .center)
        .position(elevator.position)
    }
}

//#Preview {
//    ElevatorView()
//}
