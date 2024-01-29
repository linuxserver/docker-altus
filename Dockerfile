FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# set version label
ARG BUILD_DATE
ARG VERSION
ARG ALTUS_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=Altus 

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libgtk-3-0 && \
  echo "**** install altus studio from appimage ****" && \
  if [ -z ${ALTUS_VERSION+x} ]; then \
    ALTUS_VERSION=$(curl -sX GET "https://api.github.com/repos/amanharwara/altus/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  cd /tmp && \
  curl -o \
    /tmp/altus.app -L \
    "https://github.com/amanharwara/altus/releases/download/${ALTUS_VERSION}/Altus-${ALTUS_VERSION}.AppImage" && \
  chmod +x /tmp/altus.app && \
  ./altus.app --appimage-extract && \
  mv squashfs-root /opt/altus && \
  find /opt/altus -type d -exec chmod go+rx {} + && \
  sed -i 's|</applications>|  <application title="Altus*" type="normal">\n    <maximized>yes</maximized>\n  </application>\n</applications>|' /etc/xdg/openbox/rc.xml && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /config/.launchpadlib \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config
