module Conglomerate
  module Serializer
    def self.included(descendant)
      descendant.extend(ClassMethods)
    end

    def initialize(objects, context: nil)
      self.objects = [*objects].compact
      self.context = context
    end

    def serialize
      {
        "collection" => actions.inject({}) do |collection, action|
          send("apply_#{action}", collection)
        end
      }
    end

    private

    attr_accessor :objects, :context

    def actions
      [:version, :href, :queries, :items, :template, :links]
    end

    def apply_version(collection)
      collection.merge({"version" => "1.0"})
    end

    def apply_href(collection, proc: self.class._href, object: nil)
      if proc
        if object
          collection.merge({"href" => context.instance_exec(object, &proc)})
        else
          collection.merge({"href" => context.instance_eval(&proc)})
        end
      else
        collection
      end
    end

    def apply_data(
      collection, data: [], object: nil, default_value: nil,
      build_template: false
    )
      data = data.map do |datum|
        name = datum[:name]
        type = datum.fetch(:type, :value)
        prompt = datum.fetch(:prompt, nil)
        value = sanitize_value(
          object, :name => name, :type => type, :default_value => default_value
        )

        {"name" => name.to_s, type.to_s => value}.tap do |d|
          d["prompt"] = prompt if build_template && prompt
        end
      end

      if data.empty?
        collection
      else
        collection.merge({"data" => data})
      end
    end

    def apply_queries(collection)
      queries = self.class._queries.map do |query|
        build_query(query[:rel], query[:data], query[:block])
      end

      if queries.empty?
        collection
      else
        collection.merge({"queries" => queries})
      end
    end

    def apply_items(collection)
      items = objects.map do |object|
        item = {}

        if self.class._item_href
          item = apply_href(
            item, :proc => self.class._item_href, :object => object
          )
        end

        attributes = self.class._attributes
        item = apply_data(item, :data => attributes, :object => object)

        links = self.class._attributes
          .select { |attr| attr[:block] }
        links += self.class._item_links

        if links.empty?
          item.empty? ? nil : item
        else
          apply_links(item, :links => links, :object => object)
        end
      end

      if items.compact.empty?
        collection
      else
        collection.merge({"items" => items})
      end
    end

    def apply_template(collection)
      attrs = self.class._attributes
        .select { |attr| attr[:template] }
      attrs += self.class._templates

      if attrs.empty?
        collection
      else
        collection.merge(
          {
            "template" => apply_data(
              {}, :data => attrs, :default_value => "", :build_template => true
            )
          }
        )
      end
    end

    def apply_links(collection, links: self.class._links, object: nil)
      if object && !links.empty?
        links = links.map do |link|
          if !link.has_key?(:name) || present?(object.send(link[:name]))
            build_item_link(
              link[:rel], :proc => link[:block], :object => object
            )
          else
            nil
          end
        end.compact.reject { |link| link["href"].nil? }

        if links.empty?
          collection
        else
          collection.merge({"links" => links})
        end
      elsif !links.empty?
        collection.merge(
          {
            "links" => links.map do |link|
              {
                "rel" => link[:rel].to_s,
                "href" => context.instance_eval(&link[:block])
              }
            end.reject { |link| link["href"].nil? }
          }
        )
      else
        collection
      end
    end

    def build_query(rel, data, block)
      query = {"rel" => rel.to_s}
      query = apply_href(query, :proc => block)
      apply_data(query, :data => data, :default_value => "")
    end

    def build_item_link(rel, proc: nil, object: nil)
      link = {"rel" => rel.to_s}
      apply_href(link, :proc => proc, :object => object)
    end

    def sanitize_value(object, name:, type: :value, default_value: nil)
      if blank?(object) || blank?(object.send(name))
        if type == :array
          []
        elsif type == :object
          {}
        else
          if present?(object) && object.send(name) == false
            false
          else
            default_value
          end
        end
      else
        object.send(name)
      end
    end

    def blank?(value)
      if value.is_a?(String)
        value !~ /[^[:space:]]/
      else
        value.respond_to?(:empty?) ? value.empty? : !value
      end
    end

    def present?(value)
      !blank?(value)
    end

    module ClassMethods
      def href(&block)
        self._href = block
      end

      def item_href(&block)
        self._item_href = block
      end

      def query(rel, data: [], &block)
        data = [*data]
        data = data.map { |datum| {:name => datum} }
        self._queries = self._queries << {
          :rel => rel, :data => data, :block => block
        }
      end

      def attribute(
        name, template: false, rel: nil, type: :value, prompt: nil, &block
      )
        self._attributes = self._attributes << {
          :name => name, :template => template, :rel => rel, :type => type,
          :prompt => prompt, :block => block
        }
      end

      def link(rel, &block)
        self._links = self._links << {
          :rel => rel, :block => block
        }
      end

      def item_link(rel, &block)
        self._item_links = self._item_links << {
          :rel => rel, :block => block
        }
      end

      def template(name, type: :value, prompt: nil)
        self._templates = self._templates << {
          :name => name, :type => type, :prompt => prompt, :template => true
        }
      end

      attr_writer :_href, :_item_href, :_queries, :_attributes, :_links,
        :_item_links, :_templates

      def _href
        @_href || nil
      end

      def _item_href
        @_item_href || nil
      end

      def _queries
        @_queries || []
      end

      def _attributes
        @_attributes || []
      end

      def _links
        @_links || []
      end

      def _item_links
        @_item_links || []
      end

      def _templates
        @_templates || []
      end
    end
  end
end
