# DualSize — iOS Agent

<img src="https://raw.githubusercontent.com/FL-corp/DualSize/main/docs/icon.png" width="128" height="128" align="right"/>

**Professional iOS Screen Mirroring Agent**  
*by FL-corp.ltd · 2023–2026*

![Build Status](https://github.com/FL-corp/DualSize/actions/workflows/build-ios.yml/badge.svg)
![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Структура проекта

```
DSize/
├── ios_agent/                        ← iOS приложение (этот README)
│   ├── DualSizeAgent.xcodeproj/
│   └── DualSizeAgent/
│       ├── DualSizeAgentApp.swift     ← @main точка входа
│       ├── ContentView.swift          ← Онбординг и root view
│       ├── MainTabView.swift          ← iOS 26 Liquid Glass таббар
│       ├── Views/
│       │   ├── StatusView.swift       ← Статус, метрики, быстрые действия
│       │   ├── StreamView.swift       ← Управление стримингом
│       │   ├── LocationView.swift     ← GPS Spoofing + маршруты
│       │   ├── SettingsView.swift     ← Все настройки
│       │   ├── ConnectionView.swift   ← Поиск и подключение к ПК
│       │   ├── PairingCodeView.swift  ← QR / код сопряжения
│       │   └── InfoView.swift         ← Горячие клавиши и справка
│       ├── Components/
│       │   ├── GlassCard.swift        ← Базовый glass-контейнер
│       │   ├── GlassToggle.swift      ← Кастомный toggle
│       │   ├── MetricRow.swift        ← Строка метрики
│       │   ├── StatusIndicator.swift  ← Анимированный индикатор
│       │   ├── AnimatedGradientBG.swift
│       │   ├── LiquidGlassModifier.swift
│       │   └── DynamicIslandActivity.swift
│       ├── Managers/
│       │   ├── ConnectionManager.swift ← TCP + Bonjour + USB
│       │   ├── StreamingManager.swift  ← ReplayKit оркестратор
│       │   ├── VideoEncoder.swift      ← VideoToolbox H.264/H.265
│       │   ├── NetworkStreamer.swift   ← UDP RTP-like streaming
│       │   ├── PairingService.swift    ← Код сопряжения
│       │   ├── AppDetector.swift       ← Контекст активного приложения
│       │   ├── MotionTracker.swift     ← Гироскоп → ПК
│       │   ├── BatteryMonitor.swift
│       │   ├── HapticManager.swift
│       │   └── SampleHandler.swift    ← ReplayKit Extension
│       └── Models/
│           ├── Theme.swift            ← Дизайн-система (токены)
│           └── DeviceIdentifier.swift ← База данных iPhone моделей
├── .github/
│   └── workflows/
│       └── build-ios.yml             ← CI/CD: lint → build → sign → release
└── electron/                         ← Desktop приложение (Phase 2)
```

## Установка .ipa

### Sideloadly (рекомендуется)
1. Скачайте последний релиз со страницы [Releases](../../releases)
2. Откройте [Sideloadly](https://sideloadly.io) на ПК
3. Подключите iPhone по USB
4. Перетащите `.ipa` → введите Apple ID → Start

### AltStore
1. Установите AltStore через AltServer
2. В AltStore: **+** → выберите `.ipa`
3. Готово — приложение будет активно 7 дней (бесплатный Apple ID)

### TrollStore (iOS 14.0–16.6.1)
- Прямая установка без ограничений и без перепідписи

---

## Сборка из исходников

```bash
# Клонировать
git clone https://github.com/FL-corp/DualSize.git
cd DualSize

# Открыть в Xcode
open ios_agent/DualSizeAgent.xcodeproj

# Или собрать из командной строки (без подписи)
xcodebuild \
  -project ios_agent/DualSizeAgent.xcodeproj \
  -scheme DualSizeAgent \
  -configuration Release \
  -sdk iphoneos \
  -destination "generic/platform=iOS" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  build
```

## Протокол DSP 1.0

| Порт | Протокол | Назначение |
|------|----------|------------|
| 9090 | TCP JSON | Управление, handshake, события |
| 9091 | UDP      | Видеопоток H.264/H.265 (RTP-like) |
| 9092 | TCP      | Аудиопоток AAC |
| 9093 | TCP REST | API Gateway |

## Лицензия

MIT License © 2023–2026 FL-corp.ltd
