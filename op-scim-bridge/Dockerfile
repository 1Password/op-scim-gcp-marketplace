ARG PUBLIC_TAG

FROM 1password/scim:v$PUBLIC_TAG as base

FROM registry.1password.io/dev/b5/op/base:2022.06.07

RUN apt-get update \
	&& apt-get upgrade -y \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=base /op-scim /op-scim

RUN chmod +x /op-scim/create-session-docker.sh

EXPOSE 8080
EXPOSE 8443

USER opuser

CMD ["/op-scim/op-scim"]
