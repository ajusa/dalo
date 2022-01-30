{.experimental: "dotOperators".}
import std/[with, sequtils, strtabs, strutils, tables]
import karax/[karaxdsl, vdom]
import constructor/constructor
import dalo/[validators, values]
export validators
export values
export vdom

type 
  Widget* = proc(f: Field, value: string, error: string): VNode {.closure.}
  Field* = object 
    label*: string # Human readable label
    name*: string # Internal field name
    default*: string # Default value
    attributes*: seq[(string, string)] # List of attributes, usually for HTML
    widget*: Widget # a Widget that defines a renderer
    opts*: seq[(string, string)] # only used for multi select type fields
    validators*: seq[Validator] # Validations to run for the field
  FormValidator* = proc(r: Values): string {.closure.}
  Form* = object
    fields*: OrderedTable[string, Field]
    validators*: seq[FormValidator]
  Errors* = object
    fieldErrors*: OrderedTable[string, string] # Errors for each field
    formError*: string # Overall form error
proc empty*(e: Errors): bool = e.fieldErrors.len == 0 and e.formError.len == 0
include dalo/widgets

proc initField*(label = "", default = "", name = "", widget: Widget = defaultInput): Field {.constr.}
proc initField*(label = "", default = "", name = "", widget: Widget = defaultSelect, options: openarray[(string, string)]): Field {.constr.} =
  result.opts = toSeq(options)
  result.validators = @[selectValidator(result.opts)]

proc fillInValidators*(f: var Field) =
  var kind = f.attributes.filterIt(it[0] == "type")
  if kind.len > 0:
    f.validators &= kind[0][1].defaultValidators(f.attributes)

template attrs*(f: Field, x: varargs[untyped]): Field =
  var cp = f
  var attrNode = buildHtml(p(x)) # todo more efficient
  cp.attributes = toSeq(attrNode.attrs)
  if attrNode.id.len != 0:
    cp.attributes.add ("id", attrNode.id)
  if attrNode.class.len != 0:
    cp.attributes.add ("class", attrNode.class)
  cp.fillInValidators()
  cp

template `.=`*(form: Form, fieldName: untyped, field: Field) =
  form.fields[astToStr(fieldName)] = field
  form.fields[astToStr(fieldName)].name = astToStr(fieldName)

template `.`*(form: Form, fieldName: untyped): Field =
  form.fields[astToStr(fieldName)]

proc render*(f: Field, value = Values(), errors = Errors()): VNode =
  var renderedValue = if f.name in value: value[f.name] else: f.default
  return f.widget(f, value = renderedValue, error = errors.fieldErrors.getOrDefault(f.name))

proc isRequired*(f: Field): bool =
  f.attributes.anyIt(it[0] == "required")

proc validate*(form: Form, values: Table[string, string]): Errors =
  for name, field in form.fields:
    var submittedVal = values.getOrDefault(name)
    if not field.isRequired and submittedVal == "": continue
    for validator in field.validators:
      var error = validator(field.label, submittedVal)
      if error.len > 0:
        result.fieldErrors[name] = error
        break
  for validator in form.validators:
    var error = validator(values)
    if error.len > 0:
      result.formError = error
      break

template makeForm*(body: untyped): untyped =
  var form = Form()
  with form: body
  form

proc initForm*(validators: seq[FormValidator] = @[]): Form {.constr.}
