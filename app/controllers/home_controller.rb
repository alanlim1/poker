class HomeController < ApplicationController

  def index
  end

  def flush_redis
    $redis.flushall
    redirect_to :root
  end
end
