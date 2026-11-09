# SimpleX — before first start

1. Set `SIMPLEX_ADDR` in this stack's `.env` — the hostname baked into the
   SMP/XFTP certificates at init. It becomes part of every server address
   (`smp://fingerprint@host`). Pick the real value first; changing it later
   means every client re-adds the servers.
2. First start generates certificates and `.ini` files under `./data`.
   Then stop the stack, set the SMP server **password** in
   `data/smp/config/smp-server.ini` (`[AUTH]` section) so the relay stays
   private, and start again.
3. The full server addresses print in the first-start logs and live in the
   `.ini` files. The Tor address is in `data/tor/hs-smp/hostname`.
4. `./data` is identity: it is in the Backrest scope. Lose it and the
   server addresses change for every client.
