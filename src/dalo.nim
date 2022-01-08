{.experimental: "dotOperators".}
import tables, std/[with, sequtils, strtabs]
import karax/[karaxdsl, vdom]
import dalo/validators
  
type 
  Field* = object 
    label*: string
    node*: VNode
    validators*: seq[Validator]


proc initField(label = ""): Field =
  var defaultNode = buildHtml(input())
  Field(label: label, node: defaultNode)

proc fromVNode(f: Field, node: VNode): Field =
  var cp = f
  cp.node = node
  return cp

template attrs(f: Field, x: varargs[untyped]): Field =
  var cp = f
  var attrNode = buildHtml(p(x))
  for (attr, value) in attrNode.attrs:
    cp.node.setAttr(attr, value)
  cp

proc options(f: Field, options: openarray[(string, string)]): Field =
  var html = buildHtml(select):
    for (value, name) in options:
      option(value = value):
        text name
  for (attr, value) in f.node.attrs:
    html.setAttr(attr, value)
  return f.fromVNode(html)

type Form* = OrderedTable[string, Field]

template `.=`*(form: Form, fieldName: untyped, field: Field) =
  form[astToStr(fieldName)] = field

template `.`*(form: Form, fieldName: untyped): Field =
  form[astToStr(fieldName)]

proc render(f: Field, name = "", errors: seq[string] = @[]): VNode =
  var node = f.node
  node.setAttr("name", name)
  when compiles(overrideRender(f)): # hook for user defined rendering
    overrideRender(f)
  else:
    buildHtml(label):
      text f.label
      node

proc render*(form: Form, values = newStringTable()): VNode =
  buildHtml(tdiv):
    for name, field in form:
      var errors = field.validators.mapIt(it(label = field.label, value = values.getOrDefault(name)))
      field.render(name, errors)

# proc generate*(form: Form, values = initTable[string, string](), readonly = false): VNode =
#   var inputs = newSeq[VNode]()
#   for name, input in form:
#     var node = buildHtml(input(type=input.type, name=name, placeholder=input.placeholder, value=values.getOrDefault(name)))
#     if readonly:
#       node.setAttr("readonly")
#     var error = input.validators[0].validate(values.getOrDefault(name))
#     if values.len > 0 and error.len > 0:
#       node.setAttr("aria-invalid", "true")
#     inputs.add(node)
#   var i = 0
#   buildHtml(tdiv):
#     for name, input in form:
#       label:
#         text input.label
#         inputs[i]
#         var error = input.validators[0].validate(values.getOrDefault(name))
#         if error.len > 0 and values.len > 0:
#           small(class="error"): text error
#       inc i
template initForm(body: untyped): untyped =
    var form = Form()
    with form:
      body
    form

when isMainModule:
  var myForm = initForm():
    email = initField(label = "Email Address").attrs(type="email", placeholder="something@gmail.com")
    name = initField(label="name").attrs(type="text", placeholder="John Doe")
    location = initField(label="Location").options(options = {"USA": "United States", "GB": "Great Brit"})
  echo myForm.render()
