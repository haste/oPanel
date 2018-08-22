--[[-------------------------------------------------------------------------
  Copyright (c) 2006-2010, Trond A Ekseth
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
local min, max, temp = 50, 180

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
local addon = CreateFrame("Button", "oPanel", UIParent)
addon:RegisterEvent"PLAYER_LOGIN"

addon:SetHeight(min)
addon:SetPoint("BOTTOM", UIParent, 0, -5)
addon:SetPoint("LEFT", UIParent, -25, 0)
addon:SetPoint("RIGHT", UIParent, 25, 0)

addon:SetBackdrop({
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
})
addon:SetBackdropColor(0, 0, 0)
addon:SetBackdropBorderColor(0, 0, 0)
addon:SetFrameStrata"BACKGROUND"

addon:RegisterForClicks"LeftButtonUp"
addon.OnUpdate = function(self) self:SetScript("OnUpdate", onUpdate) end
addon:SetScript("OnDoubleClick", addon.OnUpdate)

local fade = addon:CreateTexture(nil, "BORDER")
fade:SetTexture"Interface\\ChatFrame\\ChatFrameBackground"
fade:SetPoint("TOP", addon, 0, -4)
fade:SetPoint("LEFT", addon, 4, 0)
fade:SetPoint("RIGHT", addon, -4, 0)
fade:SetPoint("BOTTOM", addon, 0, -25)
fade:SetBlendMode"ADD"
fade:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .25, .25, .35, 1)

addon.fade = fade

addon:SetScript("OnEvent", function(self)
	-- Hide the chatframe textures
	for i = 1, NUM_CHAT_WINDOWS do
		_G['ChatFrame' .. i]:SetClampedToScreen(false)

		for k,v in pairs(CHAT_FRAME_TEXTURES) do
			_G["ChatFrame"..i..v]:Hide()
		end
	end

	for k in pairs(CHAT_FRAME_TEXTURES) do
		CHAT_FRAME_TEXTURES[k] = nil
	end

	for i, t in next, {true, true, nil, true, nil, nil, nil} do
		if(t) then
			UIPARENT_MANAGED_FRAME_POSITIONS["ChatFrame"..i] = nil
			local cf = _G["ChatFrame"..i]
			cf:SetWidth(550)
			cf:ClearAllPoints()
			cf:SetPoint("BOTTOM", self, 0, 8)
			cf:SetPoint("TOP", self, 0, -6)

			local sbb = cf.ScrollToBottomButton
			sbb:UnregisterAllEvents()
			sbb:SetScript("OnShow", sbb.Hide)
			sbb:Hide()

			local sb = cf.ScrollBar
			sb:UnregisterAllEvents()
			sb:SetScript("OnShow", sb.Hide)
			sb:Hide()

			FCF_SetLocked(cf, 1)
		end
	end

	ChatFrame1:SetPoint("LEFT", self, 28, 0)
	ChatFrame2:SetPoint("RIGHT", self, -28, 0)
	ChatFrame4:SetPoint('CENTER', self)

	WorldFrame:SetUserPlaced(false)

	local h, w = GetScreenHeight(), GetScreenWidth()
	if(GetCVarBool'useUiScale') then
		local s = GetCVar'uiscale' or 1
		h, w = h * s, w * s
	end

	WorldFrame:SetHeight(h)
	WorldFrame:SetWidth(w)

	local stateToggle = function(state)
		WorldFrame:ClearAllPoints()
		if(state) then
			WorldFrame:SetPoint"TOP"
			WorldFrame:SetPoint("BOTTOM", oPanel, "TOP", 0, -3)
		else
			WorldFrame:SetAllPoints()
		end
	end
	hooksecurefunc('SetUIVisibility', stateToggle)
	stateToggle(UIParent:IsShown())
end)
