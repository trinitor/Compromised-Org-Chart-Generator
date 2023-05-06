# Example Cypher Queries

You can use this examples in Neo4j to query the database and draw the graph.

## show all users
```
MATCH (employee)
RETURN employee
```

## show only users with manager relationship
```
MATCH (manager)-[:MANAGER_OF]->(employee)
RETURN manager, employee
```

## show only users from a specific department
```
MATCH (employee {department:'IT'})
RETURN employee
```
