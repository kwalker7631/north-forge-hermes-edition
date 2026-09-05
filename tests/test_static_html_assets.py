"""Checks that repository-local links in static HTML point to real files."""

from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit
import unittest


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
HTML_FILES = (REPOSITORY_ROOT / "WELCOME.html",)


class LocalReferenceParser(HTMLParser):
    """Collect local src and href attribute values."""

    def __init__(self):
        super().__init__()
        self.references = []

    def handle_starttag(self, tag, attrs):
        del tag
        for name, value in attrs:
            if name in {"src", "href"} and value:
                parsed = urlsplit(value)
                if not parsed.scheme and not parsed.netloc and parsed.path:
                    self.references.append(unquote(parsed.path))


class StaticHtmlAssetTests(unittest.TestCase):
    def test_local_references_exist(self):
        missing = []
        for html_file in HTML_FILES:
            parser = LocalReferenceParser()
            parser.feed(html_file.read_text(encoding="utf-8"))
            for reference in parser.references:
                base = REPOSITORY_ROOT if reference.startswith("/") else html_file.parent
                target = (base / reference.lstrip("/")).resolve()
                try:
                    target.relative_to(REPOSITORY_ROOT)
                except ValueError:
                    missing.append(f"{html_file.name}: {reference} (outside repository)")
                    continue
                if not target.is_file():
                    missing.append(f"{html_file.name}: {reference}")

        self.assertEqual([], missing, "Missing local HTML assets: " + ", ".join(missing))

    def test_welcome_uses_expected_logo_paths(self):
        parser = LocalReferenceParser()
        parser.feed(HTML_FILES[0].read_text(encoding="utf-8"))

        self.assertIn("assets/north-forge-icon.svg", parser.references)
        self.assertIn("assets/logo-kyocera-1024.png", parser.references)


if __name__ == "__main__":
    unittest.main()
