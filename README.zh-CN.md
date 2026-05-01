# yzlab

**[![README](https://img.shields.io/badge/README-white)](https://github.com/yonzilch/yzlab) | [![English](https://img.shields.io/badge/English-blue)](https://github.com/yonzilch/yzlab/blob/main/README.md) | [![中文](https://img.shields.io/badge/Chinese-red)](https://github.com/yonzilch/yzlab/blob/main/README.zh-CN.md)**

> 我的个人 Infrastrate Lab（基础设施实验室），完全声明式且可复现 —— 由 NixOS Flakes 驱动。

[![NixOS](https://img.shields.io/badge/NixOS-unstable-5277C3?logo=nixos&logoColor=white)](https://nixos.org)
[![built with nix](https://img.shields.io/badge/built%20with-Nix-7EBAE4?logo=nixos)](https://builtwithnix.org)
[![License](https://img.shields.io/github/license/yonzilch/yzlab)](./LICENSE)

---

## 基础设施状态实时概览

| 服务 | 链接 |
|---|---|
| 服务器监控 | [monitor.yzlab.eu.org](https://monitor.yzlab.eu.org) |
| 状态页 | [status.yzlab.eu.org](https://status.yzlab.eu.org) |

---

## 这是什么？

这个代码仓库是我 lab 中所有 NixOS 主机的**唯一可信源（single source of truth）**。每一台主机、每一项服务、每一个系统选项都在此以代码形式定义。没有手动配置，没有配置漂移 —— 不在这个仓库里的东西，就不会存在于机器上。

该技术栈围绕 [NixOS Flakes](https://nixos.wiki/wiki/Flakes) 构建，重点关注：

- **可复现性** —— 任何机器、任何时间，都能构建出完全一致的系统
- **声明式部署** —— 一条命令即可将全新主机配置完毕
- **机密安全** —— 加密后的密钥直接提交至 Git
- **运维极简** —— 复杂操作被封装为简短的 `just` 命令

当前规模：**10+ 台主机**、**50+ 个自托管服务**，涵盖跨多个云服务商的 VPS/VDS 实例、本地裸金属服务器主机以及虚拟机。

---

## 为什么选择 NixOS Flakes？

大多数基础设施随着时间的推移都会产生配置漂移 —— 手动安装的软件包、就地修改的配置文件、未记录的临时修补。NixOS 从根本上消除了这些问题：

- **原子化升级与回滚** —— 一条命令切换系统世代（generation）；回滚同样轻松
- **可复现构建** —— `flake.lock` 锁定所有依赖；同一个 flake 始终生成相同的系统
- **无命令式状态** —— 系统是配置的纯函数；无需担心任何隐藏状态
- **内置开发环境** —— `nix develop` 让你直接进入包含所有工具（`sops`、`nixos-rebuild`、`alejandra` 等）的 Shell，无需全局安装任何东西

---

## 技术栈

| 层级 | 工具 | 职责 |
|---|---|---|
| 操作系统 | [NixOS](https://nixos.org) (unstable) | 声明式、原子化的 Linux |
| Flake 框架 | [flake-parts](https://github.com/hercules-ci/flake-parts) | 模块化 flake 组合 |
| 磁盘布局 | [disko](https://github.com/nix-community/disko) | 声明式磁盘分区 |
| 远程安装 | [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) | 基于 SSH 的零接触部署 |
| 密钥管理 | [sops-nix](https://github.com/Mic92/sops-nix) + [age](https://github.com/FiloSottile/age) | Git 中的加密密钥 |
| 任务运行器 | [just](https://github.com/casey/just) | 简洁的命令自动化 |
| 代码格式化 | [alejandra](https://github.com/kamadorueda/alejandra) + [deadnix](https://github.com/astro/deadnix) | Nix 代码质量 |
| Compose 桥接 | [compose2nix](https://github.com/aksiksi/compose2nix) | Docker Compose → Nix 转换 |

---

## 仓库结构

```
yzlab/
├── flake.nix          # Flake 入口，输入声明
├── flake.lock         # 锁定的依赖图
├── justfile           # 自动化命令
├── .sops.yaml         # SOPS 加密规则
├── hosts/             # 各主机的 NixOS 配置
│   └── <hostname>/
│       ├── default.nix
│       └── hardware.nix
├── modules/           # 可复用的 NixOS 模块
│   └── private/       # SOPS 加密的密钥（可安全提交）
└── pkgs/              # 自定义 Nix 包
```

### 主机是如何组织的

`hosts/` 下的每台主机都是一个独立的 NixOS 系统定义。硬件配置在部署期间通过 `nixos-generate-config` 自动生成，并与声明式配置一并提交。共享的行为逻辑存放在 `modules/` 中，从而保持主机配置的精简，使其专注于特定机器的需求。

---

## 密钥管理

密钥使用 [age](https://github.com/FiloSottile/age) 密钥通过 [SOPS](https://github.com/getsops/sops) 加密，并直接提交到 `modules/private/` 目录中。`.sops.yaml` 定义了哪些文件需要被加密，以及哪些密钥可以解密它们。

```yaml
# .sops.yaml
keys:
  - &admin_yonzilch age1yzce0p...
creation_rules:
  - path_regex: modules/private/.*
    key_groups:
      - age:
          - *admin_yonzilch
```

---

## 使用方法

### 前置要求

- 启用了 flakes 的 Nix
- 已安装 `just`
- `~/.config/sops/age/keys.txt` 路径下存在 age 密钥（可通过 `just keygen` 生成）

### 可用命令

```
just keygen               # 通过 rage 生成新的 age 密钥
just update               # 更新所有 flake 输入源
just upgrade              # 原地重建并切换本地主机

just build   <hostname>   # 构建主机配置（不部署）
just build-vm <hostname>  # 构建并以本地虚拟机形式启动以供测试

just deploy    <hostname>  # 部署到正在运行的远程主机 (nixos-rebuild switch)
just deploy-rb <hostname>  # 同上，但在远程机器上构建

just anywhere    <hostname>  # 从零开始部署全新主机 (nixos-anywhere)
just anywhere-lb <hostname>  # 同上，但在本地构建后再发送
just anywhere-vm <hostname>  # 在本地虚拟机中试运行

just enc  <hostname>       # 加密某台主机的密钥
just dec  <hostname>       # 解密某台主机的密钥
just eac                   # 加密所有密钥
just dac                   # 解密所有密钥

just format               # 格式化所有 Nix 文件 (alejandra + deadnix)
```

### 从零部署新主机

```bash
# 1. 创建主机配置
mkdir -p hosts/<hostname>
# ... 编写 hosts/<hostname>/default.nix

# 2. 如果你还没有 age 密钥，请先生成
just keygen

# 3. 部署 —— hardware-config 会被自动生成并应用
just anywhere <hostname>
```

`anywhere` 命令会处理一切：更新 `flake.nix` 中的目标主机名、通过 `nixos-generate-config` 自动生成硬件配置，并通过 SSH 一步完成部署。

### 向现有主机部署更改

```bash
just deploy <hostname>
```

就这么简单。NixOS 会原子化地切换到新的系统世代；如果出现问题，前一个世代依然完好且可正常启动。

---

## 许可证

[BSD 2-Clause](./LICENSE)
