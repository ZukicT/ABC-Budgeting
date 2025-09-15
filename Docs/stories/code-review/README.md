# Code Review Process

## Overview
This folder contains stories that are ready for code review. Stories move here after development is complete but before final acceptance.

## Code Review Workflow

### Before Moving to Code Review
1. All acceptance criteria must be met
2. All tests must be passing
3. Code must follow project standards
4. Documentation must be updated
5. No obvious bugs or issues

### Code Review Process
1. **Assign Reviewer**: Assign appropriate reviewer based on expertise
2. **Review Code**: Use the code review checklist
3. **Provide Feedback**: Document all feedback and suggestions
4. **Approve or Request Changes**: Make decision based on review
5. **Move to Completed**: If approved, move to completed folder

### Code Review Checklist
Use the checklist in `/templates/code-review-checklist.md` for systematic review.

## Review Criteria

### Code Quality
- Clean, readable code
- Appropriate function and method sizes
- Descriptive variable and function names
- Clear and necessary comments
- No code duplication
- Proper error handling

### Architecture & Design
- Follows established patterns (MVVM-C)
- Maintains separation of concerns
- Proper dependency management
- No circular dependencies
- Appropriate design patterns
- Modular and reusable code

### Integration
- No breaking changes to existing functionality
- Maintains existing APIs
- Backward compatible database changes
- Consistent UI changes
- No performance degradation
- Accessibility requirements met

### Testing
- Adequate unit test coverage
- Integration tests cover key scenarios
- Edge cases are tested
- Error conditions are tested
- Performance tests pass
- UI tests cover user flows

### Security
- No security vulnerabilities
- Appropriate input validation
- Secure handling of sensitive data
- No hardcoded secrets
- Proper authentication/authorization

## Review Timeline
- **Standard Review**: 2-3 business days
- **Urgent Review**: 1 business day
- **Complex Review**: 5 business days

## Review Assignment
- **Frontend/UI Stories**: Assign to UI/UX expert
- **Backend/Data Stories**: Assign to backend expert
- **Architecture Stories**: Assign to senior developer
- **Security Stories**: Assign to security expert

## Review Notes Template
Each story in code review should have:
- Reviewer name and date
- Review status (Approved/Needs Changes/Rejected)
- Detailed feedback and suggestions
- Specific issues to address
- Next steps and timeline

## Escalation Process
If review is blocked or controversial:
1. Discuss with team lead
2. Escalate to technical lead if needed
3. Schedule team review session
4. Document decision and rationale

## Quality Gates
Stories cannot move to completed without:
- [ ] Code review approval
- [ ] All feedback addressed
- [ ] Final verification by reviewer
- [ ] Documentation updated
- [ ] Tests passing
