# Base image
FROM clarkson/textbook-binder:2021fa

# Copy textbook into image
COPY --chown=opam . /home/opam
