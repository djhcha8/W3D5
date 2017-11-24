require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    @class_name.constantize
  end

  def table_name
    # ...
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
    default = {
      foreign_key: "#{name}_id".to_sym,
      primary_key: :id,
      class_name: name.to_s.capitalize
    }
    
    default.merge!(options) unless options.empty?
    
    @foreign_key = default[:foreign_key]
    @primary_key = default[:primary_key]
    @class_name =  default[:class_name]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ...
    default = {
      foreign_key: "#{self_class_name.downcase}_id".to_sym,
      primary_key: :id,
      class_name: name.singularize.to_s.capitalize
    }
    
    default.merge!(options) unless options.empty?
    
    @foreign_key = default[:foreign_key]
    @primary_key = default[:primary_key]
    @class_name =  default[:class_name]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
    bto = BelongsToOptions.new(name, options)
    
    define_method(name.to_s) do
      name.to_s.capitalize.constantize.where(id: self.send(bto.foreign_key)).first
    end
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
