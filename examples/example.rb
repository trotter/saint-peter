base_dir = File.dirname(__FILE__)
server_dir = "#{base_dir}/../server"

# start SaintPeter
saint_peter = Kernel.fork do
  exec "ruby #{server_dir}/lib/saint_peter.rb"
end

# start Protected Server
protected_server = Kernel.fork do
  exec "rackup --pid rack.pid #{base_dir}/config.ru"
end

print "Waiting for servers to load"
# wait on servers to start
until system("curl http://localhost:3333/status >/dev/null 2>&1") && 
      system("curl http://localhost:9292/ >/dev/null 2>&1")
  print "."
  sleep 2
end
puts

# add user
puts "Creating user"
system "#{server_dir}/bin/saint_peters_list add_user trotter admin"

# add resource
puts "Creating resource"
system "#{server_dir}/bin/saint_peters_list add_resource / admin"

# Hit the resource unauthenticated
puts "\n\nUnauthenticated:"
system "curl -i http://localhost:9292/"

# Hit it as our user
puts "\n\nAauthenticated:"
system %|curl -i -H "X_USER: trotter" http://localhost:9292/|

Process.kill("KILL", saint_peter)
Process.kill("KILL", protected_server)
