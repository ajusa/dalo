import dalo, susta, karax/[karaxdsl], tables

section "large demo":
  var myForm = makeForm:
    email = initField(label = "Email Address").setAttrs(type="email", placeholder="something@gmail.com")
    name = initField(label="Name", default = "Hey").setAttrs(type="text", placeholder="John Doe")
    location = initField(label="Location", default = "USA", options = {"USA": "United States", "GB": "Great Brit"})
    aboutYou = initField(label="About", default = "Hey there, my name is John Smith", widget = defaultTextarea)

  for name, field in myForm.fields:
    echo field.render(value = Values())
