import ClipperCoreKit
import MarkdownUI
import SwiftUI

struct MemoryUsageView: View {
    @Environment(\.clipperAssistant) private var clipperAssistant
    @Environment(\.deviceStat) private var deviceStat

    var body: some View {
        List {
            Section("Model") {
                Text(clipperAssistant.modelInfo.model)
                    .font(.headline)
            }
            Section("Memory") {
                Markdown(
                """
                **Memory usage:** \(deviceStat.gpuUsage.activeMemory.formatted(.byteCount(style: .memory)))\n
                **Active Memory:** \(deviceStat.gpuUsage.activeMemory.formatted(.byteCount(style: .memory)))/
                \(DeviceStat.ClipperGPU.memoryLimit.formatted(.byteCount(style: .memory)))\n
                **Cache Memory:** \(deviceStat.gpuUsage.cacheMemory.formatted(.byteCount(style: .memory)))/
                \(DeviceStat.ClipperGPU.cacheLimit.formatted(.byteCount(style: .memory)))\n
                **Peak Memory:** \(deviceStat.gpuUsage.peakMemory.formatted(.byteCount(style: .memory)))
                """
                )
            }
        }
        .navigationBarTitle("Memory Usage")
    }
}
