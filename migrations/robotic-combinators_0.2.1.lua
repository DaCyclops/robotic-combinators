-- LUA to execute before migrating from 0.2.1 to new version


  if global.robotic_combinators.rcscobs ~= nil then
    global.robotic_combinators.rc_network = global.robotic_combinators.rcscobs
    global.robotic_combinators.rcscobs = nil
  end

