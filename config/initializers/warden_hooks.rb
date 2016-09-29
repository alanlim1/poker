Warden::Manager.after_set_user do |player,auth,opts|
  scope = opts[:scope]
  auth.cookies.signed["#{scope}.id"] = player.id
  auth.cookies.signed["#{scope}.expires_at"] = 30.minutes.from_now
end


Warden::Manager.before_logout do |player, auth, opts|
  scope = opts[:scope]
  auth.cookies.signed["#{scope}.id"] = nil
  auth.cookies.signed["#{scope}.expires_at"] = nil
end
