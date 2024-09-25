# MELODY #

Multibody properties tool

Modify the properties (boundary conditions) of several bodies in a single command.

% - Examples -
The format is as follows:
SECTION NAME (the new one if boundary conditions)
New content

To keep a part of the old content, you can use the '~'
character, placing it after the name of the section or at
the very end.

The number of boundary conditions is calculated automatically

Examples:

#. e.g.
Before:
Y Dirichlet Driven
2
0 0
1000000 0
Changes:
Y Neumann Following
2
0 0
1000000 0
After:
Y Neumann Following
2
0 0
1000000 0

#. e.g.
Before
Y Dirichlet Driven
2
0 0
10 0
Changes:
Y Neumann Following
~
1000000 0
After:
Y Neumann Following
3
0 0
10 0
1000000 0

#. e.g.
Before
Y Dirichlet Driven
2
10 0
1000000 0
Changes:
Y Neumann Following
0 0
~
After:
Y Neumann Following
3
0 0
10 0
10000000 0
