export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).end();

  const { to, subject, html } = req.body || {};
  if (!to || !subject || !html) return res.status(400).json({ error: 'Missing fields' });

  const RESEND_KEY = process.env.RESEND_KEY;
  if (!RESEND_KEY) return res.status(500).json({ error: 'RESEND_KEY not set' });

  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${RESEND_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      from:    'miCunda <noreply@micunda.es>',
      to:      Array.isArray(to) ? to : [to],
      subject,
      html
    })
  });

  const data = await response.json();
  if (data.id) return res.status(200).json({ ok: true });
  return res.status(500).json({ error: data });
}
