# Programming

## Zenhub

Please use boards and pipelines to manage your tasks. Keep them update!

We also use milestones to define goals. One or two milestones per month should
be done.

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
