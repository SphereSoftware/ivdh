module IVDH
  # BlankSlate is class with no instance methods except critical
  # for Ruby methods(\_\_send\_\_, \_\_id\_\_).
  # Usually BlankSlate is used as a base class of classes wich
  # depend on method_missing method.
  class BlankSlate
    instance_methods.each{|m| undef_method m unless m =~ /^__/}
  end
end
