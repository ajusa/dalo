# Dalo 

Dalo is a form input library for Nim, similar in scope to Django's forms
and WTForms. Some aspects of this library are inspired by Django's form
implementation as well.

### What is a form library?

To be clear, this is a library for HTML forms. Since form libraries differ in scope, here's a list of features this library tries to target.

1. Easier creation and rendering of forms 
2. Form validation and error handling
3. Coercing/marshalling the results of a form submission to a Nim type

In other words, coupled with a web server and an ORM, this library aims to make it trivial to create a form that saves to a database.

### What does *this* form library offer?

As far as I am aware, Nim doesn't really have a form library yet. There is a project I've seen to do validation, but that's more geared towards validating an object for construction, not for websites.

More complex interactions with forms (such as conditionally toggling parts of a form) are easier in this library than with Django. Django uses a class to describe a form while this library uses objects, which are more flexible.

The validations are decoupled completely from the implementation. If you want to just have a useful list of validations with error messages, feel free to just import that module without using the rest of the code.

The rendering of forms is coupled to Karax's templating engine. There are plently of other templating engines, but I happen to find Karax best fits Nim personally. HOWEVER, it is possible to use this library with alternative templating engines, you'll just need to use Karax when creating custom Widgets (described below).

### Concepts

As this library borrows some high level design choices from Django, some of this may be review. However, I also made some design choices that may conflict with Django, either due to stricter typing from Nim or for ease of use.

A Validator is a function that takes in the label name and the value to validate against, as a string. It returns an error message, or an empty string if there is no error. The label name is passed in to aid in creating good error messages, such as "First Name must be longer than 5 characters".

A Form is a collection of fields, mapping the field name (not the label) to the field itself. A Form also as a list of validators to validate itself against, to do cross field validation. A Form Validator takes in the various values submitted from a Form and returns an error message if there's an issue.

A Field is the basic building block of this library. It contains many different attributes to be as flexible as possible. A Field has a label, the human readable text describing it. A Field can have a default value. A Field usually has a list of HTML attributes, such as ("max", "5"), ("required", ""). A field is rendered via a Widget. A Field has a list of validators to validate itself against. A Field can also have options, for a `<select>` type of control. Options are just a list of the value of the field along with the human readable text.

A Widget is a simple renderer of a Field, the value of a field from a request, and any potential errors from validation. This is where the Karax requirement comes in. A Widget also has access to the `name`, which is a string that describes how a field is referred to internally (corresponding to the `name` attribute from HTML). Widgets are where a lot of the complexity can live for an application, and you'll need to create your own for any CSS frameworks. Here's the most basic version without any rendering of errors:

```nim
proc defaultInput*(f: Field, name, value: string, errors: seq[string] = @[]): VNode =
  var node = buildHtml(input(name = name, value = value))
  node.applyAttrs(f.attrs)
  buildHtml(label):
    text f.label
    node
```

### Current Status
WIP, though the ideas of the overall API is unlikely to change. I need to write more tests, more examples, and iterate on the overall design likely.

## Examples

```nim
var myForm = makeForm:
  email = initField(label = "Email Address").setAttrs(type="email", placeholder = "something@gmail.com")
  name = initField(label="Name", default = "Hey").setAttrs(type="text", placeholder="John Doe")
  location = initField(label="Location", default = "USA", options = {"USA": "United States", "GB": "Great Brit"})
  aboutYou = initField(label="About", default = "Hey there, my name is John Smith", widget = defaultTextarea)
```
This produces the following HTML:

```html
<label>Email Address<input name="email" value="" type="email" placeholder="something@gmail.com" /></label>
<label>Name<input name="name" value="Hey" type="text" placeholder="John Doe" /></label>
<label>Location<select name="location">
  <option value="USA" selected="">United States</option>
  <option value="GB">Great Brit</option>
</select></label>
<label>About<textarea name="aboutYou">Hey there, my name is John Smith</textarea></label>
```
