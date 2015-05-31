--[[
* Purpose of this file *
This is the HUD of MinuteMap. It displays the map.

* Credits *
Scripting: TheAndrew61

* Notes *
- Here's how to take a screenshot:
local RCD = {}
RCD.format = "jpeg"
RCD.h = CamData.h
RCD.w = CamData.w
RCD.quality = 100
RCD.x = CamData.x
RCD.y = CamData.y
local data = render.Capture(RCD)
file.Write("ss.txt", data)

Here's how to detect if the spawnmenu is open
hook.Add("OnSpawnMenuOpen", "SMOpen", function()
  spawnmenuOpen = true
end)
hook.Add("OnSpawnMenuClose", "SMClose", function()
  spawnmenuOpen = false
end)

!! PLEASE DON'T STEAL THIS CODE !!
]]

-- VARIABLES
local zoomFactor = 170
local CamData = {}
local MirrorData = {}
local mapX = 0
local mapY = 0
local personX = 0
local personY = 0
mm_enabled = CreateClientConVar("mm_enabled", 1)
mm_show_player = CreateClientConVar("mm_show_player", 1)
mm_rotate_map = CreateClientConVar("mm_rotate_map", 1)
mm_width = CreateClientConVar("mm_width", 4)
mm_height = CreateClientConVar("mm_height", 4)
mm_map_pos = CreateClientConVar("mm_map_pos", "2")
mm_mirror_enabled = CreateClientConVar("mm_mirror_enabled", 0)

-- INIT
local initDone = false
hook.Add("Initialize","MMInit", function()
  if initDone == false then
    MsgC(Color(255, 0, 255), "---------------\n! MinuteMap loaded !\n---------------\n")
    initDone = true
  end
end)

-- MAIN
hook.Add("HUDPaint", "DrawMap", function()
  if mm_enabled:GetInt() == 1 then
    -- regular map
    if mm_rotate_map:GetInt() == 1 then
      CamData.angles = Angle(90, LocalPlayer():EyeAngles().yaw, 0) -- pitch yaw roll (LocalPlayer():EyeAngles().yaw)
    else
      CamData.angles = Angle(90, 0, 0)
    end
    CamData.origin = LocalPlayer():GetPos() + Vector(0, 0, zoomFactor)
    CamData.w = ScrW() / mm_width:GetInt()
    CamData.h = ScrH() / mm_height:GetInt()
    setMapPos(mm_map_pos:GetInt())
    render.RenderView(CamData)
    if mm_show_player:GetInt() == 0 then
      surface.SetDrawColor(255, 255, 255, 255)
      surface.SetMaterial(Material("vgui/entities/person.png"))
      surface.DrawTexturedRect(personX, personY, 14, 14)
    end

    -- rear view mirror
    if mm_mirror_enabled:GetInt() == 1 && LocalPlayer():InVehicle() then
      local vPos = LocalPlayer():GetVehicle():GetPos()
      local vAng = LocalPlayer():GetVehicle():GetAngles()
      local pPos = LocalPlayer():GetPos()
      MirrorData.angles = Angle(0, LocalPlayer():GetAngles().yaw+180, 0) -- pitch yaw roll
      MirrorData.origin = vPos + Vector(0, 0, 90)
      MirrorData.w = 320
      MirrorData.h = 192 -- 5:3 ratio?
      MirrorData.x = (ScrW()/2) - (MirrorData.w/2)
      MirrorData.y = 0
      render.RenderView(MirrorData)
    end
  end
end)

-- ZOOM
hook.Add("Think", "KeyEvents", function()
  if mm_enabled:GetInt() == 1 then
    -- zoom in
    if input.IsKeyDown(KEY_LCONTROL) && input.IsKeyDown(KEY_EQUAL) then
      if zoomFactor > 20 then
          zoomFactor = zoomFactor - 10
      end
      render.RenderView(CamData)
    end
    if input.IsKeyDown(KEY_RCONTROL) && input.IsKeyDown(KEY_EQUAL) then
      if zoomFactor > 20 then
          zoomFactor = zoomFactor - 10
      end
      render.RenderView(CamData)
    end
    -- zoom out
    if input.IsKeyDown(KEY_LCONTROL) && input.IsKeyDown(KEY_MINUS) then
      zoomFactor = zoomFactor + 10
      render.RenderView(CamData)
    end
    if input.IsKeyDown(KEY_RCONTROL) && input.IsKeyDown(KEY_MINUS) then
      zoomFactor = zoomFactor + 10
      render.RenderView(CamData)
    end
    -- reset zoom
    if input.IsKeyDown(KEY_LCONTROL) && input.IsKeyDown(KEY_0) then
      zoomFactor = 170
      render.RenderView(CamData)
    end
    if input.IsKeyDown(KEY_RCONTROL) && input.IsKeyDown(KEY_0) then
      zoomFactor = 170
      render.RenderView(CamData)
    end
    -- show player
    CamData.drawviewmodel = mm_show_player:GetBool()
    -- map rotation
    if mm_rotate_map:GetInt() == 1 then
      CamData.angles = Angle(90, LocalPlayer():EyeAngles().yaw, 0)
    else
      CamData.angles = Angle(90, 0, 0)
    end
    -- map size
    CamData.w = ScrW() / mm_width:GetInt()
    CamData.h = ScrH() / mm_height:GetInt()
    setMapPos(mm_map_pos:GetInt())
  end
end)

function setMapPos(pos)
  if pos == 0 then
    mapX = 0
    mapY = 0
    personX = CamData.w/2
    personY = CamData.h/2
  end
  if pos == 1 then
    mapX = ScrW() - (ScrW()/mm_height:GetInt())
    mapY = 0
    personX = ScrW() - (CamData.w/2)
    personY = CamData.h/2
  end
  if pos == 2 then
    mapX = 0
    mapY = ScrH() - (ScrH()/mm_height:GetInt())
    personX = CamData.w/2
    personY = ScrH() - (CamData.h/2)
  end
  if pos == 3 then
    mapX = ScrW() - (ScrW()/mm_height:GetInt())
    mapY = ScrH() - (ScrH()/mm_height:GetInt())
    personX = ScrW() - (CamData.w/2)
    personY = ScrH() - (CamData.h/2)
  end
  CamData.x = mapX
  CamData.y = mapY
end

-- OPTIONS panel
hook.Add("PopulateToolMenu", "OptionsMenu", function()
  spawnmenu.AddToolMenuOption("Options", "TheAndrew61", "mm_menu", "MinuteMap", "", "", function(Panel)
    Panel:ClearControls()
    Panel:AddControl("Checkbox", {
      Label = "Show the map?",
      Command = "mm_enabled"
    })
    Panel:AddControl("Checkbox", {
      Label = "Show yourself?",
      Command = "mm_show_player"
    })
    Panel:AddControl("Checkbox", {
      Label = "Rotate map to match camera?",
      Command = "mm_rotate_map"
    })
    Panel:AddControl("Checkbox", {
      Label = "Enable rear view mirror in vehicles?",
      Command = "mm_mirror_enabled"
    })

    local wSlider = vgui.Create("DNumSlider")
    wSlider:SetText("* Map width:")
    wSlider:SetMin(2)
    wSlider:SetMax(10)
    wSlider:SetDecimals(0)
    wSlider:SetConVar("mm_width")
    Panel:AddItem(wSlider)

    local hSlider = vgui.Create("DNumSlider")
    hSlider:SetText("* Map height:")
    hSlider:SetMin(2)
    hSlider:SetMax(10)
    hSlider:SetDecimals(0)
    hSlider:SetConVar("mm_height")
    Panel:AddItem(hSlider)

    Panel:AddControl("Label", {
      Text = "* The smaller the values, the larger the map is, and vice versa. MinuteMap configures the map's size by the game window's size divided by the values."
    })
    Panel:AddControl("ListBox", {
      Label = "Map position",
      Height = 85,
      Options = {
        ["Top left"] = {
          mm_map_pos = "0"
        },
        ["Top right"] = {
          mm_map_pos = "1"
        },
        ["Bottom left"] = {
          mm_map_pos = "2"
        },
        ["Bottom right"] = {
          mm_map_pos = "3"
        }
      }
    })

    Panel:AddControl("Label", {
      Text = "HOW TO USE:\n\nControl + Equals (=) -- Zoom in\n\nControl + Minus (-) -- Zoom out\n\nControl + Zero (0) -- Reset zoom"
    })
    Panel:AddControl("Label", {
      Text = "CREDITS:\nScripting: TheAndrew61"
    })
  end)
end)