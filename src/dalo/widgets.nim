proc applyAttrs*(node: var VNode, attrs: seq[(string, string)]) =
  for (attr, val) in attrs: node.setAttr(attr, val)

proc defaultInput*(f: Field, name, value: string, errors: seq[string] = @[]): VNode =
  var node = buildHtml(input(name = name, value = value))
  node.applyAttrs(f.attrs)
  buildHtml(label):
    text f.label
    node

proc defaultTextarea*(f: Field, name, value: string, errors: seq[string] = @[]): VNode =
  var node = buildHtml(textarea(name = name)): text value
  node.applyAttrs(f.attrs)
  buildHtml(label):
    text f.label
    node

proc defaultSelect*(f: Field, name, value: string, errors: seq[string] = @[]): VNode =
  var node = buildHtml(select())
  node.applyAttrs(f.attrs)
  node.setAttr("name", name)
  var selected = asClosure value.split(SEP) # multiselect support
  buildHtml(label):
    text f.label
    buildHtml node:
      for (val, name) in f.options:
        if not selected.finished and selected.peek == val:
          option(value = val, selected = ""): text name
          var a = selected()
        else:
          option(value = val): text name
