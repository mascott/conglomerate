module Conglomerate
  class Datum
    attribute :type, :type => String
  end

  module DatumBuilder
    value :type
  end
end
