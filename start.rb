require 'rubygems'
require 'sqlite3'
require 'io/console'

class Menu

    attr_accessor :user_name

    def initialize(status, user_name = nil)
        @status = status
        @user_name = user_name
        @db = SQLite3::Database.open('./../chinook/Chinook_Sqlite.sqlite')
        @db.results_as_hash = true
    end

    def user_command_line_input
        STDIN.gets.chomp
    end
    
    def user_name_login
        system "clear"
        puts "Input user name:"
        user_name = user_command_line_input
        returned_user = @db.execute("select au.* from Auth au where au.userName = '#{user_name}'")
        case returned_user
        when []
            puts "Sorry there is no user by that name please try again."
            user_name_login
        else
            @user_name = user_name
            user_pass_login(returned_user)
        end

    end

    def user_pass_login(curr_user)
        system "clear"
        puts  "Input password for #{@user_name}:"
        password = STDIN.noecho(&:gets).chomp
        if password == curr_user[0][2]
            @current_user = curr_user[0]
            system "clear"
            user_splash_page
        else
            puts "Sorry your password did not match."
            user_pass_login(curr_user)
        end

    end

    def create_new_user
        @db.results_as_hash = false
        puts "Input desired username: "
        potential_username = user_command_line_input
        pass = ''
        users = @db.execute("select au.userName from Auth au")
        users = users.flatten
        case potential_username
        when 'back'
            user_access
        when 'quit'
            return
        else
            if users.include?(potential_username)
                puts "Sorry username already in use. Please try again."
                create_new_user
            else
                system "clear"
                puts "What will you password be #{potential_username}: "
                pass = user_command_line_input
                @db.execute("insert into Auth ('userName', 'pass') values ('#{potential_username}', '#{pass}')")
                @current_user = [@db.last_insert_row_id]
                @db.results_as_hash = true
        
                system "clear"
                puts "****************************************************"
                puts "Congats #{potential_username}! Welcom to the fam!"
                puts "****************************************************"
                puts
                user_splash_page
            end
        end


    end

    def user_access
        system "reset"
        puts "Hello, and welcome to whatever this is turning into."
        puts
        puts "Select an option below:"
        puts
        puts "[1] Login"
        puts "[2] Create Account"
        puts
        option = user_command_line_input
        case option
        when '1'
            user_name_login
        when '2'
            system "clear"
            create_new_user
        when 'quit'
            return
        else
            puts "Command not recognized. Please enter valid command."
            user_access
        end

    end

    def user_splash_page
        puts "Choose one of the options below. Type 'quit' at anytime to exit the program."
        puts
        puts "[1] Search songs to add to your playlist."
        puts "[2] Create New Playlist."
        puts "[3] View your playlists."
        puts
        option = user_command_line_input
        case option
        when '1'
            system "clear"
            search_by_song_title
        when '2'
            create_new_playlist
        when '3'
            view_songs_from_playlist
        when 'quit'
            return
        else
            puts
            puts "Command not recognized. Please enter valid command."
            puts
            user_splash_page
        end

        return
    end
end