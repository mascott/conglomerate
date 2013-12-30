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
      if object
        collection.merge({"href" => context.instance_exec(object, &proc)})
      else
        collection.merge({"href" => context.instance_eval(&proc)})
      end
    end

    def apply_data(collection, data: [], object: nil)
      data = data.map do |name|
        {"name" => name.to_s, "value" => object.nil? ? "" : object.send(name)}
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

        names = self.class._attributes.map { |attr| attr[:name] }
        item = apply_data(item, :data => names, :object => object)

        links = self.class._attributes
          .select { |attr| attr[:block] }

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
        .map { |attr| attr[:name] }

      if attrs.empty?
        collection
      else
        collection.merge({"template" => apply_data({}, :data => attrs)})
      end
    end

    def apply_links(collection, links: self.class._links, object: nil)
      if object && !links.empty?
        links = links.map do |link|
          if object.send(link[:name])
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
      apply_data(query, :data => data)
    end

    def build_item_link(rel, proc: nil, object: nil)
      link = {"rel" => rel.to_s}
      apply_href(link, :proc => proc, :object => object)
    end

    module ClassMethods
      def href(&block)
        self._href = block
      end

      def item_href(&block)
        self._item_href = block
      end

      def query(rel, data: [], &block)
        self._queries = self._queries << {
          :rel => rel, :data => [*data], :block => block
        }
      end

      def attribute(name, template: false, rel: nil, &block)
        self._attributes = self._attributes << {
          :name => name, :template => template, :rel => rel, :block => block
        }
      end

      def link(rel, &block)
        self._links = self._links << {
          :rel => rel, :block => block
        }
      end

      attr_writer :_href, :_item_href, :_queries, :_attributes, :_links

      def _href
        @_href || Proc.new { request.original_url }
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
    end
  end
end
