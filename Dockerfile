FROM node:boron

ENV USER_NAME=keypress \
    USER_UID=1001 \
    HOME=/usr/src
WORKDIR /usr/src

RUN git clone https://github.com/dymurray/keypress

WORKDIR /usr/src/keypress
RUN npm install

RUN useradd -u ${USER_UID} -r -g 0 -M -d /usr/src -b /usr/src -s /sbin/nologin -c "keypress user" ${USER_NAME} \
               && chown -R ${USER_NAME}:0 /usr/src \
               && chmod -R g=u /usr/src /etc/passwd
USER 1001
EXPOSE 3000


ADD entrypoint.sh /usr/bin

ENTRYPOINT ["entrypoint.sh"]

