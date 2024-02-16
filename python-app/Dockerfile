FROM python:3.12-alpine

WORKDIR /app

EXPOSE 80
EXPOSE 8000

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
CMD [ "python", "app.py" ]

# TODO Create a non-root user
# TODO HEALTHCHECK --interval=30s --timeout=5s CMD wget -qO- http://localhost:$PORT/ || exit 1
