FROM debian:stable-slim

LABEL desc="Stakelovelace Cardano Node"
ARG DEBIAN_FRONTEND=noninteractive

USER root
WORKDIR /

ENV \
    ENV=/etc/profile \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    CNODE_HOME=/opt/cardano/cnode \
    PATH=/nix/var/nix/profiles/per-user/guild/profile/bin:/nix/var/nix/profiles/per-user/guild/profile/sbin:/opt/cardano/cnode/scripts:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/home/guild/.cabal/bin \
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt \
    NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    NIX_PATH=/nix/var/nix/profiles/per-user/guild/channels

# Install locales package
RUN  apt-get update \ 
     && apt-get install --no-install-recommends -y locales apt-utils
     
# COPY NODE BINS AND DEPS 
COPY --from=stakelovelace/cardano-htn:stage2 /root/.cabal/bin/* /usr/local/bin/
COPY --from=stakelovelace/cardano-htn:stage2 /opt/ /opt/

#COPY --from=stakelovelace/cardano-htn:stage2 /lib/x86_64-linux-gnu/lib* /lib/x86_64-linux-gnu/
#COPY --from=stakelovelace/cardano-htn:stage2 /lib64/ld-linux-x86-64* /lib64/
#COPY --from=stakelovelace/cardano-htn:stage2 /usr/lib/x86_64-linux-gnu/libgmp.* /usr/lib/x86_64-linux-gnu/
#COPY --from=stakelovelace/cardano-htn:stage2 /usr/lib/x86_64-linux-gnu/liblz4.* /usr/lib/x86_64-linux-gnu/
#COPY --from=stakelovelace/cardano-htn:stage2 /usr/lib/x86_64-linux-gnu/libsodium.* /usr/lib/x86_64-linux-gnu/


RUN chmod a+x /usr/local/bin/* && mkdir -p $CNODE_HOME/priv/files 

#  en_US.UTF-8 for inclusion in generation
RUN sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen \
    && echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc \
    && echo "export LANG=en_US.UTF-8" >> ~/.bashrc \
    && echo "export LANGUAGE=en_US.UTF-8" >> ~/.bashrc

# PREREQ --no-install-recommends
RUN apt-get update && apt-get install -y libcap2 libselinux1 libc6 libsodium-dev ncurses-bin iproute2 curl wget apt-utils xz-utils netbase sudo coreutils dnsutils net-tools procps tcptraceroute bc usbip \
    && apt-get install -y --no-install-recommends cron \
    && sudo apt-get -y purge && sudo apt-get -y clean && sudo apt-get -y autoremove && sudo rm -rf /var/lib/apt/lists/* # && sudo rm -rf /usr/bin/apt*
    
ADD https://raw.githubusercontent.com/stakelovelace/cardano-node/master/promtail.yml /etc/ 
ADD https://raw.githubusercontent.com/stakelovelace/cardano-node/master/promtail /etc/init.d/
ADD https://raw.githubusercontent.com/stakelovelace/cardano-node/master/crontab /etc/cron.d/crontab
RUN chmod a+x /etc/init.d/promtail && chmod 0644 /etc/cron.d/crontab && touch /var/log/cron.log 

# from https://github.com/grafana/loki/releases
RUN cd /usr/local/bin \
&& curl -fSL -o promtail.gz "https://github.com/grafana/loki/releases/download/v1.5.0/promtail-linux-amd64.zip" \
&& gunzip promtail.gz \
&& chmod a+x promtail && ls /opt/

RUN wget https://github.com/javadmohebbi/IP2Location/raw/master/dist/linux/amd64/ip2location \
&& mv ip2location /usr/local/bin/ -v \
&& chmod a+x /usr/local/bin/ip2location -v \
&& /usr/local/bin/ip2location -dl \
&& setcap cap_net_raw=+ep /usr/local/bin/ip2location

RUN cd /usr/bin \
&& sudo wget http://www.vdberg.org/~richard/tcpping \
&& sudo chmod 755 tcpping 

# SETUP Guild USER 
RUN adduser --disabled-password --gecos '' guild \
&& echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
&& adduser guild sudo \ 
&& chown -R guild:guild /home/guild/.*

USER guild
WORKDIR /home/guild

# INSTALL NIX
RUN sudo curl -sL https://nixos.org/nix/install | sh \
    && sudo ln -s /nix/var/nix/profiles/per-user/etc/profile.d/nix.sh /etc/profile.d/ \
    && . /home/guild/.nix-profile/etc/profile.d/nix.sh \
    && sudo crontab -u guild /etc/cron.d/crontab \
    && echo "head -n 8 ~/.scripts/banner.txt" >> ~/.bashrc \
    && echo "grep MENU -A 6 ~/.scripts/banner.txt | grep -v MENU" >> ~/.bashrc \
    && echo "alias env=/usr/bin/env" >> ~/.bashrc \
    && echo "alias cntools=$CNODE_HOME/scripts/cntools.sh" >> ~/.bashrc \
    && echo "alias gLiveView=$CNODE_HOME/scripts/gLiveView.sh" >> ~/.bashrc \
    && echo "alias cncli=$CNODE_HOME/scripts/cncli.sh" >> ~/.bashrc \
    && echo "export PATH=/nix/var/nix/profiles/per-user/guild/profile/bin:/nix/var/nix/profiles/per-user/guild/profile/sbin:/opt/cardano/cnode/scripts:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/home/guild/.cabal/bin"  >> ~/.bashrc

# INSTALL DEPS  
RUN /nix/var/nix/profiles/per-user/guild/profile/bin/nix-env -i python3 libsodium tmux jq ncurses libtool autoconf git wget gnupg systemd util-linux less openssl vim \
    && /nix/var/nix/profiles/per-user/guild/profile/bin/nix-channel --update \
    && /nix/var/nix/profiles/per-user/guild/profile/bin/nix-env -u --always \
    && /nix/var/nix/profiles/per-user/guild/profile/bin/nix-collect-garbage -d \
    && sudo rm /nix/var/nix/profiles/per-user/guild/profile/bin/nix-*

# ENTRY Scripts
ADD https://raw.githubusercontent.com/stakelovelace/cardano-node/master/banner.txt /home/guild/.scripts/banner.txt
ADD https://raw.githubusercontent.com/stakelovelace/cardano-node/master/master-topology.sh /home/guild/.scripts/
ADD https://raw.githubusercontent.com/stakelovelace/cardano-node/master/ip2loc.sh /home/guild/.scripts/
ADD https://raw.githubusercontent.com/stakelovelace/cardano-node/master/guild-topology.sh /home/guild/.scripts/
ADD https://raw.githubusercontent.com/stakelovelace/cardano-node/master/block_watcher.sh /home/guild/.scripts/
ADD https://raw.githubusercontent.com/stakelovelace/cardano-node/master/healthcheck.sh /home/guild/.scripts/
ADD https://raw.githubusercontent.com/cardano-community/guild-operators/alpha/scripts/cnode-helper-scripts/prereqs.sh /opt/cardano/cnode/scripts/
ADD https://raw.githubusercontent.com/stakelovelace/cardano-node/master/entrypoint.sh ./entrypoint.sh

RUN sudo chown -R guild:guild $CNODE_HOME/* \
    && sudo chown -R guild:guild /home/guild/.* \
    && sudo chmod a+x /home/guild/.scripts/*.sh /opt/cardano/cnode/scripts/*.sh /home/guild/entrypoint.sh 

HEALTHCHECK --start-period=5m --interval=5m --timeout=100s CMD /home/guild/.scripts/healthcheck.sh

ENTRYPOINT ["./entrypoint.sh"] 
