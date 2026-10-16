<!--
SPDX-FileCopyrightText: 2026 Travis Wichert

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Docker Socket Access for Authentik Worker

Authentik's Docker outpost integration requires the Authentik worker to have access to the host's Docker daemon. This allows Authentik to automatically manage outpost containers on the same host.

This role provides two methods for granting Docker socket access to the worker:
* Docker socket proxy (recommended)
* Bind mount (lighter-weight, but unsafe for production)

## Docker Socket Proxy (Production, Safer)

The [Docker socket proxy](https://docs.linuxserver.io/images/docker-socket-proxy/) configures HAProxy to listen on the Authentik container network at http://mash-authentik-docker-socket-proxy:2375. When another container connects (hopefully the Authentik worker), HAProxy checks the request against an allow-list. If the request passes checks, it is passed on to the host's Docker API through the socket. This reduces the API attack surface in the event the Authentik worker container is compromised.

The `DOCKER_HOST` environment variable is provided to the Authentik worker container.

### How to Enable

Set the following variable in your configuration:

```yaml
authentik_docker_socket_proxy_enabled: true
```

### Filtering API Access

By default, the proxy is configured with the following permissions, which are sufficient for most Authentik operations:

- `CONTAINERS=1` (Manage containers)
- `IMAGES=1` (Pull images)
- `NETWORKS=1` (Connect to networks)
- `VOLUMES=1` (Create volumes)
- `POST=1` (Allow POST requests/write operations)
- `INFO=1` (Read engine info)

You can customize these by overriding `authentik_docker_socket_proxy_environment_variables`,  but that shouldn't be necessary. If it is, please file a bug report and explain the situation. Thanks!

```yaml
authentik_docker_socket_proxy_environment_variables:
  - "CONTAINERS=1"
  - "IMAGES=1"
  - "NETWORKS=1"
  - "VOLUMES=1"
  - "POST=1"
  - "INFO=1"
  # Add more filters if needed
```

## Direct Socket Mount (Dev/Test, Unsafe)

This method mounts the host's Docker socket directly into the Authentik worker container. This is less secure because it gives the container full, unfiltered access to your Docker daemon's API. Probably best to avoid this in production.

### How to Enable

If you prefer this method, ensure the proxy is disabled and enable the worker mount:

```yaml
authentik_docker_socket_proxy_enabled: false
authentik_worker_docker_socket_mount_enabled: true
```

> [!NOTE]
> If `authentik_docker_socket_proxy_enabled` is `true`, it takes precedence, and the direct mount will be ignored for security reasons.

### Permission Issues

When directly mounting, the Authentik Worker (uid/gid 1000, by default) might not have permissions to read/write to the Docker socket. Add the `docker` group ID to the container using `authentik_worker_container_extra_arguments`:

```yaml
# Replace 999 with your host's 'docker' group ID
authentik_worker_container_extra_arguments:
  - "--group-add 999"
```

## Configuration Summary

| Variable                                       | Default                                   | Description                                   |
|------------------------------------------------|-------------------------------------------|-----------------------------------------------|
| `authentik_docker_socket_proxy_enabled`        | `false`                                   | Enables the Docker socket proxy service.      |
| `authentik_docker_socket_proxy_image`          | `lscr.io/linuxserver/socket-proxy:latest` | The image used for the proxy.                 |
| `authentik_docker_socket_path`                 | `/var/run/docker.sock`                    | Path to the Docker socket on the Docker host. |
| `authentik_worker_docker_socket_mount_enabled` | `false`                                   | Bind-mounts `docker.sock`                     |
