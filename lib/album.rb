class Album
  attr_reader :id
  attr_accessor :name

  def initialize(attributes)
    @name = attributes.fetch(:name)
    @id = attributes.fetch(:id)
  end

  def self.all
    returned_albums = DB.exec("SELECT * FROM albums")
    albums = []
    returned_albums.each do |album|
      name = album.fetch("name")
      id = album.fetch("id").to_i
      albums.push(Album.new({:name => name, :id => id}))
    end
    albums
  end

  def self.clear
    DB.exec("DELETE FROM albums *")
  end

  def save
    result = DB.exec("INSERT INTO albums (name) VALUES ('#{@name}') RETURNING id;")
    @id = result.first().fetch("id").to_i
  end

  def self.find(id)
    album = DB.exec("SELECT * FROM albums WHERE id = #{id};").first
    name = album.fetch("name")
    id = album.fetch("id").to_i
    Album.new({:name => name, :id => id})
  end

  # def update(name)
  #   @name = name
  #   DB.exec("UPDATE albums SET name = '#{@name}' WHERE id = #{@id};")
  # end

  def update(attributes)
    if (attributes.has_key?(:name)) && (attributes.fetch(:name) != nil)
      @name = attributes.fetch(:name)
      DB.exec("UPDATE albums SET name = '#{@name}' WHERE id = #{@id};")
    elsif (attributes.has_key?(:artist_name)) && (attributes.fetch(:artist_name) != nil)
      artist_name = attributes.fetch(:artist_name)
      artist = DB.exec("SELECT * FROM artists WHERE lower(name)='#{artist_name.downcase}';").first
      if artist != nil
        DB.exec("INSERT INTO albums_artists (artist_id, album_id) VALUES (#{artist['id'].to_i}, #{@id});")
      end
    end
  end

  def delete
    DB.exec("DELETE FROM albums_artists WHERE album_id = #{@id}")
    DB.exec("DELETE FROM albums WHERE id = #{@id};")
  end

  def ==(album_to_compare)
    self.name() == album_to_compare.name()
  end

  def self.search(search_name)
    album_names = Album.all.map {|a| a.name.downcase }
    result = []
    names = album_names.grep(/#{search_name}/)
    names.each do |n|
      album = DB.exec("SELECT * FROM albums WHERE lower(name) = '#{n}'").first
      name = album.fetch("name")
      id = album.fetch("id")
      return_album = Album.new({:name => name, :id => id})
      result.push(return_album)
    end
    result
  end

  def songs
    Song.find_by_album(self.id)
  end 

  # def self.find_by_artist(art_id)
  #   albums = []
  #   returned_albums = DB.exec("SELECT * FROM albums_artists WHERE artist_id = #{art_id};")
  #   returned_albums.each() do |album|
  #   name = album.fetch("name")
  #   id = album.fetch('id').to_i
  #   albums.push(Album.new({:name => name, :artist_id => art_id, :id => id}))
  #   end
  #   albums
  # end
end

