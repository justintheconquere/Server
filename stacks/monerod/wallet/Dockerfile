# Monero GUI wallet — the OFFICIAL release, served in a browser desktop.
#
# Route (checked 2026-11-09): no maintained prebuilt image carries the
# official GUI wallet, so this builds on LinuxServer's Webtop (the desktop
# base from the same family as the chrome stack) and installs the official
# GUI tarball from getmonero.org, verified against the SHA256 published
# with the release. To bump the wallet: change both ARGs (hashes are listed
# on the GitHub release page and in the signed getmonero.org hashes.txt).
#
# The base tag is Webtop's rolling variant tag — pin it by digest here
# after the first successful build if you want it frozen.
FROM lscr.io/linuxserver/webtop:ubuntu-xfce

ARG MONERO_GUI_VERSION=0.18.5.4
ARG MONERO_GUI_SHA256=44cd148993ebd4ca63d7a191244eef7e2a783225cbaa0e5edd475ca34abd5874

RUN apt-get update \
    && apt-get install -y --no-install-recommends bzip2 \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL -o /tmp/monero-gui.tar.bz2 \
      "https://downloads.getmonero.org/gui/monero-gui-linux-x64-v${MONERO_GUI_VERSION}.tar.bz2" \
    && echo "${MONERO_GUI_SHA256}  /tmp/monero-gui.tar.bz2" | sha256sum -c - \
    && tar -xjf /tmp/monero-gui.tar.bz2 -C /opt \
    && ln -s "/opt/monero-gui-v${MONERO_GUI_VERSION}" /opt/monero-gui \
    && rm /tmp/monero-gui.tar.bz2

# Start the wallet with the desktop session, and put it in the app menu.
COPY monero-wallet-gui.desktop /etc/xdg/autostart/monero-wallet-gui.desktop
COPY monero-wallet-gui.desktop /usr/share/applications/monero-wallet-gui.desktop
