class HomeController < ApplicationController
  def index
    render :json => { }, :serializer => RootSerializer
  end
end
