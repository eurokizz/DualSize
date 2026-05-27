import Foundation
import ReplayKit

// MARK: - Sample Handler (Broadcast Upload Extension)

class SampleHandler: RPBroadcastSampleHandler {
    
    private var encoder: VideoEncoder?
    private var streamer: NetworkStreamer?
    
    override func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
        encoder = VideoEncoder(codec: "H.265", bitrateMbps: 8, fps: 60)
        streamer = NetworkStreamer(port: 9091)
        
        encoder?.onEncodedSample = { [weak self] data in
            self?.streamer?.send(data)
        }
    }
    
    override func broadcastPaused() {}
    
    override func broadcastResumed() {}
    
    override func broadcastFinished() {
        encoder = nil
        streamer = nil
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case .video:
            encoder?.encode(sampleBuffer)
        case .audioApp:
            break
        case .audioMic:
            break
        @unknown default:
            break
        }
    }
}
