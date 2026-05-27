import SwiftUI
import ActivityKit

// MARK: - Dynamic Island Live Activity

// Attributes for Live Activity
struct DualSizeActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var fps: Int
        var latencyMs: Int
        var isStreaming: Bool
        var connectedDevice: String
    }
    var sessionID: String
}

// MARK: - Dynamic Island View (displayed when streaming is active)

struct DynamicIslandCompactView: View {
    let state: DualSizeActivityAttributes.ContentState
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(state.isStreaming ? Color(hex: "34C759") : Color(hex: "FF3B30"))
                .frame(width: 6, height: 6)
            
            Text("\(state.fps)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text("FPS")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
            
            Divider()
                .frame(height: 12)
                .overlay(.white.opacity(0.3))
            
            Image(systemName: "bolt.fill")
                .font(.system(size: 10))
                .foregroundStyle(Color(hex: "FF9500"))
            
            Text("\(state.latencyMs)ms")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Manager

final class DynamicIslandActivity: ObservableObject {
    
    @available(iOS 16.2, *)
    private var activity: Activity<DualSizeActivityAttributes>?
    
    func start(deviceName: String) {
        guard #available(iOS 16.2, *) else { return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let attributes = DualSizeActivityAttributes(sessionID: UUID().uuidString)
        let state = DualSizeActivityAttributes.ContentState(
            fps: 0,
            latencyMs: 0,
            isStreaming: false,
            connectedDevice: deviceName
        )
        
        do {
            activity = try Activity<DualSizeActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("[DynamicIsland] Failed to start activity: \(error)")
        }
    }
    
    func update(fps: Int, latency: Int, streaming: Bool) {
        guard #available(iOS 16.2, *) else { return }
        let state = DualSizeActivityAttributes.ContentState(
            fps: fps,
            latencyMs: latency,
            isStreaming: streaming,
            connectedDevice: ""
        )
        Task {
            await activity?.update(.init(state: state, staleDate: nil))
        }
    }
    
    func stop() {
        guard #available(iOS 16.2, *) else { return }
        Task {
            await activity?.end(.dismissed)
        }
    }
}
