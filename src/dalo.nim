{.experimental: "dotOperators".}
import std/[with, sequtils, strtabs, strutils, tables]
import karax/[karaxdsl, vdom]
import slicerator
import dalo/[validators, values]
export validators
export values
  
type 
  Widget* = proc(f: Field, name, value: string, errors: seq[string]): VNode {.closure.}
  Field* = object 
    label*: string # Human readable label
    default*: string # Default value
    attrs*: seq[(string, string)] # List of attributes, usually for HTML
    widget*: Widget # a Widget that defines a renderer
    options*: seq[(string, string)] # only used for multi select type fields
    validators*: seq[Validator] # Validations to run for the field
  FormValidator* = proc(r: Values): string {.closure.}
  Form* = object
    fields: OrderedTable[string, Field]
    validators*: seq[FormValidator]
  Errors* = object
    fieldErrors: OrderedTable[string, seq[string]] # Errors for each field
    formErrors: seq[string] # Overall form errors


include dalo/widgets

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

proc validate*(form: Form, values: Values): Errors =
  for name, field in form.fields:
    result.fieldErrors[name] = field.validators
      .mapIt(it(field.label, values.getOrDefault(name)))
      .filterIt(it.len > 0)
  result.formErrors = form.validators.mapIt(values.it).filterIt(it.len > 0)

template makeForm(body: untyped): untyped =
  var form = Form()
  with form: body
  form

proc initForm(validators: seq[FormValidator]): Form =
  Form(validators: validators)

when isMainModule:
  var myForm = makeForm:
    email = initField(label = "Email Address").setAttrs(type="email", placeholder="something@gmail.com")
    name = initField(label="Name", default = "Hey").setAttrs(type="text", placeholder="John Doe")
    location = initField(label="Location", default = "USA", options = {"USA": "United States", "GB": "Great Brit"})
    aboutYou = initField(label="About", default = "Hey there, my name is John Smith", widget = defaultTextarea)
  var vals = initValues("")
  var a = buildHtml(tdiv):
    for name, field in myForm.fields:
      var errors = field.validators.mapIt(it(label = field.label, value = vals.getOrDefault(name)))
      field.render(name = name, errors = errors, value = vals)
  echo a
