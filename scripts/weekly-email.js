// Weekly miCunda report — runs every Sunday via GitHub Actions
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;
const RESEND_KEY   = process.env.RESEND_KEY;

async function sb(path) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    headers: {
      'apikey': SUPABASE_KEY,
      'Authorization': `Bearer ${SUPABASE_KEY}`
    }
  });
  return res.json();
}

function grupoKey(conductorId, asistentes) {
  const todos = [conductorId, ...(asistentes || [])].filter(Boolean);
  return [...new Set(todos)].sort().join(',');
}

function fmt(iso) {
  if (!iso) return '';
  const [, m, d] = iso.split('-');
  return `${d}/${m}`;
}

function getWeekBounds() {
  const now  = new Date();
  const day  = now.getDay();
  const diff = day === 0 ? -6 : 1 - day;
  const mon  = new Date(now); mon.setDate(now.getDate() + diff);
  const sun  = new Date(mon); sun.setDate(mon.getDate() + 6);
  const pad  = d => `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
  return { start: pad(mon), end: pad(sun) };
}

function buildWeeklySummary(miembros, viajes, start, end) {
  const trips = viajes.filter(v => v.fecha >= start && v.fecha <= end);
  if (!trips.length) return '<p style="color:#999;font-size:14px;margin:0">Sin viajes registrados esta semana.</p>';

  return trips.map(v => {
    const cond = miembros.find(m => m.id === v.conductor_id);
    const asis = (v.asistentes || [])
      .map(id => miembros.find(m => m.id === id)?.nombre?.split(' ')[0])
      .filter(Boolean).join(', ');
    const [y, mo, d] = v.fecha.split('-');
    return `
      <div style="padding:9px 0;border-bottom:1px solid #F5F5F5;font-size:14px">
        <strong style="color:#1a4a8a">${cond?.nombre || '?'}</strong>
        <span style="color:#888"> · ${d}/${mo}/${y}${asis ? ' · <em>' + asis + '</em>' : ''}</span>
      </div>`;
  }).join('');
}

function buildCuadrante(miembros, viajes, memberId = null) {
  if (!viajes.length) return '<p style="color:#999;text-align:center;font-size:13px">Sin viajes registrados.</p>';

  const groups = {};
  viajes.forEach(v => {
    const k = grupoKey(v.conductor_id, v.asistentes);
    if (!groups[k]) {
      const mgr = [v.conductor_id, ...(v.asistentes || [])]
        .map(id => miembros.find(m => m.id === id))
        .filter(Boolean)
        .sort((a, b) => a.nombre.localeCompare(b.nombre));
      groups[k] = { miembros: mgr, trips: [] };
    }
    groups[k].trips.push(v);
  });

  if (memberId) {
    Object.keys(groups).forEach(k => {
      const participa = groups[k].trips.some(v =>
        v.conductor_id === memberId || (v.asistentes || []).includes(memberId)
      );
      if (!participa) delete groups[k];
    });
  }

  if (!Object.keys(groups).length) return '<p style="color:#999;text-align:center;font-size:13px">Sin viajes registrados en tu grupo esta semana.</p>';

  return Object.values(groups).map((g, idx) => {
    const label = g.miembros.map(m => m.nombre.split(' ')[0]).join(' · ');
    const sep   = idx > 0 ? 'margin-top:20px;' : '';

    const headerCols = g.trips.map((v, i) =>
      `<th style="background:#F0F4F8;color:#666;font-size:9px;font-weight:600;padding:5px 3px;text-align:center;min-width:36px;border-right:1px solid #E8ECF0;border-bottom:2px solid #DDE3EA;line-height:1.3">
        ${i+1}<br><span style="color:#AAB4BE">${fmt(v.fecha)}</span>
      </th>`
    ).join('');

    const rows = g.miembros.map(mb => {
      const count = g.trips.filter(v => v.conductor_id === mb.id).length;
      const cells = g.trips.map(v => {
        if (v.conductor_id === mb.id) {
          return `<td style="text-align:center;vertical-align:middle;background:#E8F1FC;border-right:1px solid #F0F4F8;border-bottom:1px solid #F0F4F8;height:42px;width:36px">
            <span style="color:#1565C0;font-size:17px;line-height:1">✓</span><br>
            <span style="color:#7A9BC4;font-size:8px">${fmt(v.fecha)}</span>
          </td>`;
        }
        return `<td style="border-right:1px solid #F0F4F8;border-bottom:1px solid #F0F4F8;height:42px;width:36px"></td>`;
      }).join('');

      return `<tr>
        <td style="padding:0 14px;font-size:13px;font-weight:700;color:#333;white-space:nowrap;border-right:2px solid #E8ECF0;border-bottom:1px solid #F0F4F8;height:42px;background:#fff">
          ${mb.nombre.split(' ')[0]}${count > 0 ? ` <span style="color:#1565C0;font-size:11px;font-weight:600">(${count})</span>` : ''}
        </td>
        ${cells}
      </tr>`;
    }).join('');

    return `
      <div style="${sep}">
        <p style="font-size:11px;font-weight:600;color:#999;text-transform:uppercase;letter-spacing:.5px;margin:0 0 6px">
          <span style="display:inline-block;width:7px;height:7px;border-radius:50%;background:#1565C0;margin-right:6px;vertical-align:middle"></span>
          ${label}
        </p>
        <div style="overflow-x:auto;-webkit-overflow-scrolling:touch;border-radius:8px;border:1px solid #E8ECF0">
          <table style="border-collapse:collapse;min-width:100%">
            <thead>
              <tr>
                <th style="background:#1565C0;color:#fff;font-size:11px;font-weight:700;padding:7px 14px;text-align:left;white-space:nowrap;border-right:2px solid rgba(255,255,255,.2)"></th>
                ${headerCols}
              </tr>
            </thead>
            <tbody>${rows}</tbody>
          </table>
        </div>
      </div>`;
  }).join('');
}

function buildModificaciones(miembros, modificados) {
  if (!modificados.length) {
    return '<p style="color:#999;font-size:14px;margin:0">No hay modificaciones de registro esta semana.</p>';
  }

  return modificados.map(v => {
    const editor = miembros.find(m => m.id === v.updated_by);
    const cond   = miembros.find(m => m.id === v.conductor_id);
    const asis   = (v.asistentes || [])
      .map(id => miembros.find(m => m.id === id)?.nombre?.split(' ')[0])
      .filter(Boolean).join(', ');
    return `
      <div style="padding:9px 0;border-bottom:1px solid #F5F5F5;font-size:14px">
        <strong style="color:#D4520A">${editor?.nombre || '?'}</strong>
        <span style="color:#888"> editó el viaje del <strong style="color:#333">${fmt(v.fecha)}</strong>
        · conductor: ${cond?.nombre?.split(' ')[0] || '?'}${asis ? ' · <em>' + asis + '</em>' : ''}</span>
      </div>`;
  }).join('');
}

async function main() {
  const { start, end } = getWeekBounds();
  const [, sm, sd] = start.split('-');
  const [ey, em, ed] = end.split('-');
  const weekLabel = `${sd}/${sm} – ${ed}/${em}/${ey}`;

  const cundas = await sb('cundas?select=id,nombre');

  for (const cunda of cundas) {
    const [miembros, viajes, modificados] = await Promise.all([
      sb(`miembros?select=id,nombre,email,rol,incorporado_at&cunda_id=eq.${cunda.id}&order=incorporado_at.asc`),
      sb(`viajes?select=*&cunda_id=eq.${cunda.id}&deleted_at=is.null&order=fecha.asc`),
      sb(`viajes?select=*&cunda_id=eq.${cunda.id}&deleted_at=is.null&updated_at=gte.${start}&updated_at=lte.${end}T23:59:59&updated_by=not.is.null&order=updated_at.asc`)
    ]);

    const miembrosConEmail = miembros.filter(m => m.email);
    if (!miembrosConEmail.length) continue;

    const summaryHTML        = buildWeeklySummary(miembros, viajes, start, end);
    const modificacionesHTML = buildModificaciones(miembros, modificados);

    let enviados = 0;
    for (const miembro of miembrosConEmail) {
      const esAdmin       = miembro.rol === 'admin';
      const cuadranteHTML = buildCuadrante(miembros, viajes, esAdmin ? null : miembro.id);

      const html = `
<!DOCTYPE html>
<html lang="es">
<body style="margin:0;padding:0;background:#ECEFF1;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif">
<div style="max-width:600px;margin:0 auto;padding:20px">

  <!-- Cabecera -->
  <div style="background:#1a4a8a;padding:20px 24px;border-radius:12px 12px 0 0;text-align:center">
    <div style="font-size:30px">🚗</div>
    <h1 style="color:#fff;margin:6px 0 2px;font-size:21px;font-weight:800">miCunda</h1>
    <p style="color:rgba(255,255,255,.7);margin:0;font-size:13px">${cunda.nombre}</p>
  </div>

  <!-- Cuerpo -->
  <div style="background:#fff;padding:24px;border-radius:0 0 12px 12px;border:1px solid #e0e0e0;border-top:none">

    <!-- Resumen semana -->
    <h2 style="font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:#555;margin:0 0 14px">
      📅 Semana del ${weekLabel}
    </h2>
    ${summaryHTML}

    <div style="height:28px"></div>

    <!-- Cuadrante -->
    <h2 style="font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:#555;margin:0 0 14px">
      📊 Cuadrante de viajes
    </h2>
    ${cuadranteHTML}

    <div style="height:28px"></div>

    <!-- Modificaciones -->
    <h2 style="font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:#555;margin:0 0 14px">
      ✏️ Modificaciones de registro esta semana
    </h2>
    ${modificacionesHTML}

    <!-- Pie -->
    <p style="margin:28px 0 0;font-size:12px;color:#bbb;text-align:center">
      miCunda · <a href="https://micunda.es" style="color:#1a4a8a;text-decoration:none">micunda.es</a>
    </p>
  </div>

</div>
</body>
</html>`;

      const res  = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${RESEND_KEY}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({
          from:    'miCunda <noreply@micunda.es>',
          to:      [miembro.email],
          subject: `🚗 Resumen semanal · ${weekLabel} · ${cunda.nombre}`,
          html
        })
      });
      const data = await res.json();
      console.log(`[${cunda.nombre}] → ${miembro.email}`, data.id || data);
      if (data.id) enviados++;
    }

    if (enviados > 0) {
      await fetch(`${SUPABASE_URL}/rest/v1/email_logs`, {
        method: 'POST',
        headers: {
          'apikey': SUPABASE_KEY,
          'Authorization': `Bearer ${SUPABASE_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          tipo:          'semanal',
          cunda_nombre:  cunda.nombre,
          destinatarios: enviados
        })
      }).catch(() => {});
    }
  }
}

main().catch(err => { console.error(err); process.exit(1); });
