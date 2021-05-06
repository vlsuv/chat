//
//  BasicAudioController.swift
//  chat
//
//  Created by vlsuv on 04.05.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import AVFoundation
import MessageKit

enum PlayerState {
    case playing
    case pause
    case stopped
}

class BasicAudioController: NSObject {
    
    // MARK: - Properties
    private var audioPlayer: AVAudioPlayer?
    
    var message: MessageType?
    var playingCell: AudioMessageCell?
    
    var state: PlayerState = .stopped
    
    init(message: MessageType, cell: AudioMessageCell) {
        self.message = message
        self.playingCell = cell
        super.init()
    }
    
    func playSound() {
        switch message?.kind {
        case .audio(let item):
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
                let audioPlayer = try AVAudioPlayer(contentsOf: item.url)
                
                audioPlayer.volume = 1.0
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch {
                print(error)
            }
        
//            guard let player = try? AVAudioPlayer(contentsOf: item.url) else {
//                print("player error")
//                return
//            }
            
//            audioPlayer = player
            
//            audioPlayer?.prepareToPlay()
//            audioPlayer?.delegate = self
//            audioPlayer?.play()
//            state = .playing
//
//            playingCell?.playButton.isSelected = true
//            playingCell?.delegate?.didStartAudio(in: playingCell!)
        default:
            break
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension BasicAudioController: AVAudioPlayerDelegate {
    
}
