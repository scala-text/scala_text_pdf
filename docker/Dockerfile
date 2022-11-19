FROM ubuntu:22.04

LABEL maintainer="YOSHIMRUA Hikaru <yyu [at] mental.poker>"

ARG TARGETARCH

RUN apt-get update

ENV PERSISTENT_DEPS \
    openjdk-8-jdk \
    python3-pip \
    wget \
    make \
    perl \
    ghostscript \
    inkscape \
    bash \
    git \
    lz4 \
    ca-certificates \
    unzip \
    fontconfig
RUN apt-get install -y --no-install-recommends $PERSISTENT_DEPS

# Setup fonts
ENV FONT_PATH /usr/share/fonts/
RUN mkdir -p $FONT_PATH && \
    # Source Code Pro
    wget "https://github.com/adobe-fonts/source-code-pro/releases/download/2.038R-ro%2F1.058R-it%2F1.018R-VAR/OTF-source-code-pro-2.038R-ro-1.058R-it.zip" && \
      unzip OTF-source-code-pro-2.038R-ro-1.058R-it.zip -d source-code-pro && \
      cp source-code-pro/*.otf $FONT_PATH && \
      rm -rf OTF-source-code-pro-2.038R-ro-1.058R-it.zip source-code-pro && \
    fc-cache -f -v

# Install Pandoc
ENV PANDOC_VERSION 2.19
ENV PANDOC_DOWNLOAD_URL https://github.com/jgm/pandoc/releases/download/$PANDOC_VERSION/pandoc-$PANDOC_VERSION-linux-$TARGETARCH.tar.gz
ENV PANDOC_ROOT /usr/local/bin/pandoc
RUN wget -qO- "$PANDOC_DOWNLOAD_URL" | tar -xzf - && \
    cp pandoc-$PANDOC_VERSION/bin/pandoc $PANDOC_ROOT && \
    rm -Rf pandoc-$PANDOC_VERSION/

# Install Pandocfilter
COPY requirements.txt ./
RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    rm requirements.txt

# Install TeXLive
ARG TEXLIVE_OPTIONS=""
ENV TEXLIVE_PATH /usr/local/texlive
RUN mkdir /tmp/install-tl-unx && \
    wget -qO- http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz | \
      tar -xz -C /tmp/install-tl-unx --strip-components=1 && \
    printf "%s\n" \
      "TEXDIR $TEXLIVE_PATH" \
      "selected_scheme scheme-small" \
      "option_doc 0" \
      "option_src 0" \
      > /tmp/install-tl-unx/texlive.profile && \
    if [[ "$TARGETARCH" = "arm64" ]]; then \
      /tmp/install-tl-unx/install-tl \
        -profile /tmp/install-tl-unx/texlive.profile \
        $TEXLIVE_OPTIONS \
        -force-platform aarch64-linux; \
    else \
      /tmp/install-tl-unx/install-tl \
        -profile /tmp/install-tl-unx/texlive.profile \
        $TEXLIVE_OPTIONS; \
    fi

ENV PATH $TEXLIVE_PATH/bin/aarch64-linux:$TEXLIVE_PATH/bin/x86_64-linux:/bin:$PATH
RUN tlmgr $TEXLIVE_OPTIONS install latexmk collection-luatex collection-langjapanese \
      collection-fontsrecommended filehook type1cm mdframed needspace \
      fncychap everyhook svn-prov zref sourcesanspro \
      cm-unicode sourceserifpro haranoaji && \
    luaotfload-tool -u -vvv && \
    rm -fr /tmp/install-tl-unx && \
    apt-get -y clean

VOLUME ["/workdir", "/root/.sbt", "/root/.ivy2"]

WORKDIR /workdir

ENTRYPOINT ["/bin/bash", "-c", "./setup.sh && make"]
