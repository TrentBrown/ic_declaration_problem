Steps to reproduce:

1. Execute: `npm install`
2. Execute: `npx web-dev-server`
3. Open browser debugger
4. Observe the console error

This is the console error: 

```Uncaught SyntaxError: The requested module '/__wds-outside-root__/1/backend/node_modules/js-sha256/src/sha256.js' does not provide an export named 'sha224' (at sha224.ts:1:10)```