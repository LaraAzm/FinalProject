# starting from the rstudio image
FROM rocker/r-ver:4.4.1

# installing the linux libraries needed for plumber
RUN apt-get update -qq && apt-get install -y  libssl-dev  libcurl4-gnutls-dev  libpng-dev

# installing plumber and other required packages used in finalAPI
RUN R -e "install.packages('plumber')"
RUN R -e "install.packages('readr')"
RUN R -e "install.packages('readxl')"
RUN R -e "install.packages('caret')"
RUN R -e "install.packages('ranger')"

# copy everything from the current directory into the container
COPY . .

# open port 90 to traffic
EXPOSE 90

# when the container starts, start the runAPI.R script
ENTRYPOINT ["R", "-e", \
"pr <- plumber::plumb('runAPI.R'); pr$run(host='0.0.0.0', port=90)"]