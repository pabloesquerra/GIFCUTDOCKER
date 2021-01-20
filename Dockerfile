FROM tiangolo/uwsgi-nginx:python3.7
#RUN add bash nano
LABEL maintainer="Sebastian Ramirez <tiangolo@gmail.com>"

RUN apt-get update
RUN apt-get install ffmpeg libsm6 libxext6  -y


RUN pip install --upgrade pip


RUN pip install flask
RUN pip install opencv-python


# URL under which static (not modified by Python) files will be requested
# They will be served by Nginx directly, without being handled by uWSGI
ENV STATIC_URL /static
# Absolute path in where the static files wil be
ENV STATIC_PATH /app/static

# If STATIC_INDEX is 1, serve / with /static/index.html directly (or the static URL configured)
# ENV STATIC_INDEX 1
ENV STATIC_INDEX 0

# Add demo app
COPY ./app /app
WORKDIR /app

# Make /app/* available to be imported by Python globally to better support several use cases like Alembic migrations.
ENV PYTHONPATH=/app

# Move the base entrypoint to reuse it
RUN mv /entrypoint.sh /uwsgi-nginx-entrypoint.sh
# Copy the entrypoint that will generate Nginx additional configs
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# Run the start script provided by the parent image tiangolo/uwsgi-nginx.
# It will check for an /app/prestart.sh script (e.g. for migrations)
# And then will start Supervisor, which in turn will start Nginx and uWSGI
CMD ["/start.sh"]
#ENV STATIC_URL /static
#ENV STATIC_PATH /var/www/app/static
#COPY ./requirements.txt /var/www/requirements.txt
#RUN pip install -r /var/www/requirements.txt
