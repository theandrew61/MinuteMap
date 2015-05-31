--[[
* Purpose of this file *
Initialize the files of MinuteMap.

* Credits *
Scripting: TheAndrew61

* Notes *
- This mod may work server side

!! PLEASE DON'T STEAL THIS CODE !!
]]

if SERVER then
  AddCSLuaFile("client/hud_minutemap.lua")
  resource.AddSingleFile("materials/vgui/entities/person.png")
else
  include("client/hud_minutemap.lua")
end