FROM rocker/verse:latest

RUN apt update && apt install git \
    && DEBIAN_FRONTEND=noninteractive apt install -y python3-pip python-is-python3

RUN pip3 install --upgrade pip && \
    pip3 install \
    requests \
    beautifulsoup4 \
    nltk \
    pandas \
    html5lib \
    tqdm \
    chardet \
    ipykernel\
    selenium

RUN R -e "install.packages(c('languageserver'), repos='http://cran.rstudio.com/')"