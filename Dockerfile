FROM mcr.microsoft.com/devcontainers/cpp:debian13 AS deps
USER root
ENV SKIP_VCPKG=1
WORKDIR /app
COPY vcpkg.json Makefile ./
COPY scripts/install.cmake scripts/install.cmake
RUN make install
RUN make deps

FROM gcc:14 AS compile
RUN apt-get update \
    && apt-get install -y --no-install-recommends cmake \
    && rm -rf /var/lib/apt/lists/*
ENV SKIP_VCPKG=1
WORKDIR /app
COPY --from=deps /app/vcpkg_installed /app/vcpkg_installed
COPY . .
RUN make install
RUN make compile

FROM debian:trixie-slim
WORKDIR /app
ENV LD_LIBRARY_PATH=/app
COPY --from=compile /app/out/app /app/app
COPY --from=compile /app/vcpkg_installed/x64-linux-dynamic/lib/*.so* /app/
COPY --from=compile /usr/local/lib64/libstdc++.so* /usr/local/lib64/libgcc_s.so* /app/
ENTRYPOINT ["./app"]
