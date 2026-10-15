# 减法与清理 AI 痕迹（技术 6、7）

> **保真度声明**：技术 6「Cut out elements that don't add value」来自原文公开正文，本节忠实还原。
> 技术 7「Remove AI tells」的**正文位于付费墙后**，原文未公开其清单与提示词。
> 下文标记为 **[原文确认]** 的条目来自文章其他章节明确点名；标记为 **[重建]** 的条目是基于这些线索与公开二手资料整理的保守补充，**不是作者原文**。

---

## 技术 6：删掉不增加价值的元素

### 原理

- AI 喜欢做加法，很少做减法。
- 设计是 AI 生成的最大标志之一：**过度解释一切，或包含没有任何实用目的的元素**。
- 相反，懂得克制（exercises restraint）的设计立刻显得高级、有品味。
- 关键警告：**"Today's AI models would never think to make these choices on their own. Remember, AI doesn't like to take risks, and it's risky to strip down a design and delete code. The model needs a push from you."**
- 通篇检查，问什么才是真正必须存在的。**"Often, putting less on the screen communicates more, because you can hold your users' attention without overwhelming them with clutter."**

### 删除测试（对每个元素问四个问题）

删掉后，用户是否失去：

1. **关键信息**？
2. **操作入口**？
3. **当前状态 / 下一步的理解**？
4. **本设计方向最有辨识度的部分**？

四个答案都是否 → **删掉通常比继续美化更有效。**

### 卡路里应用案例（原文的正面 / 反面教材）

初稿已经要求了 "clean, minimalist design"，结果仍包含一堆不增加价值的东西：

- **[原文确认]** 背景与进度条上的粉色 glow 效果
- **[原文确认]** 文字上的随机颜色与高亮
- **[原文确认]** 展示一天所有食物时的多余标签与空白（图片已经表达了同样的信息）
- **[原文确认]** 比 iOS 原生组件更差的自定义按钮与输入框

修正指令（三组）：

```
Simplify the layout into an image-centric grid
Get rid of gradients, glows, and unnecessary containers
Aim for a truly minimalist aesthetic that feels Apple-native
```

结果：有主张（opinionated）、让视觉自己说话、用原生 iOS 组件、多余颜色与渐变消失、文字更小更简单更紧凑。作者评价："This is good design."

---

## 技术 7：清理 AI 痕迹

### 已由原文其他章节点名的视觉痕迹 **[原文确认]**

1. **Gradients** —— 编码 Agent 的默认替代方案
2. **Shapes 与 basic patterns** —— 同上；作者称这些是 "strong giveaways"
3. **Glow / 光晕** —— 卡路里应用案例中被明确点名删除
4. **文字上的随机颜色与高亮**
5. **重复 / 多余的标签**（信息已被其他元素表达时）
6. **比原生组件更差的自定义按钮与输入框**
7. **Overdone / excessive 的模式** —— Critic prompt 中被要求显式惩罚
8. **过度解释**（overexplains everything）
9. 骨架层面：**顶部导航 + 左文右图 + 下方 CTA** 的默认三段式

### 补充清单 **[重建，非作者原文]**

以下条目来自公开二手资料对同类问题的整理，用于把"去痕迹"变成可执行的两遍扫描。使用时请自行判断适配性。

**视觉一遍**：
- 紫 / 靛 → 蓝渐变（"紫色渐变家族"）
- 全站默认 Inter / Geist / Roboto
- 渐变文字
- 标题上方的药丸徽章（"Introducing"、"New"）
- 区块背后的发光光晕与柔光聚光
- 玻璃拟态：模糊、玻璃卡片、发光描边（除非真的解决了层级问题）
- 每个标题上方"圆角方块里的图标"
- 一模一样的卡片网格 / 三栏特性行
- 卡片套卡片；卡片侧面粗色条
- 无上下文的大数字（"10M+ users"）
- 无实际序列含义的编号标签（01 / 02 / 03）
- 脉冲圆点、弹跳缓动、hover 缩放、自动滚动的 logo 条
- 米色 / 奶油色 + 超大斜体衬线标题

**文案一遍**：
- "It's not X. It's Y." 句式
- 清嗓子式开场（throat-clearing openers）
- 假深度动词、空泛营销词（supercharge、world-class）
- 句子节奏过于整齐一致
- 关键位置（H1、主按钮、空状态、错误态）由模型顺手生成的套话

### 可用的扫描提示词 **[重建]**

```
Audit this design for AI tells. Run visual and copy passes separately so I can see
what each one changed.

Visual: purple gradients, glow, glassmorphism, three identical feature cards,
text-left/graphic-right default skeleton, too many fonts, no white space, custom
buttons that look worse than native ones.

Copy: flag "it's not X, it's Y" constructions, throat-clearing openers, generic
marketing verbs, and perfectly even sentence rhythm.

Keep my meaning, jokes, and specific facts. Do not make every sentence the same length.
List each tell, where it is, and the smallest fix. Then apply the fixes.
```

---

## 最后一关：关键文案人工重写

模型不会主动跳过这步，**如果你让它写，它就会写**。

四处必须人工重写，念出声检验：

1. H1
2. 主按钮
3. 空状态
4. 错误态

规则：**如果你不会端着咖啡对客户这么说，它就不该出现在页面上。**

---

## 执行顺序建议

1. **先做减法**（技术 6）——删掉装饰，页面结构会变清楚
2. **再跑视觉痕迹扫描**——在精简后的结构上找破绽
3. **最后跑文案痕迹扫描**——此时需处理的文本量最小
4. **人工重写四处关键文案**

顺序颠倒会导致你在即将被删除的元素上浪费去痕迹的功夫。
