# cream example

> [!WARNING]
> You should use ``vite-plugin-singlefile`` for Vite/its analogs for other frameworks, because after building Vite in the output html file (without the plugin) there will be css/js imports that will be invalid in the game, hence will not work as needed. And so everything is in one file, and does not cause errors, works well.

This example was created in Vite+React+TypeScript

# Usage
```bash
npm/bun install # install deps (once)
npm/bun run dev --host # copy second ip
# or build in release mode
npm/bun run build
```