# Changelog Maintenance Guidelines

## Core Rule
**ALWAYS update the CHANGELOG.md file when making significant changes to the codebase.**

## When to Update the Changelog

### Required Updates
- **New Features**: Any new functionality added to the application
- **Bug Fixes**: Significant bug fixes that affect user experience
- **Breaking Changes**: Any changes that might affect existing functionality
- **Performance Improvements**: Notable performance optimizations
- **Security Updates**: Security-related fixes or enhancements
- **API Changes**: Modifications to API endpoints or data structures
- **Configuration Changes**: Updates to configuration options or requirements

### Optional Updates
- Minor code refactoring that doesn't affect functionality
- Documentation-only changes (unless they're major additions)
- Test improvements (unless they reveal significant issues)
- Development tooling changes

## Changelog Format

Follow the [Keep a Changelog](https://keepachangelog.com/) format:

### Version Structure
```markdown
## [Version] - YYYY-MM-DD

### Added
- New features and functionality

### Changed
- Changes to existing functionality

### Deprecated
- Features that will be removed in future versions

### Removed
- Features that have been removed

### Fixed
- Bug fixes and corrections

### Security
- Security-related changes
```

### Entry Guidelines
- Use clear, user-focused language
- Start entries with action verbs (Added, Fixed, Enhanced, etc.)
- Include the impact or benefit when relevant
- Group related changes together
- Use bullet points for individual changes

## Workflow Integration

### During Development
1. **Before Committing**: Check if your changes warrant a changelog entry
2. **Add Entry**: Update the `[Unreleased]` section with your changes
3. **Commit Together**: Include changelog updates in the same commit as the feature

### During Releases
1. **Version the Changes**: Move `[Unreleased]` entries to a new version section
2. **Add Date**: Include the release date in ISO format (YYYY-MM-DD)
3. **Create New Unreleased**: Add a new empty `[Unreleased]` section

### Git Commit Integration
- When making significant commits, reference the changelog impact
- Use conventional commit messages that align with changelog categories
- Consider the user impact when deciding changelog inclusion

## Examples

### Good Changelog Entries
```markdown
### Added
- **GIF Support**: Full GIF download, display, and slideshow support with visual indicators
- **Collection Management**: Complete collection system with creation, management, and organization
- Random selection mode for slideshow viewing

### Fixed
- Video slideshow functionality issues
- Collection slideshow empty images handling
- Windows compatibility improvements

### Enhanced
- **Performance System**: Comprehensive performance monitoring and analytics
- **Memory Management**: Real-time monitoring with automatic cleanup
```

### Poor Changelog Entries
```markdown
### Added
- Stuff
- Fixed things
- Updated code
- Made improvements
```

## Automation Reminders

### Pre-commit Checklist
- [ ] Does this change affect user functionality?
- [ ] Should users know about this change?
- [ ] Have I updated the changelog?
- [ ] Is my changelog entry clear and descriptive?

### Review Process
- Always review changelog entries during code review
- Ensure entries match the actual changes made
- Verify that user-facing changes are properly documented
- Check that the format follows the established pattern

## Maintenance Tasks

### Regular Reviews
- Monthly review of `[Unreleased]` section for completeness
- Quarterly review of recent versions for accuracy
- Annual review of changelog format and guidelines

### Git History Integration
- Periodically review Git commits to ensure no significant changes were missed
- Use `git log --oneline --since="YYYY-MM-DD"` to audit recent changes
- Cross-reference commit messages with changelog entries

## Special Considerations

### Breaking Changes
- Always document breaking changes prominently
- Include migration instructions when relevant
- Consider creating a separate migration guide for major changes

### Security Updates
- Document security fixes without revealing vulnerabilities
- Focus on the impact and recommended actions
- Consider separate security advisories for critical issues

### Performance Changes
- Include measurable improvements when available
- Explain the user benefit of performance optimizations
- Note any configuration changes required

## Tools and Automation

### Helpful Commands
```bash
# Review recent commits for changelog updates
git log --oneline --since="2024-01-01" --reverse

# Check for unreleased changes
git log --oneline HEAD...v1.0.0

# Generate commit summary for changelog
git log --pretty=format:"%s" --since="last-release-date"
```

### Integration Opportunities
- Consider adding changelog validation to CI/CD pipeline
- Use commit message conventions to auto-suggest changelog entries
- Implement changelog generation tools for routine updates

Remember: The changelog is for users, not developers. Focus on what changed from their perspective and how it affects their experience with the application.