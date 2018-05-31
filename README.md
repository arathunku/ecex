# Ecex


Simple CQRS implementation based on:

  - https://gist.github.com/pcreux/d094affd957a336af4f59b85f6ec0e6d
  - https://kickstarter.engineering/event-sourcing-made-simple-4a2625113224


## TODO

  - cleanup aggregate definitions
  - add more tests
  - improve changeset validations
  - add helpers for changeset based validations for commands
  - remove hard coded reference to the repo


## Running
```
# 1st terminal: plis run postgres
# 2nd terminal: mix test.watch
```
