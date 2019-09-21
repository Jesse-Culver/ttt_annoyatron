if SERVER then
  AddCSLuaFile("shared.lua")
  AddCSLuaFile("cl_init.lua")
end

ENT.Type = "anim"
ENT.Model = Model("models/props/cs_office/radio.mdl")

local zapsound = Sound("npc/assassin/ball_zap1.wav")

local songs = {{
}};

if SERVER then
  util.AddNetworkString("RadioBegin")
  util.AddNetworkString("RadioStop")
  local contents =
[[https://somafm.com/bootliquor.pls
https://somafm.com/poptron.pls
https://somafm.com/thetrip.pls
https://somafm.com/groovesalad256.pls
https://somafm.com/dubstep256.pls]]
  -- Check if the mttt directory even exists in the data folder
  if file.IsDir("mttt", "DATA") ~= true then
    file.CreateDir("mttt")
  end
  -- Check if the file exists
  if file.Read("mttt/annoyatron.txt") == nil then
    file.Write("mttt/annoyatron.txt", contents)
  end
  table.Empty(songs)
  local songFile = file.Read("mttt/annoyatron.txt")
  local tempSongs = string.Explode("\n", songFile)
  for key, val in pairs(tempSongs) do
    -- We check if it's a blank line, if so that means we can skip this entire loop
    if val ~= "" then
      table.insert(songs, val)
    end
  end
  PrintTable(songs)
end

function PlayRadio()
  if SERVER then
    local URL = table.Random(songs)
    print("Sending "..URL.." to play")
    net.Start("RadioBegin")
      net.WriteString(URL)
    net.Broadcast()
  end
end

function KillRadio()
  if SERVER then
    print("Ending Radio")
    net.Start("RadioStop")
    net.Broadcast()
  end
end

function ENT:Initialize()

  self:SetModel(self.Model)

  if SERVER then
    self:PhysicsInit(SOLID_VPHYSICS)
  end
  
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_BBOX)
  self:SetCollisionGroup(COLLISION_GROUP_NONE)
  if SERVER then
    self:SetUseType(SIMPLE_USE)
  end
  if SERVER then
    self:SetMaxHealth(40)
    self:SetHealth(40)
    PlayRadio()
  end
end

function ENT:OnTakeDamage(dmginfo)
  if SERVER then
    self:SetHealth(self:Health() - dmginfo:GetDamage())
    if self:Health() < 0 then
      KillRadio()
      self:Remove()
      local effect = EffectData()
      effect:SetOrigin(self:GetPos())
      util.Effect("cball_explode", effect)
      sound.Play(zapsound, self:GetPos())
    end
  end
end

function ENT:Use(activator)
  if IsValid(activator) and activator:IsPlayer() and activator:IsActiveTraitor() then
    PlayRadio()
  end
end

hook.Add("PostPlayerDeath", "stopRadioForDead", function(ply)
  if SERVER then
    net.Start("RadioStop")
    net.Send(ply)
  end
end)