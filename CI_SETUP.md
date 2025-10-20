# GitHub Actions CI Setup

## Overview

GitHub Actions CI is now enabled for the Orion web framework. The workflow runs automatically on every push and pull request, ensuring code quality and test coverage.

## Workflow Configuration

**File:** `.github/workflows/crystal.yml`

### Triggers

- **Push events:** Runs on pushes to `master` or `main` branches
- **Pull requests:** Runs on PRs targeting `master` or `main` branches

### Jobs

#### 1. Test Job (runs on all pushes and PRs)

Runs on: `ubuntu-latest` with `crystallang/crystal:1.18.1` container

**Steps:**
1. **Checkout code** - Uses `actions/checkout@v4`
2. **Install dependencies** - Runs `shards install`
3. **Check code formatting** - Runs `crystal tool format --check`
4. **Run specs** - Executes full test suite with `crystal spec`
5. **Build verification** - Compiles project with `crystal build --no-codegen`

**Success Criteria:**
- ✅ All 143 tests must pass
- ✅ Code must follow Crystal formatting guidelines
- ✅ Project must compile without errors

#### 2. Docs Job (runs only on master/main pushes)

Runs on: `ubuntu-latest` with `crystallang/crystal:1.18.1` container

**Conditional:** Only runs when:
- Event is a push (not a PR)
- Branch is `master` or `main`

**Steps:**
1. **Checkout code** - Uses `actions/checkout@v4`
2. **Install dependencies** - Runs `shards install`
3. **Build documentation** - Generates API docs with `crystal docs`
4. **Deploy to GitHub Pages** - Uses `peaceiris/actions-gh-pages@v4`

## Benefits

### Quality Assurance
- Automated testing on every commit
- Prevents regressions from being merged
- Ensures consistent code style across contributors

### Documentation
- API documentation automatically regenerated on master/main updates
- Always up-to-date documentation on GitHub Pages
- No manual doc deployment needed

### Developer Experience
- Immediate feedback on PRs
- Clear pass/fail status before merge
- Catches issues early in development cycle

## Current Status

### Test Coverage
- **143/143 tests passing** (100%)
- **0 failures, 0 errors, 0 pending**
- Average run time: ~800ms

### Code Quality
- All source files formatted per Crystal style guide
- No syntax errors or compilation issues
- Crystal 1.18.1 compatibility verified

### Compilation
- Full project compiles successfully
- No type errors
- All middleware and features functional

## Local Development

To ensure your code will pass CI before pushing:

```bash
# Install dependencies
shards install

# Check formatting
crystal tool format --check

# Run tests
crystal spec

# Verify compilation
crystal build --no-codegen src/orion.cr
```

## Viewing CI Results

1. Go to the repository on GitHub
2. Click the "Actions" tab
3. View workflow runs for your branch/PR
4. Click on a run to see detailed logs

## CI Badge

The README.md already includes a CI status badge:

```markdown
[![Crystal CI](https://github.com/obsidian/orion/workflows/Crystal%20CI/badge.svg)](https://github.com/obsidian/orion/actions?query=workflow%3A%22Crystal+CI%22)
```

This shows the current CI status for the master/main branch.

## Troubleshooting

### Format Check Fails
Run `crystal tool format` locally to auto-fix formatting issues.

### Tests Fail
Run `crystal spec` locally to see detailed failure messages.

### Build Fails
Run `crystal build src/orion.cr` locally to see compilation errors.

## Future Improvements

Potential enhancements to consider:

- [ ] Add test coverage reporting
- [ ] Matrix builds for multiple Crystal versions
- [ ] Performance benchmarking
- [ ] Security scanning
- [ ] Dependency caching for faster builds
- [ ] Slack/Discord notifications for failures
