require "defines"
require "config"

local ReadyToRoll=0

local mod_version="0.3.0"

local poll_network = math.floor(60/rc_polling_rate_network)
local poll_network_slow = math.floor(60/rc_polling_rate_network_slow)
local poll_personal = math.floor(60/rc_polling_rate_personal)
local poll_personal_slow = math.floor(60/rc_polling_rate_personal_slow)
local poll_local = math.floor(60/rc_polling_rate_local)
local poll_local_slow = math.floor(60/rc_polling_rate_local_slow)


local combs_polling_cycles = math.floor(60/5)

    local rc_network={}
    local rc_personal={}
    local rc_local={}
    
local function setSig_network(thisRC,rclogidle, rclogtotal, rcconidle, rccontotal)
  local rcparas = {parameters={
    {index=1,count=rclogidle,signal={type="virtual",name="signal-robot-log-idle"}},
    {index=2,count=rclogtotal,signal={type="virtual",name="signal-robot-log-total"}},
    {index=3,count=rcconidle,signal={type="virtual",name="signal-robot-con-idle"}},
    {index=4,count=rccontotal,signal={type="virtual",name="signal-robot-con-total"}},
  }}
  thisRC.set_circuit_condition(1,rcparas)
end

local function setSig_personal(thisRC,rclogidle, rclogtotal, rcconidle, rccontotal)
  local rcparas = {parameters={
    {index=1,count=rclogidle,signal={type="virtual",name="signal-robot-log-idle"}},
    {index=2,count=rclogtotal,signal={type="virtual",name="signal-robot-log-total"}},
    {index=3,count=rcconidle,signal={type="virtual",name="signal-robot-con-idle"}},
    {index=4,count=rccontotal,signal={type="virtual",name="signal-robot-con-total"}},
  }}
  thisRC.set_circuit_condition(1,rcparas)
end

local function setSig_local(thisRC,rclogidle, rclogtotal, rcconidle, rccontotal)
  local rcparas = {parameters={
    {index=1,count=rclogidle,signal={type="virtual",name="signal-robot-log-idle"}},
    {index=2,count=rclogtotal,signal={type="virtual",name="signal-robot-log-total"}},
    {index=3,count=rcconidle,signal={type="virtual",name="signal-robot-con-idle"}},
    {index=4,count=rccontotal,signal={type="virtual",name="signal-robot-con-total"}},
  }}
  thisRC.set_circuit_condition(1,rcparas)
end







local function onLoad()
  grc = global.robotic-combinators

  if global.robotic_combinators == nil or global.robotic_combinators.version ~= mod_version then
    --unlock if needed
    for _,force in pairs(game.forces) do
      force.reset_recipes()
      force.reset_technologies()

      local techs=force.technologies
      local recipes=force.recipes
      if techs["logistic-robotics"].researched then
        recipes["robotic-combinator"].enabled=true
      end
      if techs["construction-robotics"].researched then
        recipes["robotic-combinator"].enabled=true
      end

    end
    grc.version=mod_version
  end


  
  if grc.rc_network ~= nil then
    local rc_network=grc.rc_network
  end

  if grc.rc_personal ~= nil then
    local rc_personal=grc.rc_personal
  end
  
  if grc.rc_local ~= nil then
    local rc_local=grc.rc_local
  end

  
ReadyToRoll=11
end


local function onSave()
  --
  local soEmpty = nil
end


local function onTick(event)
if ReadyToRoll == 11 then



  if event.tick%poll_network == poll_network-1 then
    for k,v in pairs(rc_network) do
      local ve
      if v.EntityID.valid then
        ve = v.EntityID
        local LogiNet
        LogiNet = ve.surface.find_logistic_network_by_position(ve.position,ve.force.name)
        if LogiNet == nil then
          setSig_network(ve, 0, 0, 0, 0)
        else
          setSig_network(ve, LogiNet.available_logistic_robots, LogiNet.all_logistic_robots, LogiNet.available_construction_robots, LogiNet.all_construction_robots)
        end
      end
    end
  end

end
end






local function onPlaceEntity(event)
  local entity=event.created_entity
  if entity.name=="robotic-network-combinator" then
    rc_network[#rc_network+1]={EntityID=entity}
  end


end













game.on_init(onLoad)
game.on_load(onLoad)

game.on_save(onSave)

game.on_event(defines.events.on_built_entity,onPlaceEntity)
game.on_event(defines.events.on_robot_built_entity,onPlaceEntity)



game.on_event(defines.events.on_tick,onTick)
