//
//  GameView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 12.08.24.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var manager: GameManager
    @ObservedObject var jumpMan:JumpMan
    @ObservedObject var kong:Kong
    @ObservedObject var barrelArray:BarrelArray
    @ObservedObject var fireBlobArray:FireBlobArray
    @ObservedObject var elevatorArray:ElevatorArray
    @ObservedObject var springArray:SpringArray
    @ObservedObject var conveyorArray:ConveyorArray
    @ObservedObject var pieArray:PieArray
    @ObservedObject var loftLadders:Ladders
    var body: some View {
        ZStack {
            ScreenView(gameScreen: manager.gameScreen)
                .position(x:manager.gameScreen.gameSize.width / 2,y:manager.gameScreen.gameSize.height / 2)
                .zIndex(0.1)
            BonusBoxView()
                .position(x:manager.gameScreen.gameSize.width - 70,y:50)
            JumpManView(jumpMan: jumpMan)
                .position(jumpMan.position)
                .zIndex(2.0)
            KongView(kong: kong)
                .position(kong.position)
                .zIndex(1.95)
            PaulineView(pauline: manager.pauline)
                .position(manager.pauline.position)
                .zIndex(1.7)
            if manager.gameScreen.hasFlames {
                FlamesView(flames: manager.flames)
                    .position(manager.flames.position)
                    .zIndex(1.9)
            }
            if manager.gameScreen.hasExplosion {
                ExplodeView(explode: manager.explosion)
                    .position(manager.explosion.position)
                    .zIndex(2.9)
            }
            if manager.gameScreen.hasPoints {
                PointsView(points: manager.pointsShow)
                    .position(manager.pointsShow.position)
                    .zIndex(2.9)
            }
            ForEach(barrelArray.barrels, id: \.id) { barrel in
                if barrel.isShowing {
                    BarrelView(barrel: barrel)
                        .position(barrel.position)
                        .zIndex(2.1)
                }
            }
            ForEach(fireBlobArray.fireblob, id: \.id) { fireBlob in
                if fireBlob.isShowing {
                    FireBlobView(fireBlob: fireBlob)
                        .position(fireBlob.position)
                        .zIndex(2.2)
                }
            }
            ForEach(manager.collectibles, id: \.id) { collectible in
                if !collectible.collected {
                    CollectiblesView(collectible: collectible)
                        .position(collectible.position)
                        .zIndex(1.8)
                }
            }
            if manager.gameScreen.hasElevators {
                ForEach(elevatorArray.elevators, id: \.id) { elevator in
                    ElevatorView(elevator: elevator)
                        .position(elevator.position)
                        .zIndex(1.85)
                }
            }
            if manager.gameScreen.hasSprings {
                ForEach(springArray.springs, id: \.id) { spring in
                    SpringView(spring: spring)
                        .position(spring.position)
                        .zIndex(2.3)
                }
            }
            if manager.gameScreen.hasConveyor {
                ForEach(conveyorArray.conveyors, id: \.id) { conveyor in
                    ConveyorView(conveyor: conveyor)
                        .position(conveyor.position)
                        .zIndex(1.8)
                }
                ForEach(pieArray.pies, id: \.id) { pie in
                    PieView(pie: pie)
                        .position(pie.position)
                        .zIndex(1.85)
                }
                
            }
            if manager.gameScreen.hasLoftLadders {
                LoftLadderView(ladder: loftLadders.leftLadder)
                    .position(loftLadders.leftLadder.position)
                    .zIndex(1.81)
                LoftLadderView(ladder: loftLadders.rightLadder)
                    .position(loftLadders.rightLadder.position)
                    .zIndex(1.81)
            }
        }.zIndex(1.0)
    }
}

//#Preview {
//    let previewEnvObject = GameManager()
//    return GameView()
//        .environmentObject(previewEnvObject)
//}
