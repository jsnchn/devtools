FROM devcontainer-base:latest

ARG PROJECT_NAME="project"
ARG INSTALL_DEPS=true

ENV PROJECT_NAME=${PROJECT_NAME}

RUN if [ "$INSTALL_DEPS" = "true" ]; then \
    apt-get update && apt-get install -y --no-install-recommends \
    ; \
    apt-get clean && rm -rf /var/lib/apt/lists/* \
    ; \
    fi

COPY --chown=jsnchn:jsnchn .mise.toml* /workspaces/

RUN if [ -f .mise.toml ] && [ "$INSTALL_DEPS" = "true" ]; then \
    mise install \
    ; \
    fi

WORKDIR /workspaces/${PROJECT_NAME}
