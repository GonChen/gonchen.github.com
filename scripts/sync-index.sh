#!/bin/bash
# sync-index.sh - 自动扫描文章并更新首页 feature、sidebar、归档页
set -e

cd "$(dirname "$0")/.."
DOCS_DIR="docs"

# 临时文件
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# 步骤1: 扫描所有文章 .md 文件（排除索引/配置页）
POSTS=()
while IFS= read -r f; do
  POSTS+=("$f")
done < <(find "$DOCS_DIR" -name '*.md' \
  ! -name 'index.md' \
  ! -name 'about.md' \
  ! -name 'tags.md' \
  ! -name 'archives.md' \
  ! -path '*/node_modules/*' \
  ! -path '*/.vitepress/*' \
  | sort -r)

if [ ${#POSTS[@]} -eq 0 ]; then
  echo "No posts found."
  exit 1
fi

echo "Found ${#POSTS[@]} posts."

# 步骤2: 解析 frontmatter，输出到临时文件
# 格式: date|title|details|link|year
POST_DATA="$TMP_DIR/posts.txt"
> "$POST_DATA"

for post in "${POSTS[@]}"; do
  raw=$(cat "$post")

  # 提取 frontmatter (--- 之间的内容)
  fm=$(echo "$raw" | sed -n '/^---$/,/^---$/p' | sed '1d;$d')

  title=$(echo "$fm" | grep -oP '^title:\s*\K(.*)' | sed "s/^['\"]//;s/['\"]$//;s/^\"//;s/\"$//")
  date=$(echo "$fm" | grep -oP '^date:\s*\K(.*)' | sed "s/^['\"]//;s/['\"]$//")
  year="${date:0:4}"

  # 提取摘要
  body=$(echo "$raw" | sed '/^---$/,/^---$/d')

  if echo "$body" | grep -q '<!-- more -->'; then
    # 有 <!-- more -->: 截取之前的内容
    details=$(echo "$body" | sed -n '/^<!-- more -->/q;p')
  else
    # 没有 <!-- more -->: 取全文
    details="$body"
  fi

  # 提取第一段有意义的正文（跳过空行、blockquote、表格、分隔线、标题、元数据行）
  details=$(echo "$details" | grep -v '^$' | grep -v '^<!--' | grep -v '^>' | grep -v '^|---' | grep -v '^---$' | head -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  # 如果第一行是 # 标题，跳过它，取正文中第一个非空行
  if echo "$details" | grep -q '^#'; then
    # 优先取 "**内容:**" 行
    details=$(echo "$body" | grep '^\*\*内容' | head -1 | sed 's/^\*\*内容:\*\{0,2\}[[:space:]]*"\{0,1\}//;s/"\{0,1\}$//')
    # 否则取第一个非标题非空行
    if [ -z "$details" ]; then
      details=$(echo "$body" | grep -v '^$' | grep -v '^<!--' | grep -v '^>' | grep -v '^#' | grep -v '^---$' | grep -v '^\*\*.*@' | grep -v '^\*\*链接' | grep -v '^\*\*日期' | grep -v '^\*\*Benchmark' | grep -v '^\*\*Engagement' | grep -v '^\*\*内容' | head -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    fi
  fi

  # 如果还是空，用 frontmatter 后的第一行非空行
  if [ -z "$details" ]; then
    details=$(echo "$body" | grep -v '^$' | grep -v '^>' | head -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  fi

  # 从文件路径计算相对链接: docs/2026/06/02/xxx.md -> /2026/06/02/xxx
  relative="${post#$DOCS_DIR/}"
  link="/${relative%.md}"

  if [ -z "$title" ] || [ -z "$date" ]; then
    echo "  Skip (missing title/date): $post"
    continue
  fi

  if [ -z "$details" ]; then
    details="阅读全文"
  fi

  # 确保 details 在 YAML 中安全（用双引号包裹，转义内部双引号和反斜杠）
  details_escaped=$(echo "$details" | sed 's/\\/\\\\/g; s/"/\\"/g')

  echo "$date|$title|$details_escaped|$link|$year" >> "$POST_DATA"
done

# 按日期降序排列，同一天按文件名排序
sort -t'|' -k1 -r -k2 "$POST_DATA" -o "$POST_DATA"

echo ""
echo "=== Posts ==="
cat "$POST_DATA"

# ============================================================
# 步骤3: 更新 docs/index.md (features 列表, 最多6条)
# ============================================================
echo ""
echo "--- Updating index.md ---"

INDEX_FILE="$DOCS_DIR/index.md"

# 生成新的 features YAML
FEATURES_HEADER="features:"
FEATURES_BODY=""

mapfile -t lines < "$POST_DATA"
count=0
for line in "${lines[@]}"; do
  IFS='|' read -r date title details link year <<< "$line"
  FEATURES_BODY+="  - title: \"$title\"\n    details: \"$details\"\n    link: $link\n"
  count=$((count + 1))
  [ "$count" -ge 6 ] && break
done

# 构建新 index.md: 保留 features: 之前的内容
head -n -1 "$INDEX_FILE" | sed -n '1,/^features:/p' | head -n -1 > "$TMP_DIR/index_head.txt"
# 找到文件末尾（有时文件末尾可能有空行或额外内容）
> "$TMP_DIR/index_new.txt"
cat "$TMP_DIR/index_head.txt" > "$TMP_DIR/index_new.txt"
echo -e "$FEATURES_HEADER" >> "$TMP_DIR/index_new.txt"
echo -e "$FEATURES_BODY" >> "$TMP_DIR/index_new.txt"

cp "$TMP_DIR/index_new.txt" "$INDEX_FILE"
echo "  Updated features ($count entries)"

# ============================================================
# 步骤4: 更新 docs/.vitepress/config.mjs (sidebar)
# ============================================================
echo ""
echo "--- Updating config.mjs ---"

CONFIG_FILE="$DOCS_DIR/.vitepress/config.mjs"

SIDEBAR_ITEMS=""
SIDEBAR_ITEMS+="          { text: 'Index', link: '/' },\n"
for line in "${lines[@]}"; do
  IFS='|' read -r date title details link year <<< "$line"
  SIDEBAR_ITEMS+="          { text: '$title', link: '$link' },\n"
done

# 用 awk 找到 sidebar items 数组并替换
awk -v new_items="$SIDEBAR_ITEMS" '
  /^\s+sidebar:\s*\[/ { in_sidebar=1 }
  in_sidebar && /items:\s*\[/ { in_items=1; print; next }
  in_items && /\]/ {
    # items 数组结束
    printf "%s", new_items
    in_items=0
    print
    next
  }
  in_items { next }  # 跳过旧的 items 内容
  { print }
' "$CONFIG_FILE" > "$TMP_DIR/config_new.mjs"

cp "$TMP_DIR/config_new.mjs" "$CONFIG_FILE"
echo "  Updated sidebar ($((${#lines[@]} + 1)) entries)"

# ============================================================
# 步骤5: 更新 docs/archives.md (归档列表)
# ============================================================
echo ""
echo "--- Updating archives.md ---"

ARCHIVE_FILE="$DOCS_DIR/archives.md"

# 保留归档页头部（--- title: 归档 --- 和 # 📚 归档）
> "$TMP_DIR/archive_new.md"
echo "---" >> "$TMP_DIR/archive_new.md"
echo "title: 归档" >> "$TMP_DIR/archive_new.md"
echo "---" >> "$TMP_DIR/archive_new.md"
echo "" >> "$TMP_DIR/archive_new.md"
echo "# 📚 归档" >> "$TMP_DIR/archive_new.md"
echo "" >> "$TMP_DIR/archive_new.md"

# 按年份分组
prev_year=""
for line in "${lines[@]}"; do
  IFS='|' read -r date title details link year <<< "$line"
  if [ "$year" != "$prev_year" ]; then
    echo "" >> "$TMP_DIR/archive_new.md"
    echo "## $year" >> "$TMP_DIR/archive_new.md"
    echo "" >> "$TMP_DIR/archive_new.md"
    prev_year="$year"
  fi
  echo "- [$title](${link#/}) — *$date*" >> "$TMP_DIR/archive_new.md"
  # 获取这篇文章的 tags
  fm=$(sed -n '/^---$/,/^---$/p' "${DOCS_DIR}/${link}.md" | sed '1d;$d')
  tags_str=""
  if echo "$fm" | grep -qP '^tags:\s*\['; then
    tags_str=$(echo "$fm" | grep -oP "'[^']+'" | sed "s/'//g" | tr '\n' '|')
    tags_str="${tags_str%|}"
  elif echo "$fm" | grep -q '^tags:'; then
    tags_str=$(awk '/^tags:/,/^[a-zA-Z]/' "${DOCS_DIR}/${link}.md" | grep '^- ' | sed 's/^- *//' | tr '\n' '|')
    tags_str="${tags_str%|}"
  fi
  if [ -n "$tags_str" ]; then
    tag_links=""
    IFS='|' read -ra tag_arr <<< "$tags_str"
    for t in "${tag_arr[@]}"; do
      encoded_t=$(echo "$t" | sed 's/ /%20/g')
      tag_links+="[<Badge type=\"tip\" text=\"$t\" />](</archives.html#tag-$encoded_t>) "
    done
    echo "  $tag_links" >> "$TMP_DIR/archive_new.md"
  fi
done

cp "$TMP_DIR/archive_new.md" "$ARCHIVE_FILE"
echo "  Updated archives ($((${#lines[@]})) entries)"

echo ""
echo "Done! All indexes synced."