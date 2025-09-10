<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-09-10 at 16 32 02" src="https://github.com/user-attachments/assets/8d83ed4a-5c4e-413b-bb87-21e0a2b0fad8" />
<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-09-10 at 16 31 53" src="https://github.com/user-attachments/assets/12b14d87-a50e-4090-9075-790bae53d15e" />
<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-09-10 at 16 31 50" src="https://github.com/user-attachments/assets/596d8d24-976a-4896-a77e-f906ec3a7d7f" />
<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-09-10 at 16 31 47" src="https://github.com/user-attachments/assets/a9deb317-7245-48bc-8931-bd1da0b47c6b" />
<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-09-10 at 16 31 42" src="https://github.com/user-attachments/assets/1f0b30f4-2999-4e09-8ee1-fa72d1c89dab" />


# Codeway iOS App

A modern iOS app that groups photos by heuristics (e.g. leading letter) and shows a live **scanning** progress with a sticky header.  
Built with a **UIKit** host, **SwiftUI** detail screens, **Combine** pipelines, and a **compositional layout** collection view.  
Theme can be forced to **Light/Dark/System** via a floating pills bar.

> iOS **TODO: version** · Xcode **TODO** · Swift **5.9+**  
> Minimum iPhone target: **TODO** (e.g., iOS 16)

---

## ✨ Features

- **Photo Scanner**
  - Requests photo library permissions and streams progress while indexing.
  - Groups photos into logical buckets (`PhotoGroup`), plus a catch-all **Others**.
- **Live Progress Header**
  - Pinned supplementary view that shows `processed / total` and percent.
- **Floating Controls**
  - **Rescan**, **Sort A–Z**, and **Theme** pills sit at top (blurred, rounded).
  - Theme options: **System / Light / Dark** with checkmark state.
- **Hybrid UI**
  - UIKit `UICollectionViewController` host.
  - SwiftUI `GroupDetailView` for per-group details (pushed via `UIHostingController`).
- **Reactive Pipeline**
  - `ScannerViewModel` exposes `groupsPublisher`, `othersPublisher`, `progressPublisher` via Combine.
- **Modern Layout**
  - Compositional layout, estimated cell heights, pinned header, safe-area aware.

---

## 🧱 Architecture

- **MVVM (+C flavor)**
  - `ScannerViewModel` handles permissions + scanning + publishers.
  - `HomeViewController` binds to publishers and renders the grid.
  - `GroupDetailView` (SwiftUI) shows per-group contents.
- **UIKit + SwiftUI Interop**
  - SwiftUI screens presented with `UIHostingController`.
- **Combine**
  - Publishers drive UI updates on main thread.
- **Appearance / Theming**
  - `AppearanceManager` holds `AppAppearance` (`.system/.light/.dark`) and applies to window.

> Key types you’ll see:
>
> - `HomeViewController`: collection grid + pinned progress header
> - `GroupCell`: card-style cell with title and count
> - `ProgressHeaderView`: sticky header with progress UI
> - `FloatingPillsBarView`: top floating bar for Rescan / Sort / Theme
> - `ScannerViewModel`: Combine outputs for groups, others, progress
> - `PhotoGroup`: enum of grouping buckets

---

## 📁 Project Structure (suggested)

Codeway-iOSApp/
├─ App/
│ ├─ AppDelegate.swift
│ └─ SceneDelegate.swift
├─ Modules/
│ ├─ Home/
│ │ ├─ HomeViewController.swift
│ │ ├─ GroupCell.swift
│ │ ├─ ProgressHeaderView.swift
│ │ └─ FloatingPillsBarView.swift
│ ├─ Detail/
│ │ └─ GroupDetailView.swift // SwiftUI
│ └─ Scanner/
│ ├─ ScannerViewModel.swift
│ └─ Models/
│ ├─ PhotoGroup.swift
│ └─ …
├─ Shared/
│ ├─ Appearance/
│ │ ├─ AppearanceManager.swift
│ │ └─ AppAppearance.swift
│ └─ UI/
│ └─ Colors+Typography.swift
├─ Resources/
│ ├─ Assets.xcassets
│ └─ Localizable.strings
├─ Tests/
│ └─ …
└─ README.md


---

## 🛠 Requirements

- **Xcode**: TODO (e.g., 15.4+)
- **Swift**: 5.9+
- **iOS**: TODO (e.g., 16.0+)
- **Package Manager**: Swift Package Manager (SPM)

No third-party dependencies required for core features.

---

## 🚀 Getting Started

1. **Clone**
   ```bash
   git clone https://github.com/ocobanoglu18/codeway-iOSApp.git
   cd codeway-iOSApp
Open & Build

Open Codeway-iOSApp.xcodeproj (or the workspace if you use one).

Select an iPhone simulator.

Build & Run.

First Launch

Grant Photo Library access when prompted.

