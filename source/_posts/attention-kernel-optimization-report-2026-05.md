---
title: Attention Kernel Optimization 研究报告
date: 2026-05-31 23:50:00
tags:
  - FlashAttention
  - CUDA
  - GPU Kernel
  - FlashQLA
  - Linear Attention
  - cuLA
categories: ML
---

> 🌐 last30days v3.3.1 · synced 2026-05-31

封面速览：FlashAttention-4 登顶 Blackwell（1,613 TFLOPs/s），FlashQLA 和 cuLA 代表线性 attention 两条路径，社区掀起手写 attention kernel 热潮。

<!-- more -->

## 📋 关键发现

### FlashAttention-4 登顶 Blackwell

Tri Dao 团队的 FA4 专为 NVIDIA Blackwell (B200/GB300) 设计，峰值前向推理达 **1,613 TFLOPs/s**，GPU 利用率 **71%**。相比 cuDNN 9.13 快 1.3×，相比 Triton 快 2.7×。三大核心创新：

- 重新设计的异步流水线（编排 warp 和计算 warp 分离）
- 通过 FMA 多项式近似替代 SFU 算 exp()，绕过软顶瓶颈
- 条件性 softmax rescaling 减少约 10× 重缩放操作

安装：`pip install flash-attn-4`

来源: [Lambda AI Blog](https://lambda.ai/blog/flashattention-4-gives-the-nvidia-blackwell-platform-its-most-optimized-attention-kernel-yet) · [arxiv 2603.05451](https://arxiv.org/abs/2603.05451)

### FlashQLA & cuLA — 线性 Attention 双雄

Qwen 团队的 **FlashQLA**（522★）基于 TileLang（Python DSL）为 GDN 架构实现 **2-3× forward、2× backward** 加速。inclusionAI 的 **cuLA**（513★）走手写 CuTe DSL + CUTLASS C++ 路线，支持 GLA/KDA/GDN/Lightning Attention 四种变体，在 Blackwell SM10X 上 KDA 达 **1.33-1.58×** 加速。

来源: [GitHub/QwenLM/FlashQLA](https://github.com/QwenLM/FlashQLA) · [GitHub/inclusionAI/cuLA](https://github.com/inclusionAI/cuLA) · [Qwen Blog](https://qwen.ai/blog?id=flashqla)

### 社区掀起"从零手写 Attention Kernel"热潮

r/CUDA 上月多个高赞项目：FlashAttention CUDA kernel 纯手写（forward+backward，SRAM tiling，WMMA Tensor Cores，Tesla T4 达 23.47 TFLOPs）。HN 上"FlashAttention-2 in Cute, from Scratch"同样引起关注。

帖子: [r/CUDA FA kernel from scratch](https://www.reddit.com/r/CUDA/comments/1to5r3a/p_flashattention_cuda_kernel_from_scratch_forward/) · [FA2 in Cute](https://blog.echen.io/p/flashattention-2-in-cute-from-scratch/)

### 消费级 GPU 的 Attention 优化

r/LocalLLaMA 上通过 `sudot4` 原生点积指令，在 RDNA3 (AMD RX 7900 XTX) 上为 llama.cpp 实现 Flash Attention，KV cache VRAM 降低 **47%** 且几乎无精度损失。Luce DFlash + PFlash 在 7900XTX 上达到 Qwen3.6-27B decode 2.24×、prefill 3.05× 加速 vs llama.cpp HIP。

来源: [r/LocalLLaMA RDNA3 FA](https://www.reddit.com/r/LocalLLaMA/comments/1tss1ca/flash_attention_for_llamacpp_on_rdna3_47_less_kv/) · [Luce DFlash + PFlash](https://www.reddit.com/r/LocalLLaMA/comments/1tgepbd/luce_dflash_pflash_on_7900xtx_qwen3627b_at_224x/)

### FlashInfer — LLM Serving 的 Kernel 统一层

flashinfer-ai/flashinfer 提供了 attention、GEMM、MoE 的统一 API，后端自动选择 FA2/FA3、cuDNN、CUTLASS 或 TensorRT-LLM。上层框架（vLLM 等）不需硬编码特定 kernel 实现。

来源: [GitHub/flashinfer-ai/flashinfer](https://github.com/flashinfer-ai/flashinfer)

---

## 📊 Benchmarks 汇总

| 项目 | 加速比 | 硬件 | 日期 | 来源 |
|------|--------|------|------|------|
| FlashAttention-4 (vs cuDNN 9.13) | **1.3×** | B200 | Apr | Lambda AI |
| FlashAttention-4 (vs Triton) | **2.7×** | B200 | Apr | Lambda AI |
| FA4 FlexAttention forward (vs Triton) | **1.6–3.2×** | GB200 | Apr | Lambda AI |
| FA4 FlexAttention backward (vs Triton) | **1.85–2.3×** | GB200 | Apr | Lambda AI |
| FlashAttention vs SDPA @ 8192 tok | **28×** | A100 | May 30 | @chud (X) |
| FlashAttention speedups | **2–13.3×** | 多平台 | May 27 | @Underfox3 (X) |
| Lighthouse Attention @ 98K ctx | **1.4–1.7×** | B200 | May 15 | @NousResearch (X) |
| Lighthouse Attention @ 512K ctx | **~17×** | B200 | May 15 | @NousResearch (X) |
| FlashQLA Forward (vs FLA Triton) | **2–3×** | H200 | May 2 | @Qwen (X) |
| FlashQLA Backward (vs FLA Triton) | **2×** | H200 | May 2 | @Qwen (X) |
| cuLA KDA Modular Forward (Blackwell) | **1.33×** | SM10X | May | GitHub/cuLA |
| cuLA KDA Fused Forward (Hopper) | **1.58×** | SM90 | May | GitHub/cuLA |
| cuLA Lightning Prefill (Blackwell) | **2.08×** | SM10X | May | GitHub/cuLA |
| RDNA3 llama.cpp FA (KV VRAM) | **-47%** | RX 7900 XTX | May 31 | r/LocalLLaMA |
| Luce DFlash + PFlash decode | **2.24×** | RX 7900 XTX | May | r/LocalLLaMA |
| Luce DFlash + PFlash prefill | **3.05×** | RX 7900 XTX | May | r/LocalLLaMA |

---

## 🔁 关键趋势

1. **Attention kernel 重心从 HBM 带宽转向计算调度** — FA1 解决的是 HBM 带宽瓶颈（tiling + recomputation），而 FA4 在 Blackwell 上要解决的是 Tensor Core 和 SFU 之间的调度失衡。异步流水线和 warp specialization 成为新的关键技巧。

2. **CuTe DSL (Python) 成为 Attention Kernel 新标准** — FA4 完全在 CuTe-DSL 中实现，cuLA 也用 CuTe + CUTLASS。FlashQLA 用 TileLang（另一个 Python DSL）。DSL 层面的 kernel 编写正在从手写 CUDA C++ 中抢地盘。

3. **Linear Attention 生态加速追赶** — FlashQLA、cuLA、FLA 三条路线并行发展，对长序列和 edge 推理场景影响尤其显著（2-3× 加速）。Gated Delta Net 架构的 kernel 优化是 5 月热点。

4. **Softmax 成为 Blackwell 新瓶颈** — 在 Blackwell 上，softmax（而非 matmul）成为 attention 的计算瓶颈。FA4 的核心贡献（多项式 exp 近似 + 条件性 rescaling）专门针对这个问题。

5. **消费级 GPU 的 attention 优化在加速** — RDNA3 上原生 dot-product 指令利用、llama.cpp FA 集成、Luce DFlash/PFlash 等项目表明 attention kernel 优化正在从数据中心走向桌面。

---

## 🐦 X (Twitter) 精选帖子

**Nous Research @NousResearch** (May 15 · ❤️ 2,018 · 👁 159K)
> "Today we release Lighthouse Attention, a selection-based hierarchical attention for long-context pre-training that delivers a 1.4-1.7× wall-clock speedup at 98K context. It runs the same forward+backward pass ~17× faster than standard attention at 512K context on a single B200 (Blackwell)."

**chud @chud** (May 30)
> "Baseline IS FlashAttention-2. 28× speedup at 8192 tokens vs PyTorch SDPA (FA2 backend) on A100. Triton kernel skips irrelevant blocks dynamically. O(N log N) prefill; 98% less KV cache for sparse heads."

**cv usk @cv_usk** (May 30)
> "Parallax (Parameterized Local Linear Attention) custom decode kernel matches or exceeds FlashAttention 2 and 3 throughput. Better perplexity at 0.6B-1.7B params."

**Underfox @Underfox3** (May 27)
> "Nine kernels exceed 5× (up to 82×); Flash Attention achieves 2×–13.3× speedups across all tested configurations without regression."

**Casey Aylward @caseyaylward** (May 29)
> "Great technical talk by @tedzadouri on FlashAttention-4: a deep look at how attention kernels are being redesigned for NVIDIA Blackwell, where the bottleneck shifts from tensor cores to softmax + memory movement."

**@chenzeling4 / @andresvilarino** (May 2-4)
> "FlashQLA by Qwen: High-performance linear attention kernel library. 2-3× forward and 2× backward speedup over FLA Triton on NVIDIA Hopper."

**Shuo Yang @ShuoYang** (May 27)
> "FlashLib (from Flash-KMeans team): GPU library with FlashAttention-style kernels for classical ML. Up to 26× KMeans, 19× KNN, 40× HDBSCAN, 208× TruncatedSVD over cuML."

---

## 🔗 参考来源

### 论文 & 博客
- [FlashAttention-4: Algorithm and Kernel Pipelining Co-Design](https://arxiv.org/abs/2603.05451) — arxiv
- [FA4 on Blackwell — Lambda AI Blog](https://lambda.ai/blog/flashattention-4-gives-the-nvidia-blackwell-platform-its-most-optimized-attention-kernel-yet) — 1,613 TFLOPs/s, 71% utilization
- [NVIDIA: Tuning Flash Attention with CUDA Tile](https://developer.nvidia.com/blog/tuning-flash-attention-for-peak-performance-in-nvidia-cuda-tile/) — cuTile DSL 完整指南
- [FlashQLA — Qwen Official Blog](https://qwen.ai/blog?id=flashqla) — TileLang 线性 attention kernel
- [FA2 vs FA3 迁移指南](https://www.spheron.network/blog/flashattention-2-vs-flashattention-3-h100-h200-guide/) — Spheron Blog

### GitHub 仓库
- [Dao-AILab/flash-attention](https://github.com/Dao-AILab/flash-attention) — FA4 CuTe-DSL 实现
- [QwenLM/FlashQLA](https://github.com/QwenLM/FlashQLA) ★522 — TileLang 线性 attention
- [inclusionAI/cuLA](https://github.com/inclusionAI/cuLA) ★513 — CuTe + CUTLASS 线性 attention
- [flashinfer-ai/flashinfer](https://github.com/flashinfer-ai/flashinfer) — LLM Serving 统一 kernel 库

### Reddit 讨论
- [r/CUDA: Learn CUDA by Building Flash Attention](https://www.reddit.com/r/CUDA/comments/1tr84g1/)
- [r/CUDA: FA CUDA Kernel from Scratch](https://www.reddit.com/r/CUDA/comments/1to5r3a/)
- [r/LocalLLaMA: RDNA3 FA — 47% less KV VRAM](https://www.reddit.com/r/LocalLLaMA/comments/1tss1ca/)
- [r/MachineLearning: CuTe/CUTLASS vs Python DSL 2026](https://www.reddit.com/r/MachineLearning/comments/1sqfgat/)
- [r/LocalLLaMA: FA4 1613 TFLOPs/s](https://www.reddit.com/r/LocalLLaMA/comments/1s1yw23/)