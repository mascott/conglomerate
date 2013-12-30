# Conglomerate

[![Gem Version](https://badge.fury.io/rb/conglomerate.png)](http://badge.fury.io/rb/conglomerate)
[![Code Climate](https://codeclimate.com/github/teamsnap/conglomerate.png)](https://codeclimate.com/github/teamsnap/conglomerate)
[![Coverage Status](https://coveralls.io/repos/teamsnap/conglomerate/badge.png?branch=master)](https://coveralls.io/r/teamsnap/conglomerate?branch=master)
[![Dependency Status](https://gemnasium.com/teamsnap/conglomerate.png)](https://gemnasium.com/teamsnap/conglomerate)
[![License](http://img.shields.io/license/MIT.png?color=green)](http://opensource.org/licenses/MIT)

A library to serialize Ruby objects into collection+json.

![conglomerate](http://i.imgur.com/QkKZ0ru.jpg)

This library focuses just on converting Ruby objects into Collection+JSON. It aims to have the simplest format possible when constructing serializers specific to Collection+JSON. It also tries to provide all common Collection+JSON extensions to make it easy to create your API.

## Installation

Add this line to your application's Gemfile:

    gem 'conglomerate'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install conglomerate

## Usage

```ruby
# Step 1: Create a serializer
class TeamSerializer
  include Conglomerate.serializer
  
  href { teams_url }
  item_href { |item| team_url(item.id) }
  
  attribute :id
  attribute :name, :template => true
  attribute :event_ids, :rel => :events { |item| event_url(item.event_ids.join(",")) }
  
  link :root { root_url }
  
  query :search, :data => :id { search_teams_url }
end

# Step 2: Serialize any object

class TeamsController < ApplicationController
  def index
    teams = [
      OpenStruct.new(:id => 1, :name => "Team 01", :event_ids => [1,2,3]),
      OpenStruct.new(:id => 2, :name => "Team 02", :event_ids => [4,5,6]),
    ]
    render :json => TeamSerializer.new(teams, :context => self).serialize
  end
end

# Note, context is optional. It allows you to call helper methods such as url helpers easily inside the serializer.
```

```json
{
  "collection": {
    "href": "http://example.com/teams",
    "items": [
      {
        "href": "http://example.com/teams/1",
        "data": [
          {"name": "id", "value": 1},
          {"name": "name", "value": "Team 01"},
          {"name": "event_ids", "value": [1,2,3]}
        ],
        "links": [
          {"rel": "events", "href": "http://example.com/events/1,2,3"}
        ]
      },
      {
        "href": "http://example.com/teams/2",
        "data": [
          {"name": "id", "value": 2},
          {"name": "name", "value": "Team 2"},
          {"name": "event_ids", "value": [4,5,6]}
        ],
        "links": [
          {"rel": "events", "href": "http://example.com/events/4,5,6"}
        ]
      }
    ],
    "links": [
      {"rel": "root", "href": "http://example.com"}
    ],
    "queries": [
      {
        "rel": "search",
        "href": "http://example.com/teams/search",
        "data": [
          {"name": "id", "value": ""}
        ]
      }
    ],
    "template": {
      "data": [
        {"name": "name", "value": ""}
      ]
    }
  }
}
```

## Roadmap

- Use more defaults to simplify the creation of serializers.

## Contributing

1. Fork it ( http://github.com/teamsnap/conglomerate/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
