"""Exercise cleanup through the real gclone/gwt* functions in local repositories."""

import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path


class GwtCleanupTests(unittest.TestCase):
    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name).resolve()
        self.seed = self.root / "upstream"
        self.workspace = self.root / "project with spaces"
        self.base = self.workspace / "trunk"
        self.feature = self.workspace / "feature-topic"
        self.common = self.workspace / ".git"
        self.cwd_record = self.root / "shell-cwd"
        self.env = dict(
            os.environ,
            ZDOTDIR=str(Path(__file__).resolve().parents[1] / "zsh/.config/zsh"),
            GIT_CONFIG_GLOBAL="/dev/null",
            GIT_CONFIG_NOSYSTEM="1",
            GIT_ALLOW_PROTOCOL="file",
            GIT_TERMINAL_PROMPT="0",
            CLEANUP_TEST_CWD=str(self.cwd_record),
        )
        self.git(self.root, "init", "-b", "trunk", str(self.seed))
        self.configure(self.seed)
        (self.seed / "file").write_text("initial\n")
        (self.seed / ".gitignore").write_text("ignored\n")
        self.git(self.seed, "add", ".")
        self.git(self.seed, "commit", "-m", "initial")
        self.shell_ok("gclone", str(self.seed), str(self.workspace), cwd=self.root)
        self.configure(self.base)
        self.shell_ok("gwtnew", "feature/topic", cwd=self.base)
        (self.feature / "file").write_text("feature\n")
        self.git(self.feature, "commit", "-am", "feature")

    def git(self, cwd: Path, *args: str) -> str:
        return subprocess.run(
            ["git", "-C", str(cwd), *args], env=self.env,
            capture_output=True, text=True, check=True, timeout=20,
        ).stdout.strip()

    def configure(self, cwd: Path) -> None:
        for key, value in (
            ("user.name", "Cleanup Test"),
            ("user.email", "test@example.invalid"),
            ("commit.gpgsign", "false"),
            ("core.hooksPath", "/dev/null"),
        ):
            self.git(cwd, "config", key, value)

    def shell(self, *args: str, cwd: Path | None = None) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [
                "zsh", "-f", "-c",
                'source "$ZDOTDIR/worktrees.zsh" || exit; '
                'source "$ZDOTDIR/cleanup.zsh" || exit; '
                '"$@"; cleanup_status=$?; '
                'pwd -P > "$CLEANUP_TEST_CWD"; exit "$cleanup_status"',
                "gwt-cleanup-test", *args,
            ],
            cwd=cwd or self.feature, env=self.env,
            capture_output=True, text=True, check=False, timeout=30,
        )

    def shell_ok(self, *args: str, cwd: Path | None = None) -> subprocess.CompletedProcess[str]:
        result = self.shell(*args, cwd=cwd)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result

    def publish_merge(self) -> None:
        self.git(self.seed, "fetch", str(self.common), "feature/topic")
        self.git(self.seed, "merge", "--ff-only", "FETCH_HEAD")

    def assert_feature_kept(self) -> None:
        self.assertTrue(self.feature.is_dir())
        self.assertEqual(self.git(self.feature, "branch", "--show-current"), "feature/topic")
        self.assertEqual(self.cwd_record.read_text().strip(), str(self.feature))

    def test_plan_then_execute_preserves_bare_repo_and_base(self) -> None:
        self.publish_merge()
        old_base = self.git(self.base, "rev-parse", "HEAD")
        result = self.shell_ok("git", "cleanup", "--plan")
        plan = json.loads(result.stdout)
        self.assertEqual(plan["primary_worktree"], str(self.base))
        self.assertTrue(plan["remove_worktree"])
        self.assertEqual(plan["base"], "trunk")
        self.assert_feature_kept()
        self.assertEqual(self.git(self.base, "rev-parse", "HEAD"), old_base)
        saved = self.root / "reviewed plan.json"
        saved.write_text(result.stdout)
        self.shell_ok("gcleanup", "--execute", str(saved), "--no-gc")
        self.assertFalse(self.feature.exists())
        self.assertEqual(self.cwd_record.read_text().strip(), str(self.base))
        self.assertEqual(self.git(self.base, "rev-parse", "HEAD"), self.git(self.seed, "rev-parse", "HEAD"))
        self.assertTrue(self.common.is_dir())
        self.assertEqual(self.git(self.common, "rev-parse", "--is-bare-repository"), "true")
        self.assertNotIn("refs/heads/feature/topic", self.git(self.base, "show-ref", "--heads"))
        # Cleanup leaves the repository usable by the existing helpers.
        self.shell_ok("gwtnew", "next/topic", cwd=self.base)
        self.assertTrue((self.workspace / "next-topic/.git").is_file())

    def test_default_cleanup_from_nested_feature_keeps_sibling(self) -> None:
        self.publish_merge()
        self.git(self.base, "branch", "another", "trunk")
        self.shell_ok("gwtadd", "another", cwd=self.base)
        nested = self.feature / "nested"
        nested.mkdir()
        self.shell_ok("gcleanup", "--no-gc", cwd=nested)
        self.assertFalse(self.feature.exists())
        self.assertTrue((self.workspace / "another/.git").is_file())
        self.assertEqual(self.cwd_record.read_text().strip(), str(self.base))

    def test_base_cleanup_updates_without_removing_any_worktree(self) -> None:
        self.publish_merge()
        marker = self.base / "ignored"
        marker.write_text("keep local data")
        self.shell_ok("gcleanup", "--no-gc", cwd=self.base)
        self.assertTrue(self.feature.exists())
        self.assertEqual(marker.read_text(), "keep local data")
        self.assertEqual(self.git(self.base, "rev-parse", "HEAD"), self.git(self.seed, "rev-parse", "HEAD"))
        self.assertEqual(self.cwd_record.read_text().strip(), str(self.base))

    def test_cleanup_from_project_parent_targets_base(self) -> None:
        self.publish_merge()
        self.shell_ok("gcleanup", "--no-gc", cwd=self.workspace)
        self.assertTrue(self.feature.exists())
        self.assertTrue(self.common.exists())
        self.assertEqual(self.git(self.base, "rev-parse", "HEAD"), self.git(self.seed, "rev-parse", "HEAD"))
        self.assertEqual(self.cwd_record.read_text().strip(), str(self.workspace))

    def test_unmerged_feature_is_preserved(self) -> None:
        result = self.shell("gcleanup", "--no-gc")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("not merged", result.stderr)
        self.assert_feature_kept()

    def test_local_files_are_preserved_even_with_force(self) -> None:
        self.publish_merge()
        for name in ("file", "untracked", "ignored"):
            with self.subTest(name=name):
                marker = self.feature / name
                previous = marker.read_text() if marker.exists() else None
                marker.write_text("do not delete")
                result = self.shell("gcleanup", "--force", "--no-gc")
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(marker.read_text(), "do not delete")
                self.assert_feature_kept()
                if previous is None:
                    marker.unlink()
                else:
                    marker.write_text(previous)

    def test_locked_feature_is_preserved(self) -> None:
        self.publish_merge()
        self.git(self.base, "worktree", "lock", str(self.feature))
        result = self.shell("gcleanup", "--force", "--no-gc")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("locked", result.stderr)
        self.assert_feature_kept()

    def test_missing_base_worktree_blocks_removal(self) -> None:
        self.publish_merge()
        self.shell_ok("gwtrm", "trunk")
        result = self.shell("gcleanup", "--force", "--no-gc")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("base worktree", result.stderr)
        self.assert_feature_kept()
        self.assertTrue(self.common.exists())

    def test_moved_base_invalidates_saved_plan(self) -> None:
        self.publish_merge()
        saved = self.root / "plan.json"
        saved.write_text(self.shell_ok("git", "cleanup", "--plan").stdout)
        moved = self.workspace / "moved base"
        self.git(self.feature, "worktree", "move", str(self.base), str(moved))
        result = self.shell("gcleanup", "--execute", str(saved), "--no-gc")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("evidence changed", result.stderr)
        self.assert_feature_kept()
        # Fresh cleanup finds the base through Git, not an assumed folder name.
        self.shell_ok("gcleanup", "--no-gc")
        self.assertEqual(self.cwd_record.read_text().strip(), str(moved))
        self.assertTrue(moved.exists())

    def test_dirty_base_is_not_modified_when_cleaning_feature(self) -> None:
        self.publish_merge()
        old_base = self.git(self.base, "rev-parse", "HEAD")
        marker = self.base / "file"
        marker.write_text("unfinished base work")
        self.shell_ok("gcleanup", "--no-gc")
        self.assertFalse(self.feature.exists())
        self.assertEqual(marker.read_text(), "unfinished base work")
        self.assertEqual(self.git(self.base, "rev-parse", "HEAD"), old_base)
        self.assertEqual(self.cwd_record.read_text().strip(), str(self.base))

    def test_no_update_base_preserves_base_ref(self) -> None:
        self.publish_merge()
        old_base = self.git(self.base, "rev-parse", "HEAD")
        self.shell_ok("gcleanup", "--no-gc", "--no-update-base")
        self.assertFalse(self.feature.exists())
        self.assertEqual(self.git(self.base, "rev-parse", "HEAD"), old_base)
        self.assertEqual(self.cwd_record.read_text().strip(), str(self.base))


if __name__ == "__main__":
    unittest.main()
