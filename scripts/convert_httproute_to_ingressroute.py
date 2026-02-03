#!/usr/bin/env python3
"""Convert Gateway API HTTPRoute manifests to Traefik IngressRoute.

Searches recursively for files named "httproute.yaml" and writes
"ingressroute.yaml" in the same directory. By default, deletes the original
"httproute.yaml" after conversion.
"""

from __future__ import annotations

import argparse
import os
from glob import glob
from typing import Any, Dict, Iterable, List, Optional

import yaml


def _host_match(hostnames: List[str]) -> Optional[str]:
    if not hostnames:
        return None
    # Traefik allows multiple hosts in one Host() call: Host(`a`, `b`)
    joined = "`, `".join(hostnames)
    return f"Host(`{joined}`)"


def _path_expr(path: Dict[str, Any]) -> Optional[str]:
    value = path.get("value")
    if not value:
        return None
    path_type = path.get("type", "PathPrefix")
    if path_type == "Exact":
        return f"Path(`{value}`)"
    if path_type == "RegularExpression":
        return f"PathRegexp(`{value}`)"
    # Default to PathPrefix
    return f"PathPrefix(`{value}`)"


def _match_expr(hostnames: List[str], matches: List[Dict[str, Any]]) -> str:
    host = _host_match(hostnames)
    path_parts: List[str] = []
    for match in matches:
        path = match.get("path")
        if not isinstance(path, dict):
            continue
        expr = _path_expr(path)
        if expr:
            path_parts.append(expr)

    path_expr: Optional[str] = None
    if len(path_parts) == 1:
        path_expr = path_parts[0]
    elif len(path_parts) > 1:
        path_expr = "(" + " || ".join(path_parts) + ")"

    if host and path_expr:
        return f"{host} && {path_expr}"
    if host:
        return host
    if path_expr:
        return path_expr
    return "PathPrefix(`/`)"


def _middlewares(filters: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    result: List[Dict[str, Any]] = []
    for filt in filters:
        if filt.get("type") != "ExtensionRef":
            continue
        ext = filt.get("extensionRef", {})
        if ext.get("kind") != "Middleware":
            continue
        name = ext.get("name")
        if not name:
            continue
        mw: Dict[str, Any] = {"name": name}
        namespace = ext.get("namespace")
        if namespace:
            mw["namespace"] = namespace
        result.append(mw)
    return result


def _services(
    backend_refs: List[Dict[str, Any]],
    default_namespace: Optional[str],
) -> List[Dict[str, Any]]:
    result: List[Dict[str, Any]] = []
    for backend in backend_refs:
        name = backend.get("name")
        if not name:
            continue
        svc: Dict[str, Any] = {"kind": "Service", "name": name}
        namespace = backend.get("namespace") or default_namespace
        if namespace:
            svc["namespace"] = namespace
        if "port" in backend:
            svc["port"] = backend["port"]
        if "weight" in backend:
            svc["weight"] = backend["weight"]
        result.append(svc)
    return result


def convert_doc(doc: Dict[str, Any], entrypoints: List[str]) -> Optional[Dict[str, Any]]:
    if doc.get("kind") != "HTTPRoute":
        return None

    metadata = doc.get("metadata", {})
    spec = doc.get("spec", {})
    hostnames = spec.get("hostnames", []) or []
    parent_refs = spec.get("parentRefs")

    routes: List[Dict[str, Any]] = []
    for rule in spec.get("rules", []) or []:
        matches = rule.get("matches", []) or []
        filters = rule.get("filters", []) or []
        backend_refs = rule.get("backendRefs", []) or []

        route: Dict[str, Any] = {
            "kind": "Rule",
            "match": _match_expr(hostnames, matches),
            "services": _services(backend_refs, metadata.get("namespace")),
        }

        mws = _middlewares(filters)
        if mws:
            route["middlewares"] = mws

        routes.append(route)

    ingress_spec: Dict[str, Any] = {"entryPoints": entrypoints, "routes": routes}
    if parent_refs:
        ingress_spec["parentRefs"] = parent_refs

    return {
        "apiVersion": "traefik.io/v1alpha1",
        "kind": "IngressRoute",
        "metadata": metadata,
        "spec": ingress_spec,
    }


def _load_yaml_docs(path: str) -> List[Dict[str, Any]]:
    with open(path, "r", encoding="utf-8") as handle:
        docs = [d for d in yaml.safe_load_all(handle) if d]
    return docs


def _dump_yaml_docs(docs: Iterable[Dict[str, Any]]) -> str:
    return "\n---\n".join(
        yaml.safe_dump(doc, sort_keys=False, default_flow_style=False).rstrip()
        for doc in docs
    ) + "\n"


def convert_file(path: str, entrypoints: List[str]) -> List[Dict[str, Any]]:
    docs = _load_yaml_docs(path)
    converted: List[Dict[str, Any]] = []
    for doc in docs:
        new_doc = convert_doc(doc, entrypoints)
        if new_doc:
            converted.append(new_doc)
    return converted


def iter_httproute_files(root: str) -> List[str]:
    pattern = os.path.join(root, "**", "httproute.yaml")
    return sorted(glob(pattern, recursive=True))


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Convert HTTPRoute manifests to Traefik IngressRoute.",
    )
    parser.add_argument(
        "--root",
        default=os.getcwd(),
        help="Root directory to search (default: current working directory).",
    )
    parser.add_argument(
        "--entrypoints",
        default="web",
        help="Comma-separated entryPoints list (default: web).",
    )
    parser.add_argument(
        "--keep-old",
        action="store_true",
        help="Keep original httproute.yaml files.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show files that would be converted without writing changes.",
    )
    args = parser.parse_args()

    entrypoints = [ep.strip() for ep in args.entrypoints.split(",") if ep.strip()]

    files = iter_httproute_files(args.root)
    if not files:
        print("No httproute.yaml files found.")
        return 0

    for path in files:
        converted = convert_file(path, entrypoints)
        if not converted:
            print(f"Skipping (no HTTPRoute docs): {path}")
            continue

        target = os.path.join(os.path.dirname(path), "ingressroute.yaml")
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
