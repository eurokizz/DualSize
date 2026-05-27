import Foundation
import UIKit

// MARK: - App Detector
// Detects the frontmost app context from the desktop side and adapts the UI

final class AppDetector: ObservableObject {
    
    struct AppContext {
        let bundleID: String
        let name: String
        let category: AppCategory
        let icon: String   // SF Symbol fallback
        let accentColor: String  // hex
    }
    
    enum AppCategory: String {
        case maps       = "maps"
        case photos     = "photos"
        case camera     = "camera"
        case music      = "music"
        case video      = "video"
        case browser    = "browser"
        case social     = "social"
        case game       = "game"
        case productivity = "productivity"
        case graphics   = "graphics"
        case development = "development"
        case system     = "system"
        case unknown    = "unknown"
    }
    
    @Published var currentContext: AppContext = AppContext(
        bundleID: "com.apple.springboard",
        name: "Главный экран",
        category: .system,
        icon: "house.fill",
        accentColor: "007AFF"
    )
    
    @Published var contextualControls: [ContextualControl] = []
    
    static let knownApps: [String: AppContext] = [
        "com.apple.Maps": AppContext(bundleID: "com.apple.Maps", name: "Карты", category: .maps, icon: "map.fill", accentColor: "34C759"),
        "com.apple.Photos": AppContext(bundleID: "com.apple.Photos", name: "Фото", category: .photos, icon: "photo.fill", accentColor: "FF9500"),
        "com.apple.camera": AppContext(bundleID: "com.apple.camera", name: "Камера", category: .camera, icon: "camera.fill", accentColor: "1C1C1E"),
        "com.apple.Music": AppContext(bundleID: "com.apple.Music", name: "Музыка", category: .music, icon: "music.note", accentColor: "FC3C44"),
        "com.apple.mobilesafari": AppContext(bundleID: "com.apple.mobilesafari", name: "Safari", category: .browser, icon: "safari.fill", accentColor: "007AFF"),
        "com.apple.mobilemail": AppContext(bundleID: "com.apple.mobilemail", name: "Почта", category: .productivity, icon: "envelope.fill", accentColor: "007AFF"),
        "com.apple.Preferences": AppContext(bundleID: "com.apple.Preferences", name: "Настройки", category: .system, icon: "gearshape.fill", accentColor: "8E8E93"),
        
        // Games
        "com.kiloo.subwaysurf": AppContext(bundleID: "com.kiloo.subwaysurf", name: "Subway Surfers", category: .game, icon: "gamecontroller.fill", accentColor: "FFD60A"),
        "com.supercell.clashofclans": AppContext(bundleID: "com.supercell.clashofclans", name: "Clash of Clans", category: .game, icon: "gamecontroller.fill", accentColor: "30D158"),
        "com.riotgames.mobile.leagueoflegends": AppContext(bundleID: "com.riotgames.mobile.leagueoflegends", name: "League of Legends", category: .game, icon: "gamecontroller.fill", accentColor: "C1A43A"),
        "com.pubg.mobile": AppContext(bundleID: "com.pubg.mobile", name: "PUBG Mobile", category: .game, icon: "gamecontroller.fill", accentColor: "FF9500"),
        
        // Social
        "com.burbn.instagram": AppContext(bundleID: "com.burbn.instagram", name: "Instagram", category: .social, icon: "camera.filters", accentColor: "E1306C"),
        "ph.telegra.Telegraph": AppContext(bundleID: "ph.telegra.Telegraph", name: "Telegram", category: .social, icon: "paperplane.fill", accentColor: "2AABEE"),
        "com.zhiliaoapp.musically": AppContext(bundleID: "com.zhiliaoapp.musically", name: "TikTok", category: .video, icon: "play.circle.fill", accentColor: "FF0050"),
        "com.atebits.Tweetie2": AppContext(bundleID: "com.atebits.Tweetie2", name: "X / Twitter", category: .social, icon: "bird.fill", accentColor: "1D9BF0"),
        "com.facebook.Facebook": AppContext(bundleID: "com.facebook.Facebook", name: "Facebook", category: .social, icon: "f.circle.fill", accentColor: "1877F2"),
        
        // Graphics & Creative
        "com.adobe.photoshop": AppContext(bundleID: "com.adobe.photoshop", name: "Photoshop", category: .graphics, icon: "wand.and.stars", accentColor: "31A8FF"),
        "com.adobe.lightroom": AppContext(bundleID: "com.adobe.lightroom", name: "Lightroom", category: .graphics, icon: "camera.aperture", accentColor: "31A8FF"),
        "com.procreate.procreate": AppContext(bundleID: "com.procreate.procreate", name: "Procreate", category: .graphics, icon: "paintbrush.fill", accentColor: "2D65C8"),
        
        // Development
        "com.apple.dt.Xcode": AppContext(bundleID: "com.apple.dt.Xcode", name: "Xcode", category: .development, icon: "hammer.fill", accentColor: "1C7ED6"),
    ]
    
    func update(bundleID: String) {
        let ctx = Self.knownApps[bundleID] ?? AppContext(
            bundleID: bundleID,
            name: bundleID.components(separatedBy: ".").last?.capitalized ?? "App",
            category: .unknown,
            icon: "app.fill",
            accentColor: "007AFF"
        )
        DispatchQueue.main.async {
            self.currentContext = ctx
            self.contextualControls = ContextualControl.controls(for: ctx.category)
        }
    }
}

// MARK: - Contextual Controls

struct ContextualControl: Identifiable {
    let id = UUID()
    let label: String
    let icon: String
    let action: String  // sent to desktop via ConnectionManager
    let color: String
    
    static func controls(for category: AppDetector.AppCategory) -> [ContextualControl] {
        switch category {
        case .maps:
            return [
                ContextualControl(label: "Текущее место", icon: "location.fill",      action: "maps_current_location",  color: "34C759"),
                ContextualControl(label: "Маршрут",      icon: "arrow.triangle.turn.up.right.circle.fill", action: "maps_directions", color: "007AFF"),
                ContextualControl(label: "Схема",        icon: "map",                 action: "maps_scheme_view",       color: "8E8E93"),
                ContextualControl(label: "Спутник",      icon: "globe.americas.fill", action: "maps_satellite_view",    color: "30D158"),
                ContextualControl(label: "Пробки",       icon: "car.2.fill",          action: "maps_traffic",           color: "FF3B30"),
                ContextualControl(label: "Масштаб +",    icon: "plus.magnifyingglass", action: "maps_zoom_in",          color: "007AFF"),
            ]
        case .game:
            return [
                ContextualControl(label: "Джойстик",    icon: "gamecontroller.fill",  action: "game_dpad",             color: "007AFF"),
                ContextualControl(label: "Скриншот",    icon: "camera.viewfinder",    action: "screenshot",            color: "FF9500"),
                ContextualControl(label: "Запись",      icon: "record.circle",        action: "start_recording",       color: "FF3B30"),
                ContextualControl(label: "Тап A",       icon: "a.circle.fill",        action: "game_tap_a",            color: "34C759"),
                ContextualControl(label: "Тап B",       icon: "b.circle.fill",        action: "game_tap_b",            color: "FF3B30"),
                ContextualControl(label: "Пауза",       icon: "pause.circle.fill",    action: "game_pause",            color: "8E8E93"),
            ]
        case .camera, .photos:
            return [
                ContextualControl(label: "Затвор",      icon: "camera.aperture",      action: "camera_shutter",        color: "F2F2F7"),
                ContextualControl(label: "Поменять",    icon: "arrow.triangle.2.circlepath.camera", action: "camera_flip", color: "007AFF"),
                ContextualControl(label: "Фото",        icon: "camera.fill",          action: "camera_photo_mode",     color: "F2F2F7"),
                ContextualControl(label: "Видео",       icon: "video.fill",           action: "camera_video_mode",     color: "FF3B30"),
                ContextualControl(label: "Портрет",     icon: "person.crop.artframe", action: "camera_portrait",       color: "FF9500"),
                ContextualControl(label: "Ночь",        icon: "moon.stars.fill",      action: "camera_night_mode",     color: "5856D6"),
            ]
        case .music:
            return [
                ContextualControl(label: "Вперёд",      icon: "forward.fill",         action: "media_next",            color: "FC3C44"),
                ContextualControl(label: "Назад",       icon: "backward.fill",        action: "media_prev",            color: "FC3C44"),
                ContextualControl(label: "Пауза",       icon: "pause.fill",           action: "media_pause",           color: "F2F2F7"),
                ContextualControl(label: "Повтор",      icon: "repeat.1",             action: "media_repeat",          color: "007AFF"),
                ContextualControl(label: "Перемешать",  icon: "shuffle",              action: "media_shuffle",         color: "007AFF"),
                ContextualControl(label: "Очередь",     icon: "list.bullet.indent",   action: "media_queue",           color: "8E8E93"),
            ]
        case .social, .browser:
            return [
                ContextualControl(label: "Вверх",       icon: "arrow.up.circle.fill", action: "scroll_top",           color: "007AFF"),
                ContextualControl(label: "Вниз",        icon: "arrow.down.circle.fill", action: "scroll_bottom",      color: "007AFF"),
                ContextualControl(label: "Обновить",    icon: "arrow.clockwise",      action: "refresh",               color: "34C759"),
                ContextualControl(label: "Лайк",        icon: "heart.fill",           action: "social_like",           color: "FF3B30"),
                ContextualControl(label: "Сохранить",   icon: "bookmark.fill",        action: "save",                  color: "FF9500"),
                ContextualControl(label: "Поделиться",  icon: "square.and.arrow.up",  action: "share",                 color: "5AC8FA"),
            ]
        case .graphics:
            return [
                ContextualControl(label: "Отменить",    icon: "arrow.uturn.backward", action: "undo",                  color: "007AFF"),
                ContextualControl(label: "Повторить",   icon: "arrow.uturn.forward",  action: "redo",                  color: "007AFF"),
                ContextualControl(label: "Кисть",       icon: "paintbrush.pointed.fill", action: "tool_brush",         color: "31A8FF"),
                ContextualControl(label: "Ластик",      icon: "eraser.fill",          action: "tool_eraser",           color: "FF9500"),
                ContextualControl(label: "Слои",        icon: "square.3.layers.3d",   action: "panel_layers",          color: "5856D6"),
                ContextualControl(label: "Цвет",        icon: "paintpalette.fill",    action: "panel_colors",          color: "FC3C44"),
            ]
        default:
            return [
                ContextualControl(label: "Скриншот",    icon: "camera.viewfinder",    action: "screenshot",            color: "007AFF"),
                ContextualControl(label: "Домой",       icon: "house.fill",           action: "home",                  color: "8E8E93"),
                ContextualControl(label: "Назад",       icon: "chevron.left",         action: "back",                  color: "007AFF"),
                ContextualControl(label: "Поделиться",  icon: "square.and.arrow.up",  action: "share",                 color: "5AC8FA"),
                ContextualControl(label: "Обновить",    icon: "arrow.clockwise",      action: "refresh",               color: "34C759"),
                ContextualControl(label: "Вверх",       icon: "arrow.up.circle",      action: "scroll_top",            color: "007AFF"),
            ]
        }
    }
}
