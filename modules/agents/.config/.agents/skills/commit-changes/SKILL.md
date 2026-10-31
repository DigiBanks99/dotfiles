---
name: commit-changes
description: Use this skill when you need to commit changes using git. Be proactive in using it. It describes my preferred format for commit messages.
---

1. Use conventional commit messages for the title of the commit message. The format is: `<type>(<scope>): <description>`. For example: `feat(auth): add login functionality`.
2. The title must always be lower-case and should not exceed 50 characters.
3. The body of the commit message should provide more detailed information about the changes made.
4. The body should be wrapped at 72 characters and should not exceed 72 characters per line.
5. If the commit includes breaking changes, include a section in the body that describes the breaking change and how to address it.
6. If the commit includes a reference to an issue, include the issue number in the body of the commit message. For example: `Fixes #123` or `Implements #456`.
7. Always ensure that the commit message is clear and concise, providing enough information for others to understand the changes made without needing to look at the code.
8. Avoid using vague commit messages like "fix bug" or "update code".
9. Attempt to keep changes focussed and split into multiple commits if necessary, rather than bundling unrelated changes into a single commit.