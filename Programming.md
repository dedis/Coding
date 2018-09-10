# Programming

## Development cycle

Start in master and make sure it's up to date:
```
git checkout master
git pull
```

Create a new branch for your work:
```
git checkout -b short_issue#
```

Develop and commit from time to time:
```
git commit -am "short description"
```

Push the branch to github:
```
git push -u origin short_issue#
```
The `short_issue#` must be the same name as the branch. Make sure the new branch
shows up in the zenhub-pipeline, for this go to the main page of your project and click
on `create PR` (not sure about the wording). Enter yourself as the `Assignee` and
use the button `connect with an issue` if the PR is in relation with an issue.

To check what is currently being developed and the files that are different:
```
git status
```
This will also show if you have other files that need to be `git add` to your code.
Don't add binaries or files that will be auto-generated. You can also create a
`.gitignore` files with the files to be ignored inside, so they will not show up in
`git status`.

To commit more work, do the following:
```
git commit -am "short description"
git push
```

Once you're done, you need sometimes to rebase against master. To do this, use:
```
git fetch
git rebase origin/master
# fix eventual merge conflicts, 'git add' the conflicting files and 'git rebase --continue'
git push --force
```

## Docu

Verify that godoc gives a reasonable output for the parts you've been coding. Do
this at least before a merge to development or master.

## Coding details

### Private / public

As many as possible of the fields and the methods should be kept private.
Start the file in a way that it makes sense to read it, so put the structure
definition at the top, followed by any 'New'-method and then follow with
the most important public methods on that structure.

All private methods are by definition less important and should be put at
the bottom.

### Variable names

Good variable names are one or two words. For structures, avoid
abbreviations. In methods abbreviations are of course OK. The
usual abbreviations are the capital letters of the structure
they point to. So a variable pointing to a structure called 
'TreeNodeInstance' could be named 'tni'.

Also when renaming structures, think of adjusting the names of the variables
of the structure-methods:

Before
```
func (n *Node)SendTo
```

After

```
func (tni *TreeNodeInstance)SendTo
```
