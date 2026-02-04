#!/usr/bin/env python3
"""Convert Traefik IngressRoute manifests to Istio VirtualService.

Searches recursively for files named "ingressroute.yaml" and writes
"virtualservice.yaml" in the same directory. By default, deletes the original
"ingressroute.yaml" after conversion.
"""

from __future__ import annotations

import argparse
import os
import re
from glob import glob
from typing import Any, Dict, Iterable, List, Optional, Tuple

import yaml


HOST_RE = re.compile(r"Host\(([^)]*)\)")
PATH_RE = re.compile(r"(PathPrefix|PathRegexp|Path)\(`([^`]+)`\)")


def _parse_hosts(match_expr: str) -> List[str]:
    host_match = HOST_RE.search(match_expr)
    if not host_match:
        return []
    inside = host_match.group(1)
    hosts = re.findall(r"`([^`]+)`", inside)
    return [h.strip() for h in hosts if h.strip()]


def _parse_paths(match_expr: str) -> List[Dict[str, str]]:
    paths: List[Dict[str, str]] = []
    for kind, value in PATH_RE.findall(match_expr):
        if kind == "Path":
            paths.append({"exact": value})
        elif kind == "PathRegexp":
            paths.append({"regex": value})
        else:
            paths.append({"prefix": value})
    return paths


def _build_matches(match_expr: str) -> List[Dict[str, Any]]:
    hosts = _parse_hosts(match_expr)
    paths = _parse_paths(match_expr)

    if not hosts and not paths:
        return []

    matches: List[Dict[str, Any]] = []
    if paths:
        for path in paths:
            if hosts:
                for host in hosts:
                    matches.append(
                        {"authority": {"exact": host}, "uri": path}
                    )
            else:
                matches.append({"uri": path})
    else:
        for host in hosts:
            matches.append({"authority": {"exact": host}})

    return matches


def _build_destinations(
    services: List[Dict[str, Any]], default_namespace: Optional[str]
) -> List[Dict[str, Any]]:
    routes: List[Dict[str, Any]] = []
    for service in services:
        if service.get("kind") not in (None, "Service"):
            continue
        name = service.get("name")
        if not name:
            continue
        namespace = service.get("namespace") or default_namespace
        host = name if not namespace else f"{name}.{namespace}.svc.cluster.local"
        destination: Dict[str, Any] = {"host": host}
        if "port" in service:
            destination["port"] = {"number": service["port"]}
        route: Dict[str, Any] = {"destination": destination}
        if "weight" in service:
            route["weight"] = service["weight"]
        routes.append(route)
    return routes


def _collect_hosts(match_exprs: List[str]) -> List[str]:
    hosts: List[str] = []
    for expr in match_exprs:
        for host in _parse_hosts(expr):
            if host not in hosts:
                hosts.append(host)
    return hosts


def convert_doc(
    doc: Dict[str, Any],
    gateways: List[str],
    default_hosts: List[str],
) -> Optional[Dict[str, Any]]:
    if doc.get("kind") != "IngressRoute":
        return None

    metadata = doc.get("metadata", {})
    spec = doc.get("spec", {})
    namespace = metadata.get("namespace")

    match_exprs: List[str] = [
        route.get("match", "") for route in spec.get("routes", []) or []
    ]
    hosts = _collect_hosts(match_exprs) or default_hosts
    if not hosts:
        hosts = ["*"]

    http_routes: List[Dict[str, Any]] = []
    for route in spec.get("routes", []) or []:
        match_expr = route.get("match", "")
        matches = _build_matches(match_expr)
        destinations = _build_destinations(route.get("services", []) or [], namespace)
        if not destinations:
            continue
        http_route: Dict[str, Any] = {"route": destinations}
        if matches:
            http_route["match"] = matches
        http_routes.append(http_route)

    if not http_routes:
        return None

    return {
        "apiVersion": "networking.istio.io/v1beta1",
        "kind": "VirtualService",
        "metadata": metadata,
        "spec": {
            "hosts": hosts,
            "gateways": gateways,
            "http": http_routes,
        },
    }


def _load_yaml_docs(path: str) -> List[Dict[str, Any]]:
    with open(path, "r", encoding="utf-8") as handle:
        return [doc for doc in yaml.safe_load_all(handle) if doc]


def _dump_yaml_docs(docs: Iterable[Dict[str, Any]]) -> str:
    return "\n---\n".join(
        yaml.safe_dump(doc, sort_keys=False, default_flow_style=False).rstrip()
        for doc in docs
    ) + "\n"


def convert_file(
    path: str, gateways: List[str], default_hosts: List[str]
) -> List[Dict[str, Any]]:
    docs = _load_yaml_docs(path)
    converted: List[Dict[str, Any]] = []
    for doc in docs:
        new_doc = convert_doc(doc, gateways, default_hosts)
        if new_doc:
            converted.append(new_doc)
    return converted


def iter_ingressroute_files(root: str) -> List[str]:
    pattern = os.path.join(root, "**", "ingressroute.yaml")
    return sorted(glob(pattern, recursive=True))


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Convert Traefik IngressRoute manifests to Istio VirtualService.",
    )
    parser.add_argument(
        "--root",
        default=os.getcwd(),
        help="Root directory to search (default: current working directory).",
    )
    parser.add_argument(
        "--gateway",
        default="istio-ingress/istio-ingressgateway",
        help=(
            "Comma-separated Istio gateway(s) (default: "
            "istio-ingress/istio-ingressgateway)."
        ),
    )
    parser.add_argument(
        "--default-host",
        default="",
        help=(
            "Comma-separated default host(s) if no Host() match is present "
            "(default: none -> use '*')."
        ),
    )
    parser.add_argument(
        "--keep-old",
        action="store_true",
        help="Keep original ingressroute.yaml files.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show files that would be converted without writing changes.",
    )
    args = parser.parse_args()

    gateways = [g.strip() for g in args.gateway.split(",") if g.strip()]
    default_hosts = [h.strip() for h in args.default_host.split(",") if h.strip()]

    files = iter_ingressroute_files(args.root)
    if not files:
        print("No ingressroute.yaml files found.")
        return 0

    for path in files:
        converted = convert_file(path, gateways, default_hosts)
        if not converted:
            print(f"Skipping (no IngressRoute docs): {path}")
            continue

        target = os.path.join(os.path.dirname(path), "virtualservice.yaml")
        if args.dry_run:
            print(f"Would write: {target}")
            if not args.keep_old:
                print(f"Would delete: {path}")
            continue

        with open(target, "w", encoding="utf-8") as handle:
            handle.write(_dump_yaml_docs(converted))

        if not args.keep_old:
            os.remove(path)

        print(f"Wrote: {target}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
