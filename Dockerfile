FROM jeroenpeeters/meteord:1.2.0.2

RUN echo "while [[ \$(curl -s http://mongo:27017) != *\"It looks like you are trying to access MongoDB over HTTP on the native driver port.\" ]]; do echo \"Waiting for Mongo DB\"; sleep 5; done" | cat - /opt/meteord/run_app.sh > /tmp/out && mv /tmp/out /opt/meteord/run_app.sh

RUN apt-get install -y ssh
