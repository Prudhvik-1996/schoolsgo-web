FROM epsilonis/commons:flutter_sdk-3.3.8 AS builder

RUN mkdir -p /eis/schoolsgo-web
COPY . /eis/schoolsgo-web
WORKDIR /eis/schoolsgo-web

# Build the Flutter web app
RUN flutter build web --web-renderer html --release 

FROM nginx:1.22.1

# Update the listening port in the Nginx configuration file
RUN sed -i 's/listen\s*80;/listen 8989;/' /etc/nginx/conf.d/default.conf

# Copy the build files to the Nginx document root
COPY --from=builder /eis/schoolsgo-web/build/web /usr/share/nginx/html

# Expose Nginx's default HTTP port
EXPOSE 8989

# Start Nginx and serve the built files
CMD ["nginx", "-g", "daemon off;"]
