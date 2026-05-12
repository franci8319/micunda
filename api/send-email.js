export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).end();

  const { to, subject, html, tipo, cunda_nombre } = req.body || {};
  if (!to || !subject || !html) return res.status(400).json({ error: 'Missing fields' });

  const RESEND_KEY    = process.env.RESEND_KEY;
  const SUPABASE_URL  = process.env.SUPABASE_URL;
  const SUPABASE_KEY  = process.env.SUPABASE_KEY;
  if (!RESEND_KEY) return res.status(500).json({ error: 'RESEND_KEY not set' });

  const recipients = Array.isArray(to) ? to : [to];

  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${RESEND_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      from:    'miCunda <noreply@micunda.es>',
      to:      recipients,
      subject,
      html
    })
  });

  const data = await response.json();
  if (!data.id) return res.status(500).json({ error: data });

  // Log en Supabase (best-effort, no bloquea la respuesta)
  if (SUPABASE_URL && SUPABASE_KEY) {
    fetch(`${SUPABASE_URL}/rest/v1/email_logs`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        tipo:          tipo || 'contrasena',
        cunda_nombre:  cunda_nombre || null,
        destinatarios: recipients.length
      })
    }).catch(() => {});
  }

  return res.status(200).json({ ok: true });
}
