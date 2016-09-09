These are Fowler-style [transaction scripts](http://martinfowler.com/eaaCatalog/transactionScript.html). 

They will use modules in `.../db` to access the database. They know
nothing of repos themselves. However, for the moment, tests are not
isolated from the database.
