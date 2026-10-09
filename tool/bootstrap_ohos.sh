#!/usr/bin/env bash
# ==============================================================================
# TailLimit 鸿蒙端（HarmonyOS / OpenHarmony）工程初始化脚本
# ==============================================================================
#
# 背景：官方 Flutter SDK 不包含 ohos 平台目录，必须使用 OpenHarmony SIG 维护的
#       Flutter-OH（分支 3.35.x+）。本脚本负责：
#         1. 检查 Flutter-OH 环境是否就绪
#         2. 生成 ohos/ 平台目录
#         3. 提示需要手动合并的权限声明
#
# 前置条件：
#   - Flutter-OH SDK（atomgit.com/openharmony-tpc/flutter_flutter，分支 3.35.x+）
#   - DevEco Studio 4.1+ 与 HarmonyOS SDK（API 11+）
#   - hvigor 构建工具（随 DevEco Studio 安装）
#
# 用法：
#   ./tool/bootstrap_ohos.sh                # 生成 ohos 工程
#   ./tool/bootstrap_ohos.sh --check        # 仅检查环境
#   ./tool/bootstrap_ohos.sh --clean        # 清理已生成的 ohos 目录
# ==============================================================================

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[ OK ]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_err()   { echo -e "${RED}[FAIL]${NC} $1"; }

# ------------------------------------------------------------------------------
# 环境检查
# ------------------------------------------------------------------------------
check_env() {
  log_info "检查 Flutter-OH 环境..."

  if ! command -v flutter >/dev/null 2>&1; then
    log_err "未找到 flutter 命令。请将 Flutter-OH SDK 的 bin 目录加入 PATH。"
    exit 1
  fi

  local flutter_path
  flutter_path="$(command -v flutter)"
  log_info "flutter 路径：$flutter_path"

  # 判定是否为 Flutter-OH：检查是否支持 ohos 子命令
  if flutter create --help 2>/dev/null | grep -q "ohos"; then
    log_ok "检测到 Flutter-OH（支持 ohos 平台）"
  else
    log_err "当前 Flutter SDK 不支持 ohos 平台。"
    echo ""
    echo "  请改用 Flutter-OH（OpenHarmony SIG 维护版）："
    echo "    git clone -b 3.35.x https://atomgit.com/openharmony-tpc/flutter_flutter.git"
    echo "    export PATH=<flutter_flutter>/bin:\$PATH"
    echo ""
    echo "  详见 docs/build-ohos.md"
    exit 1
  fi

  # 检查 HarmonyOS SDK 环境变量
  if [ -z "${DEVECO_SDK_HOME:-}" ] && [ -z "${OHOS_SDK_HOME:-}" ]; then
    log_warn "未设置 DEVECO_SDK_HOME / OHOS_SDK_HOME 环境变量"
    log_warn "构建时 hvigor 将无法定位 HarmonyOS SDK，请确保已安装 DevEco Studio"
  else
    log_ok "HarmonyOS SDK：${DEVECO_SDK_HOME:-${OHOS_SDK_HOME:-}}"
  fi
}

# ------------------------------------------------------------------------------
# 清理
# ------------------------------------------------------------------------------
clean_ohos() {
  if [ -d "$PROJECT_ROOT/ohos" ]; then
    log_info "删除已生成的 ohos/ 目录..."
    rm -rf "$PROJECT_ROOT/ohos"
    log_ok "已清理"
  else
    log_info "ohos/ 目录不存在，无需清理"
  fi
}

# ------------------------------------------------------------------------------
# 生成 ohos 工程
# ------------------------------------------------------------------------------
generate_ohos() {
  if [ -d "$PROJECT_ROOT/ohos" ]; then
    log_warn "ohos/ 目录已存在。如需重新生成，请先执行：$0 --clean"
    exit 0
  fi

  log_info "拉取 Dart 依赖..."
  flutter pub get

  log_info "生成 ohos 平台目录（flutter create --platforms=ohos）..."
  flutter create --platforms=ohos \
    --org com.taillimit \
    --project-name tail_limit \
    .

  if [ ! -d "$PROJECT_ROOT/ohos" ]; then
    log_err "ohos/ 目录生成失败"
    exit 1
  fi
  log_ok "ohos/ 目录已生成"

  apply_permissions
  print_next_steps
}

# ------------------------------------------------------------------------------
# 合并权限声明（引导用户手动操作，脚本仅打印 diff 提示）
# ------------------------------------------------------------------------------
apply_permissions() {
  local host_module="$PROJECT_ROOT/ohos/entry/src/main/module.json5"
  local template="$PROJECT_ROOT/tail_limit_alert_plugin/ohos/module.json5.permissions.template"

  log_info "权限声明检查..."

  if [ ! -f "$host_module" ]; then
    log_warn "未找到 $host_module，跳过权限检查"
    return
  fi

  local missing=()
  for perm in PUBLISH_AGENT_REMINDER NOTIFICATION_CONTROLLER KEEP_BACKGROUND_RUNNING INTERNET; do
    if ! grep -q "$perm" "$host_module" 2>/dev/null; then
      missing+=("ohos.permission.$perm")
    fi
  done

  if [ ${#missing[@]} -eq 0 ]; then
    log_ok "所需权限均已声明"
    return
  fi

  log_warn "以下权限尚未声明，需手动合并到 $host_module ："
  for p in "${missing[@]}"; do
    echo "    - $p"
  done
  echo ""
  echo "  权限片段模板（含 reason 文案）见："
  echo "    $template"
  echo ""
  echo "  合并后请同步在 entry/src/main/resources/base/element/string.json 中"
  echo "  补充 reason 文案（模板文件已列出所需条目）。"
}

print_next_steps() {
  echo ""
  echo "=============================================================================="
  echo "  鸿蒙工程生成完成，后续步骤："
  echo "=============================================================================="
  echo ""
  echo "  1) 合并权限声明"
  echo "     参照 tail_limit_alert_plugin/ohos/module.json5.permissions.template"
  echo "     修改 ohos/entry/src/main/module.json5"
  echo ""
  echo "  2) 用 DevEco Studio 打开 ohos/ 目录，等待 hvigor 同步完成"
  echo ""
  echo "  3) 配置签名（File → Project Structure → Signing Configs → 自动签名）"
  echo ""
  echo "  4) 连接鸿蒙设备或启动模拟器，运行："
  echo "     flutter run -d <device-id>"
  echo "     或"
  echo "     flutter build hap --release"
  echo ""
  echo "  5) 车机形态：在 module.json5 的 deviceTypes 中确认包含 \"car\""
  echo ""
  echo "  详细说明见 docs/build-ohos.md"
  echo "=============================================================================="
}

# ------------------------------------------------------------------------------
# 入口
# ------------------------------------------------------------------------------
main() {
  echo "=============================================================================="
  echo "  TailLimit 鸿蒙端工程初始化"
  echo "=============================================================================="
  echo ""

  case "${1:-}" in
    --check)
      check_env
      log_ok "环境检查完成"
      ;;
    --clean)
      clean_ohos
      ;;
    --help|-h)
      grep '^#' "$0" | sed 's/^# \?//' | head -25
      ;;
    "")
      check_env
      generate_ohos
      ;;
    *)
      log_err "未知参数：$1（可用：--check / --clean / --help）"
      exit 1
      ;;
  esac
}

main "$@"
