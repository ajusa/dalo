import strutils, strformat, regex, lenientops, uri

type 
  Validator* = proc(value, label: string): string {.closure.}
  Message* = static string

template makeValidator(isValid: untyped): untyped =
  return proc(value {.inject.}, label {.inject.}: string): string =
    if isValid:
      return &message

proc minLengthValidator(length: int, message: Message = "{label} must be at least {length} characters"): Validator =
  makeValidator(value.len < length)

proc maxLengthValidator(length: int, message: Message = "{label} cannot be longer than {length} characters"): Validator =
  makeValidator(value.len > length)


proc regexValidator(pattern: Regex, message: Message = "{label} is not valid"): Validator =
  makeValidator(not value.contains(pattern))

template parseSomeNumber(input: string, n, body: untyped): untyped =
  try:
    var n = parseInt(input)
    body
  except:
    var n = parseFloat(input)
    body

proc minNumericValidator(smallest: SomeNumber, message: Message = "{label} must be larger than {smallest}"): Validator =
  makeValidator:
    value.parseSomeNumber(numValue): numValue < smallest
proc maxNumericValidator(largest: SomeNumber, message: Message = "{label} must be smaller than {largest}"): Validator =
  makeValidator:
    value.parseSomeNumber(numValue): numValue > largest

proc requiredValidator(message: Message = "{label} is required"): Validator =
  makeValidator(value.len == 0)

const EMAIL_PATTERN = re"\S+@\S+\.\S+"
proc emailValidator(message: Message = "{value} is not a valid email"): Validator =
  makeValidator(not value.contains(EMAIL_PATTERN))

# echo maxNumericValidator(4)(label = "Age", value = "4.2")

proc builtInValidators(kind, attr, value: string): Validator =
  case attr
  of "minlength":
    return minLengthValidator(value.parseInt)
  of "maxlength":
    return maxLengthValidator(value.parseInt)
  of "required":
    return requiredValidator()
  of "pattern":
    return regexValidator(value.re)
  of "min":
    case kind
    of "number", "range":
      value.parseSomeNumber(min):
        return minNumericValidator(min)
  of "max":
    case kind
    of "number", "range":
      value.parseSomeNumber(max):
        return maxNumericValidator(max)

