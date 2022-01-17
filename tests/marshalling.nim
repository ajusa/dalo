import dalo/values, susta, tables, options, print
type Person = object
  name: string
  age: int
  middle: Option[string]
type PersonRef = ref Person
section "To Person":
  var test = initValues("name=asdf&age=5&middle=5")
  echo test.fromValues(Person)

section "To PersonRef":
  var test = initValues("name=asdf&age=5&middle=5")
  print test.fromValues(PersonRef)

section "From Person":
  var p = Person(name: "ajusa", age: 34)
  echo p.toValues()
  p = Person(name: "ajusa", age: 34, middle: some "middle name")
  echo p.toValues()
