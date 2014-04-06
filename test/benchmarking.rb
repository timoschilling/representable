require 'representable/hash'
require 'benchmark'

Album = Struct.new(:title, :songs)
Song  = Struct.new(:name)

module AlbumRepresenter
  include Representable::Hash

  property :title

  collection :songs do
    property :name
  end
end


albums = []
10000.times do
  albums << Album.new("60 Minits", [Song.new("Liar"), Song.new("Outcast")])
end

time = Benchmark.measure do
  albums.each do |album|
    album.extend(AlbumRepresenter).to_hash
  end
end

puts time



# decorator

class AlbumDecorator < Representable::Decorator
  include Representable::Hash
  include AlbumRepresenter
end

time = Benchmark.measure do
  albums.each do |album|
    AlbumDecorator.new(album).to_hash
  end
end

puts time

  # 2.150000   0.010000   2.160000 (  2.160542)
  # 1.670000   0.000000   1.670000 (  1.677469)

  # 2.110000   0.030000   2.140000 (  2.142010)
  # 1.610000   0.000000   1.610000 (  1.618115)

