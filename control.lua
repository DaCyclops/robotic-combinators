require "defines"

local ReadyToRoll=0

local mod_version="0.3.1"

local combs_polling_cycles = math.floor(60/5)


local rcs_combs={}

local function rcSetSignals(thisRC,rclogidle, rclogtotal, rcconidle, rccontotal)
  local rcparas = {parameters={
    {index=1,count=rclogidle,signal={type="virtual",name="signal-robot-log-idle"}},
    {index=2,count=rclogtotal,signal={type="virtual",name="signal-robot-log-total"}},
    {index=3,count=rcconidle,signal={type="virtual",name="signal-robot-con-idle"}},
    {index=4,count=rccontotal,signal={type="virtual",name="signal-robot-con-total"}},
  }}
  thisRC.set_circuit_condition(1,rcparas)
end




local function onLoad()
  if global.robotic_combinators==nil or global.robotic_combinators.version ~= mod_version then
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
    global.robotic_combinators={rcscombs={}, version=mod_version}
  end

  rcs_combs=global.robotic_combinators.rcscombs
  
ReadyToRoll=11
end

local function onSave()
  global.robotic_combinators={rcscombs=rcs_combs, version=mod_version}
end


local function onTick(event)
if ReadyToRoll == 11 then



  if event.tick%combs_polling_cycles == combs_polling_cycles-1 then
    for k,v in pairs(rcs_combs) do
      local ve
      if v.EntityID.valid then
        ve = v.EntityID
        local LogiNet
        LogiNet = ve.surface.find_logistic_network_by_position(ve.position,ve.force.name)
        if LogiNet == nil then
          rcSetSignals(ve, 0, 0, 0, 0)
        else
          rcSetSignals(ve, LogiNet.available_logistic_robots, LogiNet.all_logistic_robots, LogiNet.available_construction_robots, LogiNet.all_construction_robots)
        end
      end
    end
  end

end
end






local function onPlaceEntity(event)
  local entity=event.created_entity
  if entity.name=="robotic-network-combinator" then
    rcs_combs[#rcs_combs+1]={EntityID=entity}
  end


end














game.on_init(onLoad)
game.on_load(onLoad)

game.on_save(onSave)

game.on_event(defines.events.on_built_entity,onPlaceEntity)
game.on_event(defines.events.on_robot_built_entity,onPlaceEntity)



game.on_event(defines.events.on_tick,onTick)
