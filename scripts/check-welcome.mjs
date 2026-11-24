import { setTimeout as wait } from 'node:timers/promises';

async function hasWelcomePage() {
  const response = await fetch('http://127.0.0.1:19392/json/list');
  const page = (await response.json()).find(tab => tab.url.startsWith('belt-pulley://app/'));
  if (!page) return false;
  const socket = new WebSocket(page.webSocketDebuggerUrl);
  try {
    return await new Promise((resolve, reject) => {
      const timeout = setTimeout(() => reject(new Error('Renderer did not respond')), 3000);
      socket.onopen = () => socket.send(JSON.stringify({
        id: 1, method: 'Runtime.evaluate',
        params: { expression: "Boolean(document.querySelector('.welcome-primary'))", returnByValue: true }
      }));
      socket.onmessage = event => {
        const message = JSON.parse(event.data);
        if (message.id !== 1) return;
        clearTimeout(timeout);
        resolve(message.result?.result?.value === true);
      };
      socket.onerror = () => { clearTimeout(timeout); reject(new Error('Renderer connection failed')); };
    });
  } finally { socket.close(); }
}

for (let attempt = 0; attempt < 40; attempt++) {
  if (await hasWelcomePage().catch(() => false)) process.exit(0);
  await wait(500);
}
throw new Error('The extracted Apple Silicon app did not display the Pitch welcome screen.');
