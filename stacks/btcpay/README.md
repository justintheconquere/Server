# BTCPay Server — Monero only

Voodoo Bazaar's payment engine. Clearnet face:
https://pay.voodoobazaar.com via the cloudflared stack. Deploy only
after the monerod stack is fully synced. Daemon and wallet details are
in the compose header.

## Its own Tor onion

This stack runs a Tor sidecar (`torrc` in this folder) that publishes
BTCPay as a v3 onion service, so Tor buyers reach checkout without
being bounced to clearnet — the marketplace plan gives the storefront
and BTCPay separate onions.

After the first start, once Tor has bootstrapped (a minute or two):

```
cat ./data/tor/btcpay/hostname
```

That's the address. Then finish the wiring: set
`BTCPAY_ADDITIONALHOSTS: "http://<that-onion>"` on the server service
(the compose has the exact spot commented) and restart the stack, so
links generated during an onion visit stay on the onion.

Rules that matter:

- **The keys are the address.** `./data/tor/btcpay/` holds the hidden
  service private key. Back it up like a wallet seed (it's under
  `data/`, so Backrest already covers it) — lose it and the onion is
  gone forever, with every seller's shared links pointing at it.
  Never commit it; git ignores `data/`.
- **Launch gate (from the Voodoo plan):** run one full checkout in Tor
  Browser over the onion before calling it live — pay screen, wallet
  callback, confirmation.
- The onion is a second door, not a replacement: the clearnet host
  stays canonical for the tunnel, webhooks, and plugin callbacks.

## The pattern, for other services

Any stack can get an onion the same way: a `tor` sidecar on the
stack's own network, a two-line `torrc` (HiddenServiceDir +
HiddenServicePort to the service), keys under the stack's `data/`.
But onions are only for services meant to be *reached* (BTCPay, the
future storefront). Never give one to a tailnet-only admin app —
Twenty, Hermes, n8n, Gitea stay tailnet-only; an onion would be a
door around the tailnet.
