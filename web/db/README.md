The code here is responsible for isolating complicated queries from
both the controllers and the models.

It is also used to fake access to new-version model structs that don't
actually exist, but are instead currently synthesized from old data.
