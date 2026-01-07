# Repository Guidelines

## 项目结构与模块组织
- `Dayi/Dayi` 为主工程源码，包含 `Views/`（页面与组件）、`ViewModels/`（状态与业务逻辑）、`Models/`（数据模型）、`Extensions/`（类型扩展）。
- 资源文件位于 `Dayi/Dayi/Assets.xcassets`，App 图标在 `AppIcon.appiconset`。
- Xcode 项目配置在 `Dayi/Dayi.xcodeproj`。

## 构建、测试与开发命令
- 使用 Xcode 打开 `Dayi/Dayi.xcodeproj` 运行与调试。
- 本仓库未提供命令行构建或测试脚本；如需 CLI，可手动执行 `xcodebuild`（仅在你明确要求时）。

## 编码风格与命名约定
- 语言：Swift + SwiftUI。
- 缩进：4 空格；保持与现有文件一致。
- 类型与文件名使用 `UpperCamelCase`（如 `PeriodViewModel.swift`），属性/方法使用 `lowerCamelCase`。
- UI 布局遵循项目内响应式规则（参见 `响应式布局转换说明.md`）。
- 注释需解释用途，不写计算公式或像素值（参见 `CLAUDE.md`）。

## 测试指南
- 当前未发现单元测试目录与测试框架配置。
- 如需新增测试，建议使用 `XCTest`，并在 `DayiTests/` 约定目录下创建测试文件（示例：`PeriodViewModelTests.swift`）。

## 提交与 PR 规范
- 提交信息采用简短前缀风格，如 `chore:`、`refactor:`，后接简洁描述（示例：`chore: 发布前自动提交`）。
- 若提交影响 UI，请在 PR/说明中附上截图或录屏；描述中应包含变更动机、影响范围与验证方式。

## 其他说明
- 本项目强调 iOS 原生实现优先与变更确认流程，具体规则见 `CLAUDE.md`。
