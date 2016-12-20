module OodJob
  # Namespace for Ruby refinements
  module Refinements
    # This module provides a refinement for the `Array` class to help it coerce
    # other objects to itself
    module ArrayWrap
      # Wrap its argument in an array unless it is already an array (or
      # array-like)
      # @see http://apidock.com/rails/Array/wrap/class
      refine Array.singleton_class do
        def wrap(object)
          if object.nil?
            []
          elsif object.respond_to?(:to_ary)
            object.to_ary || [object]
          else
            [object]
          end
        end
      end
    end
  end
end
