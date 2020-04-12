FROM pandoc/core:2.9.1

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
    python \
    py2-pip \
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
    wget https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.zip && \
      unzip 1.050R-it.zip && \
      cp source-code-pro-2.030R-ro-1.050R-it/OTF/*.otf $FONT_PATH && \
      rm -rf 1.050R-it.zip source-code-pro-2.030R-ro-1.050R-it && \
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
      fncychap everyhook svn-prov letltxmacro zref && \
    rm -fr /tmp/install-tl-unx && \
    apk del .texlive-deps

VOLUME ["/workdir", "/root/.sbt", "/root/.ivy2"]

WORKDIR /workdir

ENTRYPOINT ["/bin/bash", "-c", "./setup.sh && USE_IPAFONT=true make"]
