IMAGE    ?= ghcr.io/michaelruelas/cnb-builder-bun
TAG      ?= v1.0.0
BUILDER   = $(IMAGE):$(TAG)
CONFIG    = builder.toml

.PHONY: build publish push

build:
	pack builder create $(BUILDER) --config $(CONFIG)

publish:
	pack builder create $(BUILDER) --config $(CONFIG) --publish

push:
	docker push $(BUILDER)
