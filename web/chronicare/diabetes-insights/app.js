(function () {
  'use strict';

  /* ---------- labels ---------- */
  var LABELS = {
    age: ['18-24', '25-34', '35-44', '45-54', '55-64', '65+'],
    sex: ['Female', 'Male'],
    edu: ['No school', 'Grades 1-8', 'Grades 9-11', 'HS graduate', 'Some college', 'College grad'],
    inc: ['<$10k', '$10-15k', '$15-20k', '$20-25k', '$25-35k', '$35-50k', '$50-75k', '$75k+'],
    st: ['No diabetes', 'Prediabetes', 'Diabetes'],
    bmi: ['Underweight', 'Normal', 'Overweight', 'Obese'],
    hbp: ['No high BP', 'High BP'],
    hch: ['Normal cholesterol', 'High cholesterol'],
    pa: ['No activity', 'Active'],
    cm: ['0', '1', '2', '3', '4'],
    gh: ['Excellent', 'Very good', 'Good', 'Fair', 'Poor'],
    dw: ['No difficulty', 'Difficulty walking'],
    md: ['None', '1-10 days', '11-20 days', '21-30 days'],
    pd: ['None', '1-10 days', '11-20 days', '21-30 days']
  };
  var EDU_LONG = ['Never attended / kindergarten only', 'Grades 1-8', 'Grades 9-11', 'High school graduate',
    'Some college or technical school', 'College graduate'];
  var INC_LONG = ['Under $10,000', '$10,000-$15,000', '$15,000-$20,000', '$20,000-$25,000', '$25,000-$35,000',
    '$35,000-$50,000', '$50,000-$75,000', '$75,000 or more'];
  var C = { no: '#5EEAD4', pre: '#FBBF24', dia: '#FB7185', cyan: '#74C0FC', blue: '#3B82F6' };
  var AGE_COLORS = ['#DBEAFE', '#BAE6FD', '#7DD3FC', '#38BDF8', '#0EA5E9', '#3B82F6'];
  var GROUPS = [
    { dim: 'age', title: 'Age' }, { dim: 'sex', title: 'Sex' }, { dim: 'edu', title: 'Education' },
    { dim: 'inc', title: 'Income' }, { dim: 'bmi', title: 'BMI category' }
  ];
  var FDIMS = GROUPS.map(function (g) { return g.dim; });

  /* ---------- decode packed data ---------- */
  var D = window.BRFSS_DATA, U = D.n;
  var bin = atob(D.b64), bytes = new Uint8Array(bin.length);
  for (var i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  var words = new Uint32Array(bytes.buffer, 0, U);
  var cnt = new Uint16Array(bytes.buffer, U * 4, U);
  var cols = {};
  Object.keys(D.layout).forEach(function (k) {
    var sh = D.layout[k][0], mask = (1 << D.layout[k][1]) - 1, a = new Uint8Array(U);
    for (var j = 0; j < U; j++) a[j] = (words[j] >>> sh) & mask;
    cols[k] = a;
  });
  var TOTAL = 0; for (var t = 0; t < U; t++) TOTAL += cnt[t];

  /* ---------- state & engine ---------- */
  var F = {}; FDIMS.forEach(function (d) { F[d] = new Set(); });
  var state = { tab: 'overview', heat: 'n' };

  function agg(keys, skip) {
    skip = skip || [];
    var act = [];
    FDIMS.forEach(function (d) {
      if (F[d].size && skip.indexOf(d) < 0) {
        var m = new Uint8Array(LABELS[d].length); F[d].forEach(function (x) { m[x] = 1; });
        act.push([cols[d], m]);
      }
    });
    var size = 1, mult = [];
    keys.forEach(function (k) { mult.push(size); size *= LABELS[k].length; });
    var r = { n: new Float64Array(size), d: new Float64Array(size), p: new Float64Array(size), b: new Float64Array(size), mult: mult, keys: keys, size: size };
    var st = cols.st, hb = cols.hbp, kc = keys.map(function (k) { return cols[k]; });
    for (var i = 0; i < U; i++) {
      var ok = true;
      for (var a = 0; a < act.length; a++) { if (!act[a][1][act[a][0][i]]) { ok = false; break; } }
      if (!ok) continue;
      var idx = 0;
      for (var j = 0; j < kc.length; j++) idx += kc[j][i] * mult[j];
      var w = cnt[i];
      r.n[idx] += w;
      if (st[i] === 2) r.d[idx] += w; else if (st[i] === 1) r.p[idx] += w;
      if (hb[i]) r.b[idx] += w;
    }
    return r;
  }
  function ix(r) { var s = 0; for (var i = 0; i < arguments.length - 1; i++) s += arguments[i + 1] * r.mult[i]; return s; }
  function prevOf(r, i) { return r.n[i] > 0 ? r.d[i] / r.n[i] : null; }
  function preOf(r, i) { return r.n[i] > 0 ? r.p[i] / r.n[i] : null; }
  function sum(arr) { var s = 0; for (var i = 0; i < arr.length; i++) s += arr[i]; return s; }

  var ALL = null; // unfiltered totals
  function allTotals() {
    if (!ALL) {
      var saved = {}; FDIMS.forEach(function (d) { saved[d] = F[d]; F[d] = new Set(); });
      ALL = agg([]); FDIMS.forEach(function (d) { F[d] = saved[d]; });
    }
    return ALL;
  }

  /* ---------- helpers ---------- */
  function esc(s) { return String(s).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }
  function int(n) { return Math.round(n).toLocaleString('en-US'); }
  function pct(v, d) { return v == null ? '-' : (v * 100).toFixed(d == null ? 1 : d) + '%'; }
  function tipAttr(s) { return ' data-tip="' + esc(s) + '"'; }
  function clickAttr(c) { return c.dim ? ' data-dim="' + c.dim + '" data-idx="' + c.idx + '"' : ''; }
  function groupCats(dim, selectable) {
    return LABELS[dim].map(function (l, i) {
      return { label: l, dim: selectable ? dim : null, idx: i, sel: selectable && F[dim].size ? F[dim].has(i) : null };
    });
  }
  function lowN(n) { return n < 100 ? '\n(small sample: n=' + int(n) + ')' : ''; }

  /* ---------- charts ---------- */
  function legend(series) {
    return '<div class="legend">' + series.map(function (s) { return '<span><i style="background:' + s.color + '"></i>' + esc(s.name) + '</span>'; }).join('') + '</div>';
  }

  // grouped vertical columns. series[].vals may contain null. series[].tips[i] optional
  function colChart(o) {
    var W = 560, H = o.h || 250, top = 26, bot = 34, pad = 10, ph = H - top - bot;
    var nC = o.cats.length, nS = o.series.length;
    var vals = []; o.series.forEach(function (s) { s.vals.forEach(function (v) { if (v != null) vals.push(v); }); });
    var max = Math.max.apply(null, vals.concat([1e-9])) * 1.12;
    var gw = (W - 2 * pad) / nC, bw = Math.min(54, gw * 0.74 / nS), g = '';
    g += '<line class="axis" x1="' + pad + '" x2="' + (W - pad) + '" y1="' + (top + ph) + '" y2="' + (top + ph) + '"/>';
    o.cats.forEach(function (c, i) {
      var cx = pad + gw * i + gw / 2, f = c.sel === false ? ' fade' : '';
      o.series.forEach(function (s, j) {
        var v = s.vals[i], bh = v == null ? 0 : v / max * ph;
        var x = cx - nS * bw / 2 + j * bw, y = top + ph - bh;
        var tip = c.label + (nS > 1 ? ' - ' + s.name : '') + '\n' + (v == null ? 'no data' : s.fmt(v)) + (s.tips ? '\n' + s.tips[i] : '');
        g += '<rect class="bar' + f + (c.dim ? ' click' : '') + '" x="' + x.toFixed(1) + '" y="' + y.toFixed(1) + '" width="' + (bw - 2).toFixed(1) + '" height="' + Math.max(bh, 0).toFixed(1) + '" rx="4" fill="' + s.color + '"' + tipAttr(tip) + clickAttr(c) + '/>';
        g += '<text class="val' + f + '" x="' + (x + bw / 2 - 1).toFixed(1) + '" y="' + (y - 6).toFixed(1) + '" text-anchor="middle">' + (v == null ? '-' : s.fmt(v)) + '</text>';
      });
      g += '<text class="xl' + f + '" x="' + cx.toFixed(1) + '" y="' + (H - 12) + '" text-anchor="middle">' + esc(c.label) + '</text>';
    });
    return '<svg viewBox="0 0 ' + W + ' ' + H + '" role="img" aria-label="' + esc(o.aria || '') + '">' + g + '</svg>' + (nS > 1 ? legend(o.series) : '');
  }

  // grouped horizontal bars
  function barChart(o) {
    var W = 560, labW = o.labW || 112, rightPad = 64, nS = o.series.length;
    var gh = nS === 1 ? 34 : 50, bh = nS === 1 ? 20 : 18;
    var H = o.cats.length * gh + 10, g = '';
    var vals = []; o.series.forEach(function (s) { s.vals.forEach(function (v) { if (v != null) vals.push(v); }); });
    var max = Math.max.apply(null, vals.concat([1e-9])) * 1.02, aw = W - labW - rightPad;
    o.cats.forEach(function (c, i) {
      var y0 = 6 + i * gh, f = c.sel === false ? ' fade' : '';
      g += '<text class="yl' + f + '" x="' + (labW - 10) + '" y="' + (y0 + (gh - 8) / 2 + 4) + '" text-anchor="end">' + esc(c.label) + '</text>';
      o.series.forEach(function (s, j) {
        var v = s.vals[i], w = v == null ? 0 : v / max * aw, y = y0 + (gh - 8 - nS * bh - (nS - 1) * 2) / 2 + j * (bh + 2);
        var tip = c.label + (nS > 1 ? ' - ' + s.name : '') + '\n' + (v == null ? 'no data' : s.fmt(v)) + (s.tips ? '\n' + s.tips[i] : '');
        g += '<rect class="bar' + f + (c.dim ? ' click' : '') + '" x="' + labW + '" y="' + y.toFixed(1) + '" width="' + Math.max(w, 0).toFixed(1) + '" height="' + bh + '" rx="4" fill="' + s.color + '"' + tipAttr(tip) + clickAttr(c) + '/>';
        g += '<text class="val' + f + '" x="' + (labW + w + 7).toFixed(1) + '" y="' + (y + bh / 2 + 4).toFixed(1) + '">' + (v == null ? '-' : s.fmt(v)) + '</text>';
      });
    });
    return '<svg viewBox="0 0 ' + W + ' ' + H + '" role="img" aria-label="' + esc(o.aria || '') + '">' + g + '</svg>' + (nS > 1 ? legend(o.series) : '');
  }

  // 100% stacked; series[].vals are counts per category
  function stackChart(o) {
    var W = 560, g = '', nC = o.cats.length;
    var totals = o.cats.map(function (c, i) { return o.series.reduce(function (a, s) { return a + s.vals[i]; }, 0); });
    function segLabel(p) { return p >= 0.07 ? Math.round(p * 100) + '%' : ''; }
    var H;
    if (o.horizontal) {
      var labW = o.labW || 112, gh = 56; H = nC * gh + 6; var aw = W - labW - 10;
      o.cats.forEach(function (c, i) {
        var y = 8 + i * gh, x = labW, f = c.sel === false ? ' fade' : '';
        g += '<text class="yl' + f + '" x="' + (labW - 10) + '" y="' + (y + 24) + '" text-anchor="end">' + esc(c.label) + '</text>';
        o.series.forEach(function (s) {
          var p = totals[i] ? s.vals[i] / totals[i] : 0, w = p * aw;
          g += '<rect class="seg-r' + f + '" x="' + x.toFixed(1) + '" y="' + y + '" width="' + w.toFixed(1) + '" height="38" fill="' + s.color + '"' + tipAttr(c.label + ' - ' + s.name + '\n' + pct(p) + ' (' + int(s.vals[i]) + ' of ' + int(totals[i]) + ')') + '/>';
          if (segLabel(p)) g += '<text class="seg" x="' + (x + w / 2).toFixed(1) + '" y="' + (y + 24) + '" text-anchor="middle">' + segLabel(p) + '</text>';
          x += w;
        });
      });
    } else {
      var top = 8, bot = 34; H = o.h || 270; var ph = H - top - bot, gw = (W - 20) / nC, bw = Math.min(70, gw * 0.78);
      o.cats.forEach(function (c, i) {
        var cx = 10 + gw * i + gw / 2, yb = top + ph;
        o.series.forEach(function (s) {
          var p = totals[i] ? s.vals[i] / totals[i] : 0, h = p * ph; yb -= h;
          g += '<rect class="seg-r" x="' + (cx - bw / 2).toFixed(1) + '" y="' + yb.toFixed(1) + '" width="' + bw.toFixed(1) + '" height="' + h.toFixed(1) + '" fill="' + s.color + '"' + tipAttr(c.label + ' - ' + s.name + '\n' + pct(p) + ' (' + int(s.vals[i]) + ' of ' + int(totals[i]) + ')') + '/>';
          if (segLabel(p)) g += '<text class="seg" x="' + cx.toFixed(1) + '" y="' + (yb + h / 2 + 4).toFixed(1) + '" text-anchor="middle">' + segLabel(p) + '</text>';
        });
        g += '<text class="xl" x="' + cx.toFixed(1) + '" y="' + (H - 12) + '" text-anchor="middle">' + esc(c.label) + '</text>';
      });
    }
    return '<svg viewBox="0 0 ' + W + ' ' + H + '" role="img" aria-label="' + esc(o.aria || '') + '">' + g + '</svg>' + legend(o.series.slice().reverse());
  }

  function donut(o) {
    var total = o.cats.reduce(function (a, c) { return a + c.value; }, 0), cx = 105, cy = 105, R = 92, r = 58, ang = -Math.PI / 2, g = '';
    o.cats.forEach(function (c) {
      var p = total ? c.value / total : 0, a2 = ang + p * 2 * Math.PI, f = c.sel === false ? ' fade' : '';
      var tip = c.label + '\n' + int(c.value) + ' respondents (' + pct(p) + ')';
      if (p >= 0.9999) {
        g += '<circle class="slice' + f + (c.dim ? ' click' : '') + '" cx="' + cx + '" cy="' + cy + '" r="' + ((R + r) / 2) + '" fill="none" stroke="' + c.color + '" stroke-width="' + (R - r) + '"' + tipAttr(tip) + clickAttr(c) + '/>';
      } else if (p > 0) {
        var x1 = cx + R * Math.cos(ang), y1 = cy + R * Math.sin(ang), x2 = cx + R * Math.cos(a2), y2 = cy + R * Math.sin(a2);
        var x3 = cx + r * Math.cos(a2), y3 = cy + r * Math.sin(a2), x4 = cx + r * Math.cos(ang), y4 = cy + r * Math.sin(ang), lg = p > 0.5 ? 1 : 0;
        g += '<path class="slice' + f + (c.dim ? ' click' : '') + '" d="M' + x1.toFixed(2) + ' ' + y1.toFixed(2) + 'A' + R + ' ' + R + ' 0 ' + lg + ' 1 ' + x2.toFixed(2) + ' ' + y2.toFixed(2) + 'L' + x3.toFixed(2) + ' ' + y3.toFixed(2) + 'A' + r + ' ' + r + ' 0 ' + lg + ' 0 ' + x4.toFixed(2) + ' ' + y4.toFixed(2) + 'Z" fill="' + c.color + '" stroke="rgba(6,43,110,.7)" stroke-width="1.5"' + tipAttr(tip) + clickAttr(c) + '/>';
      }
      ang = a2;
    });
    g += '<text x="' + cx + '" y="' + (cy + 2) + '" text-anchor="middle" style="font-size:22px;font-weight:200">' + int(total) + '</text>';
    g += '<text x="' + cx + '" y="' + (cy + 20) + '" text-anchor="middle" style="font-size:11px;fill:rgba(255,255,255,.6)">respondents</text>';
    var li = o.cats.map(function (c) {
      return '<li class="' + (c.sel === false ? 'fade' : '') + '"' + clickAttr(c) + '><i style="background:' + c.color + '"></i>' + esc(c.label) + '<span>' + pct(total ? c.value / total : 0) + '</span></li>';
    }).join('');
    return '<div class="donut"><svg viewBox="0 0 210 210" role="img" aria-label="' + esc(o.aria || '') + '">' + g + '</svg><ul>' + li + '</ul></div>';
  }

  // heat table. cell(r,c) -> {v, text, sub, tip}; v null => empty
  function heat(o) {
    var vs = [], cells = [];
    o.rows.forEach(function (_, r) { cells[r] = []; o.cols.forEach(function (__, c) { var x = o.cell(r, c); cells[r][c] = x; if (x.v != null) vs.push(x.v); }); });
    var min = Math.min.apply(null, vs.concat([0])), max = Math.max.apply(null, vs.concat([1e-9])), rgb = o.rgb;
    var h = '<table class="heat" role="table"><thead><tr><th class="corner">' + esc(o.rowTitle) + ' / ' + esc(o.colTitle) + '</th>' +
      o.cols.map(function (c) { return '<th>' + esc(c) + '</th>'; }).join('') + '</tr></thead><tbody>';
    o.rows.forEach(function (rl, r) {
      h += '<tr><th class="rh">' + esc(rl) + '</th>';
      o.cols.forEach(function (_, c) {
        var x = cells[r][c], t = x.v == null ? 0 : (x.v - min) / (max - min || 1);
        var bg = 'rgba(' + rgb + ',' + (0.1 + 0.85 * t).toFixed(2) + ')', fg = t > 0.55 ? '#062B6E' : '#fff';
        h += '<td style="background:' + bg + ';color:' + fg + '"' + tipAttr(x.tip) + '>' + x.text + (x.sub ? '<small>' + x.sub + '</small>' : '') + '</td>';
      });
      h += '</tr>';
    });
    return h + '</tbody></table>';
  }

  /* ---------- layout helpers ---------- */
  function panel(cls, title, sub, body, extra) {
    return '<section class="card panel ' + cls + '"><div class="ph"><div><h3>' + title + '</h3>' + (sub ? '<p class="sub">' + sub + '</p>' : '') + '</div>' + (extra || '') + '</div>' + body + '</section>';
  }
  function kpi(label, value, cmp, color) {
    return '<section class="card kpi s3"><div class="lbl">' + label + '</div><div class="big" style="color:' + color + '">' + value + '</div><div class="cmp">' + cmp + '</div></section>';
  }
  function insight(html) { return '<section class="card insight s12">' + html + '</section>'; }
  var pctFmt = function (v) { return pct(v); };
  var intFmt = function (v) { return int(v); };

  function prevSeries(dim, color, name, skipSelf) {
    var r = agg([dim], skipSelf ? [dim] : []);
    return { name: name || 'Diabetes prevalence', color: color, fmt: pctFmt,
      vals: LABELS[dim].map(function (_, i) { return prevOf(r, i); }),
      tips: LABELS[dim].map(function (_, i) { return 'n = ' + int(r.n[i]) + lowN(r.n[i]); }) };
  }

  /* ---------- pages ---------- */
  function pageOverview() {
    var t = agg([]), A = allTotals(), n = t.n[0];
    var dp = n ? t.d[0] / n : null, pp = n ? t.p[0] / n : null, hp = n ? t.b[0] / n : null;
    var dA = A.d[0] / A.n[0], pA = A.p[0] / A.n[0], hA = A.b[0] / A.n[0];
    var filtered = FDIMS.some(function (d) { return F[d].size; });
    function cmp(a) { return filtered ? 'All respondents: ' + a : 'Whole survey'; }
    var status = agg(['st']);
    var statusCats = LABELS.st.map(function (l, i) {
      return { label: l, color: [C.no, C.pre, C.dia][i], v: status.n[i] };
    });
    var ageR = agg(['age'], ['age']);
    var ageCats = groupCats('age', true).map(function (c, i) { c.value = ageR.n[i]; c.color = AGE_COLORS[i]; return c; });
    var ins = n ? 'In this selection <b>' + pct(dp) + '</b> of the <b>' + int(n) + '</b> respondents report diabetes' + (filtered ? ' (<b>' + pct(dA) + '</b> in the full survey)' : '') +
      ', and a further <b>' + pct(pp) + '</b> report prediabetes. <b>' + pct(hp) + '</b> report high blood pressure.' : 'No respondents match this combination of filters.';
    var h = '<div class="grid enter">' +
      kpi('Total respondents', int(n), filtered ? pct(n / TOTAL) + ' of ' + int(TOTAL) : 'CDC BRFSS 2015', '#fff') +
      kpi('Diabetes prevalence', pct(dp), cmp(pct(dA)), C.dia) +
      kpi('Prediabetes prevalence', pct(pp), cmp(pct(pA)), C.pre) +
      kpi('High blood pressure', pct(hp), cmp(pct(hA)), C.cyan) +
      insight(ins) +
      panel('s6', 'Respondents by diabetes status', 'Count of respondents in the current selection', statusBars(statusCats)) +
      panel('s6', 'Respondent mix by age', 'Click a slice to filter by age band', donut({ aria: 'Respondent mix by age band', cats: ageCats })) +
      panel('s6', 'Diabetes prevalence by age', 'Click a bar to filter',
        colChart({ aria: 'Diabetes prevalence by age band', cats: groupCats('age', true), series: [prevSeries('age', C.dia, 'Diabetes', true)] })) +
      panel('s6', 'Diabetes prevalence by BMI category', 'Click a bar to filter',
        colChart({ aria: 'Diabetes prevalence by BMI category', cats: groupCats('bmi', true), series: [prevSeries('bmi', C.dia, 'Diabetes', true)] })) +
      '</div>';
    return h;
  }
  function statusBars(cs) {
    var W = 560, labW = 100, aw = W - labW - 90, max = Math.max.apply(null, cs.map(function (c) { return c.v; }).concat([1])), g = '';
    var tot = cs.reduce(function (a, c) { return a + c.v; }, 0);
    cs.forEach(function (c, i) {
      var y = 6 + i * 34, w = c.v / max * aw;
      g += '<text class="yl" x="' + (labW - 10) + '" y="' + (y + 18) + '" text-anchor="end">' + c.label + '</text>';
      g += '<rect class="bar" x="' + labW + '" y="' + y + '" width="' + w.toFixed(1) + '" height="22" rx="4" fill="' + c.color + '"' + tipAttr(c.label + '\n' + int(c.v) + ' respondents (' + pct(tot ? c.v / tot : 0) + ')') + '/>';
      g += '<text class="val" x="' + (labW + w + 7).toFixed(1) + '" y="' + (y + 16) + '">' + int(c.v) + '</text>';
    });
    return '<svg viewBox="0 0 ' + W + ' ' + (cs.length * 34 + 10) + '" role="img" aria-label="Respondents by diabetes status">' + g + '</svg>';
  }

  function statusSeries(r, dimKeyCount, getIdx) { // returns series [diabetes, prediabetes, none] counts per category
    var cats = dimKeyCount, d = [], p = [], nn = [];
    for (var i = 0; i < cats; i++) { var k = getIdx(i); d.push(r.d[k]); p.push(r.p[k]); nn.push(r.n[k] - r.d[k] - r.p[k]); }
    return [{ name: 'Diabetes', color: C.dia, vals: d }, { name: 'Prediabetes', color: C.pre, vals: p }, { name: 'No diabetes', color: C.no, vals: nn }];
  }

  function pageRisk() {
    var cm = agg(['cm']), hh = agg(['hbp', 'hch']), pa = agg(['pa']);
    var both = prevOf(hh, ix(hh, 1, 1)), none = prevOf(hh, ix(hh, 0, 0));
    var nb = hh.n[ix(hh, 1, 1)], nn = hh.n[ix(hh, 0, 0)];
    var ins = (both != null && none != null && nb >= 100 && nn >= 100 && none > 0)
      ? 'Respondents with <b>both</b> high blood pressure and high cholesterol have a diabetes prevalence of <b>' + pct(both) + '</b>, compared with <b>' + pct(none) + '</b> for those with neither (about <b>' + (both / none).toFixed(1) + 'x</b> higher). Risk factors overlap and compound.'
      : 'Too few respondents in the high-risk and low-risk corners to compare under the current filters.';
    var heatH = heat({
      rows: LABELS.hbp, cols: LABELS.hch, rowTitle: 'Blood pressure', colTitle: 'Cholesterol', rgb: '251,113,133',
      cell: function (r, c) { var k = ix(hh, r, c), v = prevOf(hh, k); return { v: v, text: pct(v), sub: 'n = ' + int(hh.n[k]), tip: LABELS.hbp[r] + ' + ' + LABELS.hch[c] + '\nDiabetes prevalence ' + pct(v) + '\nn = ' + int(hh.n[k]) + lowN(hh.n[k]) }; }
    });
    var sc = statusSeries(pa, 2, function (i) { return i; });
    return '<div class="grid enter">' +
      insight(ins) +
      panel('s6', 'Diabetes prevalence by BMI category', 'Click a bar to filter',
        colChart({ aria: 'Diabetes prevalence by BMI category', cats: groupCats('bmi', true), series: [prevSeries('bmi', C.dia, 'Diabetes', true)] })) +
      panel('s6', 'Comorbidity score', 'Count of: high BP, high cholesterol, heart disease, stroke (0-4)',
        colChart({ aria: 'Diabetes prevalence by comorbidity score', cats: groupCats('cm', false), series: [prevSeries('cm', '#F43F5E', 'Diabetes')] })) +
      panel('s6', 'High blood pressure x high cholesterol', 'Diabetes prevalence for each combination: the overlapping-risk view', heatH) +
      '<div class="s6 stack">' +
        panel('', 'Diabetes prevalence by blood pressure', null,
          barChart({ aria: 'Diabetes prevalence by high blood pressure', labW: 110, cats: groupCats('hbp', false), series: [prevSeries('hbp', C.dia, 'Diabetes')] })) +
        panel('', 'Physical activity vs diabetes status', 'Share of respondents in each status (any physical activity in the last 30 days)',
          stackChart({ aria: 'Diabetes status by physical activity', horizontal: true, labW: 110, cats: groupCats('pa', false), series: sc })) +
      '</div>' +
      '</div>';
  }

  function pageHealth() {
    var mp = agg(['md', 'pd']), gh = agg(['gh']), dw = agg(['dw']), md = agg(['md']), pd = agg(['pd']);
    var totalN = sum(mp.n);
    var poor = prevOf(gh, 4), exc = prevOf(gh, 0);
    var ins = (poor != null && exc != null && gh.n[4] >= 100 && gh.n[0] >= 100 && exc > 0)
      ? 'Respondents who rate their general health <b>Poor</b> have a diabetes prevalence of <b>' + pct(poor) + '</b>, versus <b>' + pct(exc) + '</b> for those who rate it <b>Excellent</b> (about <b>' + (poor / exc).toFixed(0) + 'x</b>). These are self-reported associations, not causal effects.'
      : 'Too few respondents in the Poor / Excellent groups under the current filters.';
    var byN = state.heat === 'n';
    var toggle = '<div class="seg-ctl" role="group" aria-label="Heatmap value"><button data-heat="n" aria-pressed="' + byN + '">Respondents</button><button data-heat="prev" aria-pressed="' + !byN + '">Diabetes %</button></div>';
    var heatH = heat({
      rows: LABELS.md, cols: LABELS.pd, rowTitle: 'Mental days', colTitle: 'Physical days', rgb: byN ? '116,192,252' : '251,113,133',
      cell: function (r, c) {
        var k = ix(mp, r, c), v = byN ? mp.n[k] : prevOf(mp, k);
        return { v: v, text: byN ? int(mp.n[k]) : pct(v), sub: byN ? pct(totalN ? mp.n[k] / totalN : 0) : 'n = ' + int(mp.n[k]),
          tip: 'Mental: ' + LABELS.md[r] + ', Physical: ' + LABELS.pd[c] + '\n' + int(mp.n[k]) + ' respondents (' + pct(totalN ? mp.n[k] / totalN : 0) + ')\nDiabetes prevalence ' + pct(prevOf(mp, k)) + lowN(mp.n[k]) };
      }
    });
    var preSeries = prevSeries('dw', C.pre, 'Prediabetes');
    preSeries.vals = LABELS.dw.map(function (_, i) { return preOf(dw, i); });
    var ghS = statusSeries(gh, 5, function (i) { return i; });
    function daysSeries(r, name, color) {
      var tot = sum(r.n);
      return { name: name, color: color, fmt: intFmt, vals: Array.prototype.slice.call(r.n),
        tips: LABELS.md.map(function (_, i) { return pct(tot ? r.n[i] / tot : 0) + ' of selection'; }) };
    }
    var daysChart = colChart({ aria: 'Distribution of mental and physical unhealthy days', h: 230,
      cats: LABELS.md.map(function (l) { return { label: l }; }),
      series: [daysSeries(md, 'Mental health', C.cyan), daysSeries(pd, 'Physical health', C.no)] });
    return '<div class="grid enter">' +
      insight(ins) +
      panel('s6', 'Mental vs physical unhealthy days', 'Days in the past 30 with poor mental / physical health (0-30 grouped into bands)', heatH, toggle) +
      panel('s6', 'General health by diabetes status', 'Self-rated general health, 100% stacked',
        stackChart({ aria: 'Diabetes status by general health rating', cats: LABELS.gh.map(function (l) { return { label: l }; }), series: ghS })) +
      panel('s6', 'Difficulty walking', 'Diabetes and prediabetes prevalence',
        barChart({ aria: 'Prevalence by difficulty walking', labW: 112, cats: groupCats('dw', false),
          series: [prevSeries('dw', C.dia, 'Diabetes'), preSeries] })) +
      panel('s6', 'Unhealthy days distribution', 'Respondents per band of unhealthy days in the past 30',
        daysChart) +
      '</div>';
  }

  function pageDemo() {
    var a = agg(['age'], ['age']), best = -1, worst = -1, inc = agg(['inc'], ['inc']);
    for (var i = 0; i < 6; i++) { if (a.n[i] >= 100) { var v = prevOf(a, i); if (best < 0 || v > prevOf(a, best)) best = i; if (worst < 0 || v < prevOf(a, worst)) worst = i; } }
    var ins = (best >= 0 && worst >= 0 && best !== worst)
      ? 'Across age bands, diabetes prevalence ranges from <b>' + pct(prevOf(a, worst)) + '</b> (' + LABELS.age[worst] + ') to <b>' + pct(prevOf(a, best)) + '</b> (' + LABELS.age[best] + ').'
      : 'Not enough data under the current filters to compare age bands.';
    if (inc.n[0] >= 100 && inc.n[7] >= 100) ins += ' By income, prevalence is <b>' + pct(prevOf(inc, 0)) + '</b> in the lowest bracket (' + LABELS.inc[0] + ') and <b>' + pct(prevOf(inc, 7)) + '</b> in the highest (' + LABELS.inc[7] + '). Age mix partly explains these gaps.';
    function hbar(dim, title, sub, labW) {
      return panel('', title, sub, barChart({ aria: title, labW: labW || 108, cats: groupCats(dim, true), series: [prevSeries(dim, C.dia, 'Diabetes', true)] }));
    }
    return '<div class="grid enter">' + insight(ins) +
      '<div class="s6 stack">' + hbar('age', 'Diabetes prevalence by age', 'Click a bar to filter') + hbar('edu', 'By education level', 'Lowest to highest') + '</div>' +
      '<div class="s6 stack">' + hbar('inc', 'By income bracket', 'Annual household income, lowest to highest') + hbar('sex', 'By sex', 'Click a bar to filter', 80) + '</div>' +
      '</div>';
  }

  /* ---------- filter UI ---------- */
  function buildFilters() {
    var h = '';
    GROUPS.forEach(function (g) {
      h += '<div class="f-group"><h4>' + g.title + '</h4><div class="chips">';
      LABELS[g.dim].forEach(function (l, i) {
        var long = g.dim === 'edu' ? EDU_LONG[i] : g.dim === 'inc' ? INC_LONG[i] : l;
        h += '<button type="button" class="chip" data-dim="' + g.dim + '" data-idx="' + i + '" title="' + esc(long) + '" aria-pressed="false">' + esc(l) + '</button>';
      });
      h += '</div></div>';
    });
    document.getElementById('f-groups').innerHTML = h;
  }
  function syncFilters() {
    document.querySelectorAll('#f-groups .chip').forEach(function (b) {
      var on = F[b.dataset.dim].has(+b.dataset.idx);
      b.classList.toggle('on', on); b.setAttribute('aria-pressed', on);
    });
    var any = FDIMS.some(function (d) { return F[d].size; }), n = agg([]).n[0];
    document.getElementById('f-clear').disabled = !any;
    document.getElementById('f-summary').textContent = any
      ? 'Showing ' + int(n) + ' of ' + int(TOTAL) + ' respondents (' + pct(n / TOTAL) + ')'
      : 'No filters applied: all ' + int(TOTAL) + ' respondents';
  }

  /* ---------- render ---------- */
  var PAGES = { overview: pageOverview, risk: pageRisk, health: pageHealth, demo: pageDemo };
  function render(animate) {
    syncFilters();
    var view = document.getElementById('view');
    view.innerHTML = PAGES[state.tab]();
    if (!animate) view.querySelector('.grid').classList.remove('enter');
    document.querySelectorAll('.tabs button').forEach(function (b) { b.setAttribute('aria-selected', b.dataset.tab === state.tab); });
  }
  function toggleFilter(dim, idx) {
    if (F[dim].has(idx)) F[dim].delete(idx); else F[dim].add(idx);
    render(false);
  }

  /* ---------- events ---------- */
  var tip = document.getElementById('tip');
  document.addEventListener('mouseover', function (e) {
    var t = e.target.closest && e.target.closest('[data-tip]');
    if (!t) { tip.classList.remove('show'); return; }
    tip.innerHTML = esc(t.getAttribute('data-tip')).replace(/\n/g, '<br>'); tip.classList.add('show');
  });
  document.addEventListener('mousemove', function (e) {
    var x = Math.min(e.clientX + 14, window.innerWidth - tip.offsetWidth - 8), y = e.clientY + 16;
    if (y + tip.offsetHeight > window.innerHeight - 8) y = e.clientY - tip.offsetHeight - 12;
    tip.style.left = x + 'px'; tip.style.top = y + 'px';
  });
  document.addEventListener('click', function (e) {
    var c = e.target.closest('[data-dim][data-idx]');
    if (c) { toggleFilter(c.dataset.dim, +c.dataset.idx); tip.classList.remove('show'); return; }
    var h = e.target.closest('[data-heat]');
    if (h) { state.heat = h.dataset.heat; render(false); return; }
    var tb = e.target.closest('.tabs button');
    if (tb) { state.tab = tb.dataset.tab; history.replaceState(null, '', '#' + state.tab); render(true); }
  });
  document.getElementById('f-clear').addEventListener('click', function () { FDIMS.forEach(function (d) { F[d].clear(); }); render(false); });
  document.getElementById('f-toggle').addEventListener('click', function () {
    var box = document.querySelector('.filters'), open = box.classList.toggle('open');
    this.textContent = open ? 'Hide filters' : 'Show filters'; this.setAttribute('aria-expanded', open);
  });
  window.addEventListener('hashchange', function () { var t = location.hash.slice(1); if (PAGES[t]) { state.tab = t; render(true); } });

  document.getElementById('total-n').textContent = int(TOTAL);
  var h0 = location.hash.slice(1); if (PAGES[h0]) state.tab = h0;
  buildFilters(); render(true);
  window.__dash = { F: F, agg: agg, TOTAL: TOTAL, state: state, render: render };
})();
