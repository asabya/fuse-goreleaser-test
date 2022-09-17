.PHONY: release
release:
	docker run --rm --privileged \
		--env-file .release-env \
		-v ~/go/pkg/mod:/go/pkg/mod \
		-v `pwd`:/go/src/github.com/asabya/fuse-goreleaser-test \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-w /go/src/github.com/asabya/fuse-goreleaser-test \
		ghcr.io/goreleaser/goreleaser-cross:v1.19.0 release --rm-dist
