# UAV Worktree Operations

This reference documents workspace topologies and the lifecycle of git worktrees used for UAV missions.

---

## Workspace Topologies

UAV supports two workspace topologies:

1. **Isolated Worktree (Default)**:
   - Creates a temporary git worktree in `/tmp` checked out to a dedicated branch `uav/<task-slug>`.
   - Complete filesystem and branch isolation: child runs cannot accidentally modify the parent tree, staging area, or uncommitted work.
   - Ideal for autonomous coding, refactoring, and potentially disruptive changes.

2. **In-Place / Current Working Directory (Optional)**:
   - Runs directly in the parent directory (`cwd`).
   - Used for quick read-only investigations, non-git repositories, or when immediate in-place edits are explicitly desired.

---

## Worktree Lifecycle Recipes

### 1. Pre-Flight Creation

```bash
# Variables
REPO_NAME="$(basename "$(git rev-parse --show-toplevel)")"
TASK_SLUG="<task-slug>"
TIMESTAMP="$(date +%s)"
WORKTREE_PATH="/tmp/uav-${REPO_NAME}-${TASK_SLUG}-${TIMESTAMP}"
BRANCH_NAME="uav/${TASK_SLUG}"

# Create branch and worktree from current HEAD
git worktree add -b "${BRANCH_NAME}" "${WORKTREE_PATH}" HEAD
```

*Notes*:
- If `uav/${TASK_SLUG}` already exists from a prior attempt, either use a unique slug, prune the old branch (`git branch -D uav/${TASK_SLUG}`), or attach without `-b` (`git worktree add "${WORKTREE_PATH}" "${BRANCH_NAME}"`).
- Any uncommitted changes in the parent tree are **not** present in the new worktree. Worktree branches off `HEAD`. If parent uncommitted changes are needed, commit or stash them first.

---

### 2. During-Flight Inspection (From Parent Session)

The parent session can observe progress without interfering with the child runner:

```bash
# Check child git status
git -C "${WORKTREE_PATH}" status -s

# Check recent child commits
git -C "${WORKTREE_PATH}" log -n 5 --oneline --graph

# View active uncommitted diff in worktree
git -C "${WORKTREE_PATH}" diff
```

---

### 3. Post-Flight Review & Integration

Once the child runner completes and writes its debrief:

```bash
# Compare UAV branch to parent branch
git diff HEAD..."${BRANCH_NAME}"

# Inspect commit log on UAV branch
git log --oneline HEAD.."${BRANCH_NAME}"

# Option A: Merge the UAV branch
git merge "${BRANCH_NAME}"

# Option B: Rebase and merge
git rebase HEAD "${BRANCH_NAME}" && git merge "${BRANCH_NAME}"

# Option C: Cherry-pick specific commits
git cherry-pick <commit-sha>
```

---

### 4. Teardown & Cleanup

Always clean up the temporary worktree and tmux window once integration or review is finished and approved:

```bash
# Close the UAV tmux window if still open
tmux kill-window -t "uav:${TASK_SLUG}" 2>/dev/null || true

# Force-remove worktree directory and git metadata
git worktree remove --force "${WORKTREE_PATH}"

# Prune any stale worktree administrative files
git worktree prune

# Delete the temporary task branch once merged
git branch -d "${BRANCH_NAME}"

# Or force-delete if abandoned
git branch -D "${BRANCH_NAME}"

# Clean up mission files
rm -f "/tmp/uav-${TASK_SLUG}-mission.md"
# Debrief can be moved to notes or deleted after parent review
```

---

## Edge Cases & Troubleshooting

- **"fatal: '<path>' already exists"**: An aborted run left a directory in `/tmp`. Clean it up with `rm -rf <path>` and `git worktree prune`.
- **"fatal: a branch named 'uav/<task>' already exists"**: Delete the stale branch with `git branch -D uav/<task>` or append a timestamp/suffix to the task slug.
- **Dirty Parent Working Tree**: `git worktree add` operates on commits, not uncommitted working copy changes. Ensure required base changes are committed before dispatching an isolated UAV.
- **Non-Git Repositories**: Worktree isolation is unavailable; fall back automatically to In-Place / CWD mode.
