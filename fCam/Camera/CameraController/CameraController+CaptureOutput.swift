//
//  CameraController+CaptureOutput.swift
//  fCam
//
//  Created by Muhammad M. Munir on 18/11/23.
//

import AVFoundation
import CoreImage
import UIKit

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvImageBuffer: cvBuffer)
        
        // filter camera
        let filteredCIImage: CIImage
        if selectedColorFilter != UIColor.clear,
            let ciImageColorFilter = colorFilter.process(image: ciImage, color: selectedColorFilter)
        {
            filteredCIImage = ciImageColorFilter
        } else {
            filteredCIImage = ciImage
        }
        currentCIImage = filteredCIImage
        
        // draw to camera preview
        mtkView.draw()
        
        // writing to file
        if isRecording {
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
            let time = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)
            ciContext.render(filteredCIImage, to: pixelBuffer)
            
            DispatchQueue.main.async {
                self.videoWriter.appendPixelBuffer(pixelBuffer: pixelBuffer, time: time)
            }
        }
    }
}
