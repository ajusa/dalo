{.experimental: "dotOperators".}
import std/[with, sequtils, strtabs, strutils, tables]
import karax/[karaxdsl, vdom]
import slicerator
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
    attrs*: seq[(string, string)] # List of attributes, usually for HTML
    widget*: Widget # a Widget that defines a renderer
    options*: seq[(string, string)] # only used for multi select type fields
    validators*: seq[Validator] # Validations to run for the field
  FormValidator* = proc(r: Values): string {.closure.}
  Form* = object
    fields*: OrderedTable[string, Field]
    validators*: seq[FormValidator]
  Errors* = object
    fieldErrors: OrderedTable[string, string] # Errors for each field
    formErrors: seq[string] # Overall form errors


include dalo/widgets

proc initField*(label = "", default = "", widget = defaultInput): Field =
  Field(label: label, widget: widget, default: default)

proc initField*(label = "", default = "", widget = defaultSelect, options: openarray[(string, string)]): Field =
  Field(label: label, widget: widget, options: toSeq(options), default: default)

template setAttrs*(f: Field, x: varargs[untyped]): Field =
  var cp = f
  var attrNode = buildHtml(p(x))
  cp.attrs = toSeq(attrNode.attrs)
  cp

template `.=`*(form: Form, fieldName: untyped, field: Field) =
  form.fields[astToStr(fieldName)] = field
  form.fields[astToStr(fieldName)].name = astToStr(fieldName)

template `.`*(form: Form, fieldName: untyped): Field =
  form.fields[astToStr(fieldName)]

proc render*(f: Field, value: Values, error = ""): VNode =
  var renderedValue = if f.name in value: value[f.name] else: f.default # is this right?
  return f.widget(f, value = renderedValue, error = error)

proc validate*(form: Form, values: Values): Errors =
  for name, field in form.fields:
      result.fieldErrors[name] = ""
      for validator in field.validators:
        var error = validator(field.label, values.getOrDefault(name))
        if error.len > 0:
          result.fieldErrors[name] = error
          break
  result.formErrors = form.validators.mapIt(values.it).filterIt(it.len > 0)

template makeForm*(body: untyped): untyped =
  var form = Form()
  with form: body
  form

proc initForm*(validators: seq[FormValidator] = @[]): Form =
  Form(validators: validators)
