require_relative './track.rb'

class UserPlaylist < Track

    attr_accessor :current_user

    def initialize(status, current_user = nil)
        super(status)
        @current_user = current_user
    end

    def get_user_playlists
        @db.execute("select l.* from Library l where l.authId = '#{@current_user[0]}'")
    end

    def create_new_playlist
        system "clear"
        puts "Insert a name for your playlist:"
        puts
        library_name = user_command_line_input
        uid = @current_user[0]
        @db.execute("insert into Library (libraryName, authId) values ('#{library_name}', #{uid})")
        system "clear"
        puts "#{library_name} successfully created!"
        system "clear"
        another_playlist?
        
    end
    
    def another_playlist?
        puts
        puts "Would you like to make another? [y/n]"
        puts
        another_playlist = user_command_line_input
        case another_playlist
        when 'y'
            create_new_playlist
        when 'n'
            user_splash_page
        when 'quit'
            return
        else
            puts
            puts "Command not recognized. Please input valid option."
            another_playlist?
        end

    end

    def display_user_playlists(playlists)

        table = Terminal::Table.new
        table.headings = ['Option', 'Playlist']
        table.style = {:border_x => "-", :border_i => '+', :all_separators => true}
        table.add_row ["----", "----"]

        playlists.each_with_index do |p, i|
            table.add_row [i, p[1]]
        end

        puts table

    end

    def add_song_to_playlist(song)
        system "clear"
        display_user_playlists(get_user_playlists)
        puts
        selection = get_user_playlist_selection
        playlist = get_user_playlists[selection]
        @db.execute("insert into LibraryTrack (libraryId, trackId) values ('#{playlist[0]}', '#{song[4]}')")
        puts
        puts "*******************************************************************"
        puts "#{song[0]} was successfully added to #{playlist[1]}!"
        puts "*******************************************************************"
        puts 
        user_splash_page
    end

    def get_user_playlist_selection
        puts "Select a playlist."
        puts
        option = user_command_line_input
        system "clear"
        if is_option_valid_number?(option)
            option = option.to_i
            return option
        else
            case option
            when 'back'
                system "clear"
                user_splash_page
            when 'quit'
                system "clear"
                return
            else
                puts "Playlist not available. Please make valid selection."
                get_user_playlist_selection
            end
        end
    end

    def view_songs_from_playlist
        system "clear"
        display_user_playlists(get_user_playlists)
        puts
        selection = get_user_playlist_selection
        playlist = get_user_playlists[selection]
        songs = @db.execute("select t.Name, a.Name, al.Title from Library l, LibraryTrack lt, Track t, Artist a, Album al where lt.libraryId = #{playlist[0]} and l.libraryId = lt.libraryId and lt.trackId = t.trackId and t.albumId = al.albumId and al.artistId = a.artistId")
        table = Terminal::Table.new
        table.title = playlist[1]
        table.headings = ['Song', 'Artist', 'Album']
        table.style = {:border_x => "-", :border_i => 'x', :all_separators => true}
        table.add_row ["----", "----", "----"]

        songs.each_with_index do |s, i|
            table.add_row [s[0], s[1], s[2]]
        end

        puts table

        puts 
        puts "Would you like to view a different playlist? [y/n]"
        puts
        option = user_command_line_input
        case option
        when 'y'
            view_songs_from_playlist
        when 'n'
            system "clear"
            user_splash_page
        when 'back'
            user_splash_page
        when 'quit'
            return
        end
        
    end

end
UserPlaylist.new(false).user_access