FROM stakelovelace/cardano-htn:master

ENV \
CNODE_HOME=/opt/cardano/cnode \
CNODE_PORT=6000 \
DEBIAN_FRONTEND=noninteractive \ 
LANG=C.UTF-8 \
USER=root \
PATH=$CNODE_HOME/scripts:/root/.cabal/bin:/root/.ghcup/bin:$PATH

RUN git clone https://github.com/input-output-hk/cardano-node.git \
  && cd cardano-node \
  && echo "package cardano-crypto-praos" > cabal.project.local \
  && echo "   flags: -external-libsodium-vrf" >> cabal.project.local \
  && wget https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/cabal-build-all.sh \
  && cat ./cabal-build-all.sh  > /tmp/cabal-build-all.sh  \
  && chmod +x /tmp/cabal-build-all.sh \
  && bash /tmp/cabal-build-all.sh
