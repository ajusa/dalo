import dalo/validators, susta
section "Ensure Built in Works":
  echo typeValidator("number")("Age", "asdf")
  # echo typeValidator("n")("Age", "5e5")
  # echo attrValidators("number", "minlength", "5")("Age", "4")
