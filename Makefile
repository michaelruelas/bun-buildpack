IMAGE    ?= forgejo.qubitquilt.dev/qubitquilt/cnb-builder-bun
TAG      ?= v0.1.0
BUILDER   = $(IMAGE):$(TAG)
CONFIG    = builder.toml

.PHONY: build publish push

build:
	pack builder create $(BUILDER) --config $(CONFIG)

publish:
	pack builder create $(BUILDER) --config $(CONFIG) --publish

push:
	docker push $(BUILDER)
