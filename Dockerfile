FROM rocker/verse
RUN apt update && apt install -y man-db && rm -rf /var/lib/apt/lists/*
RUN yes | unminimize
RUN R -e "install.packages(c('languageserver'), repos='http://cran.rstudio.com/')"