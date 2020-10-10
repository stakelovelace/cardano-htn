FROM stakelovelace/cardano-htn:master

ENV \
CNODE_HOME=/opt/cardano/cnode \
CNODE_PORT=6000 \
DEBIAN_FRONTEND=noninteractive \ 
LANG=C.UTF-8 \
USER=root \
PATH=$CNODE_HOME/scripts:/root/.cabal/bin:/root/.ghcup/bin:$PATH 

RUN git clone https://github.com/input-output-hk/cardano-node.git \
  && export BOOTSTRAP_HASKELL_NO_UPGRADE=1 \
  && wget https://raw.githubusercontent.com/stakelovelace/cardano-htn/master/release-versions/cardano-node-latest.txt \
  && CNVERSION=$(cat cardano-node-latest.txt) \
  && cd cardano-node \
  && echo "package cardano-crypto-praos" > cabal.project.local \
  && echo "   flags: -external-libsodium-vrf" >> cabal.project.local \
  && git fetch --tags --all && git checkout tags/$CNVERSION \
  && bash $CNODE_HOME/scripts/cabal-build-all.sh \
  && sudo apt-get -y remove libpq-dev build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ &&  sudo apt-get -y remove exim4 && apt-get -y purge && sudo apt-get -y clean && sudo apt-get -y autoremove \
  && cardano-node --version;
