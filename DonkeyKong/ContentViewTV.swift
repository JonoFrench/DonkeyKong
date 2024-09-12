//
//  ContentViewTV.swift
//  DonkeyKong
//
//  Created by Jonathan French on 6.09.24.
//

import SwiftUI

struct ContentViewTV: View {
    @EnvironmentObject var manager: GameManager
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            ZStack(alignment: .center) {
                Color(.black)
                Spacer()
                VStack(alignment: .center) {
                    Spacer()
                    TopView()
                        .frame(height: 120, alignment: .center)
                        .zIndex(3.0)
                        .background(.black)
                    if manager.gameState == .intro {
                        IntroView()
                            .background(.clear)
                    }
                    else if manager.gameState == .kongintro {
                        KongIntroView(manager: manager,kong: manager.kong)
                            .background(.clear)
                            .zIndex(1.0)
                    }
                    else if manager.gameState == .playing {
                        GameView(jumpMan: manager.jumpMan,kong:manager.kong, barrelArray:manager.barrelArray,fireBlobArray:manager.fireBlobArray,elevatorArray:manager.elevatorsArray,springArray:manager.springArray,conveyorArray:manager.conveyorArray,pieArray:manager.pieArray,loftLadders:manager.loftLadders)
                            .zIndex(1.0)
                    }
                    else if manager.gameState == .howhigh {
                        HowHighView(level: manager.gameScreen.level)
                            .background(.clear)
                            .zIndex(1.0)
                    }
                    else if manager.gameState == .highscore {
                        NewHighScoreView(hiScores: manager.hiScores)
                            .background(.clear)
                            .zIndex(1.0)
                    }
                    Spacer()
                    Spacer()
                    HStack {
                        Spacer()
                    }
                }.background(.black)
                
            }.frame(width: (UIScreen.main.bounds.width / 2) - 120 , height: UIScreen.main.bounds.height,alignment: .center)
            Spacer()
        }.frame(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height,alignment: .center)
            .background(.black)
    }
}

#Preview {
    let previewEnvObject = GameManager()
    return ContentView()
        .environmentObject(previewEnvObject)
}

#Preview {
    ContentViewTV()
}
