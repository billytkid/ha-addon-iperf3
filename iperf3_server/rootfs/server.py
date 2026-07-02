import json
import os
import uuid
from http.server import BaseHTTPRequestHandler, HTTPServer

STATE_FILE = "/data/state.json"
CMD_FILE = "/data/tx_command.json"

PAGE = """<!doctype html>
<html><head><meta charset="utf-8"><title>iperf3</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body{font-family:-apple-system,Segoe UI,Roboto,sans-serif;margin:1.2rem;background:#111;color:#eee}
  h2{border-bottom:1px solid #333;padding-bottom:.3rem;font-size:1.1rem}
  table{border-collapse:collapse;margin-bottom:1.5rem;width:100%;max-width:480px}
  td{padding:.35rem .6rem;border-bottom:1px solid #262626;font-size:.9rem}
  td:first-child{color:#999}
  input,select{padding:.4rem;margin:.15rem 0 .6rem;background:#1c1c1c;color:#eee;border:1px solid #333;
    border-radius:4px;width:100%;max-width:260px;box-sizing:border-box}
  button{padding:.55rem 1.2rem;background:#03a9f4;color:#fff;border:none;border-radius:4px;cursor:pointer;font-size:.95rem}
  button:hover{background:#0288d1}
  label{display:block;margin-top:.5rem;font-size:.85rem;color:#bbb}
  .row{display:flex;gap:1rem;flex-wrap:wrap}
  .row > div{flex:1;min-width:140px}
  #msg{color:#4caf50;font-size:.85rem;min-height:1.2em}
  .chk{display:flex;align-items:center;gap:.5rem;margin-top:.8rem}
  .chk input{width:auto}
</style></head>
<body>
<h2>RX &mdash; incoming tests</h2>
<table id="rx"></table>

<h2>TX &mdash; outgoing tests</h2>
<table id="tx"></table>

<h2>Run a TX test</h2>
<div class="row">
  <div>
    <label>Target IP</label>
    <input id="target" placeholder="192.168.1.50">
    <label>Streams (1-10)</label>
    <input id="streams" type="number" min="1" max="10" value="1">
    <label>Duration (s)</label>
    <input id="duration" type="number" min="1" max="60" value="10">
  </div>
  <div>
    <label>Protocol</label>
    <select id="protocol"><option>TCP</option><option>UDP</option></select>
    <label>UDP Bandwidth (Mbit/s)</label>
    <input id="udpbw" type="number" min="1" max="1000" value="100">
    <div class="chk"><input id="reverse" type="checkbox"><label style="margin:0">Reverse (download)</label></div>
  </div>
</div>
<button onclick="runTest()">Run Test</button>
<p id="msg"></p>

<script>
function row(k,v){return `<tr><td>${k}</td><td>${v || '-'}</td></tr>`}
async function refresh(){
  try{
    const r = await fetch('state');
    const s = await r.json();
    document.getElementById('rx').innerHTML =
      row('Status', s.rx_status) +
      row('Last sending host', s.rx_sending_host) +
      row('Last throughput (Mbit/s)', s.rx_throughput_mbps) +
      row('Last test', s.rx_last_test);
    document.getElementById('tx').innerHTML =
      row('Status', s.tx_status) +
      row('Tested IP', s.tx_tested_ip) +
      row('Total transferred (MB)', s.tx_total_transferred) +
      row('Bitrate (Mbit/s)', s.tx_bitrate) +
      row('Last test', s.tx_last_test);
  }catch(e){}
}
async function runTest(){
  const body = {
    target_ip: document.getElementById('target').value,
    streams: document.getElementById('streams').value,
    protocol: document.getElementById('protocol').value,
    duration: document.getElementById('duration').value,
    udp_bandwidth: document.getElementById('udpbw').value,
    reverse: document.getElementById('reverse').checked ? 'ON' : 'OFF'
  };
  if(!body.target_ip){ document.getElementById('msg').textContent = 'Enter a target IP first.'; return; }
  document.getElementById('msg').textContent = 'Test triggered - watch TX status above.';
  await fetch('run', {method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(body)});
  setTimeout(refresh, 500);
}
setInterval(refresh, 2000);
refresh();
</script>
</body></html>"""


class Handler(BaseHTTPRequestHandler):
    def _send(self, code, body, ctype="application/json"):
        data = body if isinstance(body, bytes) else body.encode()
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if self.path.startswith("/state"):
            try:
                with open(STATE_FILE) as f:
                    data = f.read()
            except FileNotFoundError:
                data = "{}"
            self._send(200, data)
        else:
            self._send(200, PAGE, "text/html; charset=utf-8")

    def do_POST(self):
        if self.path.startswith("/run"):
            try:
                length = int(self.headers.get("Content-Length", 0))
                body = json.loads(self.rfile.read(length) or b"{}")
            except Exception:
                body = {}
            body["trigger"] = str(uuid.uuid4())
            with open(CMD_FILE, "w") as f:
                json.dump(body, f)
            self._send(200, json.dumps({"ok": True}))
        else:
            self._send(404, json.dumps({"error": "not found"}))

    def log_message(self, fmt, *args):
        pass


if __name__ == "__main__":
    port = int(os.environ.get("INGRESS_PORT", "8099"))
    HTTPServer(("0.0.0.0", port), Handler).serve_forever()
