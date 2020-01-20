FROM ubuntu:18.04

USER root
RUN apt-get update && apt-get update -y && apt-get autoremove -y
RUN apt-get install curl ocrmypdf tesseract-ocr-deu -y

RUN useradd -ms /bin/bash ocr
ADD ocr.sh /home/ocr/
RUN chown ocr:ocr /home/ocr/ocr.sh && chmod +x /home/ocr/ocr.sh

USER ocr
WORKDIR /home/ocr/

RUN curl -L https://github.com/gdrive-org/gdrive/releases/download/2.1.0/gdrive-linux-x64 -o gdrive
RUN chmod +x gdrive
RUN mkdir .gdrive

ENTRYPOINT [ "/bin/bash", "/home/ocr/ocr.sh" ]