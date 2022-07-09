FROM pandoc/core:2.16

MAINTAINER yyu <yyu [at] mental.poker>

ENV TEXLIVE_DEPS \
    xz \
    tar \
    fontconfig-dev \
    zlib-dev \
    gnupg \
    musl-dev \
    alpine-sdk \
    pkgconfig \
    gmp-dev
    
ENV TEXLIVE_PATH /usr/local/texlive

ENV FONT_DEPS \
    unzip \
    fontconfig-dev

ENV FONT_PATH /usr/share/fonts/

ENV PERSISTENT_DEPS \
    openjdk8 \
    py-pip \
    wget \
    make \
    perl \
    ghostscript \
    inkscape \
    bash \
    git \
    lz4 \
    ca-certificates


ENV PATH $TEXLIVE_PATH/bin/x86_64-linux:$TEXLIVE_PATH/bin/x86_64-linuxmusl:/bin:$PATH

RUN apk upgrade --update

# Install basic dependencies
RUN apk add --no-cache --virtual .persistent-deps $PERSISTENT_DEPS

# Setup fonts
RUN mkdir -p $FONT_PATH && \
    apk add --no-cache --virtual .font-deps $FONT_DEPS && \
    # Source Code Pro
    wget "https://github.com/adobe-fonts/source-code-pro/releases/download/2.038R-ro%2F1.058R-it%2F1.018R-VAR/OTF-source-code-pro-2.038R-ro-1.058R-it.zip" && \
      unzip OTF-source-code-pro-2.038R-ro-1.058R-it.zip -d source-code-pro && \
      cp source-code-pro/*.otf $FONT_PATH && \
      rm -rf OTF-source-code-pro-2.038R-ro-1.058R-it.zip source-code-pro && \
    fc-cache -f -v && \
    apk del .font-deps 

# Install Pandocfilter
COPY requirements.txt ./
RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    rm requirements.txt

# Install TeXLive
RUN apk add --no-cache --virtual .texlive-deps $TEXLIVE_DEPS && \
    mkdir /tmp/install-tl-unx && \
    wget -qO- http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz | \
      tar -xz -C /tmp/install-tl-unx --strip-components=1 && \
    printf "%s\n" \
      "TEXDIR $TEXLIVE_PATH" \
      "selected_scheme scheme-small" \
      "option_doc 0" \
      "option_src 0" \
      > /tmp/install-tl-unx/texlive.profile && \
    /tmp/install-tl-unx/install-tl \
      -profile /tmp/install-tl-unx/texlive.profile && \
    tlmgr install latexmk collection-luatex collection-langjapanese \
      collection-fontsrecommended filehook type1cm mdframed needspace \
      fncychap everyhook svn-prov letltxmacro zref sourcesanspro \
      cm-unicode sourceserifpro haranoaji && \
    luaotfload-tool -u -vvv && \
    rm -fr /tmp/install-tl-unx && \
    apk del .texlive-deps

VOLUME ["/workdir", "/root/.sbt", "/root/.ivy2"]

WORKDIR /workdir

ENTRYPOINT ["/bin/bash", "-c", "./setup.sh && make"]
