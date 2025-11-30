import SwiftUI
import MetalKit

public struct MetalBackgroundView: UIViewRepresentable, Sendable {
    public init() {}
    public class Renderer: NSObject, MTKViewDelegate {
        let device: MTLDevice
        var commandQueue: MTLCommandQueue

        init(device: MTLDevice) {
            self.device = device
            self.commandQueue = device.makeCommandQueue()!
        }

        public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

        public func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let descriptor = view.currentRenderPassDescriptor,
                  let commandBuffer = commandQueue.makeCommandBuffer(),
                  let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }

            // Clear color animation: change over time
            let time = Float(Date().timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 10)) / 10.0
            view.clearColor = MTLClearColor(
                red: Double(sin(time * 2 * .pi) * 0.2 + 0.6),
                green: Double(cos(time * 2 * .pi) * 0.2 + 0.4),
                blue: Double(sin(time * 2 * .pi + .pi/2) * 0.2 + 0.5),
                alpha: 1
            )

            encoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }

    public func makeCoordinator() -> Renderer {
        Renderer(device: MTLCreateSystemDefaultDevice()!)
    }

    public func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = context.coordinator.device
        mtkView.delegate = context.coordinator
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false
        mtkView.framebufferOnly = false
        return mtkView
    }

    public func updateUIView(_ uiView: MTKView, context: Context) {}
}
