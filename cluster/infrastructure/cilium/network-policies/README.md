# Cilium Network Policies

This directory contains Cilium network policies implementing the principle of least privilege for network access in the cluster.

## Structure

- `common/` - Reusable policy templates that are commonly needed across services
- `apps/` - Service-specific network policies

## Common Policies

The `common/` directory contains shared policies that are typically needed by most services:

- `allow-dns.yaml` - Allows DNS resolution via CoreDNS (kube-system)
- `allow-ingress-nginx.yaml` - Allows traffic from the nginx ingress controller
- `allow-monitoring.yaml` - Allows monitoring stack (Prometheus/Alloy) to scrape metrics

These common policies use an empty `endpointSelector` which means they apply to all pods in the namespace where they are deployed.

## Implementation Approach

Following a gradual rollout strategy:

1. **Start with isolated services** - Begin with services that have minimal dependencies
2. **Document traffic patterns** - Each policy documents what traffic is allowed and why
3. **Use L7 policies** - Where applicable, use HTTP path/method filtering
4. **Test incrementally** - Apply policies to a few services at a time to avoid widespread breakages

## Adding Policies for a New Service

1. Create a policy file in `apps/` named `<service-name>-policy.yaml`
2. Define both ingress (what can talk TO the service) and egress (what the service can talk TO) policies
3. Reference common policies as needed via kustomization
4. Document the allowed traffic patterns in comments
5. Add the policy to the appropriate kustomization.yaml

## Policy Format

Each service-specific policy should:
- Use specific endpoint selectors to target the right pods
- Define explicit ingress and egress rules
- Include comments explaining why each rule is needed
- Use L7 policy features for HTTP services where possible

## References

- [Cilium Network Policy Documentation](https://docs.cilium.io/en/stable/security/policy/index.html)
- [Cilium Policy Examples](https://docs.cilium.io/en/stable/security/policy/language/)
