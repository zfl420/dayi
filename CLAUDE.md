# 大姨 - 项目开发规范

## UI 设计规范

### 响应式设计原则

**重要：所有UI尺寸必须使用屏幕比例，而非固定像素值**

#### 设计基准
- **基准设备**：iPhone 17
- **设计流程**：用户提供基于 iPhone 17 的固定像素值 → 开发时转换为屏幕比例

#### 转换规则

1. **间距/尺寸转换**
   - 用户提供固定值时，需转换为屏幕高度/宽度的比例
   - 使用 GeometryReader 获取实际屏幕尺寸
   - 公式：`geometry.size.height * (固定值 / iPhone17屏幕高度)`

   示例：
   ```swift
   // ❌ 错误：固定值
   .padding(.top, 110)

   // ✅ 正确：屏幕比例
   GeometryReader { geometry in
       .padding(.top, geometry.size.height * 0.13)
   }
   ```

2. **字号转换**
   - 字号也应基于屏幕尺寸动态计算
   - 公式：`UIScreen.main.bounds.height * (字号 / iPhone17屏幕高度)`

   示例：
   ```swift
   // ❌ 错误：固定字号
   .font(.system(size: 14, weight: .bold))

   // ✅ 正确：动态字号
   .font(.system(size: UIScreen.main.bounds.height * 0.017, weight: .bold))
   ```

3. **iPhone 17 规格参考**
   - 屏幕高度：852 pt (逻辑像素)
   - 屏幕宽度：393 pt (逻辑像素)

#### 实施要求
- 所有新增的UI组件必须使用比例值
- 现有固定值需逐步重构为比例值
- 确保在不同设备上保持一致的视觉比例

---

## 开发注意事项
- 使用中文进行所有交流和注释
- 保持代码整洁，组件化设计
