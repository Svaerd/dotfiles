#!/usr/bin/env python3
import argparse
import json
import os
from collections import OrderedDict


def _split_path_env(value, fallback):
    text = value if value else fallback
    return [p for p in text.split(":") if p]


def _read_desktop_entry(path):
    name = ""
    mime_types = []
    in_desktop_entry = False

    try:
        with open(path, "r", encoding="utf-8", errors="replace") as fh:
            for raw in fh:
                line = raw.strip()
                if not line or line.startswith("#"):
                    continue

                if line.startswith("[") and line.endswith("]"):
                    in_desktop_entry = line == "[Desktop Entry]"
                    continue

                if not in_desktop_entry or "=" not in line:
                    continue

                key, value = line.split("=", 1)
                key = key.strip()
                value = value.strip()

                if key == "Hidden" and value.lower() == "true":
                    return None
                if key == "NoDisplay" and value.lower() == "true":
                    # Keep as fallback handler, do not drop.
                    pass
                if key == "Name" and not name:
                    name = value
                if key == "MimeType":
                    mime_types.extend([m.strip() for m in value.split(";") if m.strip()])
    except OSError:
        return None

    if not mime_types:
        return None

    return {
        "name": name,
        "mime_types": mime_types,
    }


def _desktop_search_paths():
    home = os.path.expanduser("~")
    xdg_data_home = os.environ.get("XDG_DATA_HOME", os.path.join(home, ".local", "share"))
    xdg_data_dirs = _split_path_env(os.environ.get("XDG_DATA_DIRS"), "/usr/local/share:/usr/share")

    roots = [xdg_data_home] + xdg_data_dirs
    paths = [os.path.join(root, "applications") for root in roots]

    # Preserve order and remove duplicates.
    seen = set()
    ordered = []
    for p in paths:
        if p not in seen:
            seen.add(p)
            ordered.append(p)
    return ordered


def _collect_handlers():
    handlers_by_mime = {}
    desktop_info = {}

    for app_dir in _desktop_search_paths():
        if not os.path.isdir(app_dir):
            continue

        for root, _, files in os.walk(app_dir):
            for filename in files:
                if not filename.endswith(".desktop"):
                    continue

                full_path = os.path.join(root, filename)
                desktop_id = filename

                # Keep first entry by search precedence.
                if desktop_id in desktop_info:
                    continue

                entry = _read_desktop_entry(full_path)
                if not entry:
                    continue

                info = {
                    "desktopId": desktop_id,
                    "name": entry["name"] or desktop_id,
                    "path": full_path,
                }
                desktop_info[desktop_id] = info

                for mime_type in entry["mime_types"]:
                    handlers_by_mime.setdefault(mime_type, []).append(desktop_id)

    return handlers_by_mime, desktop_info


def _desktop_tokens():
    raw = os.environ.get("XDG_CURRENT_DESKTOP", "")
    if not raw:
        return []
    return [token.strip().lower() for token in raw.split(":") if token.strip()]


def _mimeapps_precedence_paths():
    home = os.path.expanduser("~")
    tokens = _desktop_tokens()

    paths = []

    def add(path):
        if path not in paths:
            paths.append(path)

    for token in tokens:
        add(os.path.join(home, ".config", f"{token}-mimeapps.list"))
    add(os.path.join(home, ".config", "mimeapps.list"))

    for token in tokens:
        add(os.path.join("/etc/xdg", f"{token}-mimeapps.list"))
    add(os.path.join("/etc/xdg", "mimeapps.list"))

    for token in tokens:
        add(os.path.join(home, ".local", "share", "applications", f"{token}-mimeapps.list"))
    add(os.path.join(home, ".local", "share", "applications", "mimeapps.list"))

    for base in ("/usr/local/share/applications", "/usr/share/applications"):
        for token in tokens:
            add(os.path.join(base, f"{token}-mimeapps.list"))
        add(os.path.join(base, "mimeapps.list"))

    return paths


def _read_default_from_file(path):
    defaults = {}
    if not os.path.isfile(path):
        return defaults

    section = ""
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as fh:
            for raw in fh:
                line = raw.strip()
                if not line or line.startswith("#"):
                    continue
                if line.startswith("[") and line.endswith("]"):
                    section = line[1:-1].strip()
                    continue
                if section != "Default Applications" or "=" not in line:
                    continue

                mime_type, value = line.split("=", 1)
                mime_type = mime_type.strip()
                apps = [x.strip() for x in value.split(";") if x.strip()]
                if apps:
                    defaults[mime_type] = apps
    except OSError:
        return {}

    return defaults


def _effective_defaults():
    result = {}
    source = {}
    for path in _mimeapps_precedence_paths():
        defaults = _read_default_from_file(path)
        for mime_type, apps in defaults.items():
            if mime_type not in result and apps:
                result[mime_type] = apps
                source[mime_type] = path
    return result, source


def _read_user_config(path):
    sections = OrderedDict()
    current = None

    if not os.path.isfile(path):
        return sections

    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        for raw in fh:
            line = raw.rstrip("\n")
            stripped = line.strip()
            if stripped.startswith("[") and stripped.endswith("]"):
                current = stripped[1:-1].strip()
                sections.setdefault(current, OrderedDict())
                continue
            if not stripped or stripped.startswith("#") or "=" not in line or current is None:
                continue

            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip()
            sections.setdefault(current, OrderedDict())[key] = value

    return sections


def _write_user_config(path, sections):
    os.makedirs(os.path.dirname(path), exist_ok=True)

    with open(path, "w", encoding="utf-8") as fh:
        first = True
        for section, keyvals in sections.items():
            if not first:
                fh.write("\n")
            first = False
            fh.write(f"[{section}]\n")
            for key, value in keyvals.items():
                fh.write(f"{key}={value}\n")


def scan(show_only_conflicts=True):
    handlers_by_mime, desktop_info = _collect_handlers()
    effective_defaults, sources = _effective_defaults()

    rows = []
    for mime_type, handlers in handlers_by_mime.items():
        unique_handlers = []
        seen = set()
        for desktop_id in handlers:
            if desktop_id in seen:
                continue
            seen.add(desktop_id)
            info = desktop_info.get(desktop_id)
            if info:
                unique_handlers.append({
                    "key": desktop_id,
                    "name": info["name"],
                })

        if len(unique_handlers) == 0:
            continue
        if show_only_conflicts and len(unique_handlers) < 2:
            continue

        default_apps = effective_defaults.get(mime_type, [])
        current_default = default_apps[0] if default_apps else ""
        if not current_default and unique_handlers:
            current_default = unique_handlers[0]["key"]

        current_name = current_default
        for handler in unique_handlers:
            if handler["key"] == current_default:
                current_name = handler["name"]
                break

        rows.append({
            "mimeType": mime_type,
            "handlers": unique_handlers,
            "currentDefault": current_default,
            "currentDefaultName": current_name,
            "defaultSource": sources.get(mime_type, ""),
        })

    rows.sort(key=lambda x: x["mimeType"])

    return {
        "ok": True,
        "entries": rows,
        "count": len(rows),
    }


def set_default(mime_type, desktop_id):
    home = os.path.expanduser("~")
    user_mimeapps = os.path.join(home, ".config", "mimeapps.list")

    sections = _read_user_config(user_mimeapps)
    defaults = sections.setdefault("Default Applications", OrderedDict())

    existing = [x.strip() for x in defaults.get(mime_type, "").split(";") if x.strip()]
    reordered = [desktop_id] + [x for x in existing if x != desktop_id]
    defaults[mime_type] = ";".join(reordered) + ";"

    _write_user_config(user_mimeapps, sections)

    return {
        "ok": True,
        "mimeType": mime_type,
        "desktopId": desktop_id,
        "file": user_mimeapps,
    }


def main():
    parser = argparse.ArgumentParser(description="MIME defaults backend for Noctalia MimeApp GUI")
    sub = parser.add_subparsers(dest="command", required=True)

    scan_cmd = sub.add_parser("scan", help="Scan desktop files and MIME handlers")
    scan_cmd.add_argument("--all", action="store_true", help="Include MIME types with a single handler")

    set_cmd = sub.add_parser("set-default", help="Set default app for a MIME type")
    set_cmd.add_argument("--mime", required=True, help="MIME type, e.g. text/plain")
    set_cmd.add_argument("--desktop", required=True, help="Desktop file id, e.g. org.example.App.desktop")

    args = parser.parse_args()

    if args.command == "scan":
        payload = scan(show_only_conflicts=not args.all)
        print(json.dumps(payload, ensure_ascii=True))
        return

    if args.command == "set-default":
        payload = set_default(args.mime, args.desktop)
        print(json.dumps(payload, ensure_ascii=True))
        return


if __name__ == "__main__":
    main()
