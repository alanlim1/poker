class TableController < ApplicationController
  before_action :authenticate_player!, only: [:join]
  respond_to :js

  def index
  end

  def join
  end
end
