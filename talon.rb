Shoes.setup do
  gem 'twitter'
end

require 'twitter'

module Talon
  def twitter_color_to_shoes_color(twitter_color)
    "##{twitter_color}"
  end
  def logo
    background '#fff'
    background 'talon.jpg', :bottom => 0, :right => -20
    flow :width => '100%' do
      background '#df9', :curve => 12
      title 'Talon', :stroke => '#691FFF', :align => 'center'
    end
  end
  def login
    @login = stack :margin => '60px' do
               background '#df9', :curve => 12
               title "Who goes there?", :stroke => '#691FFF', :align => 'center'
               flow do
                 stack :width => '100px' do
                   para 'Nom de tweet', :stroke => '#691FFF'
                 end
                 @user = edit_line :width => '-120px'
               end
               flow do
                 stack :width => '100px' do
                   para 'Sekrit', :stroke => '#691FFF'
                 end
                 @pass = edit_line :width => '-120px', :secret => true
               end
               button 'That is who I am!', :width => '100%', :stroke => '#691FFF' do
                 do_login
               end
             end
  end
  
  def show_logged_in_timeline
    @loggedin_ui, @logged_in_status = show_user @logged_in_as.screen_name
    @logged_in_timeline = stack do
                            stack :margin => '10px' do
                              background twitter_color_to_shoes_color(@logged_in_as.profile_sidebar_fill_color), :curve => 12
                              caption 'Timeline', :stroke => twitter_color_to_shoes_color(@logged_in_as.profile_text_color)
                            end
                            @twitter.timeline.each do |status|
                              show_status @twitter.user(status.user), status
                            end
                          end
  end
  
  def show_user user_name
    the_user = @twitter.user(user_name)
    user_ui = stack :margin => '10px' do
                background twitter_color_to_shoes_color(the_user.profile_background_color), :curve => 12
                flow do
                  stack :width => '120px', :margin => '10px' do
                    image the_user.profile_image_url, :width => '100px', :height => '100px'
                  end
                  stack :width => '-120px' do
                    banner the_user.screen_name, :stroke => twitter_color_to_shoes_color(the_user.profile_text_color)
                    subtitle "(#{the_user.name})", :stroke => twitter_color_to_shoes_color(the_user.profile_text_color)
                  end
                end
              end
    current_status = show_status the_user, the_user.status
    [user_ui, current_status]
  end
  
  def show_status for_user, status_info
    stack :margin => '10px' do
      background twitter_color_to_shoes_color(for_user.profile_background_color), :curve => 12
      flow do
        stack :width => '60px', :margin => '10px' do
          image for_user.profile_image_url, :width => '50px', :height => '50px'
        end
        stack :width => '-60px' do
          caption "@#{for_user.screen_name}", :stroke => twitter_color_to_shoes_color(for_user.profile_text_color)
          para status_info.text, :stroke => twitter_color_to_shoes_color(for_user.profile_text_color)
        end
      end
    end   
  end
  
  def do_login
    user = @user.text
    pass = @pass.text
    @twitter = Twitter::Base.new(user, pass)
    if @twitter.verify_credentials
      @login.hide
      @logged_in_as = @twitter.user(user)
      show_logged_in_timeline
    else
      alert "I don't think so :("
    end
  end
end

Shoes.app do
  extend Talon
  logo
  login
end