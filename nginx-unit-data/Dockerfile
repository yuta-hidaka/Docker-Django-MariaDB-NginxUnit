FROM nginx/unit:1.19.0-python3.7
ARG APP_NAME
ARG APP_PORT
WORKDIR /code
COPY requirements.txt /config/requirements.txt
COPY generate_secret_key.py /

RUN apt-get update &&\
    apt-get upgrade &&\
    apt-get install -y python3-pip &&\
    pip3 install --upgrade setuptools &&\
    pip3 install -r /config/requirements.txt &&\
    rm -rf /var/lib/apt/lists/*

COPY . /code/

# Add original script 
RUN sed -i "2i sed -i 's/\r//' /init-scripts/init.sh" /usr/local/bin/docker-entrypoint.sh &&\
    sed -i "3i /init-scripts/init.sh $APP_NAME $APP_PORT" /usr/local/bin/docker-entrypoint.sh
