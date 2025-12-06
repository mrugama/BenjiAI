import Foundation
import MLX

@Observable
final class DeviceStatImpl: DeviceStat, @unchecked Sendable {

    var gpuUsage = GPU.snapshot()

    private let initialGPUSnapshot = GPU.snapshot()
    private var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateGPUUsages()
        }
    }

    deinit {
        timer?.invalidate()
    }

    private func updateGPUUsages() {
        let gpuSnapshotDelta = initialGPUSnapshot.delta(GPU.snapshot())
        Task { @MainActor [weak self] in
            self?.gpuUsage = gpuSnapshotDelta
        }
    }

}
