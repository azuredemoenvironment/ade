FROM redis:6-alpine

# Setup working directory
WORKDIR /opt
RUN mkdir -p ade

# Install
RUN apk update \
    && apk upgrade \
    && apk add wget bash libc6-compat gzip dos2unix

# Copy Redis Config
COPY redis.conf /usr/local/etc/redis/redis.conf

# COPY Start Script
WORKDIR /opt/ade
COPY ./start.sh ./
RUN chmod 777 start.sh

ENTRYPOINT ["/opt/ade/start.sh"]