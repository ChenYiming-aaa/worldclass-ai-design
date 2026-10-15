#!/usr/bin/env bash
# 生成一长串随机字母数字，作为设计方向的外部变化源。
#
# 为什么需要它：LLM 无法内在地随机——它只能预测最可能的 token。
# 写 "make it totally random" 只会得到"听起来随机"的输出（同一配色、同一结构）。
# 随机性必须从模型外部带进来。
#
# 用法： bash seed-string.sh [长度]     （默认 64，最小 16）

set -euo pipefail

LEN="${1:-64}"

if [[ ! "$LEN" =~ ^[0-9]+$ ]] || (( LEN < 16 )); then
  echo "长度必须是 >= 16 的整数" >&2
  exit 1
fi

# 从随机字节流中筛出字母数字，直到凑够长度。
# 注意：先限定读取字节数再交给 tr，避免 head 提前关闭管道导致 tr 收到 SIGPIPE。
collect() {
  local out="" chunk
  while (( ${#out} < LEN )); do
    chunk=$(head -c "$((LEN * 8))" /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9')
    out+="$chunk"
    # 极端情况下 /dev/urandom 不可用会返回空，防止死循环
    if [[ -z "$chunk" ]]; then
      return 1
    fi
  done
  printf '%s\n' "${out:0:LEN}"
}

if [[ -r /dev/urandom ]] && collect; then
  exit 0
fi

if command -v openssl >/dev/null 2>&1; then
  openssl rand -base64 "$((LEN * 4))" | LC_ALL=C tr -dc 'a-zA-Z0-9' | head -c "$LEN" && echo
  exit 0
fi

if command -v python3 >/dev/null 2>&1; then
  python3 -c "import random,string;print(''.join(random.choice(string.ascii_letters+string.digits) for _ in range($LEN)))"
  exit 0
fi

echo "找不到可用的随机源（/dev/urandom、openssl、python3 均不可用）" >&2
echo "Windows PowerShell 替代方案：" >&2
echo "  -join ((48..57 + 65..90 + 97..122) | Get-Random -Count $LEN | ForEach-Object { [char]\$_ })" >&2
exit 1
