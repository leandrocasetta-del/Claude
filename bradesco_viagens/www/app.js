(function(){
'use strict';
const $=s=>document.querySelector(s), view=$('#view');
const P=window.PROFILE;
const LS={get(k,d){try{return JSON.parse(localStorage.getItem(k))??d}catch(e){return d}},set(k,v){try{localStorage.setItem(k,JSON.stringify(v))}catch(e){}}};
let trips=LS.get('bpb_trips',null)||JSON.parse(JSON.stringify(window.TRIPS));
const save=()=>LS.set('bpb_trips',trips);
const ST={solicitada:'Aguardando aprovação',aprovada:'Aprovada',bookada:'Bookada',andamento:'Em andamento',concluida:'Concluída',cancelada:'Cancelada'};
const brl=v=>(v||0).toLocaleString('pt-BR',{style:'currency',currency:'BRL'});
const dt=s=>{if(!s)return'—';const[d,h]=s.split(' ');const[y,m,dd]=d.split('-');return`${dd}/${m}/${y}`+(h?` ${h}`:'')};
const short=s=>{const[,m,d]=s.split('-');return`${d}/${m}`};
const days=(a,b)=>Math.round((new Date(b)-new Date(a))/864e5);
const today='2026-11-17'; // data de referência da demonstração
const total=t=>[...t.voos,...t.hoteis,...t.extras].reduce((s,x)=>s+(x.valor||0),0);
const spent=t=>[...t.voos,...t.hoteis,...t.extras].filter(x=>['pago','reembolsado'].includes(x.status)).reduce((s,x)=>s+x.valor,0);
const pill=s=>`<span class="pill s-${s}">${ST[s]}</span>`;
const esc=s=>String(s).replace(/[&<>"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const pendentes=()=>trips.filter(t=>t.status==='solicitada');
function toast(m){const t=$('#toast');t.textContent=m;t.hidden=false;setTimeout(()=>t.hidden=true,2400)}

/* ---------- navegação ---------- */
const TABS=[['home','🏠','Início'],['trips','🧳','Viagens'],['appr','✅','Aprovações'],['costs','💰','Custos'],['more','☰','Mais']];
$('#tabs').innerHTML=TABS.map(t=>`<button data-r="${t[0]}"><b>${t[1]}</b>${t[2]}</button>`).join('');
$('#tabs').onclick=e=>{const b=e.target.closest('button');if(b)location.hash='#/'+b.dataset.r};
$('#back').onclick=()=>history.length>1?history.back():location.hash='#/home';
$('#fab').onclick=()=>newTrip();
$('#bell').onclick=()=>notifications();
window.addEventListener('hashchange',render);

function render(){
  const [,r,id]=(location.hash||'#/home').split('/');
  const route=r||'home';
  document.querySelectorAll('#tabs button').forEach(b=>b.classList.toggle('on',b.dataset.r===(route==='trip'?'trips':route)));
  $('#back').hidden=route!=='trip'; $('#fab').hidden=!['home','trips'].includes(route);
  $('#badge').textContent=alerts().length||'';
  ({home,trips:list,appr,costs,more,trip:()=>detail(id)})[route]?.();
  window.scrollTo(0,0);
}

/* ---------- alertas ---------- */
function alerts(){
  const a=[];
  trips.forEach(t=>{
    if(t.status==='bookada'){const d=days(today,t.inicio);if(d<=7&&d>=0)a.push({i:'✈️',t:`${t.destino} em ${d} dia(s)`,s:'Faça o check-in online 24h antes do voo.',id:t.id})}
    if(t.status==='solicitada')a.push({i:'⏳',t:`Aprovação pendente – ${t.destino}`,s:'Aguardando '+(t.aprovacoes.find(x=>x.status==='pendente')?.etapa||'análise'),id:t.id});
    if(t.status==='concluida'&&t.prestacao==='pendente')a.push({i:'🧾',t:`Prestação de contas – ${t.destino}`,s:'Prazo: 5 dias úteis após o retorno.',id:t.id});
    (t.alertas||[]).forEach(x=>a.push({i:'⚠️',t:t.destino,s:x,id:t.id}));
  });
  return a;
}
function notifications(){
  const a=alerts();
  sheet(`<h2>Notificações</h2>${a.map(x=>`<div class="card trip" data-go="${x.id}"><b>${x.i} ${esc(x.t)}</b><div class="muted">${esc(x.s)}</div></div>`).join('')||'<p class="muted">Nada novo.</p>'}`,s=>{s.querySelectorAll('[data-go]').forEach(e=>e.onclick=()=>{closeSheet();location.hash='#/trip/'+e.dataset.go})});
}
function sheet(html,fn){const s=$('#sheet');s.innerHTML=`<div>${html}<button class="btn ghost block" id="x">Fechar</button></div>`;s.hidden=false;s.onclick=e=>{if(e.target===s)closeSheet()};$('#x').onclick=closeSheet;fn&&fn(s)}
function closeSheet(){$('#sheet').hidden=true}

/* ---------- card de viagem ---------- */
function tripCard(t){
  const tot=total(t),pc=t.orcamento?Math.min(100,tot/t.orcamento*100):0;
  return`<a class="card trip" href="#/trip/${t.id}"><div class="row"><div><div class="dest">${t.tipo==='Internacional'?'🌎':'🇧🇷'} ${esc(t.destino)}</div>
  <div class="meta">${dt(t.inicio)} → ${dt(t.fim)} · ${esc(t.motivo)}</div></div>${pill(t.status)}</div>
  <div class="meta" style="margin-top:8px">${esc(t.id)} · ${brl(tot)} de ${brl(t.orcamento)}</div>
  <div class="bar ${tot>t.orcamento?'over':''}"><i style="width:${pc}%"></i></div></a>`;
}

/* ---------- Início ---------- */
function home(){
  const prox=trips.filter(t=>['bookada','solicitada','andamento'].includes(t.status)).sort((a,b)=>a.inicio.localeCompare(b.inicio));
  const ativa=trips.find(t=>t.status==='andamento'),next=prox.find(t=>t.status==='bookada');
  const ano=trips.filter(t=>t.status!=='cancelada'&&t.status!=='solicitada');
  const gasto=ano.reduce((s,t)=>s+total(t),0),orc=ano.reduce((s,t)=>s+t.orcamento,0);
  view.innerHTML=`<div class="card hero"><div class="profile"><div class="avatar" style="background:#fff;color:var(--red)">${P.nome.split(' ').map(x=>x[0]).slice(0,2).join('')}</div>
  <div><div class="sub">Bem-vindo(a)</div><h1>${esc(P.nome)}</h1><div class="sub">Funcional ${esc(P.funcional)} · ${esc(P.cargo)}</div></div></div></div>
  ${ativa?`<h2>Viagem em andamento</h2>${tripCard(ativa)}`:''}
  ${next?`<h2>Próxima viagem · em ${days(today,next.inicio)} dias</h2>${tripCard(next)}`:''}
  <h2>Resumo</h2><div class="grid">
  <div class="card kpi"><div class="n">${trips.filter(t=>t.status==='bookada').length}</div><div class="l">Viagens bookadas</div></div>
  <div class="card kpi"><div class="n">${pendentes().length}</div><div class="l">Aguardando aprovação</div></div>
  <div class="card kpi"><div class="n">${brl(gasto)}</div><div class="l">Custo total (viagens ativas)</div></div>
  <div class="card kpi"><div class="n">${orc?Math.round(gasto/orc*100):0}%</div><div class="l">do orçamento utilizado</div></div></div>
  <h2>Pendências</h2>${alerts().slice(0,4).map(x=>`<a class="card trip" href="#/trip/${x.id}"><b>${x.i} ${esc(x.t)}</b><div class="muted">${esc(x.s)}</div></a>`).join('')||'<p class="muted">Sem pendências.</p>'}`;
}

/* ---------- Lista de viagens ---------- */
let filtro='todas',busca='';
function list(){
  const fs=['todas','bookada','solicitada','andamento','concluida','cancelada'];
  const rows=trips.filter(t=>(filtro==='todas'||t.status===filtro)&&(t.destino+t.motivo+t.id).toLowerCase().includes(busca.toLowerCase())).sort((a,b)=>b.inicio.localeCompare(a.inicio));
  view.innerHTML=`<input id="q" placeholder="🔍 Buscar destino, motivo ou código" value="${esc(busca)}">
  <div class="chips">${fs.map(f=>`<button class="chip ${f===filtro?'on':''}" data-f="${f}">${f==='todas'?'Todas':ST[f]}</button>`).join('')}</div>
  ${rows.map(tripCard).join('')||'<p class="muted">Nenhuma viagem encontrada.</p>'}`;
  $('#q').oninput=e=>{busca=e.target.value;const p=e.target.selectionStart;list();const q=$('#q');q.focus();q.setSelectionRange(p,p)};
  view.querySelectorAll('[data-f]').forEach(b=>b.onclick=()=>{filtro=b.dataset.f;list()});
}

/* ---------- Detalhe ---------- */
let dtab='resumo';
function detail(id){
  const t=trips.find(x=>x.id===id); if(!t){location.hash='#/trips';return}
  const tabs=[['resumo','Resumo'],['roteiro','Roteiro'],['custos','Custos'],['aprov','Aprovações'],['docs','Documentos']];
  const body={resumo:()=>resumo(t),roteiro:()=>roteiro(t),custos:()=>custosTrip(t),aprov:()=>aprovTrip(t),docs:()=>docs(t)}[dtab]();
  view.innerHTML=`<div class="card"><div style="display:flex;justify-content:space-between;align-items:flex-start;gap:8px"><div><div class="dest" style="font-size:19px;font-weight:700">${esc(t.destino)}</div>
  <div class="muted">${esc(t.id)} · ${esc(t.tipo)}</div></div>${pill(t.status)}</div>
  <div style="margin-top:8px">${dt(t.inicio)} → ${dt(t.fim)} (${days(t.inicio,t.fim)} noites)</div><div class="muted">${esc(t.motivo)}</div></div>
  <div class="tabs">${tabs.map(x=>`<button class="tab ${x[0]===dtab?'on':''}" data-t="${x[0]}">${x[1]}</button>`).join('')}</div>${body}`;
  view.querySelectorAll('[data-t]').forEach(b=>b.onclick=()=>{dtab=b.dataset.t;detail(id)});
  view.querySelectorAll('[data-act]').forEach(b=>b.onclick=()=>act(t,b.dataset.act));
}
function resumo(t){
  const tot=total(t);
  return`${(t.alertas||[]).map(a=>`<div class="alert">⚠️ ${esc(a)}</div>`).join('')}
  <div class="card"><table><tr><td>Origem</td><td>${esc(t.origem)}</td></tr><tr><td>Centro de custo</td><td>${esc(t.centro)}</td></tr>
  <tr><td>Solicitante</td><td>${esc(P.nome)} (${esc(P.funcional)})</td></tr><tr><td>Orçamento aprovado</td><td>${brl(t.orcamento)}</td></tr>
  <tr><td>Custo total previsto</td><td><b>${brl(tot)}</b></td></tr><tr><td>Saldo</td><td style="color:${t.orcamento-tot<0?'var(--bad)':'var(--ok)'}">${brl(t.orcamento-tot)}</td></tr>
  <tr><td>Passagens / Hotéis</td><td>${t.voos.length} / ${t.hoteis.length}</td></tr></table></div>
  <div class="grid"><button class="btn ghost" data-act="ics">📅 Adicionar à agenda</button><button class="btn ghost" data-act="share">📤 Compartilhar</button></div>
  ${['solicitada','bookada'].includes(t.status)?`<p><button class="btn ghost block" data-act="cancel">Cancelar viagem</button></p>`:''}
  ${t.status==='concluida'&&t.prestacao==='pendente'?`<p><button class="btn block" data-act="prestar">🧾 Finalizar prestação de contas</button></p>`:''}`;
}
function roteiro(t){
  const ev=[];
  t.voos.forEach(v=>ev.push({d:v.saida,t:`✈️ ${v.cia} ${v.num}: ${v.de} → ${v.para}`,s:`Chegada ${dt(v.chegada)} · ${v.classe} · assento ${v.assento} · loc. ${v.loc}`}));
  t.hoteis.forEach(h=>{ev.push({d:h.checkin+' 15:00',t:`🏨 Check-in: ${h.nome}`,s:`${h.cidade} · ${h.noites} noite(s) · loc. ${h.loc}`});ev.push({d:h.checkout+' 12:00',t:`🏨 Check-out: ${h.nome}`,s:h.cancelamento?'Cancelamento: '+h.cancelamento:''})});
  ev.sort((a,b)=>a.d.localeCompare(b.d));
  return ev.length?`<div class="tl">${ev.map(e=>`<div><div class="t">${esc(e.t)}</div><div class="d">${dt(e.d)}</div><div class="d">${esc(e.s)}</div></div>`).join('')}</div>`:'<p class="muted">Sem itens reservados.</p>';
}
function custosTrip(t){
  const row=(i,x,main,sub)=>`<tr><td>${i} ${esc(main)}<div class="muted">${esc(sub)} · ${x.status}</div></td><td>${brl(x.valor)}</td></tr>`;
  return`<div class="card"><b>Passagens</b><table>${t.voos.map(v=>row('✈️',v,`${v.de}→${v.para} ${v.cia}`,v.classe)).join('')||'<tr><td class="muted">—</td><td></td></tr>'}</table></div>
  <div class="card"><b>Hospedagem</b><table>${t.hoteis.map(h=>row('🏨',h,h.nome,`${h.noites}× ${brl(h.diaria)}${h.diaria>P.alcadaDiaria&&t.tipo==='Nacional'?' · ⚠ acima da política':''}`)).join('')||'<tr><td class="muted">—</td><td></td></tr>'}</table></div>
  <div class="card"><b>Outras despesas</b><table>${t.extras.map(x=>row('🧾',x,x.desc,'')).join('')||'<tr><td class="muted">—</td><td></td></tr>'}</table></div>
  <div class="card"><div style="display:flex;justify-content:space-between"><b>Total</b><b>${brl(total(t))}</b></div><div class="muted">Já pago: ${brl(spent(t))} · Orçamento ${brl(t.orcamento)}</div></div>
  ${t.status!=='cancelada'?`<button class="btn block" data-act="expense">＋ Lançar despesa</button>`:''}`;
}
function aprovTrip(t){
  return`<div class="card">${t.aprovacoes.map(a=>`<div class="step"><div class="dot ${a.status}">${a.status==='ok'?'✓':a.status==='negado'?'✕':a.status==='pendente'?'…':'·'}</div>
  <div><b>${esc(a.etapa)}</b><div class="muted">${esc(a.quem)}${a.data?' · '+dt(a.data):''}</div>${a.obs?`<div>${esc(a.obs)}</div>`:''}</div></div>`).join('')}</div>`;
}
function docs(t){return`<div class="card">${t.documentos.map(d=>`<div style="padding:7px 0;border-bottom:1px solid var(--line)">📄 ${esc(d)}</div>`).join('')||'<span class="muted">Sem documentos.</span>'}</div>
  <div class="card"><b>Contatos de emergência</b>${window.CONTACTS.map(c=>`<div style="padding:7px 0"><a href="tel:${c.fone.replace(/[^+\d]/g,'')}" style="color:var(--red);text-decoration:none"><b>${esc(c.nome)}</b> · ${esc(c.fone)}</a><div class="muted">${esc(c.obs)}</div></div>`).join('')}</div>`;}

/* ---------- ações ---------- */
function act(t,a){
  if(a==='ics'){
    const f=s=>s.replace(/-/g,'');
    const ics=`BEGIN:VCALENDAR\nVERSION:2.0\nBEGIN:VEVENT\nUID:${t.id}@bpb\nDTSTART;VALUE=DATE:${f(t.inicio)}\nDTEND;VALUE=DATE:${f(t.fim)}\nSUMMARY:Viagem ${t.destino} – ${t.motivo}\nEND:VEVENT\nEND:VCALENDAR`;
    const l=document.createElement('a');l.href=URL.createObjectURL(new Blob([ics],{type:'text/calendar'}));l.download=t.id+'.ics';l.click();
  }
  if(a==='share'){const txt=`Viagem ${t.destino} (${dt(t.inicio)}–${dt(t.fim)})\n${t.voos.map(v=>`${v.cia} ${v.num} ${v.de}-${v.para} ${dt(v.saida)} loc ${v.loc}`).join('\n')}\n${t.hoteis.map(h=>`${h.nome} ${dt(h.checkin)}–${dt(h.checkout)}`).join('\n')}`;
    navigator.share?navigator.share({title:'Itinerário',text:txt}).catch(()=>{}):(navigator.clipboard&&navigator.clipboard.writeText(txt),toast('Itinerário copiado'))}
  if(a==='cancel'&&confirm('Cancelar esta viagem? A agência será notificada.')){t.status='cancelada';save();toast('Viagem cancelada');detail(t.id)}
  if(a==='prestar'){t.prestacao='enviada';save();toast('Prestação de contas enviada ao gestor');detail(t.id)}
  if(a==='expense')sheet(`<h2>Lançar despesa</h2><label>Descrição</label><input id="ed" placeholder="Ex.: Táxi aeroporto"><label>Valor (R$)</label><input id="ev" type="number" inputmode="decimal"><button class="btn block" id="es">Salvar</button>`,()=>{
    $('#es').onclick=()=>{const v=parseFloat($('#ev').value);if(!$('#ed').value||!(v>0))return toast('Preencha descrição e valor');t.extras.push({desc:$('#ed').value,valor:v,status:'pago'});save();closeSheet();dtab='custos';detail(t.id)}});
}
function newTrip(){
  sheet(`<h2>Nova solicitação de viagem</h2>
  <label>Destino</label><input id="nd" placeholder="Cidade, País">
  <label>Tipo</label><select id="nt"><option>Nacional</option><option>Internacional</option></select>
  <label>Ida</label><input id="ni" type="date"><label>Volta</label><input id="nf" type="date">
  <label>Motivo / justificativa</label><textarea id="nm" rows="2"></textarea>
  <label>Orçamento estimado (R$)</label><input id="no" type="number" inputmode="decimal">
  <button class="btn block" id="ns">Enviar para aprovação</button>`,()=>{
    $('#ns').onclick=()=>{
      const d=$('#nd').value,i=$('#ni').value,f=$('#nf').value,o=parseFloat($('#no').value)||0;
      if(!d||!i||!f||f<i)return toast('Verifique destino e datas');
      const intl=$('#nt').value==='Internacional',al=[];
      if(days(today,i)<(intl?14:7))al.push(`Antecedência menor que ${intl?14:7} dias (fora da política)`);
      const n=trips.length+1;
      trips.unshift({id:`V-2026-${String(300+n).padStart(4,'0')}`,destino:d,origem:'São Paulo',tipo:$('#nt').value,motivo:$('#nm').value||'—',inicio:i,fim:f,status:'solicitada',orcamento:o,centro:'CC 4410',voos:[],hoteis:[],extras:[],alertas:al,documentos:[],
        aprovacoes:[{etapa:'Solicitante',quem:'Você',status:'ok',data:today,obs:'Solicitação enviada'},{etapa:'Gestor imediato',quem:'Gestor',status:'pendente',data:'',obs:'Aguardando análise'},...(intl?[{etapa:'Compliance',quem:'Compliance',status:'aguardando',data:'',obs:''}]:[]),{etapa:'Agência / Emissão',quem:'Agência',status:'aguardando',data:'',obs:''}]});
      save();closeSheet();toast('Solicitação enviada');location.hash='#/trips'}});
}

/* ---------- Aprovações ---------- */
function appr(){
  const p=pendentes(),h=trips.filter(t=>t.status!=='solicitada');
  view.innerHTML=`<h2>Em análise (${p.length})</h2>${p.map(t=>`${tripCard(t)}<div class="card">${aprovTrip(t).replace('<div class="card">','<div>')}</div>`).join('')||'<p class="muted">Nenhuma solicitação pendente.</p>'}
  <h2>Histórico</h2>${h.map(t=>{const u=[...t.aprovacoes].reverse().find(a=>a.status==='ok'||a.status==='negado');return`<a class="card trip" href="#/trip/${t.id}"><b>${esc(t.destino)}</b> ${pill(t.status)}<div class="muted">${u?esc(u.etapa)+' · '+dt(u.data)+' · '+esc(u.obs||''):''}</div></a>`}).join('')}`;
}

/* ---------- Custos ---------- */
function costs(){
  const act=trips.filter(t=>!['cancelada','solicitada'].includes(t.status));
  const cat={Passagens:0,Hospedagem:0,Outros:0};
  act.forEach(t=>{t.voos.forEach(x=>cat.Passagens+=x.valor);t.hoteis.forEach(x=>cat.Hospedagem+=x.valor);t.extras.forEach(x=>cat.Outros+=x.valor)});
  const tot=Object.values(cat).reduce((a,b)=>a+b,0)||1,orc=act.reduce((s,t)=>s+t.orcamento,0);
  const pagos=act.reduce((s,t)=>s+spent(t),0);
  view.innerHTML=`<div class="grid"><div class="card kpi"><div class="n">${brl(tot)}</div><div class="l">Custo total</div></div><div class="card kpi"><div class="n">${brl(orc)}</div><div class="l">Orçamento</div></div>
  <div class="card kpi"><div class="n">${brl(pagos)}</div><div class="l">Já pago</div></div><div class="card kpi"><div class="n">${brl(tot-pagos)}</div><div class="l">A pagar / previsto</div></div></div>
  <h2>Por categoria</h2><div class="card">${Object.entries(cat).map(([k,v])=>`<div style="margin-bottom:10px"><div style="display:flex;justify-content:space-between"><span>${k}</span><b>${brl(v)}</b></div><div class="bar"><i style="width:${v/tot*100}%"></i></div></div>`).join('')}</div>
  <h2>Por viagem (orçado × previsto)</h2>${act.map(t=>`<a class="card trip" href="#/trip/${t.id}"><div style="display:flex;justify-content:space-between"><b>${esc(t.destino)}</b><span>${brl(total(t))}</span></div><div class="bar ${total(t)>t.orcamento?'over':''}"><i style="width:${Math.min(100,total(t)/t.orcamento*100)}%"></i></div><div class="muted">Orçamento ${brl(t.orcamento)}</div></a>`).join('')}
  <h2>Reembolsos / prestação de contas</h2>${trips.filter(t=>t.status==='concluida').map(t=>`<a class="card trip" href="#/trip/${t.id}"><b>${esc(t.destino)}</b><div class="muted">Prestação: ${t.prestacao==='pendente'?'⚠ pendente':'enviada ✔'}</div></a>`).join('')}`;
}

/* ---------- Mais ---------- */
function more(){
  const th=LS.get('bpb_theme','auto');
  view.innerHTML=`<div class="card"><div class="profile"><div class="avatar">${P.nome.split(' ').map(x=>x[0]).slice(0,2).join('')}</div><div><b>${esc(P.nome)}</b><div class="muted">Funcional ${esc(P.funcional)}</div><div class="muted">${esc(P.cargo)} · ${esc(P.centroCusto)}</div></div></div>
  <table style="margin-top:8px"><tr><td>Gestor</td><td>${esc(P.gestor)}</td></tr><tr><td>Cartão corporativo</td><td>${esc(P.cartaoCorporativo)}</td></tr></table></div>
  <h2>Política de viagens</h2><div class="card">${window.POLICY.map(p=>`<p style="margin:0 0 8px">• ${esc(p)}</p>`).join('')}</div>
  <h2>Contatos</h2><div class="card">${window.CONTACTS.map(c=>`<p style="margin:0 0 8px"><a href="tel:${c.fone.replace(/[^+\d]/g,'')}" style="color:var(--red);text-decoration:none"><b>${esc(c.nome)}</b> · ${esc(c.fone)}</a><br><span class="muted">${esc(c.obs)}</span></p>`).join('')}</div>
  <h2>Preferências</h2><div class="card"><label>Tema</label><select id="th"><option value="auto">Automático</option><option value="light">Claro</option><option value="dark">Escuro</option></select>
  <button class="btn ghost block" id="rs">Restaurar dados de demonstração</button></div>
  <p class="muted right">Dados provisórios para demonstração · v1.0</p>`;
  $('#th').value=th;$('#th').onchange=e=>{LS.set('bpb_theme',e.target.value);applyTheme()};
  $('#rs').onclick=()=>{if(confirm('Apagar alterações e restaurar dados de exemplo?')){trips=JSON.parse(JSON.stringify(window.TRIPS));save();toast('Dados restaurados');render()}};
}
function applyTheme(){const t=LS.get('bpb_theme','auto');t==='auto'?document.documentElement.removeAttribute('data-theme'):document.documentElement.setAttribute('data-theme',t)}
applyTheme();
if('serviceWorker' in navigator&&location.protocol.startsWith('http'))navigator.serviceWorker.register('sw.js').catch(()=>{});
render();
})();
