# What about security?

*After the latest mass assignment kerfuffle, what needs to be done to
make Hobo resistant to simple attack?*

Hobo adds a permission system to Hobo models that will protect them
from mass assignment vulnerabilities. If you have any models in your
app that are not Hobo models, they may still be vulnerable to the
Rails mass-assignment vulnerability and should still be protected via
attr_accessible or similar

