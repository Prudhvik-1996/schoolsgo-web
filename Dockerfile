FROM epsilonis/commons:flutter_sdk-3.3.8

RUN mkdir -p /eis/schoolsgo-web
COPY . /eis/schoolsgo-web
WORKDIR /eis/schoolsgo-web

RUN flutter clean build

RUN flutter build web --web-renderer html --release 

EXPOSE 8989 

ENTRYPOINT ["flutter", "run", "-d", "web-server", "--web-port", "8989", "--web-hostname", "0.0.0.0"]