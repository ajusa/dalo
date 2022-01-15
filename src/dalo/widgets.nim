import std/sets

proc applyAttrs*(node: var VNode, attrs: seq[(string, string)]) =
  for (attr, val) in attrs: node.setAttr(attr, val)

proc defaultInput*(f: Field, value: string, error = ""): VNode =
  var node = buildHtml(input(name = f.name, value = value))
  node.applyAttrs(f.attributes)
  buildHtml(label):
    text f.label
    node

proc defaultTextarea*(f: Field, value: string, error = ""): VNode =
  var node = buildHtml(textarea(name = f.name)): text value
  node.applyAttrs(f.attributes)
  buildHtml(label):
    text f.label
    node

proc defaultSelect*(f: Field, value: string, error = ""): VNode =
  var node = buildHtml(select(name = f.name))
  node.applyAttrs(f.attributes)
  var selected = toHashSet value.split(SEP) # multiselect support
  buildHtml(label):
    text f.label
    buildHtml node:
      for (val, name) in f.opts:
        if val in selected:
          option(value = val, selected = ""): text name
        else:
          option(value = val): text name

# slicerator version, most folks won't have multiple same values though I assume
# proc defaultSelect*(f: Field, value: string, error = ""): VNode =
#   var node = buildHtml(select(name = f.name))
#   node.applyAttrs(f.attributes)
#   var selected = asClosure value.split(SEP) # multiselect support
#   buildHtml(label):
#     text f.label
#     buildHtml node:
#       for (val, name) in f.options:
#         if not selected.finished and selected.peek == val:
#           option(value = val, selected = ""): text name
#           var a = selected()
#         else:
#           option(value = val): text name
