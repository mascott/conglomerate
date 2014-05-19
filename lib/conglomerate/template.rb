module Conglomerate
  class Template
    include Conglomerate::Particle

    array :data, :contains => Datum

    def build(attrs = {})
      attrs = Hash[attrs.map{ |k, v| [k.to_sym, v] }]
      template = Template.new

      data.each do |datum|
        if attrs.has_key?(datum.name.to_sym)
          template.data << Datum.new(
            :name => datum.name,
            :value => attrs[datum.name.to_sym]
          )
        end
      end

      { "template" => Conglomerate.serialize(template) }
    end
  end
end
