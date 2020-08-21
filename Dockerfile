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
  && cd cardano-node \
  && echo "package cardano-crypto-praos" > cabal.project.local \
  && echo "   flags: -external-libsodium-vrf" >> cabal.project.local \
  && git fetch --tags --all && git checkout tags/1.19.0 \
  && bash $CNODE_HOME/scripts/cabal-build-all.sh \
  && cardano-node --version;
