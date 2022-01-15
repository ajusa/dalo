import dalo, susta, karax/[karaxdsl], tables, uri

section "large demo":
  var myForm = makeForm:
    email = initField(label = "Email Address").attrs(type="email", placeholder="something@gmail.com")
    name = initField(label="Name", default = "Hey").attrs(type="text", placeholder="John Doe")
    location = initField(label="Location", default = "USA", options = {"USA": "United States", "GB": "Great Brit"})
    aboutYou = initField(label="About", default = "Hey there, my name is John Smith", widget = defaultTextarea)

  for name, field in myForm.fields:
    echo field.render(value = Values())

section "validation demo":
  var myForm = makeForm:
    email = initField(label = "Email Address").attrs(type="email", minlength = "8", placeholder="something@gmail.com")
    age = initField(label="Age", default = "3").attrs(type = "number", required = "", min = "13")
  var values = encodeQuery({"email": "notanemail"}).initValues
  echo myForm.validate(values)
  values = encodeQuery({"email": "avalidemail@email.com"}).initValues
  echo myForm.validate(values)
  values = encodeQuery({"age": "not a number", "email": "s@mal.c"}).initValues
  echo myForm.validate(values)
  values = encodeQuery({"age": "3", }).initValues
  echo myForm.validate(values)
  values = encodeQuery({"age": "23", }).initValues
  echo myForm.validate(values)

