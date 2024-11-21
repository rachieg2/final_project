FROM rocker/verse:latest

RUN apt update && apt install git \
    && DEBIAN_FRONTEND=noninteractive apt install -y python3-pip python-is-python3

RUN apt-get update && apt-get install -y \
    texlive-full \
    python3-pip \
    python3-requests \
    python3-bs4 \
    python3-pandas \
    python3-nltk \
    python3-html5lib \
    python3-tqdm \
    python3-chardet && \
    apt-get clean

RUN R -e "install.packages(c('maps','formatR', 'languageserver', 'tidygeocoder'), repos='http://cran.rstudio.com/')"