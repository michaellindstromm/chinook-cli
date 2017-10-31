require_relative './start.rb'

require 'terminal-table'

class Track < Menu
    
    def initialize(status)
        super(status)
    end

    def search_by_song_title
        puts "Type the name of the song you are looking for and we will see what we can find!"
        puts
        input = user_command_line_input
        first_three = input[0..2]
        searched_songs = @db.execute("select t.Name, a.Name, al.Title, g.Name, t.TrackId from Track t, Artist a, Album al, Genre g where t.AlbumId = al.AlbumId and a.ArtistId = al.ArtistId and t.GenreId = g.GenreId and t.Name like '#{first_three}%'  order by t.Name asc")
        table = Terminal::Table.new
        table.headings = ['Option', 'Song Title', 'Artist', 'Album Title', 'Genre']
        table.style = {:border_x => "-", :border_i => 'x', :all_separators => true}
        table.add_row ["----", "----", "----", "----", "----"]

        if searched_songs == []
            puts 
            puts "Sorry nothing was returned. Please try again."
            puts
            search_by_song_title
        else

            searched_songs.each_with_index do |s, i|
                table.add_row [i, s[0], s[1], s[2], s[3]]
            end

            system "clear"
    
            puts table
            
            get_user_song_selection(searched_songs)

        end


    end

    def get_user_song_selection(searched_songs)
        puts
        puts "To add a song to your playlist, select the corresponding option number."
        puts
        input = user_command_line_input
        case input
        when 'back'
                system "clear"
                user_splash_page
        when 'quit'
            system "clear"
            return  
        end
        
        if is_option_valid_number?(input)

            input = input.to_i

            song_to_add = searched_songs[input]

            case song_to_add
            when nil
                puts "Unable to add. Please make a valid selection."
                get_user_song_selection(searched_songs)
            else 
                puts "You selected #{song_to_add[0]} to add to one of your playlists."
                add_song_to_playlist(song_to_add)
            end

        else

            puts "Unable to add. Please make a valid selection."
            get_user_song_selection(searched_songs)

        end

    end

    def is_option_valid_number?(input)

        if input =~ /^-?[0-9]+$/
            true
        else
            false
        end

    end

end