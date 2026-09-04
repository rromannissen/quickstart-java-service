# Quickstart Java Service Helm Chart

A Helm chart for deploying Java microservices (Spring Boot / Quarkus) on OpenShift and Kubernetes.

## Prerequisites

- Helm 3.x+
- OpenShift 4.x or Kubernetes 1.24+

## Quick Start

```bash
helm template my-release . --set image.repository=quay.io/example/myapp | oc apply -f -
```

For Quarkus applications, override the health check paths:

```bash
helm template my-release . \
  --set image.repository=quay.io/example/myapp \
  --set health.startup.path=/q/health \
  --set health.readiness.path=/q/health/ready \
  --set health.liveness.path=/q/health/live
```

## What Gets Deployed

| Resource | Template | Default |
|---|---|---|
| Deployment | `deployment.yaml` | Always created |
| Service | `service.yaml` | Always created |
| ServiceAccount | `serviceaccount.yaml` | Created by default |
| Route | `route.yaml` | Enabled (OpenShift) |
| Ingress | `ingress.yaml` | Disabled |

## Configuration

### Image

| Parameter | Description | Default |
|---|---|---|
| `image.repository` | Container image repository | `""` |
| `image.tag` | Image tag | `.Chart.AppVersion` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Deployment

| Parameter | Description | Default |
|---|---|---|
| `replicaCount` | Number of pod replicas | `1` |
| `containerPort` | Container port | `8080` |
| `strategy.type` | Deployment strategy (`RollingUpdate` or `Recreate`) | `RollingUpdate` |
| `strategy.rollingUpdate.maxSurge` | Max pods above desired count during rollout | `25%` |
| `strategy.rollingUpdate.maxUnavailable` | Max unavailable pods during rollout | `25%` |
| `terminationGracePeriodSeconds` | Grace period for pod shutdown | `60` |

### Health Checks

Defaults target Spring Boot Actuator endpoints. Override for Quarkus or custom health paths.

| Parameter | Description | Default |
|---|---|---|
| `health.startup.path` | Startup probe path | `/actuator/health` |
| `health.startup.failureThreshold` | Failures before the container is killed | `30` |
| `health.startup.periodSeconds` | Probe interval | `2` |
| `health.readiness.path` | Readiness probe path | `/actuator/health/readiness` |
| `health.readiness.initialDelaySeconds` | Delay before first probe | `5` |
| `health.readiness.periodSeconds` | Probe interval | `10` |
| `health.readiness.timeoutSeconds` | Probe timeout | `2` |
| `health.liveness.path` | Liveness probe path | `/actuator/health/liveness` |
| `health.liveness.initialDelaySeconds` | Delay before first probe | `10` |
| `health.liveness.periodSeconds` | Probe interval | `10` |
| `health.liveness.timeoutSeconds` | Probe timeout | `2` |

### Resources and Security

| Parameter | Description | Default |
|---|---|---|
| `resources.requests.cpu` | CPU request | `250m` |
| `resources.requests.memory` | Memory request | `256Mi` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |
| `securityContext.runAsNonRoot` | Require non-root user | `true` |
| `securityContext.allowPrivilegeEscalation` | Allow privilege escalation | `false` |
| `securityContext.capabilities.drop` | Dropped capabilities | `[ALL]` |
| `securityContext.seccompProfile.type` | Seccomp profile | `RuntimeDefault` |

The default security context complies with the `restricted` Pod Security Admission profile.

### Environment Variables and Configuration

| Parameter | Description | Default |
|---|---|---|
| `env` | List of environment variables (`[{name: FOO, value: bar}]`) | `[]` |
| `envFrom` | References to existing Secrets/ConfigMaps for env injection | `[]` |
| `configMap.mount.enabled` | Mount an existing ConfigMap as a volume | `false` |
| `configMap.mount.name` | Name of the ConfigMap to mount | `""` |
| `configMap.mount.mountPath` | Mount path inside the container | `/deployments/config` |
| `secret.mount.enabled` | Mount an existing Secret as a volume | `false` |
| `secret.mount.name` | Name of the Secret to mount | `""` |
| `secret.mount.mountPath` | Mount path inside the container | `/deployments/secret` |

The chart references existing Secrets and ConfigMaps — it does not create them. Create your Secret or ConfigMap separately, then enable the mount:

```bash
helm template my-release . \
  --set image.repository=quay.io/example/myapp \
  --set configMap.mount.enabled=true \
  --set configMap.mount.name=my-app-config \
  --set secret.mount.enabled=true \
  --set secret.mount.name=my-app-credentials
```

### Service

| Parameter | Description | Default |
|---|---|---|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8080` |
| `service.targetPort` | Target port on the container | `8080` |

### ServiceAccount

| Parameter | Description | Default |
|---|---|---|
| `serviceAccount.create` | Create a dedicated ServiceAccount | `true` |
| `serviceAccount.name` | ServiceAccount name (generated from fullname if empty) | `""` |
| `serviceAccount.annotations` | Annotations to add to the ServiceAccount | `{}` |

### Route (OpenShift)

| Parameter | Description | Default |
|---|---|---|
| `route.enabled` | Create an OpenShift Route | `true` |
| `route.hostname` | Route hostname (auto-generated by OpenShift if empty) | `""` |
| `route.tls.termination` | TLS termination mode (`edge`, `passthrough`, `reencrypt`) | `edge` |

### Ingress (Kubernetes)

| Parameter | Description | Default |
|---|---|---|
| `ingress.enabled` | Create a Kubernetes Ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Annotations to add to the Ingress | `{}` |
| `ingress.hosts` | List of hosts with paths | `[]` |
| `ingress.tls` | TLS configuration | `[]` |

To use Ingress instead of Route:

```bash
helm template my-release . \
  --set image.repository=quay.io/example/myapp \
  --set route.enabled=false \
  --set ingress.enabled=true \
  --set "ingress.hosts[0].host=app.example.com" \
  --set "ingress.hosts[0].paths[0].path=/" \
  --set "ingress.hosts[0].paths[0].pathType=Prefix"
```

### Naming

| Parameter | Description | Default |
|---|---|---|
| `nameOverride` | Override the chart name portion of resource names | `""` |
| `fullnameOverride` | Override the full resource name entirely | `""` |

## Konveyor Integration

This chart integrates with the [Konveyor](https://www.konveyor.io/) Assets Generation engine. When Konveyor's generator addon passes the canonical configuration dictionary as a values file, the chart automatically:

- **Sets resource names** from `application.name`
- **Adds labels** from application metadata (all conditional — missing fields are skipped)
- **Adds annotations** for source traceability

### Application Metadata

The following fields from Konveyor's configuration dictionary are used when present:

| Konveyor field | Kubernetes mapping | Type |
|---|---|---|
| `application.name` | Resource name (via fullname helper) | Name |
| `application.owner` | `konveyor.io/owner` label | Label |
| `application.businessService` | `konveyor.io/business-service` label | Label |
| `application.archetypes[0]` | `konveyor.io/archetype` label | Label |
| `application.repository.url` | `konveyor.io/source-repository` annotation | Annotation |

The naming precedence is: `fullnameOverride` > `application.name` > release-name-based default.

### Example Konveyor Values

```yaml
application:
  name: my-service
  owner: jsmith
  businessService: payments
  archetypes:
    - spring-boot-api
  repository:
    kind: git
    url: https://github.com/acme/my-service.git
    branch: main

image:
  repository: quay.io/acme/my-service
```

This produces resources named `my-service` with labels:

```yaml
konveyor.io/owner: "jsmith"
konveyor.io/business-service: "payments"
konveyor.io/archetype: "spring-boot-api"
```

And the annotation:

```yaml
konveyor.io/source-repository: "https://github.com/acme/my-service.git"
```

When no `application` block is provided, the chart behaves as a standard Helm chart with no Konveyor-specific labels or annotations.

### Dockerfile Generation

The chart includes a generic multi-stage Dockerfile template under `files/konveyor/Dockerfile`. Konveyor's extended templating engine renders non-YAML files placed under `files/konveyor/` using the same Helm template syntax.

The generated Dockerfile uses a Maven build stage and a UBI OpenJDK runtime stage, suitable for both Spring Boot and Quarkus (JVM mode) applications.

| Parameter | Description | Default |
|---|---|---|
| `dockerfile.buildImage` | Base image for the Maven build stage | `registry.access.redhat.com/ubi9/openjdk-21:latest` |
| `dockerfile.runtimeImage` | Base image for the runtime stage | `registry.access.redhat.com/ubi9/openjdk-21-runtime:latest` |
| `dockerfile.mavenArgs` | Additional Maven arguments (e.g. `-Pprod`, `-pl submodule`) | `""` |
| `dockerfile.javaOpts` | JVM flags for the runtime (e.g. `-Xmx512m -XX:+UseG1GC`) | `""` |

## Helm Repository

This git repository can be used as a Helm repository. The branch `gh-pages` is set as GitHub Pages and serves `quickstart-java-service` as a packaged chart.
