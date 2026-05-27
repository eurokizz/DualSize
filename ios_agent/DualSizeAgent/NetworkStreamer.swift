import Foundation
import Network

// MARK: - Network Streamer (UDP/TCP RTP-like)

final class NetworkStreamer {
    private var listener: NWListener?
    private var connections: [NWConnection] = []
    private let port: NWEndpoint.Port
    private var sequenceNumber: UInt32 = 0
    
    init(port: Int) {
        self.port = NWEndpoint.Port(rawValue: UInt16(port))!
        startListening()
    }
    
    deinit {
        listener?.cancel()
    }
    
    private func startListening() {
        let params = NWParameters.udp
        params.allowLocalEndpointReuse = true
        
        do {
            listener = try NWListener(using: params, on: port)
        } catch {
            print("[NetworkStreamer] Failed to create listener: \(error)")
            return
        }
        
        listener?.newConnectionHandler = { [weak self] conn in
            conn.start(queue: .global(qos: .userInteractive))
            self?.connections.append(conn)
        }
        
        listener?.start(queue: .global(qos: .userInteractive))
    }
    
    // MARK: - Send Frame
    
    func send(_ data: Data) {
        guard !connections.isEmpty else { return }
        
        sequenceNumber &+= 1
        let seq = sequenceNumber
        
        // RTP-like header: [magic(2)] [seq(4)] [ts(8)] [size(4)] [data...]
        var header = Data(capacity: 18)
        var magic: UInt16 = 0xD5B2
        header.append(Data(bytes: &magic, count: 2))
        var s = seq.bigEndian
        header.append(Data(bytes: &s, count: 4))
        var ts = UInt64(Date().timeIntervalSince1970 * 1000).bigEndian
        header.append(Data(bytes: &ts, count: 8))
        var sz = UInt32(data.count).bigEndian
        header.append(Data(bytes: &sz, count: 4))
        
        // Split into MTU-safe chunks (1400 bytes)
        let mtu = 1380
        var offset = 0
        let totalChunks = (data.count + mtu - 1) / mtu
        var chunkIdx: UInt16 = 0
        
        while offset < data.count {
            let end = min(offset + mtu, data.count)
            let chunk = data[offset..<end]
            
            var pkt = Data(capacity: 18 + 4 + chunk.count)
            pkt.append(header)
            // Chunk metadata: [chunkIdx(2)] [totalChunks(2)]
            var ci = chunkIdx.bigEndian
            var tc = UInt16(totalChunks).bigEndian
            pkt.append(Data(bytes: &ci, count: 2))
            pkt.append(Data(bytes: &tc, count: 2))
            pkt.append(chunk)
            
            for conn in connections {
                conn.send(content: pkt, completion: .idempotent)
            }
            
            offset = end
            chunkIdx += 1
        }
    }
}
