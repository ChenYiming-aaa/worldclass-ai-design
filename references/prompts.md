# 原文提示词库

英文部分为原文 verbatim，中文为对照说明。

> **不要把英文 verbatim 提示词翻译成中文后再发给执行 Agent / Critic。**
> 独特设计的先验分布主要锚定在英文语料里，翻译会偏移检索路径，模型更容易滑回安全模板。
> 需要中文产出时，保留英文风格指令，只在末尾追加中文文案与排版要求——见 `SKILL.md` 的「语言策略」。

---

## 技术 1 · 随机种子字符串（String Seed of Thought）

来源：Sakana AI 的 String Seed of Thought（https://pub.sakana.ai/ssot/ ）。原研究让模型在内部生成并操作随机串；作者改为**由 shell 提供外部随机串**，这是本 skill 采用的形式。

### 反例 A：默认 prompt

```
Build me a landing page for my productivity app.
```

四个实例的结果几乎一致：紫调渐变、文字在左、图形在右、顶部导航。作者评价："It looks like every AI-designed website ever."

### 反例 B：只在语言里要求随机（**这是最容易被误用的写法**）

```
Build me a landing page for my productivity app. Give me something totally unique.
Make every design decision completely at random.
```

结果仍不变，甚至反复出现同样的 awkward pottery metaphors。原因：**模型无法内在地随机，它只能预测最可能的 token。要多样性，必须从模型外部带进来。**

### 正解

```
I want you to build me a landing page for my productivity app.

Follow this procedure:

1. Generate a long, random alphanumeric string using a shell script.
2. Define the creative direction (color scheme, layout, typography, etc.) based on the
   string. Look beyond the surface for subpatterns, special numbers, anything that
   inspires you.
3. Use your judgment to bring this direction to life and make it look great.

Don't reveal the string in the design. It's only for your inspiration.
```

### 生成种子的命令

```bash
# macOS / Linux / Git Bash（首选）
LC_ALL=C tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 64; echo

# 备选
openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c 64; echo
```

Windows PowerShell（无 /dev/urandom 时）：

```powershell
-join ((48..57 + 65..90 + 97..122) | Get-Random -Count 64 | ForEach-Object { [char]$_ })
```

本 skill 也提供 `scripts/seed-string.sh`。

### 注意事项

- 字符串要**长**，太短提供的变化有限。
- 必须从字符串里**超越表面**地找结构：子模式、重复片段、特殊数字、字符形状、比例关系。
- **绝不在设计中泄露字符串**，它只是灵感源。
- 第 3 步必须保留"用你的判断把它做好看"，否则模型会把随机性理解成可以不好看。

---

## 技术 2 · 大胆的简报

### 三个原文示例

```
Build me a landing page for my productivity app, with a bold pixel art theme and
stunning graphics. Each section should feel like a still from a video game, yet
somehow it should all function as a landing page.
```

```
Build me a landing page for my productivity app, set in an isometric living 3D city,
where different features are somehow represented by neighborhoods or buildings.
```

```
Build me a landing page for my productivity app, with a radically asymmetric layout,
dissonant colors and typography, and uncomfortable negative space. Break all the rules
but still make it look good.
```

共同点：给出一个**足以统领整页每个决策的世界**，而不是形容词。
判断标准：如果你觉得 "There's no way this will work"，你就在正确的轨道上。

### 三步品味提取

**第 1 步 —— 只列方向，不展开。** 目标是刺激你的想象力，不是要完整方案。

```
I want to come up with a bold, unique design language for my product. Can you list as
many ideas as you can, with short, high-level descriptions? Go broad, not deep.
```

**第 2 步 —— 记录你的反应，让 AI 据此细化。**

```
Industrial Control Panel:

- I'm imagining something tactile. Clicky, satisfying buttons, nice sounds.
- Initially I pictured something cartoony or skeuomorphic, but this feels tacky to me.
  Avoid that.
- Instead, want consistent components and little touches that land this look without
  going overboard.
- Gray gradients would look boring. Need more texture. Maybe we can incorporate some
  color, while retaining the control panel feel?

Can you sharpen this one based on my tastes?
```

**第 3 步 —— 反写成构建 prompt。**

```
Can you write a concise prompt that an AI agent could use to build an initial POC page
with this?
```

### 关键警告

**不要把 AI 生成的 idea 直接粘回 AI。** 那样你拿不到独特的东西——任何人都能这么做。只有当你主动引导设计方向（actively steer the design direction）时，才会产出只有你能做出的东西。

**保存失败的 prompt**，新模型发布后再测一遍。这是唯一能确保你在充分利用最新模型能力的方法。

---

## 技术 3 · 独立评审子代理

```
I want you to improve this design. To figure out what to focus on, use a Fable 5
subagent as a design critic.

Follow this procedure at each iteration:

- Capture a screenshot of the current design
- Invoke the critic in a fresh context, with just the screenshot, not the code,
  implementation details, or earlier iterations/critiques
- Ask it to evaluate the aesthetic that the design is going to for, imagine how a top
  design studio would execute this aesthetic, then outline the biggest gaps
- Lastly, it should provide a score out of 10 indicating how close the current design
  is to that studio-level quality bar

Provide this guidance to the critic in its prompt:

- It should think high-level about the overall structure and composition as well as
  look at the fine details
- It should watch out for patterns that feel overdone, excessive, or otherwise
  obviously AI-generated, and penalize them
- It should provide tight, specific feedback, not vague prose
- It should be bold and opinionated, not rely on what's safe or easy

Your work is only complete when the critic independently deems it 9/10 or higher. Do
not put that criterion in the critic prompt; keep it objective in its scoring. Use the
same critic prompt each time.
```

（注：`Fable 5` 是作者所用环境的模型名，替换为你环境中能力最强的模型。）

### 评审标准的三档

| 档位 | 写法 | 问题 |
|---|---|---|
| Bad | `Judge if our design looks beautiful, not AI-generated.` | 太主观，每次运行结果漂移极大 |
| OK | `Review the aesthetic we're going for, visualize how a top design studio would execute it, then judge our design's quality against that bar.` | 仍含糊，但提供了一致框架与质量门槛 |
| Great | `Here are 5 designs: 4 professional examples and 1 screenshot of our product. Rank them by polish and taste level.` | 具体、客观，给出视觉判断基线 |

参考图要被当作 **baseline / moodboard，而不是 target**，否则评审会照抄。

---

## 技术 4 · 图像生成

```
The design is pretty plain. Add more personality using image generation. Consider
shaders or 3D effects in combination with images to create more interesting visuals.

For image generation, use this OpenAI API key (only use it locally, do not store it in
the code or product): sk-a1b2c3d4…

Verify that your work looks right frame-by-frame in the browser.
```

---

## 技术 5 · 视频生成

### 用法 A：循环动画图形

```
Can you replace the image on this page with a looping video clip that does something
more interesting? Have the crystal splinter apart and slowly spin around. It should
have awesome glassy effects that refract the page background and cast shadows and
light around it.

To get convincing glass refraction effects, render the video of the glass over the page
background colors first (so it bakes in the refraction effects), then remove the
background with a video matting model.

Use this fal.ai API key: sk-a1b2c3d4…

Find appropriate recent models for video generation and background removal.
```

### 用法 B：状态间流体过渡

```
Build a demo page for a suitcase that uses a video model to create interactive
transitions between a couple of screens. Each screen should show the suitcase in a
different state, with vertical motion that feels appropriate for scrolling:

- Initially, have the suitcase floating high up in the air
- Then have it land on the floor and pop open
- Finally, have its contents neatly land into it from the top

Generate the initial frame using your image generation skill. Then, generate a video
clip that starts from that frame and animates to the next state. Use the final frame of
that video to seed the next transition so that it continues seamlessly. Scrub through
the transitions one by one as the user scrolls.

Use this fal.ai API key: sk-a1b2c3d4…

Use a video model with strong physics and consistency, like Seedance 2.5.
```

（注：`Seedance 2.5` 是作者当时对模型的建议，会过时——让 Agent 自行评估当前可用模型。）

---

## 技术 6 · 减法

原文未给出单独的通用 prompt，给出的是对卡路里应用的具体指令：

```
Simplify the layout into an image-centric grid
Get rid of gradients, glows, and unnecessary containers
Aim for a truly minimalist aesthetic that feels Apple-native
```

可泛化为：

```
Cut every element that does not add information, an action, or a state.
- Simplify the layout so the [main object] is the focus
- Get rid of gradients, glows, extra labels, and unnecessary containers
- Prefer native platform components over custom ones that look worse
- Tighten type, spacing, and copy
For each leftover element, tell me what happens if we delete it. If the answer is
nothing, delete it.
```

---

## 技术 7 · 清理 AI 痕迹

原文正文在付费墙后，无 verbatim 提示词。可用提示词见 `references/ai-tells.md`。
