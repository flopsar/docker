# RedHat 8.5
#FROM registry.access.redhat.com/ubi8/ubi:8.5 as build-redhat8_5
#RUN dnf install zip unzip clang gcc openssh-clients perl diffutils rpm-build emacs-filesystem -y
#RUN curl -O https://support.flopsar.com/bin/redhat/rpmdevtools-8.10-8.el8.noarch.rpm && rpm -ih rpmdevtools-8.10-8.el8.noarch.rpm && rm rpmdevtools-8.10-8.el8.noarch.rpm
#RUN curl -s 'https://get.sdkman.io' | bash
#RUN source $HOME/.sdkman/bin/sdkman-init.sh && sdk install java 7.0.352-zulu -y
#RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
#
# Ubuntu 16.04
FROM ubuntu:16.04 as build-ubuntu16_04
ENV CARGO_HOME=/opt
ENV RUSTUP_HOME=/opt
RUN apt update && apt install curl zip unzip clang dh-make devscripts git rpm protobuf-compiler protobuf-c-compiler -y
RUN curl -s 'https://get.sdkman.io' | bash
RUN ["/bin/bash", "-c", "source $HOME/.sdkman/bin/sdkman-init.sh && sdk install java 7.0.352-zulu -y"]
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y


#Release image
# FROM ubuntu:18.04
# WORKDIR /opt
# COPY flopsar-server-5.2.0.amd64.deb .
# COPY flopsar-workstation.zip .
# RUN dpkg -i flopsar-server-5.2.0.amd64.deb
# RUN flopsar-server create --app flopsar-workstation.zip /opt/flopsar
# RUN chown -R flopsar /opt/flopsar
# RUN sed -i "s/eula: false/eula: true/g" /etc/flopsar/settings.yml
# RUN sed -i "s/data: \/change\/me/data: \/opt\/flopsar/g" /etc/flopsar/settings.yml

# USER flopsar
# EXPOSE 9000/tcp
# EXPOSE 9443/tcp
# CMD flopsar-server start -c /etc/flopsar/settings.yml