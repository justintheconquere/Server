# Twenty customer portal — PILOT ONLY

Community-built portal (lilremark/twentycrmclientportal), **not** an official
Twenty product. Twenty itself has no customer-facing login; this fills the
gap with invite-only, scoped client views.

Before this serves any real customer:

1. **Vet the code** — read what the pinned image does with the Twenty API
   key and customer data. The key is full-access to the CRM.
2. **Pilot on the tailnet** — deploy as-is (port 3002, tailnet/LAN only),
   create test clients, confirm a client sees only their own records.
3. **Public exposure is a separate step** — real `NEXTAUTH_URL`, a
   Cloudflare Tunnel route, and a deliberate go decision. The CRM itself
   (stacks/twenty) stays tailnet-only forever; only this portal is public,
   and it reaches Twenty over the internal `ufo-net` network.
