//
//  SoundFX.swift
//  DonkeyKong
//
//  Created by Jonathan French on 11.08.24.
//

import Foundation
import AVFoundation

final class SoundFX {
    
    private var backGroundMusicAudioPlayer: AVAudioPlayer?
    private var deathAudioPlayer: AVAudioPlayer?
    private var hammerAudioPlayer: AVAudioPlayer?
    private var howHighAudioPlayer: AVAudioPlayer?
    private var introLongAudioPlayer: AVAudioPlayer?
    private var introAudioPlayer: AVAudioPlayer?
    private var jumpAudioPlayer: AVAudioPlayer?
    private var getAudioPlayer: AVAudioPlayer?
    private var barrelJumpAudioPlayer: AVAudioPlayer?
    private var walkingAudioPlayer: AVAudioPlayer?
    private var win1AudioPlayer: AVAudioPlayer?
    private var win2AudioPlayer: AVAudioPlayer?
    private var endLevelAudioPlayer: AVAudioPlayer?
    private var gameOverAudioPlayer: AVAudioPlayer?

    private lazy var backgroundurl = Bundle.main.url(forResource: "bacmusic", withExtension: "wav")
    private lazy var deathurl = Bundle.main.url(forResource: "death", withExtension: "wav")
    private lazy var hammerurl = Bundle.main.url(forResource: "hammer", withExtension: "wav")
    private lazy var howhighurl = Bundle.main.url(forResource: "howhigh", withExtension: "wav")
    private lazy var introLongurl = Bundle.main.url(forResource: "intro1_long", withExtension: "wav")
    private lazy var introurl = Bundle.main.url(forResource: "intro1", withExtension: "wav")
    private lazy var jumpurl = Bundle.main.url(forResource: "jump", withExtension: "wav")
    private lazy var geturl = Bundle.main.url(forResource: "itemget", withExtension: "wav")
    private lazy var barrelJumpurl = Bundle.main.url(forResource: "jumpbar", withExtension: "wav")
    private lazy var walkingurl = Bundle.main.url(forResource: "walking", withExtension: "wav")
    private lazy var win1url = Bundle.main.url(forResource: "win1", withExtension: "wav")
    private lazy var win2url = Bundle.main.url(forResource: "win2", withExtension: "wav")
    private lazy var endLevelurl = Bundle.main.url(forResource: "DKEndLevel", withExtension: "m4a")
    private lazy var gameOverurl = Bundle.main.url(forResource: "DKGameOver", withExtension: "m4a")

    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            backGroundMusicAudioPlayer = try AVAudioPlayer(contentsOf: backgroundurl!, fileTypeHint: AVFileType.wav.rawValue)
            deathAudioPlayer = try AVAudioPlayer(contentsOf: deathurl!, fileTypeHint: AVFileType.wav.rawValue)
            hammerAudioPlayer = try AVAudioPlayer(contentsOf: hammerurl!, fileTypeHint: AVFileType.wav.rawValue)
            howHighAudioPlayer = try AVAudioPlayer(contentsOf: howhighurl!, fileTypeHint: AVFileType.wav.rawValue)
            introLongAudioPlayer = try AVAudioPlayer(contentsOf: introLongurl!, fileTypeHint: AVFileType.wav.rawValue)
            introAudioPlayer = try AVAudioPlayer(contentsOf: introurl!, fileTypeHint: AVFileType.wav.rawValue)
            jumpAudioPlayer = try AVAudioPlayer(contentsOf: jumpurl!, fileTypeHint: AVFileType.wav.rawValue)
            getAudioPlayer = try AVAudioPlayer(contentsOf: geturl!, fileTypeHint: AVFileType.wav.rawValue)
            barrelJumpAudioPlayer = try AVAudioPlayer(contentsOf: barrelJumpurl!, fileTypeHint: AVFileType.wav.rawValue)
            walkingAudioPlayer = try AVAudioPlayer(contentsOf: walkingurl!, fileTypeHint: AVFileType.wav.rawValue)
            win1AudioPlayer = try AVAudioPlayer(contentsOf: win1url!, fileTypeHint: AVFileType.wav.rawValue)
            win2AudioPlayer = try AVAudioPlayer(contentsOf: win2url!, fileTypeHint: AVFileType.wav.rawValue)
            endLevelAudioPlayer = try AVAudioPlayer(contentsOf: endLevelurl!, fileTypeHint: AVFileType.m4a.rawValue)
            gameOverAudioPlayer = try AVAudioPlayer(contentsOf: endLevelurl!, fileTypeHint: AVFileType.m4a.rawValue)

        } catch let error {
            print(error.localizedDescription)
        }
    }

    @objc func play(audioPlayer:AVAudioPlayer){
        audioPlayer.play()
    }

    func gameOverSound(){
        guard let gameOverAudioPlayer = gameOverAudioPlayer else { return }
        Thread.detachNewThreadSelector(#selector(play), toTarget: self, with: gameOverAudioPlayer)
    }

    func endLevelSound(){
        guard let endLevelAudioPlayer = endLevelAudioPlayer else { return }
        Thread.detachNewThreadSelector(#selector(play), toTarget: self, with: endLevelAudioPlayer)
    }

    func backgroundSound(){
        guard let backGroundMusicAudioPlayer = backGroundMusicAudioPlayer else { return }
        Thread.detachNewThreadSelector(#selector(play), toTarget: self, with: backGroundMusicAudioPlayer)
    }
    
    func deathSound(){
        guard let deathAudioPlayer = deathAudioPlayer else { return }
        Thread.detachNewThreadSelector(#selector(play), toTarget: self, with: deathAudioPlayer)
    }
    
    func hammerSound(){
        guard let hammerAudioPlayer = hammerAudioPlayer else { return }
        Thread.detachNewThreadSelector(#selector(play), toTarget: self, with: hammerAudioPlayer)
    }
    
    func howHighSound() {
        guard let howHighAudioPlayer = howHighAudioPlayer else { return }
        Thread.detachNewThreadSelector(#selector(play), toTarget: self, with: howHighAudioPlayer)
    }
    func introLongSound() {
        guard let introLongAudioPlayer = introLongAudioPlayer else { return }
        Thread.detachNewThreadSelector(#selector(play), toTarget: self, with: introLongAudioPlayer)
    }
    func introSound() {
        guard let introAudioPlayer = introAudioPlayer else { return }
        Thread.detachNewThreadSelector(#selector(play), toTarget: self, with: introAudioPlayer)
    }

    func jumpSound() {
        guard let jumpAudioPlayer = jumpAudioPlayer else { return }
        Thread.detachNewThreadSelector(#selector(play), toTarget: self, with: jumpAudioPlayer)
    }
    
    func getItemSound()
    {
        guard let getAudioPlayer = getAudioPlayer else { return }
        Thread.detachNewThreadSelector(#selector(play), toTarget: self, with: getAudioPlayer)
    }
    func barrelJumpSound()
    {
        guard let barrelJumpAudioPlayer = barrelJumpAudioPlayer else { return }
        Thread.detachNewThreadSelector(#selector(play), toTarget: self, with: barrelJumpAudioPlayer)
    }
    
    func walkingSound()
    {
        guard let walkingAudioPlayer = walkingAudioPlayer else { return }
        Thread.detachNewThreadSelector(#selector(play), toTarget: self, with: walkingAudioPlayer)
    }
    
    func win1Sound()
    {
        guard let win1AudioPlayer = win1AudioPlayer else { return }
        Thread.detachNewThreadSelector(#selector(play), toTarget: self, with: win1AudioPlayer)
    }
    
    func win2Sound()
    {
        guard let win2AudioPlayer = win2AudioPlayer else { return }
        Thread.detachNewThreadSelector(#selector(play), toTarget: self, with: win2AudioPlayer)
    }
}
