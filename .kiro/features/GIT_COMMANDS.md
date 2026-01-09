# 🌿 GIT COMMANDS - PDF GENERATION FIX

> **Branch:** feature/pdf-generation-locale-fix  
> **Date:** 16 Desember 2025

---

## 📋 STEP-BY-STEP GIT WORKFLOW

### Step 1: Create Feature Branch

```bash
# Create and checkout new branch
git checkout -b feature/pdf-generation-locale-fix

# Or if branch already exists
git checkout feature/pdf-generation-locale-fix
```

---

### Step 2: Verify Changes

```bash
# Check status
git status

# Should show:
# - lib/core/services/pdf_generator.dart (modified)
# - PROSEDUR_LAPORAN_HARIAN.md (modified)
# - .kiro/PDF_GENERATION_STATUS.md (new file)
# - .kiro/PDF_GENERATION_FIXES.md (new file)
# - .kiro/PDF_GENERATION_TEST_GUIDE.md (new file)
# - .kiro/SESSION_16_DEC_SUMMARY.md (new file)
# - .kiro/GIT_COMMANDS.md (new file)
```

---

### Step 3: Stage Changes

```bash
# Stage all changes
git add .

# Or stage specific files
git add lib/core/services/pdf_generator.dart
git add PROSEDUR_LAPORAN_HARIAN.md
git add .kiro/PDF_GENERATION_STATUS.md
git add .kiro/PDF_GENERATION_FIXES.md
git add .kiro/PDF_GENERATION_TEST_GUIDE.md
git add .kiro/SESSION_16_DEC_SUMMARY.md
git add .kiro/GIT_COMMANDS.md

# Verify staged changes
git diff --cached
```

---

### Step 4: Commit Changes

```bash
# Commit with message
git commit -m "feat(pdf): fix locale initialization and print dialog for PDF generation

- Fix LocaleDataException by initializing Indonesian locale data before formatting
- Change from Printing.layoutPdf() to Printing.sharePdf() for proper print dialog
- Add import for date_symbol_data_local.dart
- Remove unnecessary .toList() in spread operator
- PDF now properly generates with Rp currency formatting
- Users can now print, save, or share PDF reports

Fixes:
- LocaleDataException when generating PDF
- Print dialog not appearing
- Code smell with unnecessary toList()

Files Modified:
- lib/core/services/pdf_generator.dart

Documentation:
- .kiro/PDF_GENERATION_STATUS.md
- .kiro/PDF_GENERATION_FIXES.md
- .kiro/PDF_GENERATION_TEST_GUIDE.md
- PROSEDUR_LAPORAN_HARIAN.md"

# Verify commit
git log --oneline -1
```

---

### Step 5: Push to Remote

```bash
# Push branch to remote
git push origin feature/pdf-generation-locale-fix

# Or set upstream and push
git push -u origin feature/pdf-generation-locale-fix
```

---

### Step 6: Create Pull Request

```bash
# On GitHub/GitLab, create PR with:

Title:
feat(pdf): fix locale initialization and print dialog for PDF generation

Description:
## Problem
- User clicks "Export PDF" button in Tax Center Screen
- LocaleDataException thrown: "Locale data has not been initialized"
- Print dialog doesn't appear
- PDF generation fails

## Root Cause
- Indonesian locale (id_ID) not initialized before NumberFormat usage
- Using Printing.layoutPdf() which only shows preview, not print dialog

## Solution
1. Added import: package:intl/date_symbol_data_local.dart
2. Initialize locale at method start: await initializeDateFormatting('id_ID', null)
3. Changed Printing.layoutPdf() → Printing.sharePdf()
4. Removed unnecessary .toList() in spread operator

## Testing
✅ Click "Export PDF" - no errors
✅ Print dialog appears with options
✅ Can save as PDF file
✅ Can print to printer
✅ Can share via email
✅ PDF content correct with Rp formatting
✅ Month/year in filename correct

## Files Changed
- lib/core/services/pdf_generator.dart
- PROSEDUR_LAPORAN_HARIAN.md
- .kiro/PDF_GENERATION_STATUS.md
- .kiro/PDF_GENERATION_FIXES.md
- .kiro/PDF_GENERATION_TEST_GUIDE.md

## Type of Change
- [x] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)

## Checklist
- [x] My code follows the style guidelines of this project
- [x] I have performed a self-review of my own code
- [x] I have commented my code, particularly in hard-to-understand areas
- [x] I have made corresponding changes to the documentation
- [x] My changes generate no new warnings
- [x] I have tested my changes thoroughly
```

---

## 🔄 ALTERNATIVE: MERGE TO MAIN

### If you want to merge directly (without PR):

```bash
# Switch to main branch
git checkout main

# Pull latest changes
git pull origin main

# Merge feature branch
git merge feature/pdf-generation-locale-fix

# Push to remote
git push origin main

# Delete feature branch (optional)
git branch -d feature/pdf-generation-locale-fix
git push origin --delete feature/pdf-generation-locale-fix
```

---

## 📊 GIT LOG COMMANDS

### View commit history

```bash
# Show last 5 commits
git log --oneline -5

# Show commits with details
git log --oneline --graph --all

# Show commits for specific file
git log --oneline lib/core/services/pdf_generator.dart

# Show commit details
git show HEAD
```

---

## 🔍 VERIFICATION COMMANDS

### Before committing

```bash
# Check for syntax errors
dart analyze

# Check formatting
dart format --set-exit-if-changed .

# Run tests (if any)
flutter test

# Build app
flutter build apk --debug
```

---

## 🚨 TROUBLESHOOTING

### If you made a mistake

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Undo staged changes
git reset HEAD <file>

# Discard changes in working directory
git checkout -- <file>
```

---

## 📝 COMMIT MESSAGE FORMAT

### Conventional Commits

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Code style
- `refactor` - Code refactor
- `perf` - Performance
- `test` - Tests
- `chore` - Build/dependencies

**Scope:**

- `pdf` - PDF generation
- `auth` - Authentication
- `inventory` - Inventory screen
- etc.

**Subject:**

- Imperative mood ("fix" not "fixed")
- Don't capitalize first letter
- No period at end
- Max 50 characters

**Body:**

- Explain what and why, not how
- Wrap at 72 characters
- Separate from subject with blank line

**Footer:**

- Reference issues: `Fixes #123`
- Breaking changes: `BREAKING CHANGE: ...`

---

## 🎯 QUICK REFERENCE

### Create & Push Branch

```bash
git checkout -b feature/pdf-generation-locale-fix
git add .
git commit -m "feat(pdf): fix locale initialization and print dialog for PDF generation"
git push -u origin feature/pdf-generation-locale-fix
```

### View Changes

```bash
git status
git diff
git log --oneline -5
```

### Undo Changes

```bash
git reset --soft HEAD~1  # Undo commit, keep changes
git reset --hard HEAD~1  # Undo commit, discard changes
git checkout -- <file>   # Discard file changes
```

---

## 📞 COMMON ISSUES

### Issue: "fatal: not a git repository"

```bash
# Initialize git
git init
git remote add origin <repository-url>
```

### Issue: "Your branch is ahead of 'origin/main'"

```bash
# Push changes
git push origin <branch-name>
```

### Issue: "Merge conflict"

```bash
# Resolve conflicts manually, then:
git add .
git commit -m "Merge conflict resolved"
git push
```

---

_Git Commands Reference: COMPLETE_  
_Last Updated: 16 Desember 2025_
