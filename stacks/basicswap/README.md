# BasicSwap — before you trade

- **Set the UI/API password first.** Anyone who can reach port
  12700 can spend the wallets' coins (BasicSwap's own docs say so).
  After the first prepare run, stop the stack and set the password
  in `./data/basicswap.json` (key `html_password` — VERIFY against
  the generated file), then start it again. Tailnet-only, always.
- **Point XMR at your own node.** Edit `chainclients -> monero` in
  the same file: daemon address `http://monerod:18081` with the
  monerod stack's RPC login (VERIFY the exact key names in the
  generated config), so swaps use your node, not a stranger's.
- **Start tiny.** BasicSwap is beta; its July 2026 releases fixed
  refund-path bugs after a reported loss. Current pinned version
  only, amounts you can afford to lose while you learn it.
- **Agents:** the JSON API is the same port as the UI
  (`http://basicswap:12700/json/...` on ufo-net). Smart Buy is two
  calls: `POST /json/bids/plan` (places nothing) then
  `POST /json/bids/bulk`. Give an agent a plan-only brief first;
  placing bids is the step to gate behind your approval.
