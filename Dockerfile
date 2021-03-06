FROM debian

ENV \
DEBIAN_FRONTEND=noninteractive \
LANG=C.UTF-8 \
ENV=/etc/profile \
USER=root 

WORKDIR /

RUN set -x && apt update \
  && mkdir -p /root/.cabal/bin && mkdir -p /root/.ghcup/bin \
  && apt install -y  apt-utils wget gnupg apt-utils git\
  && wget https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/prereqs.sh \
  && cat prereqs.sh | sed "s/SUDO='Y';/SUDO='N';/g" | sed 's/libssl1.0-dev/libssl-dev/g' > /tmp/prereqs.sh \	  
  && export SUDO='N' \
  && export UPDATE_CHECK='N' \
  && export BOOTSTRAP_HASKELL_NO_UPGRADE=1 \
  && chmod +x /tmp/prereqs.sh &&  /tmp/prereqs.sh \
  && apt-get -y purge && apt-get -y clean && apt-get -y autoremove  && rm -rf /var/lib/apt/lists/*
