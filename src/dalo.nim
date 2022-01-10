{.experimental: "dotOperators".}
import tables, std/[with, sequtils, strtabs, uri]
import karax/[karaxdsl, vdom]
import dalo/validators
  
type 
  Widget = proc(f: Field, name, value: string, errors: seq[string]): VNode {.closure.}
  Field* = object 
    label*: string # Human readable label
    default*: string # Default value
    attrs*: seq[(string, string)] # List of attributes, usually for HTML
    widget*: Widget # a Widget that defines a renderer
    options*: seq[(string, string)] # only used for multi select type fields
    validators*: seq[Validator] # Validations to run for the field
  Form* = object
    fields: OrderedTable[string, Field]
    validators*: seq[Validator]
  Values* = OrderedTable[string, string] # Holds values from submitting form
const SEP = "\28" # AWK uses this, non printing char
proc initValues(qs: string): Values =
  for (name, value) in qs.decodeQuery:
    if name in result:
      result[name] &= SEP & value
    else:
      result[name] = value
echo initValues("asdf=a&bdsf=b&asdf=b")

proc applyAttrs(node: var VNode, attrs: seq[(string, string)]) =
  for (attr, val) in attrs: node.setAttr(attr, val)

proc defaultInput(f: Field, name, value: string, errors: seq[string] = @[]): VNode =
  var node = buildHtml(input())
  node.applyAttrs(f.attrs)
  node.setAttr("name", name)
  node.setAttr("value", value)
  buildHtml(label):
    text f.label
    node

proc defaultSelect(f: Field, name, value: string, errors: seq[string] = @[]): VNode =
  var node = buildHtml(select())
  node.applyAttrs(f.attrs)
  node.setAttr("name", name)
  buildHtml(label):
    text f.label
    buildHtml node:
      for (val, name) in f.options:
        if value == val:
          option(value = val, selected = ""): text name
        else:
          option(value = val): text name

proc initField(label = "", default = "", widget = defaultInput): Field =
  Field(label: label, widget: widget, default: default)

proc initField(label = "", default = "", widget = defaultSelect, options: openarray[(string, string)]): Field =
  Field(label: label, widget: widget, options: toSeq(options), default: default)

template setAttrs(f: Field, x: varargs[untyped]): Field =
  var cp = f
  var attrNode = buildHtml(p(x))
  cp.attrs = toSeq(attrNode.attrs)
  cp

template `.=`*(form: Form, fieldName: untyped, field: Field) =
  form.fields[astToStr(fieldName)] = field

template `.`*(form: Form, fieldName: untyped): Field =
  form.fields[astToStr(fieldName)]

proc render(f: Field, name = "", value: Values, errors: seq[string] = @[]): VNode =
  var renderedValue = if name in value: value[name] else: f.default
  return f.widget(f, name = name, value = renderedValue, errors = errors)

proc validate*(form: Form, values: Values) =
  discard

proc render*(form: Form, values = initValues("")): VNode =
  buildHtml(tdiv):
    for name, field in form.fields:
      var errors = field.validators.mapIt(it(label = field.label, value = values.getOrDefault(name)))
      field.render(name = name, errors = errors, value = values)

template initForm(body: untyped): untyped =
    var form = Form()
    with form: body
    form

# when isMainModule:
#   var myForm = initForm():
#     email = initField(label = "Email Address").setAttrs(type="email", placeholder="something@gmail.com")
#     name = initField(label="name").setAttrs(type="text", placeholder="John Doe")
#     location = initField(label="Location", default = "GB", options = {"USA": "United States", "GB": "Great Brit"})
#   echo myForm.render()
