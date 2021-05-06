//
//  AudioRecordingManager.swift
//  chat
//
//  Created by vlsuv on 05.05.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import Foundation
import AVKit

enum AudioRecordingState {
    case playing
    case stopped
}

protocol AudioRecordingManagerProtocol {
    var delegate: AudioRecordingManagerDelegate? { get set }
    func setupRecordingSession()
    func didTapRecordingButton()
}

protocol AudioRecordingManagerDelegate: class {
    func didSetupRecordingSession(succes: Bool)
    func audioRecorderDidFinishRecording(audioURL: URL)
    func didChangeRecordingState(to state: AudioRecordingState)
}

class AudioRecordingManager: NSObject, AudioRecordingManagerProtocol {
    
    // MARK: - Properties
    weak var delegate: AudioRecordingManagerDelegate?
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    // MARK: - Handlers
    func didTapRecordingButton() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    private func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            delegate?.didChangeRecordingState(to: .playing)
        } catch {
            finishRecording(success: false)
        }
    }
    
    private func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        delegate?.didChangeRecordingState(to: .stopped)
        
        if success {
            print("recording succes finish")
        } else {
            print("recording failed")
        }
    }
    
    func setupRecordingSession() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission { [weak self] allowed in
                self?.delegate?.didSetupRecordingSession(succes: true)
            }
        } catch {
            delegate?.didSetupRecordingSession(succes: false)
        }
    }
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecordingManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        let audioURL = recorder.url
        
        delegate?.audioRecorderDidFinishRecording(audioURL: audioURL)
    }
}

// MARK: - Helpers
extension AudioRecordingManager {
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
