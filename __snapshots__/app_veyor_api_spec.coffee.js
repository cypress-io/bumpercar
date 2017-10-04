exports['App Veyor API wrapper merge variables merges non-overlapping lists 1'] = [
  {
    "name": "foo",
    "value": 1
  },
  {
    "name": "bar",
    "value": 2
  }
]

exports['App Veyor API wrapper merge variables merges overlapping lists giving preference to new variables 1'] = [
  {
    "name": "foo",
    "value": "new value"
  }
]

exports['App Veyor API wrapper merge variables combines empty list with new 1'] = [
  {
    "name": "foo",
    "value": "new value"
  }
]
