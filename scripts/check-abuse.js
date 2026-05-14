// Alerta de abuso — se ejecuta cada hora via GitHub Actions
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;
const RESEND_KEY   = process.env.RESEND_KEY;

const LIMITE_CUNDAS = 10;
const LIMITE_VIAJES = 100;
const ALERTA_EMAIL  = 'fvilleguillas@gmail.com';

async function sb(path) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    headers: {
      'apikey': SUPABASE_KEY,
      'Authorization': `Bearer ${SUPABASE_KEY}`
    }
  });
  return res.json();
}

async function main() {
  const hace1hora = new Date(Date.now() - 60 * 60 * 1000).toISOString();

  const [cundas, viajes] = await Promise.all([
    sb(`cundas?created_at=gte.${hace1hora}&select=id`),
    sb(`viajes?created_at=gte.${hace1hora}&deleted_at=is.null&select=id`)
  ]);

  const numCundas = cundas.length;
  const numViajes = viajes.length;

  if (numCundas <= LIMITE_CUNDAS && numViajes <= LIMITE_VIAJES) {
    console.log(`OK — ${numCundas} cundas, ${numViajes} viajes en la última hora.`);
    return;
  }

  const alertas = [];
  if (numCundas > LIMITE_CUNDAS) alertas.push(`🚨 <b>${numCundas} cundas</b> creadas (límite: ${LIMITE_CUNDAS})`);
  if (numViajes > LIMITE_VIAJES) alertas.push(`🚨 <b>${numViajes} viajes</b> registrados (límite: ${LIMITE_VIAJES})`);

  const html = `
    <div style="font-family:monospace;background:#1a4a8a;color:#EDE8DF;padding:24px;border-radius:4px">
      <h2 style="color:#D4520A;margin:0 0 16px;font-size:20px;letter-spacing:2px">⚠ ALERTA MICUNDA</h2>
      <p style="margin:0 0 12px">Actividad inusual detectada en la última hora:</p>
      ${alertas.map(a => `<p style="margin:4px 0">${a}</p>`).join('')}
      <hr style="border-color:#D4520A;margin:16px 0">
      <p style="margin:0;font-size:13px;color:#B8A888">
        Revisa el panel de superadmin si lo consideras necesario.
      </p>
    </div>`;

  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${RESEND_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      from:    'miCunda <noreply@micunda.es>',
      to:      [ALERTA_EMAIL],
      subject: `⚠ miCunda — Actividad inusual (${numCundas} cundas, ${numViajes} viajes)`,
      html
    })
  });

  const data = await res.json();
  if (data.id) {
    console.log(`Alerta enviada: ${numCundas} cundas, ${numViajes} viajes.`);
  } else {
    console.error('Error enviando alerta:', data);
    process.exit(1);
  }
}

main().catch(e => { console.error(e); process.exit(1); });
