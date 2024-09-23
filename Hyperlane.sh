#!/bin/bash

# 显示 Logo
curl -s https://raw.githubusercontent.com/sdohuajia/Hyperlane/refs/heads/main/logo.sh | bash
sleep 3

# 定义显示函数
show() {
    echo -e "\033[1;35m$1\033[0m"
}

# 加载 NVM（Node 版本管理器）
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    show "正在加载 NVM..."
    source "$NVM_DIR/nvm.sh"
else
    show "NVM 未找到，正在安装 NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
    source "$NVM_DIR/nvm.sh"
fi

# 检查是否安装了 Node.js
if ! command -v node &> /dev/null; then
    show "Node.js 未找到。正在安装 Node.js..."
    nvm install node
else
    show "Node.js 已经安装。"
fi

# 检查是否全局安装了 Hyperlane CLI
if ! command -v hyperlane &> /dev/null; then
    show "Hyperlane CLI 未找到。正在安装..."
    npm install -g @hyperlane-xyz/cli
else
    show "Hyperlane CLI 已经安装。"
fi
echo

# 提示用户输入私钥
read -p "请输入你的私钥: " PVT_KEY
read -p "请输入上述私钥对应的钱包地址: " WALLET

# 导出私钥
export HYP_KEY="$PVT_KEY"

# 如果 configs 目录不存在，则创建
mkdir -p ./configs

# 创建 warp-route-deployment.yaml 配置文件
cat <<EOF > ./configs/warp-route-deployment.yaml
base:
  interchainSecurityModule:
    modules:
      - relayer: "$WALLET"
        type: trustedRelayerIsm
      - domains: {}
        owner: "$WALLET"
        type: defaultFallbackRoutingIsm
    threshold: 1
    type: staticAggregationIsm
  isNft: false
  mailbox: "0xeA87ae93Fa0019a82A727bfd3eBd1cFCa8f64f1D"
  owner: "$WALLET"
  token: "0x532f27101965dd16442e59d40670faf5ebb142e4"
  type: collateral
zoramainnet:
  interchainSecurityModule:
    modules:
      - relayer: "$WALLET"
        type: trustedRelayerIsm
      - domains: {}
        owner: "$WALLET"
        type: defaultFallbackRoutingIsm
    threshold: 1
    type: staticAggregationIsm
  isNft: false
  mailbox: "0xF5da68b2577EF5C0A0D98aA2a58483a68C2f232a"
  owner: "$WALLET"
  type: synthetic
EOF

# 使用 Hyperlane 部署
show "正在使用 Hyperlane 进行部署..."
hyperlane warp deploy
