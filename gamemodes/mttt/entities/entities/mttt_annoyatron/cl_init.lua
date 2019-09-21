include( "shared.lua" )

local AnnoyingRadio

function StartRadio(URL)
  if IsValid(AnnoyingRadio) then
    AnnoyingRadio:Stop()
  end
  sound.PlayURL(URL, "", function(AnnoyingSong)
    if IsValid(AnnoyingSong) then
      AnnoyingSong:SetVolume(1)
      AnnoyingSong:Play()
      AnnoyingRadio = AnnoyingSong
      print("Now Playing "..URL)
    else
      print("Something went wrong with the Annoy-A-Tron!")
    end
  end)
end

function StopRadio()
  if IsValid(AnnoyingRadio) then
    AnnoyingRadio:Stop()
  end
end

if CLIENT then
  net.Receive("RadioBegin", function()
    local URL = net.ReadString()
    print("Recieved "..URL)
    if LocalPlayer():Alive() ~= true then return end
    StartRadio(URL)
  end )
  net.Receive("RadioStop", function()
    StopRadio()
  end )
end

