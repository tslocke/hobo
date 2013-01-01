# How do you do a 'recently active' query in SQL?

Originally written by Tom on 2008-10-16.

e.g. say `User has_many :recipes`, how would you write a query that ordered the users who most recently created a recipe first?

Here's what I tried and it don't be working!

    SELECT * FROM "users"
      ORDER BY (select created_at from recipes where recipes.user_id = users.id order by created_at limit 1)
      LIMIT 6

(Yes, my SQL really is that bad)