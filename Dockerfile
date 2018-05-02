FROM ubuntu:trusty

ENV DEBIAN_FRONTEND "noninteractive"
ENV PATH            "/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

RUN apt-get update                                                               && \
    apt-get -y dist-upgrade                                                      && \
    apt-get install -y apache2                                                      \
                       gfortran                                                     \
                       git                                                          \
                       libapache2-mod-php5                                          \
                       libapache2-mod-wsgi                                          \
                       libavcodec-dev                                               \
                       libavformat-dev                                              \
                       libfreetype6                                                 \
                       libfreetype6-dev                                             \
                       libjpeg62                                                    \
                       libjpeg62-dev                                                \
                       libmysqlclient-dev                                           \
                       libswscale-dev                                               \
                       links                                                        \
                       man                                                          \
                       mysql-client-5.5                                             \
                       mysql-server-5.5                                             \
                       nano                                                         \
                       php5-cgi                                                     \
                       python-dev                                                   \
                       python-pip                                                   \
                       python-scipy                                                 \
                       python-setuptools                                            \
                       python-software-properties                                   \
                       software-properties-common                                   \
                       w3m                                                          \
                       wget                                                      && \
    add-apt-repository -y ppa:mc3man/trusty-media                                && \
    apt-get update                                                               && \
    apt-get install -y ffmpeg                                                       \
                       gstreamer0.10-ffmpeg

RUN pip install --force-reinstall                                                   \
                --upgrade --user argparse                                           \
                                 awscli                                             \
                                 cython==0.20                                       \
                                 munkres==1.0.7                                     \
                                 mysql-python==1.2.5                                \
                                 numpy==1.9.2                                       \
                                 parsedatetime==1.4                                 \
                                 Pillow                                             \
                                 SQLAlchemy==1.0.0                                  \
                                 wsgilog==0.3                                    && \
    pip install --force-reinstall                                                   \
                --upgrade --user 'git+https://github.com/cvondrick/pyvision.git'    \
                                 'git+https://github.com/cvondrick/turkic.git'

RUN cd /root                                                                     && \
    git clone https://github.com/cvondrick/vatic.git

COPY config/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY config/apache2.conf /etc/apache2/apache2.conf

RUN cp /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled        && \
    apache2ctl graceful

COPY config/config.py /root/vatic/config.py

RUN /etc/init.d/mysql start                                                      && \
    cd /root/vatic                                                               && \
    mysql -u root --execute="CREATE DATABASE vatic;"                             && \
    turkic setup --database                                                      && \
    turkic setup --public-symlink

RUN chown -R 755 /root/vatic/public                                                 \
                 /root/vatic/*.sh                                                && \
    find /root -type d -exec chmod 755 {} +                                      && \
    chmod -R 775 /var/www                                                        && \
    apache2ctl restart

COPY ascripts /root/vatic/ascripts
COPY scripts /root/vatic

EXPOSE 80

ENTRYPOINT ["/root/vatic/start_and_block.sh"]
