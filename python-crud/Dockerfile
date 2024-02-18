FROM python:3.12-alpine

WORKDIR /app

ENV LOG_LEVEL="INFO"
ENV LOG_FORMAT="%(asctime)s - %(name)s - %(levelname)s - %(message)s"

ENV APP_PORT="80"
ENV METRICS_PORT="9100"

EXPOSE $APP_PORT
EXPOSE $METRICS_PORT

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

CMD [ "python", "app.py" ]

COPY _*.py .

ARG APP_NAME
COPY ${APP_NAME}.py app.py

# TODO Create a non-root user

# TODO? HEALTHCHECK --interval=30s --timeout=5s CMD wget -qO- http://localhost:$APP_PORT/healthz || exit 1
