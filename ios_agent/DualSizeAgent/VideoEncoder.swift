import Foundation
import VideoToolbox
import CoreMedia
import CoreVideo

// MARK: - Video Encoder (H.264 / H.265 via VideoToolbox)
//
// Encodes incoming CMSampleBuffers from ReplayKit to compressed Annex-B
// at a target resolution chosen by the caller (480p / 720p / 1080p),
// NOT the device's nativeBounds. iPhone 13 nativeBounds = 1170x2532;
// encoding that in real time at 60fps melts the encoder. The capture
// stays full-res, but VideoToolbox scales internally during compression.

final class VideoEncoder {
    var onEncodedSample: ((Data) -> Void)?

    private var session: VTCompressionSession?
    private let codec: String
    private let bitrateBps: Int
    private let fps: Int
    private let targetWidth: Int32
    private let targetHeight: Int32

    init(codec: String, bitrateMbps: Double, fps: Int, width: Int = 1280, height: Int = 720) {
        self.codec = codec
        self.bitrateBps = Int(bitrateMbps * 1_000_000)
        self.fps = fps
        self.targetWidth = Int32(width)
        self.targetHeight = Int32(height)
        setupSession()
    }

    deinit {
        if let session = session {
            VTCompressionSessionInvalidate(session)
        }
    }

    private func setupSession() {
        let codecType: CMVideoCodecType = codec == "H.265" ? kCMVideoCodecType_HEVC : kCMVideoCodecType_H264

        let status = VTCompressionSessionCreate(
            allocator: nil,
            width: targetWidth,
            height: targetHeight,
            codecType: codecType,
            encoderSpecification: nil,
            imageBufferAttributes: nil,
            compressedDataAllocator: nil,
            outputCallback: outputCallback,
            refcon: Unmanaged.passUnretained(self).toOpaque(),
            compressionSessionOut: &session
        )

        guard status == noErr, let session = session else {
            print("[VideoEncoder] Failed to create session: \(status)")
            return
        }

        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_RealTime, value: kCFBooleanTrue)
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_AverageBitRate, value: bitrateBps as CFNumber)
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_ExpectedFrameRate, value: fps as CFNumber)
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_AllowFrameReordering, value: kCFBooleanFalse)
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_ProfileLevel,
                             value: codec == "H.265"
                                ? kVTProfileLevel_HEVC_Main_AutoLevel
                                : kVTProfileLevel_H264_High_AutoLevel)
        // Keyframe every 2 seconds — fine for screen-mirroring + much
        // friendlier on the encoder than every 0.5s.
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_MaxKeyFrameInterval, value: fps * 2 as CFNumber)
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration, value: 2.0 as CFNumber)

        // Cap the peak bitrate at 1.5× average over a 1-second window so
        // a sudden scene change can't blow the network buffer.
        let cap: [CFNumber] = [
            Int(Double(bitrateBps) * 1.5 / 8) as CFNumber, // bytes in 1s
            1.0 as CFNumber
        ]
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_DataRateLimits, value: cap as CFArray)

        // Hardware acceleration (iOS 17.4+)
        if #available(iOS 17.4, *) {
            VTSessionSetProperty(session, key: kVTVideoEncoderSpecification_EnableHardwareAcceleratedVideoEncoder, value: kCFBooleanTrue)
        }

        VTCompressionSessionPrepareToEncodeFrames(session)
    }

    func encode(_ sampleBuffer: CMSampleBuffer) {
        guard let session = session,
              let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let dur = CMSampleBufferGetDuration(sampleBuffer)

        VTCompressionSessionEncodeFrame(session, imageBuffer: imageBuffer, presentationTimeStamp: pts, duration: dur, frameProperties: nil, sourceFrameRefcon: nil, infoFlagsOut: nil)
    }

    // MARK: - Output Callback

    private let outputCallback: VTCompressionOutputCallback = { refcon, _, status, flags, sampleBuffer in
        guard status == noErr,
              let sampleBuffer = sampleBuffer,
              let refcon = refcon else { return }

        let encoder = Unmanaged<VideoEncoder>.fromOpaque(refcon).takeUnretainedValue()
        guard let data = sampleBuffer.toAnnexB() else { return }
        encoder.onEncodedSample?(data)
    }
}

// MARK: - CMSampleBuffer → Annex-B

private extension CMSampleBuffer {
    func toAnnexB() -> Data? {
        guard let block = CMSampleBufferGetDataBuffer(self) else { return nil }
        var length = 0
        var rawData: UnsafeMutablePointer<CChar>?
        guard CMBlockBufferGetDataPointer(block, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &length, dataPointerOut: &rawData) == noErr,
              let raw = rawData else { return nil }

        // AVCC → Annex-B conversion
        var data = Data()
        var offset = 0

        while offset < length {
            // Read 4-byte AVCC length
            var naluLength: UInt32 = 0
            memcpy(&naluLength, raw + offset, 4)
            naluLength = CFSwapInt32BigToHost(naluLength)
            offset += 4

            // Start code
            data.append(contentsOf: [0x00, 0x00, 0x00, 0x01])
            data.append(Data(bytes: raw + offset, count: Int(naluLength)))
            offset += Int(naluLength)
        }

        // Prepend SPS/PPS if this is an IDR frame
        if let description = CMSampleBufferGetFormatDescription(self) {
            var paramData = Data()
            var count = 0
            CMVideoFormatDescriptionGetH264ParameterSetAtIndex(description, parameterSetIndex: 0, parameterSetPointerOut: nil, parameterSetSizeOut: nil, parameterSetCountOut: &count, nalUnitHeaderLengthOut: nil)

            for i in 0..<count {
                var ptr: UnsafePointer<UInt8>?
                var size = 0
                CMVideoFormatDescriptionGetH264ParameterSetAtIndex(description, parameterSetIndex: i, parameterSetPointerOut: &ptr, parameterSetSizeOut: &size, parameterSetCountOut: nil, nalUnitHeaderLengthOut: nil)
                if let ptr = ptr {
                    paramData.append(contentsOf: [0x00, 0x00, 0x00, 0x01])
                    paramData.append(Data(bytes: ptr, count: size))
                }
            }
            return paramData + data
        }
        return data
    }
}
