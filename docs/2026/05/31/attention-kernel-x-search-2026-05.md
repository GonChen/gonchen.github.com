---
title: X 社区热议：Attention Kernel 优化趋势 (2026-05)
date: 2026-05-31
tags:
  - FlashAttention
  - CUDA
  - GPU Kernel
  - FlashQLA
  - Lighthouse Attention
  - Parallax
  - Triton
---

# X (Twitter) 搜索结果: Attention Kernel Optimization (2026-05)

> 通过 xAI Responses API + x_search 工具获取，搜索日期范围 2026-05-01 ~ 2026-05-31

<!-- more -->

## 1. FlashAttention-4 技术分享

**作者:** Casey Aylward (@caseyaylward)
**链接:** https://x.com/caseyaylward
**日期:** 2026-05-29
**内容:** "Great technical talk by @tedzadouri on FlashAttention-4: a deep look at how attention kernels are being redesigned for NVIDIA Blackwell, where the bottleneck shifts from tensor cores to softmax + memory movement."
**Benchmarks:** 讨论了 Blackwell 上的 kernel 重新设计，瓶颈从 Tensor Core 转向 softmax + 内存移动

---

## 2. 28× 加速 at 8192 tokens

**作者:** chud (@chud)
**链接:** https://x.com/chud/status/2060566211461779944
**日期:** 2026-05-30
**内容:** "Baseline IS FlashAttention-2. 28× speedup at 8192 tokens vs PyTorch SDPA (FA2 backend) on A100. Triton kernel skips irrelevant blocks dynamically."
**Benchmarks:** 8192 tokens 时 28× 加速；O(N log N) prefill；稀疏 head 减少 98% KV cache

---

## 3. Nine kernels exceed 5× (up to 82×)

**作者:** Underfox (@Underfox3)
**链接:** https://x.com/Underfox3/status/2059584503589339480
**日期:** 2026-05-27
**内容:** "It is important to highlight that nine kernels exceed 5× (up to 82×), and Flash Attention achieves 2×–13.3× speedups across all tested configurations without regression."
**Engagement:** 4 likes, 1 repost, 247 views

---

## 4. Parallax — 新 attention 机制超越 FlashAttention

**作者:** cv usk (@cv_usk)
**链接:** https://x.com/cv_usk/status/2060863525132857569
**日期:** 2026-05-30
**内容:** "Parallax (Parameterized Local Linear Attention) custom decode kernel matches or exceeds FlashAttention 2 and 3 throughput. Better perplexity at 0.6B-1.7B params."
**Benchmarks:** Throughput 与 FA2/FA3 相当；学习效率更高（更低 perplexity）

---

## 5. Lighthouse Attention (Nous Research)

**作者:** Nous Research (@NousResearch)
**链接:** https://x.com/NousResearch/status/2055337939270332862
**日期:** 2026-05-15
**内容:** "Today we release Lighthouse Attention, a selection-based hierarchical attention for long-context pre-training that delivers a 1.4-1.7× wall-clock speedup at 98K context. It runs the same forward+backward pass ~17× faster than standard attention at 512K context on a single B200 (Blackwell)."
**Engagement:** 2,018 likes · 231 reposts · 982 bookmarks · 159K views

---

## 6. FlashQLA by Qwen Team

**作者:** @chenzeling4
**链接:** https://x.com/chenzeling4/status/2051192336093212921
**日期:** 2026-05-04
**内容:** "FlashQLA by Qwen: High-performance linear attention kernel library. 2-3× forward and 2× backward speedup over FLA Triton on NVIDIA Hopper. Gate-driven intra-card context parallelism. TileLang fused warp-specialized kernels."

**作者:** @andresvilarino
**链接:** https://x.com/andresvilarino/status/2050502429133717872
**日期:** 2026-05-02
**内容:** "Qwen Team Releases FlashQLA: a High-Performance Linear Attention Kernel Library That Achieves Up to 3× Speedup on NVIDIA Hopper GPUs"

---

## 7. FlashLib — FlashAttention 风格 GPU 库 for Classical ML

**作者:** Shuo Yang (@ShuoYang)
**链接:** https://x.com/ShuoYang/status/2059441289763139677
**日期:** 2026-05-27
**内容:** "FlashLib (from Flash-KMeans team): GPU library with FlashAttention-style kernels for classical ML. Up to 26× KMeans, 19× KNN etc. over cuML."
**Benchmarks:**
- KMeans: 26× over cuML
- KNN: 19× over cuML
- HDBSCAN: 40× over cuML
- TruncatedSVD: 208× over cuML

---

## 汇总 Benchmarks

| 项目 | 加速比 | 硬件 | 日期 |
|------|--------|------|------|
| FlashAttention vs SDPA (8192 tokens) | 28× | A100 | May 30 |
| FlashAttention speedups | 2×–13.3× | 多平台 | May 27 |
| Lighthouse Attention @ 98K ctx | 1.4–1.7× | B200 | May 15 |
| Lighthouse Attention @ 512K ctx | ~17× | B200 | May 15 |
| FlashQLA Forward (vs FLA Triton) | 2–3× | H200 | May 2-4 |
| FlashQLA Backward (vs FLA Triton) | 2× | H200 | May 2-4 |
| Parallax decode (vs FA2/FA3) | competitive | - | May 30 |

---

> 保存时间: 2026-05-31
> 来源: xAI Responses API (grok-4-1-fast) + x_search tool