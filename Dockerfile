ARG SYSTEMD="false"
ARG DEBIAN_FRONTEND=noninteractive

FROM debian

ENV \
DEBIAN_FRONTEND=noninteractive \
LANG=C.UTF-8 \
ENV=/etc/profile \
USER=root 

WORKDIR /

RUN set -x && apt update \
  && mkdir -p /root/.cabal/bin && mkdir -p /root/.ghcup/bin \
  && apt install -y  apt-utils wget gnupg apt-utils git udev libgmp3-dev \
  && wget https://raw.githubusercontent.com/cardano-community/guild-operators/alpha/scripts/cnode-helper-scripts/prereqs.sh \
  && cat prereqs.sh | sed "s/SUDO='Y';/SUDO='N';/g" | sed 's/libssl1.0-dev/libssl-dev/g' | sed 's/ sqlite / /g' > /tmp/prereqs.sh \	  
  && export SUDO='N' \
  && export UPDATE_CHECK='N' \
  && curl -s  --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sed -e 's#read.*#answer=Y;next_answer=P;hls_answer=N#' | bash \
  && chmod +x /tmp/prereqs.sh &&  /tmp/prereqs.sh -w -c \
  && apt-get -y purge && apt-get -y clean && apt-get -y autoremove  && rm -rf /var/lib/apt/lists/*
