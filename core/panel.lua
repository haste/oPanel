--[[-------------------------------------------------------------------------
  Copyright (c) 2006-2007, Trond A Ekseth
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

      * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials provided
        with the distribution.
      * Neither the name of oPanel nor the names of its contributors
        may be used to endorse or promote products derived from this
        software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
---------------------------------------------------------------------------]]
-- local madness
local G = getfenv(0)
local cos = math.cos
local pi = math.pi

-- internal functions
local cosineInterpolation = function(y1, y2, mu)
	return y1+(y2-y1)*(1 - cos(pi*mu))/2
end

-- addon specific setting
local steps = 25
local modifier = 1/steps

-- this is... frame madness!
local hc = 0
local min, max, temp = 45, 180

local onUpdate = function(self)
	hc = hc + 1
	if(hc == steps) then
		temp = max
		max = min
		min = temp
		hc = 0
		self:SetScript("OnUpdate", nil)
		return
	end

	self:SetHeight(cosineInterpolation(min, max, modifier * hc))
end

-- za warudo!
--local addon = DongleStub"Dongle-1.0":New"oPanel"
local addon = CreateFrame"Frame"
addon:RegisterEvent"PLAYER_LOGIN"

addon:SetScript("OnEvent", function(self)
	local frame = CreateFrame("Button", "oPanel", UIParent)
	frame:SetHeight(45)
	frame:SetPoint("BOTTOM", UIParent, 0, -5)
	frame:SetPoint("LEFT", UIParent, -5, 0)
	frame:SetPoint("RIGHT", UIParent, 5, 0)

	frame:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
	})
	frame:SetBackdropColor(0, 0, 0)
	frame:SetBackdropBorderColor(0, 0, 0)
	frame:SetFrameStrata"BACKGROUND"

	frame:RegisterForClicks"LeftButtonUp"
	frame:SetScript("OnClick", function(self) self:SetScript("OnUpdate", onUpdate) end)

	local fade = frame:CreateTexture(nil, "BORDER")
	fade:SetTexture"Interface\\ChatFrame\\ChatFrameBackground"
	fade:SetPoint("TOP", frame, 0, -4)
	fade:SetPoint("LEFT", frame, 4, 0)
	fade:SetPoint("RIGHT", frame, -4, 0)
	fade:SetPoint("BOTTOM", frame, 0, -25)
	fade:SetBlendMode"ADD"
	fade:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .25, .25, .35, 1)

	local cf = ChatFrame1
	cf:SetWidth(550)
	cf:ClearAllPoints()
	cf:SetPoint("BOTTOM", frame, 0, 8)
	cf:SetPoint("LEFT", frame, 8, 0)
	cf:SetPoint("TOP", frame, 0, -6)

	cf = ChatFrame2
	cf:SetWidth(550)
	cf:ClearAllPoints()
	cf:SetPoint("BOTTOM", frame, 0, 8)
	cf:SetPoint("RIGHT", frame, -8, 0)
	cf:SetPoint("TOP", frame, 0, -6)

	local dummy = function() end
	-- Hide the chatframe textures
	for i = 1,7 do
		G["ChatFrame"..i].SetPoint = dummy
		G["ChatFrame"..i].ClearAllPoints = dummy
		for k,v in pairs(CHAT_FRAME_TEXTURES) do
			G["ChatFrame"..i..v]:Hide()
		end
	end
end)
