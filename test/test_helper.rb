require 'bundler'
Bundler.setup

gem 'minitest'
require 'representable'
require 'representable/json'
require 'representable/xml'
require 'representable/csv'
require 'test/unit'
require 'minitest/spec'
require 'minitest/autorun'
require 'test_xml/mini_test'
require 'mocha'

class Album
  attr_accessor :songs, :best_song
  def initialize(songs=nil, best_song=nil)
    @songs      = songs
    @best_song  = best_song
  end

  def ==(other)
    songs == other.songs and best_song == other.best_song
  end
end

class Song
  attr_accessor :name, :track
  def initialize(name=nil, track=nil)
    @name   = name
    @track  = track
  end

  def ==(other)
    name == other.name and track == other.track
  end
end

module XmlHelper
  def xml(document)
    Nokogiri::XML(document).root
  end
end

module AssertJson
  module Assertions
    def assert_json(expected, actual, msg=nil)
      msg = message(msg, "") { diff expected, actual }
      assert(expected.split("").sort == actual.split("").sort, msg)
    end
  end
end

MiniTest::Spec.class_eval do
  include AssertJson::Assertions
  include XmlHelper
end
