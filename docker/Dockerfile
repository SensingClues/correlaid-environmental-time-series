# Use the rocker/shiny image as a base for R and Shiny
FROM --platform=linux/amd64 rocker/shiny:latest

# Install necessary system dependencies and Python for Jupyter support
RUN apt-get update && \
    apt-get install -y libudunits2-dev libgdal-dev libgeos-dev libproj-dev \
                       libzmq3-dev libzmq5 python3 python3-pip shiny-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Jupyter and jupyter-client via pip
RUN pip3 install jupyter jupyter-client --break-system-packages

# Install devtools and IRkernel from GitHub using devtools
RUN R -e "install.packages(c('devtools', 'leaflet', 'shiny-server', 'shiny', 'shinyjs'))" && \
    R -e "devtools::install_github('IRkernel/IRkernel')" && \
    R -e "IRkernel::installspec(user = FALSE)"

# Copy the Shiny app and notebooks to the image
#COPY ./shiny_app/ /srv/shiny-server/
#COPY ./notebooks/ /home/rstudio/notebooks/

# Expose ports for both Shiny (3838) and Jupyter (8888)
EXPOSE 3838
EXPOSE 8888

COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

# Start both Shiny and Jupyter
# CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]
#CMD ["shiny-server"]
CMD /bin/bash -c "shiny-server & jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' & wait"

