# Haveno — built from upstream source. haveno-dex publishes NO
# container image (the one community daemon image is ARM64-only and
# stale), so this Dockerfile builds the daemon + seednode
# distributions from the pinned release with the project's own
# Gradle build, and the runtime stage is a plain JRE.
#
# The FIRST build is long (Gradle downloads the world, then compiles)
# and needs several GB of RAM. Confirm the two VERIFY items from the
# build log the first time:
#  1. The Gradle installDist task names and output paths below
#     (:daemon and :seednode -> daemon/build/install/daemon and
#     seednode/build/install/seednode, launchers in their bin/).
#  2. Tor: Haveno's P2P rides Tor via its bundled netlayer binary.
#     The distro tor package is installed as a fallback; if the
#     daemon logs Tor startup errors, that is where to look.
FROM eclipse-temurin:21-jdk-jammy AS build
ARG HAVENO_VERSION=v1.9.0
RUN apt-get update \
 && apt-get install -y --no-install-recommends git \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /src
RUN git clone --depth 1 --branch ${HAVENO_VERSION} https://github.com/haveno-dex/haveno.git .
RUN ./gradlew :daemon:installDist :seednode:installDist --no-daemon -x test

FROM eclipse-temurin:21-jre-jammy
RUN apt-get update \
 && apt-get install -y --no-install-recommends tor \
 && rm -rf /var/lib/apt/lists/*
COPY --from=build /src/daemon/build/install/daemon /opt/haveno/daemon
COPY --from=build /src/seednode/build/install/seednode /opt/haveno/seednode
