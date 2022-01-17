import dalo/values, susta, tables, options, print
type 
  PersonClass = enum
    Baby, Toddler, Youth, Adult, SeniorCitizen
  Person = object
    name: string
    age: int
    middle: Option[string]
    class: PersonClass
  PersonRef = ref Person
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

section "To Enum":
  var test = initValues("class=2&age=5&middle=5")
  print test.fromValues(Person)

