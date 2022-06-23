FROM public.ecr.aws/lambda/python@sha256:72125c001b044177a1be2b187464d36f5be17bcbbd7af6246d4eea148cf6fcd3 as build
RUN yum install -y unzip tar xz && \
    curl -Lo "/tmp/chromedriver.zip" "https://chromedriver.storage.googleapis.com/102.0.5005.61/chromedriver_linux64.zip" && \
    curl -Lo "/tmp/chrome-linux.tar.xz" "https://github.com/macchrome/linchrome/releases/download/v102.0.5005.63-r992738-portable-ungoogled-Lin64/ungoogled-chromium_102.0.5005.63_1.vaapi_linux.tar.xz" && \
    unzip /tmp/chromedriver.zip -d /opt/ && \
    mkdir /opt/chrome-linux && tar xvf /tmp/chrome-linux.tar.xz -C /opt/chrome-linux --strip-components=1

FROM public.ecr.aws/lambda/python@sha256:72125c001b044177a1be2b187464d36f5be17bcbbd7af6246d4eea148cf6fcd3
RUN yum install atk cups-libs gtk3 libXcomposite alsa-lib \
    libXcursor libXdamage libXext libXi libXrandr libXScrnSaver \
    libXtst pango at-spi2-atk libXt xorg-x11-server-Xvfb \
    xorg-x11-xauth dbus-glib dbus-glib-devel procps xdpyinfo -y
RUN pip install selenium
COPY --from=build /opt/chrome-linux /opt/chrome
COPY --from=build /opt/chromedriver /opt/
COPY test.py ./
COPY entrypoint.sh /
CMD [ "test.handler" ]
ENTRYPOINT ["/entrypoint.sh"]
