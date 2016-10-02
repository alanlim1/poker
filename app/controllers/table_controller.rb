class TableController < ApplicationController
  before_action :authenticate_player!, only: [:join] & [:start]
  respond_to :js

  def index
  end

  def join
  end

  def start
  end
end
