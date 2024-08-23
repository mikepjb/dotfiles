FROM node:22-alpine3.19 AS box

ENV USER=developer \
    GROUP=developer \
    UID=1001 \
    TZ=UTC \
    LANG=en_US.utf8

COPY packages.list /tmp/

RUN set -eux; \
    apk -U upgrade; \
    apk -v add util-linux alpine-conf; \
    xargs -r apk -v add < /tmp/packages.list; \
    addgroup --system --gid $UID $GROUP; \
    adduser --system --disabled-password --uid $UID $USER -G $GROUP -s /bin/bash; \
    setup-timezone -z $TZ; \
    apk del util-linux alpine-conf; \
    rm -rf /var/cache/apk/*; \
    rm -rf /tmp/*

WORKDIR /home/$USER
USER $USER
COPY init.lua ./.config/nvim/init.lua
RUN nvim +Dots +qall

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
