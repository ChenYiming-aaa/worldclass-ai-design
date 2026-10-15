# 图像与视频生成（技术 4、5）

## 为什么要显式要求

编码 Agent 喜欢写代码，通常不融入图片。它们倾向使用容易的代码替代方案：**gradients、shapes、basic patterns**。作者明确指出这些是 AI 生成设计的 **strong giveaways（强烈破绽）**。

当所有视觉都来自几行 CSS 时，作品必然暴露相同的生成痕迹。图像 / shader / 3D / 视频承担的是**界面材料**的角色，不是文末装饰。

## 接入方式（按你的工具链选一条）

### Codex / Antigravity / Grok Build

明确要求 Agent 使用其内置图像生成。它本来就会，但**极少主动做，除非你指示**。

### Claude Code（或其他 Agent）+ 有 ChatGPT 订阅

```
Use the Codex CLI to generate images. Help me install it if it isn't already present.
Make sure it's billing my subscription, not an API key.
```

### 只用 Claude 或任何其他工具

给 Agent 一个 OpenAI 或 Gemini API key。

**必须这样做**：

- 创建**独立的** API key，专供 Agent 使用
- 设**严格的消费上限**
- key 泄露或被滥用时成本可控，且可轻松吊销而不影响其他工作

如果需要频繁把 key 粘进对话，改为放进文件并在项目中指向它：

```
Create a gitignored file called .env.agents, store this API key in it, and note to
yourself in AGENTS.md/CLAUDE.md that these keys are for you to use during development
(but must not ship with the product).
```

### 视频生成

作者偏好用聚合平台 **fal.ai**（https://fal.ai ）：给 Agent 一个 API key，让它自行评估不同模型并选最佳，无需多个集成。视频模型迭代很快，别把具体模型名硬编码进长期流程。

## API key 安全红线

1. **仅本地使用**（only use it locally）
2. **不存进代码或产品**（do not store it in the code or product）
3. **不随产品发布**（must not ship with the product）
4. 独立 key + 严格 spend limit + 可随时吊销
5. `.env.agents` 必须 gitignored
6. 在 `AGENTS.md` / `CLAUDE.md` 中显式注明这些 key 仅供开发期使用

## 图像生成

提示词见 `references/prompts.md` 技术 4。

**收尾必做**：`Verify that your work looks right frame-by-frame in the browser.` 逐帧验证，不要只看静态截图。

## 视频生成 · 用法 A：循环动画图形

流程：

1. 生成**纯色背景**的循环片段
2. 用 chroma key（绿幕式抠像）或 video matting model 去背
3. 叠加到 UI 任意位置——它看起来像动画，不像视频

**玻璃折射的关键技巧**：先把玻璃视频渲染在**页面背景色**上（把折射效果烘进去 / bake in），再用 matting model 去背。否则折射的是纯色背景，叠加后穿帮。

能达到代码做不出的效果：interesting caustic reflections、glassy refraction、complex physical motion。

## 视频生成 · 用法 B：状态间流体过渡

1. 用图像生成技能生成**初始帧**
2. 生成从该帧动画到下一状态的视频片段
3. **用上一段视频的最后一帧作为下一段过渡的种子**，保证无缝
4. 把视频进度映射到滚动 / 手势，逐段 scrubbing

选物理性与一致性强的模型。（作者当时用 Seedance 2.5，会过时——让 Agent 找最新的。）

## 验证与降级（不要省）

| 检查项 | 通过条件 |
|---|---|
| 循环接缝 | 无明显跳变 |
| 首尾状态 | 连续 |
| 滚动方向 | 与物体运动方向一致 |
| 静态 / reduced-motion | 关闭自动播放后用户仍能理解页面 |
| 首屏性能 | 媒体体积与解码成本未破坏体验 |
| 降级 | 每张动效都准备了首帧 / 海报图作为静止替代 |

**可检查产物**：动效文件、静止替代帧、触发条件、交互映射。
**验收标准**：删除一张生成图 / 一段视频后，如果信息与体验没有损失，它很可能只是装饰 → 删；如果所有生成图都能被普通渐变替代，说明视觉方向还没做深。
