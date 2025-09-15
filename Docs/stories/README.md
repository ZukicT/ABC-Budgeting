# Stories Management System

## Overview
This folder contains all user stories for the ABC Budgeting project, organized by status and development phase.

## Folder Structure

### `/active/`
Contains stories currently in development or ready to be started. Stories move here when they're assigned to a developer.

### `/completed/`
Contains stories that have been fully implemented, tested, and accepted. Stories move here after successful completion.

### `/code-review/`
Contains stories that are implemented and ready for code review. Stories move here when development is complete but before final acceptance.

### `/templates/`
Contains story templates and workflow documentation for creating and managing stories.

## Story Status Workflow

```
[Backlog] → [Active] → [Code Review] → [Completed]
```

### Status Definitions

- **Backlog**: Story is defined but not yet assigned to a developer
- **Active**: Story is assigned and currently being worked on
- **Code Review**: Story implementation is complete and ready for review
- **Completed**: Story has passed code review and is accepted

## Story File Naming Convention

```
{epic-number}-{story-number}-{short-description}.md
```

Examples:
- `1-1-ios-widget-implementation.md`
- `1-2-advanced-analytics-dashboard.md`
- `1-3-enhanced-notification-system.md`

## Moving Stories Between Folders

### To Move a Story to Active:
1. Copy story file from backlog to `/active/`
2. Update status in story file to "Active"
3. Add assigned developer and start date

### To Move a Story to Code Review:
1. Copy story file from `/active/` to `/code-review/`
2. Update status in story file to "Code Review"
3. Add completion date and implementation notes

### To Move a Story to Completed:
1. Copy story file from `/code-review/` to `/completed/`
2. Update status in story file to "Completed"
3. Add acceptance date and final notes

## Developer Instructions

### Starting a New Story
1. Check `/active/` folder for assigned stories
2. Read the complete story file including acceptance criteria
3. Review integration requirements and technical constraints
4. Update story status to "In Progress" with your name and start date
5. Create feature branch following naming convention: `feature/{story-number}-{short-description}`

### Completing a Story
1. Ensure all acceptance criteria are met
2. Run all tests and verify functionality
3. Update story file with implementation details
4. Move story file to `/code-review/` folder
5. Update status to "Code Review" with completion date
6. Create pull request for code review

### Code Review Process
1. Review code against acceptance criteria
2. Check integration requirements are met
3. Verify technical constraints are followed
4. Test functionality thoroughly
5. Approve or request changes
6. If approved, move story to `/completed/` folder

## Story Template Usage

Use the templates in `/templates/` folder to create new stories:
- `user-story-template.md` - For standard user stories
- `technical-story-template.md` - For technical implementation stories
- `bug-fix-template.md` - For bug fixes and issues

## Integration with Development

Each story includes:
- Clear acceptance criteria
- Integration verification requirements
- Technical implementation details
- Testing requirements
- Dependencies and prerequisites

## Quality Assurance

Before moving any story to completed:
- [ ] All acceptance criteria met
- [ ] Integration requirements verified
- [ ] Code review completed
- [ ] Tests passing
- [ ] Documentation updated
- [ ] No breaking changes to existing functionality
