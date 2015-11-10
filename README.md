# Coding

Scripts for coding and best practices for the DeDiS-workgroup.

## GitHub usage

When working with github, we rely on the http://ZenHub.io plugin to use the board which helps to put each task into a ```pipeline```:

- Bugs - things that should be fixed ASAP
- QuickFix - small 1-10 liners for documentation, output or other fixes - should be worked on during the last hour of the working-day
- Features - for new things
- Refactoring - least important, things we want to rewrite

### Assignees

An issue/pull-request with an assignee belongs to this person - he is responsible for it. Specially for a pull-request, this means:

- only the assignee may add commits to this pull-request
- only somebody else than the assignee may merge the pull-request

If somebody else wants to participate on a given pull-request, he can make a new branch off from this pull-request and continue the work therein:

```
PR1 with assignee1
+- PR2 with assignee2
```

Now the assignee1 has to merge the PR2 into his PR1, but only somebody else than assignee1 can merge the PR1 back into the development-branch.

### Commits

The general rule is that for each commit, all tests should pass. This is not a hard rule, but it should be used whenever possible.

### Push

For push to github.com/dedis, all tests MUST pass. This can be enforced by using the ```.git/hooks/pre-push``` hook provided in this repository.

### Travis

TODO: there will be a travis-testfile that checks to ```gofmt``` and ```go test ./...```. This is also a requirement before a merge can be done.
