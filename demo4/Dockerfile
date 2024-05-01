

#Release image
FROM ubuntu:18.04
WORKDIR /opt
COPY flopsar-server-5.1.0.amd64.deb .
COPY flopsar-workstation.zip .
RUN dpkg -i flopsar-server-5.1.0.amd64.deb
RUN flopsar-server create --app flopsar-workstation.zip /opt/flopsar
RUN chown -R flopsar /opt/flopsar
RUN sed -i "s/eula: false/eula: true/g" /etc/flopsar/settings.yml
RUN sed -i "s/data: \/change\/me/data: \/opt\/flopsar/g" /etc/flopsar/settings.yml

USER flopsar
EXPOSE 9000/tcp
EXPOSE 9443/tcp
CMD flopsar-server start -c /etc/flopsar/settings.yml
