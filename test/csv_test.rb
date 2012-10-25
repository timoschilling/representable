require 'test_helper'

module CSVTest
  class APITest < MiniTest::Spec
    Def = Representable::Definition

    describe "CSV module" do
      before do
        @Band = Class.new do
          include Representable::CSV
          property :name
          property :label
          property :since
          attr_accessor :name, :label, :since

          def initialize(name=nil, label=nil, since=nil)
            self.name = name if name
            self.label = label if label
            self.since = since if since
          end
        end

        @band = @Band.new
      end


      describe ".from_csv" do
        it "is delegated to #from_csv" do
          block = lambda {|*args|}
          @Band.any_instance.expects(:from_csv).with("{document}", "options") # FIXME: how to NOT expect block?
          @Band.from_csv("{document}", "options", &block)
        end

        # it "yields new object and options to block" do
        #   @Band.class_eval { attr_accessor :new_name }
        #   @band = @Band.from_csv("{}", :new_name => "Diesel Boy") do |band, options|
        #     band.new_name= options[:new_name]
        #   end
        #   assert_equal "Diesel Boy", @band.new_name
        # end
      end

      describe "#from_csv" do
        before do
          @csv  = "name,label\nNofx,NOFX"
          @csv2 = "name,label,since\nNofx,NOFX,"
          @csv3 = "name,label,since\nNofx,NOFX,1983"
        end

        it "parses CSV and assigns properties" do
          @band.from_csv(@csv)
          assert_equal ["Nofx", "NOFX"], [@band.name, @band.label]
        end

        it "parses CSV and assigns properties" do
          @band.from_csv(@csv2)
          assert_equal ["Nofx", "NOFX", nil], [@band.name, @band.label, @band.since]
        end

        it "parses CSV and assigns properties" do
          @band.from_csv(@csv3)
          assert_equal ["Nofx", "NOFX", "1983"], [@band.name, @band.label, @band.since]
        end
      end

      describe "#to_csv" do
        it "delegates to #to_hash and returns string" do
          assert_equal "name,label,since\nRise Against,DGC Records,1999\n", @Band.new("Rise Against", "DGC Records", "1999").to_csv
        end

        it "delegates to #to_hash and returns string and render nil properties" do
          assert_equal "name,label,since\nRise Against,DGC Records,\n", @Band.new("Rise Against", "DGC Records").to_csv
        end
      end


#       describe "#to_hash" do
#         it "returns unwrapped hash" do
#           hash = @Band.new("Rise Against").to_hash
#           assert_equal({"name"=>"Rise Against"}, hash)
#         end
# 
#         it "respects #representation_wrap=" do
#           @Band.representation_wrap = :group
#           assert_equal({:group=>{"name"=>"Rise Against"}}, @Band.new("Rise Against").to_hash)
#         end
# 
#         it "respects :wrap option" do
#           assert_equal({:band=>{"name"=>"NOFX"}}, @Band.new("NOFX").to_hash(:wrap => :band))
#         end
# 
#         it "respects :wrap option over representation_wrap" do
#           @Band.class_eval do
#             self.representation_wrap = :group
#           end
#           assert_equal({:band=>{"name"=>"Rise Against"}}, @Band.new("Rise Against").to_hash(:wrap => :band))
#         end
#       end
# 
#       describe "#build_for" do
#         it "returns ObjectBinding" do
#           assert_kind_of Representable::Hash::ObjectBinding, Representable::Hash::PropertyBinding.build_for(Def.new(:band, :class => Hash))
#         end
# 
#         it "returns TextBinding" do
#           assert_kind_of Representable::Hash::PropertyBinding, Representable::Hash::PropertyBinding.build_for(Def.new(:band))
#         end
# 
#         it "returns HashBinding" do
#           assert_kind_of Representable::Hash::HashBinding, Representable::Hash::PropertyBinding.build_for(Def.new(:band, :hash => true))
#         end
# 
#         it "returns CollectionBinding" do
#           assert_kind_of Representable::Hash::CollectionBinding, Representable::Hash::PropertyBinding.build_for(Def.new(:band, :collection => true))
#         end
#       end
# 
#       describe "#representable_bindings_for" do
#         it "returns bindings for each property" do
#           assert_equal 2, @band.send(:representable_bindings_for, Representable::CSV::PropertyBinding).size
#           assert_equal "name", @band.send(:representable_bindings_for, Representable::CSV::PropertyBinding).first.name
#         end
#       end
    end
# 
# 
#     describe "DCI" do
#       module SongRepresenter
#         include Representable::CSV
#         property :name
#       end
# 
#       module AlbumRepresenter
#         include Representable::CSV
#         property :best_song, :class => Song, :extend => SongRepresenter
#         collection :songs, :class => Song, :extend => [SongRepresenter]
#       end
# 
# 
#       it "allows adding the representer by using #extend" do
#         module BandRepresenter
#           include Representable::CSV
#           property :name
#         end
# 
#         civ = Object.new
#         civ.instance_eval do
#           def name; "CIV"; end
#           def name=(v)
#             @name = v
#           end
#         end
# 
#         civ.extend(BandRepresenter)
#         assert_csv "{\"name\":\"CIV\"}", civ.to_csv
#       end
# 
#       it "extends contained models when serializing" do
#         @album = Album.new([Song.new("I Hate My Brain"), mr=Song.new("Mr. Charisma")], mr)
#         @album.extend(AlbumRepresenter)
# 
#         assert_csv "{\"best_song\":{\"name\":\"Mr. Charisma\"},\"songs\":[{\"name\":\"I Hate My Brain\"},{\"name\":\"Mr. Charisma\"}]}", @album.to_csv
#       end
# 
#       it "extends contained models when deserializing" do
#         #@album = Album.new(Song.new("I Hate My Brain"), Song.new("Mr. Charisma"))
#         @album = Album.new
#         @album.extend(AlbumRepresenter)
# 
#         @album.from_csv("{\"best_song\":{\"name\":\"Mr. Charisma\"},\"songs\":[{\"name\":\"I Hate My Brain\"},{\"name\":\"Mr. Charisma\"}]}")
#         assert_equal "Mr. Charisma", @album.best_song.name
#       end
#     end
#   end
# 
# 
#   class PropertyTest < MiniTest::Spec
#     describe "property :name" do
#       class Band
#         include Representable::CSV
#         property :name
#         attr_accessor :name
#       end
# 
#       it "#from_csv creates correct accessors" do
#         band = Band.from_csv({:name => "Bombshell Rocks"}.to_csv)
#         assert_equal "Bombshell Rocks", band.name
#       end
# 
#       it "#to_csv serializes correctly" do
#         band = Band.new
#         band.name = "Cigar"
# 
#         assert_csv '{"name":"Cigar"}', band.to_csv
#       end
#     end
# 
#     describe ":class => Item" do
#       class Label
#         include Representable::CSV
#         property :name
#         attr_accessor :name
#       end
# 
#       class Album
#         include Representable::CSV
#         property :label, :class => Label
#         attr_accessor :label
#       end
# 
#       it "#from_csv creates one Item instance" do
#         album = Album.from_csv('{"label":{"name":"Fat Wreck"}}')
#         assert_equal "Fat Wreck", album.label.name
#       end
# 
#       it "#to_csv serializes" do
#         label = Label.new; label.name = "Fat Wreck"
#         album = Album.new; album.label = label
# 
#         assert_csv '{"label":{"name":"Fat Wreck"}}', album.to_csv
#       end
# 
#       describe ":different_name, :class => Label" do
#         before do
#           @Album = Class.new do
#             include Representable::CSV
#             property :seller, :class => Label
#             attr_accessor :seller
#           end
#         end
# 
#         it "#to_xml respects the different name" do
#           label = Label.new; label.name = "Fat Wreck"
#           album = @Album.new; album.seller = label
# 
#           assert_csv "{\"seller\":{\"name\":\"Fat Wreck\"}}", album.to_csv(:wrap => false)
#         end
#       end
#     end
# 
#     describe ":from => :songName" do
#       class Song
#         include Representable::CSV
#         property :name, :from => :songName
#         attr_accessor :name
#       end
# 
#       it "respects :from in #from_csv" do
#         song = Song.from_csv({:songName => "Run To The Hills"}.to_csv)
#         assert_equal "Run To The Hills", song.name
#       end
# 
#       it "respects :from in #to_csv" do
#         song = Song.new; song.name = "Run To The Hills"
#         assert_csv '{"songName":"Run To The Hills"}', song.to_csv
#       end
#     end
# 
#     describe ":default => :value" do
#       before do
#         @Album = Class.new do
#         include Representable::CSV
#         property :name, :default => "30 Years Live"
#         attr_accessor :name
#       end
#     end
# 
#     describe "#from_csv" do
#       it "uses default when property nil in doc" do
#         album = @Album.from_csv({}.to_csv)
#         assert_equal "30 Years Live", album.name
#       end
# 
#       it "uses value from doc when present" do
#         album = @Album.from_csv({:name => "Live At The Wireless"}.to_csv)
#         assert_equal "Live At The Wireless", album.name
#       end
# 
#       it "uses value from doc when empty string" do
#         album = @Album.from_csv({:name => ""}.to_csv)
#         assert_equal "", album.name
#       end
#     end
# 
#     describe "#to_csv" do
#       it "uses default when not available in object" do
#         assert_csv "{\"name\":\"30 Years Live\"}", @Album.new.to_csv
#       end
# 
#       it "uses value from represented object when present" do
#         album = @Album.new
#         album.name = "Live At The Wireless"
#         assert_csv "{\"name\":\"Live At The Wireless\"}", album.to_csv
#       end
# 
#       it "uses value from represented object when emtpy string" do
#         album = @Album.new
#         album.name = ""
#         assert_csv "{\"name\":\"\"}", album.to_csv
#       end
#     end
#   end
# end
# 
# 
#   class CollectionTest < MiniTest::Spec
#     describe "collection :name" do
#       class CD
#         include Representable::CSV
#         collection :songs
#         attr_accessor :songs
#       end
# 
#       it "#from_csv creates correct accessors" do
#         cd = CD.from_csv({:songs => ["Out in the cold", "Microphone"]}.to_csv)
#         assert_equal ["Out in the cold", "Microphone"], cd.songs
#       end
# 
#       it "#to_csv serializes correctly" do
#         cd = CD.new
#         cd.songs = ["Out in the cold", "Microphone"]
# 
#         assert_csv '{"songs":["Out in the cold","Microphone"]}', cd.to_csv
#       end
#     end
# 
#     describe "collection :name, :class => Band" do
#       class Band
#         include Representable::CSV
#         property :name
#         attr_accessor :name
# 
#         def initialize(name="")
#           self.name = name
#         end
#       end
# 
#       class Compilation
#         include Representable::CSV
#         collection :bands, :class => Band
#         attr_accessor :bands
#       end
# 
#       describe "#from_csv" do
#         it "pushes collection items to array" do
#           cd = Compilation.from_csv({:bands => [
#             {:name => "Cobra Skulls"},
#             {:name => "Diesel Boy"}]}.to_csv)
#           assert_equal ["Cobra Skulls", "Diesel Boy"], cd.bands.map(&:name).sort
#         end
# 
#         it "creates emtpy array from default if configured" do
#           cd = Compilation.from_csv({}.to_csv)
#           assert_equal [], cd.bands
#         end
#       end
# 
#       it "responds to #to_csv" do
#         cd = Compilation.new
#         cd.bands = [Band.new("Diesel Boy"), Band.new("Bad Religion")]
# 
#         assert_csv '{"bands":[{"name":"Diesel Boy"},{"name":"Bad Religion"}]}', cd.to_csv
#       end
#     end
# 
# 
#     describe ":from => :songList" do
#       class Songs
#         include Representable::CSV
#         collection :tracks, :from => :songList
#         attr_accessor :tracks
#       end
# 
#       it "respects :from in #from_csv" do
#         songs = Songs.from_csv({:songList => ["Out in the cold", "Microphone"]}.to_csv)
#         assert_equal ["Out in the cold", "Microphone"], songs.tracks
#       end
# 
#       it "respects option in #to_csv" do
#         songs = Songs.new
#         songs.tracks = ["Out in the cold", "Microphone"]
# 
#         assert_csv '{"songList":["Out in the cold","Microphone"]}', songs.to_csv
#       end
#     end
#   end
# 
#   class HashTest < MiniTest::Spec
#     describe "hash :songs" do
#       before do
#         representer = Module.new do
#           include Representable::CSV
#           hash :songs
#         end
# 
#         class SongList
#           attr_accessor :songs
#         end
# 
#         @list = SongList.new.extend(representer)
#       end
# 
#       it "renders with #to_csv" do
#         @list.songs = {:one => "65", :two => "Emo Boy"}
#         assert_csv "{\"songs\":{\"one\":\"65\",\"two\":\"Emo Boy\"}}", @list.to_csv
#       end
# 
#       it "parses with #from_csv" do
#         assert_equal({"one" => "65", "two" => ["Emo Boy"]}, @list.from_csv("{\"songs\":{\"one\":\"65\",\"two\":[\"Emo Boy\"]}}").songs)
#       end
#     end
# 
#   end


  # require 'representable/csv/collection'
  # class CollectionRepresenterTest < MiniTest::Spec
  #   module SongRepresenter
  #     include Representable::CSV
  #     property :name
  #   end
  # 
  #   describe "CSV::Collection" do
  #     describe "with contained objects" do
  #       before do
  #         @songs_representer = Module.new do
  #           include Representable::CSV::Collection
  #           items :class => Song, :extend => SongRepresenter
  #         end
  #       end
  # 
  #       it "renders objects with #to_csv" do
  #         assert_csv "[{\"name\":\"Days Go By\"},{\"name\":\"Can't Take Them All\"}]", [Song.new("Days Go By"), Song.new("Can't Take Them All")].extend(@songs_representer).to_csv
  #       end
  # 
  #       it "returns objects array from #from_csv" do
  #         assert_equal [Song.new("Days Go By"), Song.new("Can't Take Them All")], [].extend(@songs_representer).from_csv("[{\"name\":\"Days Go By\"},{\"name\":\"Can't Take Them All\"}]")
  #       end
  #     end
  # 
  #     describe "with contained text" do
  #       before do
  #         @songs_representer = Module.new do
  #           include Representable::CSV::Collection
  #         end
  #       end
  # 
  #       it "renders contained items #to_csv" do
  #         assert_csv "[\"Days Go By\",\"Can't Take Them All\"]", ["Days Go By", "Can't Take Them All"].extend(@songs_representer).to_csv
  #       end
  # 
  #       it "returns objects array from #from_csv" do
  #         assert_equal ["Days Go By", "Can't Take Them All"], [].extend(@songs_representer).from_csv("[\"Days Go By\",\"Can't Take Them All\"]")
  #       end
  #     end
  #   end
  # end
  # 
  # 
  # require 'representable/csv/hash'
  # class HashRepresenterTest < MiniTest::Spec
  #   module SongRepresenter
  #     include Representable::CSV
  #     property :name
  #   end
  # 
  #   describe "CSV::Hash" do  # TODO: move to HashTest.
  #     describe "with contained objects" do
  #       before do
  #         @songs_representer = Module.new do
  #           include Representable::CSV::Hash
  #           values :class => Song, :extend => SongRepresenter
  #         end
  #       end
  # 
  #       describe "#to_csv" do
  #         it "renders objects" do
  #           assert_csv "{\"one\":{\"name\":\"Days Go By\"},\"two\":{\"name\":\"Can't Take Them All\"}}", {:one => Song.new("Days Go By"), :two => Song.new("Can't Take Them All")}.extend(@songs_representer).to_csv
  #         end
  # 
  #         it "respects :exclude" do
  #           assert_csv "{\"two\":{\"name\":\"Can't Take Them All\"}}", {:one => Song.new("Days Go By"), :two => Song.new("Can't Take Them All")}.extend(@songs_representer).to_csv(:exclude => [:one])
  #         end
  # 
  #         it "respects :include" do
  #           assert_csv "{\"two\":{\"name\":\"Can't Take Them All\"}}", {:one => Song.new("Days Go By"), :two => Song.new("Can't Take Them All")}.extend(@songs_representer).to_csv(:include => [:two])
  #         end
  #       end
  # 
  #       describe "#from_csv" do
  #         it "returns objects array" do
  #           assert_equal({"one" => Song.new("Days Go By"), "two" => Song.new("Can't Take Them All")}, {}.extend(@songs_representer).from_csv("{\"one\":{\"name\":\"Days Go By\"},\"two\":{\"name\":\"Can't Take Them All\"}}"))
  #         end
  # 
  #         it "respects :exclude" do
  #           assert_equal({"two" => Song.new("Can't Take Them All")}, {}.extend(@songs_representer).from_csv("{\"one\":{\"name\":\"Days Go By\"},\"two\":{\"name\":\"Can't Take Them All\"}}", :exclude => [:one]))
  #         end
  # 
  #         it "respects :include" do
  #           assert_equal({"one" => Song.new("Days Go By")}, {}.extend(@songs_representer).from_csv("{\"one\":{\"name\":\"Days Go By\"},\"two\":{\"name\":\"Can't Take Them All\"}}", :include => [:one]))
  #         end
  #       end
  #     end
  # 
  #     describe "with contained text" do
  #       before do
  #         @songs_representer = Module.new do
  #           include Representable::CSV::Collection
  #         end
  #       end
  # 
  #       it "renders contained items #to_csv" do
  #         assert_csv "[\"Days Go By\",\"Can't Take Them All\"]", ["Days Go By", "Can't Take Them All"].extend(@songs_representer).to_csv
  #       end
  # 
  #       it "returns objects array from #from_csv" do
  #         assert_equal ["Days Go By", "Can't Take Them All"], [].extend(@songs_representer).from_csv("[\"Days Go By\",\"Can't Take Them All\"]")
  #       end
  #     end
  #   end
  end
end
