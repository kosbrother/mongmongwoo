class MyMessagesController < ApplicationController
  layout 'user'

  before_action :load_categories_and_campaigns

  def index
    user = current_user || User.find(User::ANONYMOUS)
    @messages = user.my_messages
  end
end