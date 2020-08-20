FROM debian

ENV \
CNODE_HOME=/opt/cardano/cnode \
CNODE_PORT=6000 \
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
  && wget https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/prereqs.sh \
  && cat prereqs.sh | sed 's/SUDO="Y";/SUDO="N";/g' | sed 's/libssl1.0-dev/libssl-dev/g' > /tmp/prereqs.sh \
  && export BOOTSTRAP_HASKELL_NO_UPGRADE=1 \
  && chmod +x /tmp/prereqs.sh &&  /tmp/prereqs.sh
  
  
