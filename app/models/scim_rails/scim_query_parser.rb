module ScimRails
  class ScimQueryParser
    attr_accessor :query_elements
    attr_accessor :resource_type

    def initialize(query_string, resource_type=nil)
      self.query_elements = query_string.split(" ")
      self.resource_type = resource_type
    end

    def attribute
      attribute = query_elements.dig(0)
      raise ScimRails::ExceptionHandler::InvalidQuery if attribute.blank?
      attribute = attribute.to_sym

      mapped_attribute = attribute_mapping(attribute)
      raise ScimRails::ExceptionHandler::InvalidQuery if mapped_attribute.blank?
      mapped_attribute
    end

    def operator
      sql_comparison_operator(query_elements.dig(1))
    end

    def parameter
      parameter = query_elements[2..-1].join(" ")
      return if parameter.blank?
      parameter.gsub(/"/, "")
    end

    private

    def attribute_mapping(attribute)
      if resource_type == "group"
        ScimRails.config.queryable_group_attributes[attribute]
      else
        ScimRails.config.queryable_user_attributes[attribute]
      end
    end

    def sql_comparison_operator(element)
      case element
      when "eq"
        "="
      else
        # TODO: implement additional query filters
        raise ScimRails::ExceptionHandler::InvalidQuery
      end
    end
  end
end
