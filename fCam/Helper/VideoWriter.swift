//
//  VideoWriter.swift
//  fCam
//
//  Created by Muhammad M. Munir on 18/11/23.
//

import UIKit
import AVFoundation

class VideoWriter {
    
    private var assetWriter: AVAssetWriter!
    private var videoInputWriter: AVAssetWriterInput!
    private var firstFrame = false
    private var startTime: CMTime!
    private var assetWriterPixelBufferInput: AVAssetWriterInputPixelBufferAdaptor?
    
    private func initVideoWriter(_ url: URL) {
        firstFrame = false
        do {
            assetWriter = try AVAssetWriter(url: url, fileType: .mp4)
        } catch {
            fatalError("error init assetWriter")
        }

        let videoOutputSettings = AVOutputSettingsAssistant(
            preset: .preset1280x720
        )!.videoSettings!
        
        if assetWriter.canApply(outputSettings: videoOutputSettings, forMediaType: .video) {
            self.videoInputWriter = AVAssetWriterInput(
                mediaType: .video,
                outputSettings: videoOutputSettings
            )
        } else {
            
        }
        if assetWriter.canAdd(self.videoInputWriter) {
            assetWriter.add(self.videoInputWriter)
        }
        assetWriterPixelBufferInput = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoInputWriter
        )

    }
    
    func startWriting(_ url: URL) {
        firstFrame = false
        startTime = CMClockGetTime(CMClockGetHostTimeClock())
        initVideoWriter(url)
    }
    
    func stopWriting(_ blockCompletion: @escaping (_ url: URL) -> ()) {
        videoInputWriter.markAsFinished()
        
        assetWriter.finishWriting { () -> Void in
            blockCompletion(self.assetWriter.outputURL)
        }
    }
    
    func appendPixelBuffer(pixelBuffer: CVPixelBuffer, time: CMTime) {
        firstFrame = true
        if assetWriter.status == .unknown {
            let startTime = time
            assetWriter.startWriting()
            assetWriter.startSession(atSourceTime: startTime)
        }
        if videoInputWriter.isReadyForMoreMediaData {
            let _ = self.assetWriterPixelBufferInput?.append(pixelBuffer, withPresentationTime: time)
        }
    }
}
