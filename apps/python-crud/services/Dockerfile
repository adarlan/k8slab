FROM python:3.12-alpine

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

ENV APP_ENVIRONMENT="container"
ENV LOG_LEVEL="INFO"

COPY _*.py .

ARG APP_NAME
COPY ${APP_NAME}.py app.py
CMD [ "python", "app.py" ]

# TODO Create a non-root user
