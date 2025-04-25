# cream example

> [!WARNING]
> You should use ``vite-plugin-singlefile`` for Vite/its analogs for other frameworks, because after building Vite in the output html file (without the plugin) there will be css/js imports that will be invalid in the game, hence will not work as needed. And so everything is in one file, and does not cause errors, works well.

This example was created in Vite+React+TypeScript

# Building
```bash
npm/bun install # install deps (once)
# or build in release mode
npm/bun run build
```

# Installing
1. Copy ``dist/index.html`` to ``garrysmod/shared/example``
2. Copy [cream_example.lua](./lua/autorun/client/cream_example.lua) to ``garrysmod/lua/autorun/client/``
3. Start your gmodds