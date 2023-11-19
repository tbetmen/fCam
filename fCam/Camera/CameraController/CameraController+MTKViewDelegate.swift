//
//  CameraController+MTKViewDelegate.swift
//  fCam
//
//  Created by Muhammad M. Munir on 18/11/23.
//

import MetalKit

extension CameraController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer(),
              let ciImage = currentCIImage,
              let currentDrawable = view.currentDrawable
        else { return }
        
        let xPosition = {
            let diff = view.drawableSize.width - ciImage.extent.width
            return diff > 0 ? (diff / 2) : 0
        }()
        let yPosition = (view.drawableSize.height / 10) * 2.5
        let origin = CGPoint(x: -xPosition, y: -yPosition)
        
        self.ciContext.render(
            ciImage,
            to: currentDrawable.texture,
            commandBuffer: commandBuffer,
            bounds: CGRect(origin: origin, size: view.drawableSize),
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
}
