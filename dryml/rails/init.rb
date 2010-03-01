# If Hobo is defined, assume that it enables DRYML.  Otherwise enable ourselves
begin
  Hobo  # can't use const_defined? in case it's autoloaded.
rescue NameError
  Dryml.enable
end
