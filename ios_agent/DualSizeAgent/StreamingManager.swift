import Foundation
import ReplayKit
import VideoToolbox
import Combine
import UIKit

// MARK: - Streaming Manager

final class StreamingManager: ObservableObject {

    @Published var isStreaming: Bool = false
    @Published var currentFPS: Int = 0
    @Published var latencyMs: Int = 0
    @Published var bitrate: Double = 8
    @Published var selectedQuality: String = "720p"
    @Published var targetFPS: Int = 60
    @Published var hardwareAcceleration: Bool = true
    @Published var audioEnabled: Bool = false
    @Published var gyroEnabled: Bool = true
    @Published var selectedCodec: String = "H.265"
    @Published var startOnConnection: Bool = false
    @Published var droppedPackets: Int = 0
    @Published var totalMBTransferred: Int = 0

    var bitrateString: String {
        String(format: "%.1f", bitrate)
    }

    // (width, height) the encoder should target for the currently
    // selected quality. "Авто" falls back to the device's native
    // resolution divided down to fit within 1080p — the encoder cannot
    // realistically push native 1170x2532 @ 60fps in real time.
    var targetResolution: (width: Int, height: Int) {
        switch selectedQuality {
        case "480p":  return (854, 480)
        case "720p":  return (1280, 720)
        case "1080p": return (1920, 1080)
        case "4K":    return (3840, 2160)
        default:      return (1920, 1080) // "Авто" — capped to 1080p
        }
    }

    var resolutionString: String {
        let (w, h) = targetResolution
        return "\(w)×\(h)"
    }

    private let recorder = RPScreenRecorder.shared()
    private var encoder: VideoEncoder?
    private var streamer: NetworkStreamer?
    private var statsTimer: Timer?
    private var frameCount = 0
    private var lastFPSTime = Date()

    init() {
        recorder.isMicrophoneEnabled = false
        recorder.isCameraEnabled = false
    }

    // MARK: - Start / Stop

    func startStreaming() {
        guard !isStreaming else { return }
        guard recorder.isAvailable else {
            print("[DualSize] ReplayKit unavailable")
            return
        }

        let (w, h) = targetResolution
        encoder = VideoEncoder(codec: selectedCodec, bitrateMbps: bitrate, fps: targetFPS, width: w, height: h)
        streamer = NetworkStreamer(port: 9091)

        encoder?.onEncodedSample = { [weak self] data in
            self?.streamer?.send(data)
            DispatchQueue.main.async {
                self?.totalMBTransferred += data.count / 1_000_000
            }
        }

        recorder.startCapture(handler: { [weak self] buffer, type, error in
            guard error == nil else { return }
            guard type == .video else { return }
            self?.frameCount += 1
            self?.encoder?.encode(buffer)
            self?.updateFPS()
        }) { [weak self] error in
            if error == nil {
                DispatchQueue.main.async {
                    self?.isStreaming = true
                    self?.startStatsTimer()
                }
            }
        }
    }

    func stopStreaming() {
        recorder.stopCapture { [weak self] error in
            DispatchQueue.main.async {
                self?.isStreaming = false
                self?.currentFPS = 0
                self?.latencyMs = 0
                self?.statsTimer?.invalidate()
            }
        }
        encoder = nil
        streamer = nil
    }

    func requestScreenshot() {
        // Capture current frame and send as JPEG
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, UIScreen.main.scale)
        UIApplication.shared.windows.first?.drawHierarchy(in: UIScreen.main.bounds, afterScreenUpdates: true)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let jpeg = img?.jpegData(compressionQuality: 0.9) {
            streamer?.send(jpeg)
        }
    }

    // MARK: - Stats

    private func updateFPS() {
        let now = Date()
        let elapsed = now.timeIntervalSince(lastFPSTime)
        if elapsed >= 1.0 {
            DispatchQueue.main.async {
                self.currentFPS = Int(Double(self.frameCount) / elapsed)
            }
            frameCount = 0
            lastFPSTime = now
        }
    }

    private func startStatsTimer() {
        statsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            // Simulate latency measurement — real impl uses round-trip ping
            let jitter = Int.random(in: -5...5)
            DispatchQueue.main.async {
                self.latencyMs = max(12, self.latencyMs + jitter)
            }
        }
    }
}
