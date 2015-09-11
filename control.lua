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


    local rc_network={}
    local rc_network_slowstats={}
    local rc_personal={}
    local rc_local={}

  local function onLoad()
  grc = global.robotic_combinators

  -- Version Recipie Reset Migration
  if global.robotic_combinators == nil or global.robotic_combinators.version ~= mod_version then
    --unlock if needed
    for _,force in pairs(game.forces) do
      force.reset_recipes()
      force.reset_technologies()

      local techs=force.technologies
      local recipes=force.recipes
      if techs["logistic-robotics"].researched then
        recipes["robotic-network-combinator"].enabled=true
      end
      if techs["construction-robotics"].researched then
        recipes["robotic-network-combinator"].enabled=true
      end

    end
    grc.version=mod_version
  end

   -- Global Migrations
  if grc.rcscobs ~= nil then
    grc.rc_network = grc.rcscobs
    grc.rcscobs = nil
  end

  -- Global Extraction
  if grc.rc_network ~= nil then
    local rc_network=grc.rc_network
  end

  if grc.rc_network_slowstats ~= nil then
    local rc_network_slowstats=grc.rc_network_slowstats
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
  -- Global Re-saving, to be safe...
    
  global.robotic_combinators.rc_network = rc_network
  global.robotic_combinators.rc_network_slowstats = rc_network_slowstats
  global.robotic_combinators.rc_personal = rc_personal
  global.robotic_combinators.rc_local = rc_local
    
  global.robotic_combinators.version=mod_version
  
end


local function onTick(event)
if ReadyToRoll == 11 then

  --Robotic Network Combinator Slow-Tick
  if event.tick%poll_network_slow == poll_network_slow-1 then
    for k,v in pairs(rc_network) do
      local ve
      if v.EntityID.valid then
        ve = v.EntityID
        local LogiNet
        LogiNet = ve.surface.find_logistic_network_by_position(ve.position,ve.force.name)
        if LogiNet ~= nil then
          local emptyStorage = 0
          for sk,sv in pairs(LogiNet.storages) do
          -- TODO: Calc empty storage space.
            emptyStorage = emptyStorage + 2
          end
          local nowCharging = 0
          local toCharge = 0
          for ck,cv in pairs(LogiNet.cells) do
            nowCharging = nowCharging + cv.charging_robot_count
            toCharge = toCharge + cv.to_charge_robot_count 
          end
          rc_network_slowstats[k] = {es=emptyStorage, nc=nowCharging, tc=toCharge}
        end
      end
    end
  end


  -- Robotic Network Combinator Fast-Tick
  if event.tick%poll_network == poll_network-1 then
    for k,v in pairs(rc_network) do
      if v.EntityID.valid then
        
        local thisLogIdle = 0
        local thisLogTotal = 0
        local thisConIdle = 0
        local thisConTotal = 0
        local thisCellCount = 0
        local thisStorageCount = 0
        local thisStorageEmpty = 0
        local thisRequesters = 0
        --local thisSatisfiedRequesters = 0
        local thisCharging = 0
        local thisToCharge = 0
  
        local thisNet = v.EntityID.surface.find_logistic_network_by_position(v.EntityID.position,v.EntityID.force.name)
        if thisNet ~= nil then
          thisLogIdle = thisNet.available_logistic_robots
          thisLogTotal = thisNet.all_logistic_robots
          thisConIdle = thisNet.available_construction_robots
          thisConTotal = thisNet.all_construction_robots
          for _ in pairs(thisNet.cells) do thisCellCount = thisCellCount + 1 end
          for _ in pairs(thisNet.storages) do thisStorageCount = thisStorageCount + 1 end  
          for _ in pairs(thisNet.requesters ) do thisRequesters = thisRequesters + 1 end  
          --for _ in pairs(thisNet.full_or_satisfied_requesters) do thisSatisfiedRequesters = thisSatisfiedRequesters + 1 end  
          if rc_network_slowstats[k] ~= nil then
            thisStorageEmpty = rc_network_slowstats[k].es
            thisCharging = rc_network_slowstats[k].nc
            thisToCharge = rc_network_slowstats[k].tc
          end
        end
        local rcparas = {parameters={
          {index=1,count=thisLogIdle,signal={type="virtual",name="signal-robot-log-idle"}},
          {index=2,count=thisLogTotal,signal={type="virtual",name="signal-robot-log-total"}},
          {index=3,count=thisConIdle,signal={type="virtual",name="signal-robot-con-idle"}},
          {index=4,count=thisConTotal,signal={type="virtual",name="signal-robot-con-total"}},
          {index=5,count=thisCellCount,signal={type="virtual",name="signal-robot-roboports"}},
          {index=6,count=thisStorageCount,signal={type="virtual",name="signal-robot-storage-count"}},
          {index=7,count=thisStorageEmpty,signal={type="virtual",name="signal-robot-storage-empty"}},
          {index=8,count=thisRequesters,signal={type="virtual",name="signal-robot-pending-requesters"}},
          {index=9,count=thisCharging,signal={type="virtual",name="signal-robot-charging-count"}},
          {index=10,count=thisToCharge,signal={type="virtual",name="signal-robot-to-charge-count"}},
        }}
        v.EntityID.set_circuit_condition(1,rcparas)
        
        
        
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
  
  if entity.name=="personal-robotics-combinator" then
    rc_personal[#rc_personal+1]={EntityID=entity}
  end

    if entity.name=="local-robotics-combinator" then
    rc_local[#rc_local+1]={EntityID=entity}
  end
  
  
end













game.on_init(onLoad)
game.on_load(onLoad)

game.on_save(onSave)

game.on_event(defines.events.on_built_entity,onPlaceEntity)
game.on_event(defines.events.on_robot_built_entity,onPlaceEntity)



game.on_event(defines.events.on_tick,onTick)
