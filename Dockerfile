# Pinned by multi-arch index digest; update tag and digest together.
FROM alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf

# kubectl version to install (official release from dl.k8s.io).
ARG KUBECTL_VERSION="v1.32.13"
# Set automatically by BuildKit; falls back to amd64 for the legacy builder.
ARG TARGETARCH

RUN set -eu; \
    arch="${TARGETARCH:-amd64}"; \
    base="https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${arch}"; \
    wget -q -O /usr/local/bin/kubectl "${base}/kubectl"; \
    wget -q -O /tmp/kubectl.sha256 "${base}/kubectl.sha256"; \
    echo "$(cat /tmp/kubectl.sha256)  /usr/local/bin/kubectl" | sha256sum -c -; \
    rm /tmp/kubectl.sha256; \
    chmod 0755 /usr/local/bin/kubectl

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
