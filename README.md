<h1 align="center">
  <img src="./assets/logo.png">

  cream
</h1>

<!-- # cream -->
``cream`` is a lua library for Garry's Mod that adds an API to work with the Web UI.

# Table of contents
* [Installation](#installation)
* [Documentation](#documentation)
* [About performance](#about-performance)
* [Example Web UI](./example)

# Installation
Via [libloader](https://github.com/autumngmod/libloader)

```bash
lib i autumngmod/cream
lib enable autumngmod/cream@0.1.0
```

> [!TIP]
> I also strongly advise you to install [GmodCEFCodecFix](https://github.com/solsticegamestudios/GModCEFCodecFix), it updates Chromium to a fresh version, which can improve performance (at least it raises css/js functionality).

# Documentation
All the docs related in [.docs](./docs)

# About performance
See the thing is, comparing VGUI/default gmod functions for rendering with web-technology, the former is likely to win in terms of arbitrariness due to its simplicity, but the web adds a huge number of features. You can make UI of any complexity without problems with the help of web technologies, it's a fact that nobody will argue with.

## We wait for you, facepunch
Performance will be a couple heads better if Facepunch adopts [this commit, which updates CEF to version 124 (very recent)](https://github.com/Facepunch/gmod-html/pull/3). In the meantime, performance, if you don't run 3D modeling in the browser (via, for example, Three.js) is good. But just if you use three.js, because of the large number of operations FPS drops from 600 to 60-30 frames (due to the lack of normal GPU acceleration in the current gmod brunches).\

On my crappy PC, on gm_construct the fps with a simple WebView gobbles up in the neighborhood of 1-3% performance. This is not as much as it could be.

## Benchmark
Right now I don't have a benchmark on hand to show how much worse the web is in terms of performance, so I'll leave that task to you