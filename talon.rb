Shoes.setup do
  gem 'twitter'
end

require 'twitter'

Twitter::Base.class_eval do
  def end_session
    request('account/end_session.xml', :auth => true)
  end
end

module Talon  
  def twitter_colour_to_shoes_colour(twitter_colour)
    "##{twitter_colour}"
  end
  
  def safe_profile_image_url(image_url)
    if image_url.blank? 
      'default_profile_bigger.png'
    else
      image_url
    end
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
    @login = stack :margin => ['10%', '15%', '10%', '0px'] do
               background '#df9', :curve => 12
               title "Who goes there?", :stroke => '#691FFF', :align => 'center'
               flow do
                 stack :width => '150px' do
                   para 'Nom de tweet', :stroke => '#691FFF'
                 end
                 @user = edit_line :width => '-170px'
               end
               flow do
                 stack :width => '150px' do
                   para 'Sekrit', :stroke => '#691FFF'
                 end
                 @pass = edit_line :width => '-170px', :secret => true
               end
               button 'That is who I am!', :width => '100%', :stroke => '#691FFF' do
                 do_login
               end
             end
  end
  
  def cached_user_lookup(screen_name)
    @user_cache ||= {}
    if @user_cache.has_key? screen_name
      @user_cache[screen_name]
    else
      @user_cache[screen_name] = @twitter.user(screen_name)
    end
  end
  
  def show_logged_in_timeline
    @logged_in_ui, @logged_in_status = show_user @logged_in_as, true
    @logged_in_timeline = stack do
                            stack :margin => ['10px', '0px', '10px', '0px'] do
                              background twitter_colour_to_shoes_colour(@logged_in_as.profile_sidebar_fill_color), :curve => 12
                              caption 'Timeline', :stroke => twitter_colour_to_shoes_colour(@logged_in_as.profile_text_color), :align => 'center'
                            end
                            @twitter.timeline.each do |status|
                              show_status cached_user_lookup(status.user.screen_name), status
                            end
                          end
  end
  
  def show_user twitter_user, is_logged_in_user = false
    user_ui = stack :margin => ['10px', '0px', '10px', '0px'] do
                background twitter_colour_to_shoes_colour(twitter_user.profile_sidebar_fill_color), :curve => 12
                flow do
                  stack :width => '120px', :margin => '10px' do
                    image safe_profile_image_url(twitter_user.profile_image_url), :width => '100px', :height => '100px'
                    if is_logged_in_user
                      button "Logout", :width => '100px' do
                        do_logout
                      end
                    end
                  end
                  stack :width => '-120px' do
                    banner twitter_user.screen_name, :stroke => twitter_colour_to_shoes_colour(twitter_user.profile_text_color)
                    subtitle "(#{twitter_user.name})", :stroke => twitter_colour_to_shoes_colour(twitter_user.profile_text_color)
                  end
                end
              end
    current_status = show_status twitter_user, twitter_user.status
    [user_ui, current_status]
  end
  
  def show_status for_user, status_info
    unless status_info.nil?
      stack :margin => '10px' do
        background twitter_colour_to_shoes_colour(for_user.profile_sidebar_fill_color), :curve => 12
        flow do
          stack :width => '60px', :margin => '10px' do
            image safe_profile_image_url(for_user.profile_image_url), :width => '50px', :height => '50px'
          end
          stack :width => '-60px' do
            caption "@#{for_user.screen_name}", :stroke => twitter_colour_to_shoes_colour(for_user.profile_text_color)
            para status_info.text, :stroke => twitter_colour_to_shoes_colour(for_user.profile_text_color)
          end
        end
      end
    end
  end
  
  def do_login
    user = @user.text
    pass = @pass.text
    # TODO - uncomment if you're using trikker locally to pretend to be twitter
    @twitter = Twitter::Base.new(user, pass) #, :api_host => '127.0.0.1')
    begin
      @twitter.verify_credentials
      @login.hide
      @logged_in_as = cached_user_lookup user
      show_logged_in_timeline
    rescue Twitter::CantConnect => e
      incorrect_login
    end
  end
  
  def incorrect_login
    if @incorrect_login_anim.nil?
      @incorrect_login_anim = animate do |i|
                                @login.displace((Math.sin(i) * 6).to_i, 0)
                              end
    end
    @incorrect_login_anim.start
    timer(2) do
      @incorrect_login_anim.stop
      @login.displace(0,0)
    end
  end
  
  def do_logout
    @login.show
    @user.text = ''
    @pass.text = ''
    @logged_in_ui.remove unless @logged_in_ui.nil?
    @logged_in_status.remove unless @logged_in_status.nil?
    @logged_in_timeline.remove unless @logged_in_timeline.nil?
    @user_cache = nil
    begin
      @twitter.end_session
    ensure
      @twitter = nil
    end
    @logged_in_as = nil
  end
end

Shoes.app :title => 'Talon' do
  extend Talon
  logo
  login
end