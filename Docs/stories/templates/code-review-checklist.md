# Code Review Checklist

## Pre-Review Checklist
- [ ] Story implementation is complete
- [ ] All acceptance criteria have been met
- [ ] Unit tests are written and passing
- [ ] Integration tests are passing
- [ ] Code follows project coding standards
- [ ] No obvious bugs or issues
- [ ] Documentation is updated

## Code Quality Review
- [ ] Code is clean and readable
- [ ] Functions and methods are appropriately sized
- [ ] Variable and function names are descriptive
- [ ] Comments are clear and necessary
- [ ] No code duplication
- [ ] Error handling is appropriate
- [ ] Memory management is correct (if applicable)

## Architecture & Design Review
- [ ] Code follows established patterns (MVVM-C)
- [ ] Separation of concerns is maintained
- [ ] Dependencies are properly managed
- [ ] No circular dependencies
- [ ] Design patterns are used appropriately
- [ ] Code is modular and reusable

## Integration Review
- [ ] No breaking changes to existing functionality
- [ ] Existing APIs are maintained
- [ ] Database schema changes are backward compatible
- [ ] UI changes maintain consistency
- [ ] Performance is not degraded
- [ ] Accessibility requirements are met

## Security Review
- [ ] No security vulnerabilities introduced
- [ ] Input validation is appropriate
- [ ] Sensitive data is handled securely
- [ ] Authentication/authorization is correct (if applicable)
- [ ] No hardcoded secrets or credentials

## Testing Review
- [ ] Unit test coverage is adequate
- [ ] Integration tests cover key scenarios
- [ ] Edge cases are tested
- [ ] Error conditions are tested
- [ ] Performance tests pass
- [ ] UI tests cover user flows

## Documentation Review
- [ ] Code is properly documented
- [ ] README files are updated (if applicable)
- [ ] API documentation is updated (if applicable)
- [ ] User documentation is updated (if applicable)
- [ ] Story documentation is complete

## Performance Review
- [ ] No performance regressions
- [ ] Memory usage is appropriate
- [ ] Database queries are efficient
- [ ] UI rendering is smooth
- [ ] Network requests are optimized (if applicable)

## Accessibility Review
- [ ] VoiceOver support is maintained
- [ ] Dynamic Type support is maintained
- [ ] Color contrast requirements are met
- [ ] Touch targets are appropriate size
- [ ] Keyboard navigation works
- [ ] Screen reader compatibility

## Final Review
- [ ] All checklist items are completed
- [ ] Code is ready for production
- [ ] No critical issues remain
- [ ] Story can be moved to completed status

## Review Notes
[Space for reviewer comments and feedback]

## Approval
- **Reviewer**: [Name]
- **Review Date**: [YYYY-MM-DD]
- **Status**: [Approved/Needs Changes/Rejected]
- **Comments**: [Final comments and next steps]
