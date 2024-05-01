FROM fedora:40
WORKDIR /opt
COPY flopsar-server.x86_64.rpm .
COPY flopsar-workstation.zip .
#RUN dnf install -y sqlite3 util-linux-ng
RUN rpm -ihv flopsar-server.x86_64.rpm
RUN flopsar-server create --app flopsar-workstation.zip /opt/flopsar
RUN chown -R flopsar /opt/flopsar
RUN sed -i "s/eula: false/eula: true/g" /etc/flopsar/settings.yml
RUN sed -i "s/data: \/change\/me/data: \/opt\/flopsar/g" /etc/flopsar/settings.yml

USER flopsar
EXPOSE 9000/tcp
EXPOSE 9443/tcp
EXPOSE 4318/tcp
CMD flopsar-server start -c /etc/flopsar/settings.yml
