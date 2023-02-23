FROM stakelovelace/cardano-htn:stage1

ENV \
CNODE_HOME=/opt/cardano/cnode \
DEBIAN_FRONTEND=noninteractive \ 
LANG=C.UTF-8 \
USER=root \
PATH=$CNODE_HOME/scripts:/root/.cabal/bin:/root/.ghcup/bin:$PATH 

RUN git clone https://github.com/input-output-hk/cardano-node.git \
  && export BOOTSTRAP_HASKELL_NO_UPGRADE=1 \
  && cd \
  && wget https://raw.githubusercontent.com/stakelovelace/cardano-htn/master/release-versions/cardano-node-latest.txt \
  && CNVERSION=$(cat cardano-node-latest.txt)  \
  && mkdir -p /root/.local/bin \
  && cd cardano-node \
  && echo "tags/$CNVERSION" \
  && git fetch --tags --all && git checkout tags/$CNVERSION \
  && bash $CNODE_HOME/scripts/cabal-build-all.sh \
  && cardano-node --version \
  && for i in $(ls /root/.cabal/bin); do ldd /root/.cabal/bin/$i | cut -d ">" -f 2 | cut -d "(" -f 1| sed 's/[[:blank:]]//g' > /tmp/liblisttmp ; done \
  && cat  /tmp/liblisttmp | sort | uniq > /tmp/liblist \
  && cd \
  && apt-get update -y && apt-get install -y automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf \
  && git clone --recurse-submodules https://github.com/cardano-community/cncli \
  && cd cncli \
  && tag=`curl https://github.com/cardano-community/cncli/tags | grep "cncli/releases" | grep -v ">Releases<" | head -n 1 | cut -d ">" -f 3 | cut -d "<" -f 1` \
  && git checkout $tag \
  && curl https://sh.rustup.rs -sSf | sh -s -- -y \
  && ~/.cargo/bin/cargo install --path . --force \
  && newCLI=$(find ~/ -type f -executable -name cncli) \
  && newCLI2=$(echo $newCLI | cut -d " " -f 1) \
  && $newCLI2 --version \
  && mv $newCLI2 /root/.local/bin/ \
  && apt-get -y remove libpq-dev build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ && apt-get -y purge && apt-get -y clean && apt-get -y autoremove

