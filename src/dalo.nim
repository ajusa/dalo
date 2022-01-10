{.experimental: "dotOperators".}
import tables, std/[with, sequtils, strtabs]
import karax/[karaxdsl, vdom]
import dalo/validators
  
type 
  Widget = proc(f: Field, name, value: string, errors: seq[string]): VNode {.closure.}
  Field* = object 
    label*: string
    node*: VNode
    attrs*: seq[(string, string)]
    widget*: Widget
    options*: seq[(string, string)] # only used for multi select type fields
    validators*: seq[Validator]
proc applyAttrs(node: var VNode, attrs: seq[(string, string)]) =
  for (attr, val) in attrs: node.setAttr(attr, val)

proc defaultInput(f: Field, name, value = "", errors: seq[string] = @[]): VNode =
  var node = buildHtml(input())
  node.applyAttrs(f.attrs)
  node.setAttr("name", name)
  buildHtml(label):
    text f.label
    node

proc defaultSelect(f: Field, name, value = "", errors: seq[string] = @[]): VNode =
  var node = buildHtml(select())
  node.applyAttrs(f.attrs)
  node.setAttr("name", name)
  buildHtml(label):
    text f.label
    buildHtml node:
      for (value, name) in f.options:
        option(value = value): text name

proc initField(label = "", widget = defaultInput): Field =
  Field(label: label, widget: widget)

proc initField(label = "", widget = defaultSelect, options: openarray[(string, string)]): Field =
  Field(label: label, widget: widget, options: toSeq(options))

template setAttrs(f: Field, x: varargs[untyped]): Field =
  var cp = f
  var attrNode = buildHtml(p(x))
  cp.attrs = toSeq(attrNode.attrs)
  cp


type Form* = object
  fields: OrderedTable[string, Field]
  validators*: seq[Validator]

template `.=`*(form: Form, fieldName: untyped, field: Field) =
  form.fields[astToStr(fieldName)] = field

template `.`*(form: Form, fieldName: untyped): Field =
  form.fields[astToStr(fieldName)]

proc render(f: Field, name = "", errors: seq[string] = @[]): VNode =
  return f.widget(f, name = name, value = "", errors = errors)

proc render*(form: Form, values = newStringTable()): VNode =
  buildHtml(tdiv):
    for name, field in form.fields:
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
    with form: body
    form

when isMainModule:
  var myForm = initForm():
    email = initField(label = "Email Address").setAttrs(type="email", placeholder="something@gmail.com")
    name = initField(label="name").setAttrs(type="text", placeholder="John Doe")
    location = initField(label="Location", options = {"USA": "United States", "GB": "Great Brit"})
  echo myForm.render()
