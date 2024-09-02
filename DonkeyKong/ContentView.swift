//
//  ContentView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 11.08.24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var manager: GameManager
    var body: some View {
        ZStack(alignment: .top) {
            Color(.black)
            VStack {
                TopView()
                    .frame(width: UIScreen.main.bounds.width,height: 60, alignment: .center)
                    .zIndex(3.0)
                //Spacer()
                if manager.gameState == .intro {
                    IntroView()
                        .frame(maxWidth: .infinity)
                        .background(.clear)
                } 
                else if manager.gameState == .kongintro {
                    KongIntroView(manager: manager,kong: manager.kong)
                        .background(.clear)
                        .zIndex(1.0)
                }  
                else if manager.gameState == .playing {
                    GameView(jumpMan: manager.jumpMan,kong:manager.kong, barrelArray:manager.barrelArray,fireBlobArray:manager.fireBlobArray,elevatorArray:manager.elevatorsArray,springArray:manager.springArray,conveyorArray:manager.conveyorArray)
//                    GameView(manager: manager)
                            .zIndex(1.0)
                } 
                    else if manager.gameState == .howhigh {
                        HowHighView(level: manager.level)
                        .background(.clear)
                        .zIndex(1.0)
                }
//                else if manager.gameState == .highscore {
//                    NewHighScoreView()
//                        .background(.clear)
//                        .zIndex(1.0)
//                }
                Spacer()
                Spacer()
                Spacer()

                ControlsView()
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(.all)
                    .zIndex(2.0)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.black,.red, .controlBackground,.red, .white]), startPoint: .top, endPoint: .bottom)
                    )
            }.background(.black)

        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    let previewEnvObject = GameManager()
    return ContentView()
        .environmentObject(previewEnvObject)
}

////        .onAppear(perform: {
////            for family in UIFont.familyNames.sorted() {
////                print("Family: \(family)")
////                
////                let names = UIFont.fontNames(forFamilyName: family)
////                for fontName in names {
////                    print("- \(fontName)")
////                }
////            }
////        })
