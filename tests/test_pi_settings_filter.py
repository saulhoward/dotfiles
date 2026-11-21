"""Test the real clean/smudge filter with synthetic settings and an isolated HOME."""

import json
import os
import shlex
from pathlib import Path
import stat
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/pi-settings-filter"


class PiSettingsFilterTests(unittest.TestCase):
    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.home = Path(temporary.name)
        self.private = self.home / ".pi/agent/settings.private.json"
        self.env = dict(os.environ, HOME=str(self.home))
        self.public = {"theme": "system", "packages": ["npm:example-package"]}
        self.hidden = {"slack-bridge": {"botToken": "synthetic-test-value", "allowedUsers": ["test-user"]}}

    def run_filter(self, mode: str, text: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [str(SCRIPT), mode], input=text, env=self.env,
            capture_output=True, text=True, check=False,
        )

    def test_round_trip_masks_private_fields_and_keeps_runtime_settings(self) -> None:
        original = {**self.public, **self.hidden}
        clean = self.run_filter("clean", json.dumps(original))
        self.assertEqual(clean.returncode, 0, clean.stderr)
        self.assertEqual(json.loads(clean.stdout), self.public)
        self.assertEqual(json.loads(self.private.read_text()), self.hidden)
        self.assertEqual(stat.S_IMODE(self.private.stat().st_mode), 0o600)
        smudge = self.run_filter("smudge", clean.stdout)
        self.assertEqual(smudge.returncode, 0, smudge.stderr)
        self.assertEqual(json.loads(smudge.stdout), original)
        again = self.run_filter("clean", smudge.stdout)
        self.assertEqual(again.stdout, clean.stdout)

    def test_public_only_clean_does_not_erase_saved_private_settings(self) -> None:
        result = self.run_filter("clean", json.dumps({**self.public, **self.hidden}))
        self.assertEqual(result.returncode, 0, result.stderr)
        result = self.run_filter("clean", json.dumps(self.public))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(self.private.read_text()), self.hidden)

    def test_unknown_settings_are_private_by_default(self) -> None:
        unknown = {"new-extension": {"credential": "another-test-value"}}
        result = self.run_filter("clean", json.dumps({**self.public, **unknown}))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout), self.public)
        self.assertEqual(json.loads(self.private.read_text()), unknown)

    def test_invalid_input_or_overlay_fails_without_emitting_settings(self) -> None:
        for text in ("{invalid", "[]", "null"):
            with self.subTest(text=text):
                result = self.run_filter("clean", text)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(result.stdout, "")
        self.private.parent.mkdir(parents=True)
        self.private.write_text("invalid overlay")
        result = self.run_filter("smudge", json.dumps(self.public))
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")

    def test_overlay_preserves_private_values_without_overriding_public_settings(self) -> None:
        self.private.parent.mkdir(parents=True)
        self.private.write_text(json.dumps({"theme": "wrong", **self.hidden}))
        historical = {**self.public, "slack-bridge": {"runtimeMode": "test"}}
        result = self.run_filter("smudge", json.dumps(historical))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout), {**self.public, **self.hidden})
        clean = self.run_filter("clean", result.stdout)
        self.assertEqual(clean.returncode, 0, clean.stderr)
        self.assertEqual(json.loads(clean.stdout), self.public)
        self.assertEqual(json.loads(self.private.read_text()), self.hidden)

    def test_git_index_is_masked_and_required_filter_fails_closed(self) -> None:
        repo = self.home / "repo"
        repo.mkdir()
        env = dict(self.env, GIT_CONFIG_GLOBAL="/dev/null", GIT_CONFIG_NOSYSTEM="1")

        def git(*args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
            return subprocess.run(
                ["git", "-C", str(repo), *args], env=env,
                capture_output=True, text=True, check=check,
            )

        git("init", "-q")
        for mode in ("clean", "smudge"):
            git("config", f"filter.pi-private.{mode}", f"{shlex.quote(str(SCRIPT))} {mode}")
        git("config", "filter.pi-private.required", "true")
        (repo / ".gitattributes").write_text("settings.json filter=pi-private\n")
        settings = repo / "settings.json"
        original = {**self.public, **self.hidden}
        settings.write_text(json.dumps(original))
        git("add", "settings.json")
        self.assertEqual(json.loads(git("show", ":settings.json").stdout), self.public)
        self.assertEqual(json.loads(settings.read_text()), original)
        git("checkout-index", "-f", "settings.json")
        self.assertEqual(json.loads(settings.read_text()), original)
        settings.write_text("{malformed")
        self.assertNotEqual(git("add", "settings.json", check=False).returncode, 0)
        self.assertEqual(json.loads(git("show", ":settings.json").stdout), self.public)

    def test_fresh_machine_without_overlay_uses_public_settings(self) -> None:
        result = self.run_filter("smudge", json.dumps(self.public))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout), self.public)
        self.assertFalse(self.private.exists())


if __name__ == "__main__":
    unittest.main()
