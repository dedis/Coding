# Coding

Scripts for coding and best practices for the DeDiS-workgroup.

## GitHub usage

On top of github, we rely on the [ZenHub](http://ZenHub.io) for project
management. We use its board to put each task into a 'pipeline':

- Bugs: things that should be fixed ASAP
- QuickFix: small 1-10 liners for documentation, output or other fixes -
 should be worked on during the last hour of the working-day
- Features: for new things
- Refactoring: least important, things we want to rewrite

### Branches

All work has to be done in branches. Per default, branches go off from
`development`, as this is the working branch. For release-critical bugs
you can also branch from `release`.

The branch-name should be two or three words, concatenated using underscores.
If you work on a foreign branch, include the start of the foreign branch in
your branch.

Let's say user 1 made a branch `add_platform_lxc` and you want to
participate, you'll create a branch that goes off it with the name
`add_platform_lxc_macosxfix` and do a pull-request to the first branch,
`add_platform_lxc`.

There are two scripts, [`gic`](#gid) and [`gid`](#gid), in the `bin`
directory which make it a lot easier to handle a lot of long branch names
and can save you a lot of typing.

### Assignees

An issue/pull-request with an assignee belongs to this person - he is
 responsible for it. Specially for a pull-request, this means:

- only the assignee may add commits to this pull-request
- only somebody else than the assignee may merge the pull-request

If somebody else wants to participate on a given pull-request, he can make a
 new branch off from this pull-request and continue the work therein:

```
PR1 with assignee1
+- PR2 with assignee2
```

Now the assignee1 has to merge the PR2 into his PR1, but only somebody else
 than assignee1 can merge the PR1 back into the development-branch.

### Commits

The general rule is that for each commit, all tests should pass. This is not
  a hard rule, but it should be used whenever possible.

### Push

For push to github.com/dedis, all tests MUST pass. This can be enforced by
 using the ```.git/hooks/pre-push``` hook provided in this repository.

### Travis

TODO: there will be a travis-testfile that checks to `gofmt` and
 `go test ./...`. This is also a requirement before a merge can be done.

## Comments

Two important links regarding comments:
- [Godoc: documenting Go code](http://blog.golang.org/godoc-documenting-go-code)
- [Effective Go](https://golang.org/doc/effective_go.html)

Some important notes about what to comment:

- every function should be commented
- every package needs a comment in the `packagename.go`-file (arbitrarily
 set by myself)

Commenting-language is English, if you're not sure, don't hesitate to take
some time off in Google or wherever to increase your knowledge of English!

Please turn your auto-correction on and fix words that are marked as wrong,
except function- and variable-names that aren't English words.

## Line-width

The standard line-width is 80 characters and this is a hard limit.

## Scripts

Two scripts are provided for more easy switching and cleaning up between
branches.

### gic

The bash script [`gic`](bin/gic) stands for git-checkout. If you call it
without any arguments, it will output a list of all branches that are checked
out, together with a number in front. This lets you easily change between
branches.

New branches that have never been checked out will come in the second part of
the list and can be checked out the same way.

### gid

The script [`gid`](bin/gic) will delete a local branch to make place for new
branches. Called without arguments, it will show a list of all branches
available for deletion, called with a number, it will try to delete that
branch. This can fail if the branch hasn't been pushed.
