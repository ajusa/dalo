import dalo/values, susta
type Person = object
  name: string
  age: int
section "To Person":
  var test = initValues("name=asdf&age=5")
  echo test.fromValues(Person)

