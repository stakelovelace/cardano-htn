FROM debian

ENV \
CNODE_HOME=/opt/cardano/cnode \
CNODE_PORT=9000 \
DEBIAN_FRONTEND=noninteractive \
LANG=C.UTF-8 \
ENV=/etc/profile \
USER=root \
PATH=$CNODE_HOME/scripts:~/.cabal/bin:~/.ghcup/bin:$PATH

WORKDIR /

RUN set -x && apt update \
  && mkdir -p /root/.cabal/bin && mkdir -p /root/.ghcup/bin \
  && apt install -y  apt-utils wget gnupg apt-utils git\
  && cd / \
  && wget https://raw.githubusercontent.com/cardano-community/guild-operators/master/files/ptn0/scripts/prereqs.sh \
  && cat prereqs.sh | sed 's/SUDO="Y";/SUDO="N";/g' | sed 's/libssl1.0-dev/libssl-dev/g' > /tmp/prereqs.sh \
  && export BOOTSTRAP_HASKELL_NO_UPGRADE=1 \
  && chmod +x /tmp/prereqs.sh &&  /tmp/prereqs.sh \
  && git clone https://github.com/input-output-hk/cardano-node.git && cd cardano-node \
  && ~/.ghcup/bin/cabal update && ln -s ~/.ghcup/bin/ghc /bin/ghc  && bash $CNODE_HOME/scripts/cabal-build-all.sh \
  && cd - && apt remove -y build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev npm yarn make g++ git && apt-get clean && apt install -y socat && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cabal/store ~/.cabal/packages ~/.ghcup/ghc cardano-node ~/git \
  && echo cardano-node --version;
  
  
