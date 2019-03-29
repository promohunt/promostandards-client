module Refinements
  refine Object do
    # https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/array/wrap.rb
    def wrap_in_array
      if nil?
        []
      elsif respond_to? :to_ary
        to_ary || [self]
      else
        [self]
      end
    end
  end
end
