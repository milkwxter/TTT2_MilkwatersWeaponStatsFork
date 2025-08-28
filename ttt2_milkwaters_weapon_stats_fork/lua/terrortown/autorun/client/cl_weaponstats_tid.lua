local mat_tid_dmg = Material("vgui/ttt/dynamic/roles/icon_traitor")
local mat_tid_acc = Material("vgui/ttt/tid/tid_accuracy")
local mat_tid_ammo = Material("vgui/ttt/tid/tid_ammo")
local mat_tid_bullet = Material("vgui/ttt/pickup/icon_ammo.png")
local mat_tid_auto = Material("vgui/ttt/tid/tid_automatic")
local mat_tid_rec = Material("vgui/ttt/tid/tid_recoil")
local mat_tid_speed = Material("vgui/ttt/tid/tid_spm")
local mat_tid_large_ammo = Material("vgui/ttt/tid/tid_lg_ammo")
local mat_tid_star = Material("vgui/ttt/tid/star")
local mat_tid_checkmark = Material("vgui/ttt/tid/checkmark")
local mat_tid_xmark = Material("vgui/ttt/tid/xmark")
local mat_tid_rarity = Material("vgui/ttt/tid/rarity")
local mat_tid_suppressed = Material("vgui/ttt/tid/suppressed")

local BaseHUD = baseclass.Get("pure_skin_element")

local function GetDamage(weapon)
	local damage = weapon.Primary.Damage or weapon.Damage

	if damage == nil then return "N/A" end

	return damage * (weapon.damageScaling or 1)
end

hook.Add("TTTRenderEntityInfo", "HUDDrawTargetIDWeaponStats", function(tData)
	-- Make sure only living, playing, clients can see weapon statistics
	local client = LocalPlayer()
	local ent = tData:GetEntity()

	if not IsValid(client) or not client:IsTerror() or not client:Alive()
	or not IsValid(ent) or tData:GetEntityDistance() > 100 or not ent:IsWeapon() then
		return
	end

	if not istable(ent.Primary) then return end
	
	-- show what ammo the weapon uses
	if ent.AmmoEnt == "None" then
		tData:AddDescriptionLine(
			LANG.TryTranslation("ttt2_wstat_compatAmmoNone"),
			nil,
			{mat_tid_large_ammo}
		)
	else
		tData:AddDescriptionLine(
			LANG.TryTranslation("ttt2_wstat_compatAmmo") .. ent.Primary.Ammo,
			nil,
			{mat_tid_large_ammo}
		)
	end
	
	-- show the damage of the weapon
	tData:AddDescriptionLine(
		LANG.GetParamTranslation("ttt2_wstat_dmg", {dmg = GetDamage(ent)}),
		nil,
		{mat_tid_dmg}
	)
	
	-- show the firerate of the weapon
	tData:AddDescriptionLine(
		LANG.GetParamTranslation("ttt2_wstat_rpm", {rpm = math.floor(60 / ent.Primary.Delay)}),
		nil,
		{mat_tid_speed}
	)
	
	-- Show the fire mode so people know whats up
	if ent.BurstSelected then
		tData:AddDescriptionLine(
			LANG.GetParamTranslation("ttt2_wstat_burst", {burst = ent.BurstBulletsPerBurst}),
			nil,
			{mat_tid_auto}
		)
	elseif ent.Primary.Automatic then
		tData:AddDescriptionLine(
			LANG.TryTranslation("ttt2_wstat_auto"),
			nil,
			{mat_tid_auto}
		)
	else
		tData:AddDescriptionLine(
			LANG.TryTranslation("ttt2_wstat_semi"),
			nil,
			{mat_tid_auto}
		)
	end
	
	-- show if the weapon is suppressed
	if ent.IsSilent then
		tData:AddDescriptionLine(
			LANG.TryTranslation("ttt2_wstat_supp"),
			nil,
			{mat_tid_suppressed}
		)
	end
	
	-- show if the weapon can swap bullet types
	if ent.SelectiveSBT then
		tData:AddDescriptionLine(
			LANG.TryTranslation("ttt2_wstat_sbt"),
			nil,
			{mat_tid_star}
		)
	end
	
	-- display weapon rarity
	if ent.Rarity then
		tData:AddDescriptionLine(
			LANG.GetParamTranslation("ttt2_wstat_rarity", {rarity = ent.Rarity}),
			nil,
			{mat_tid_rarity}
		)
	end
end)

local ammo_types = {
	["item_ammo_357_ttt"] = true,
	["item_ammo_pistol_ttt"] = true,
	["item_ammo_revolver_ttt"] = true,
	["item_ammo_smg1_ttt"] = true,
	["item_box_buckshot_ttt"] = true
}

hook.Add("TTTRenderEntityInfo", "HUDDrawTargetIDAmmoBoxes", function(tData)
	local client = LocalPlayer()
	local ent = tData:GetEntity()

	if not IsValid(client) or not client:IsTerror() or not client:Alive()
	or not IsValid(ent) or tData:GetEntityDistance() > 100 or not ammo_types[ent:GetClass()] then
		return
	end

	-- enable targetID rendering
	tData:EnableText()
	tData:EnableOutline()
	tData:SetOutlineColor(client:GetRoleColor())

	tData:SetTitle(LANG.TryTranslation("ttt2_wstat_ammo_name") .. ": " .. ent.AmmoType)
	tData:SetSubtitle(LANG.TryTranslation("ttt2_wstat_ammo_walk_over"))
	
	-- show if the ammo is valid for your gun or not
	if ent:GetClass() == client:GetActiveWeapon().AmmoEnt then
		tData:AddDescriptionLine(
			LANG.TryTranslation("ttt2_wammo_canuse"),
			nil,
			{mat_tid_checkmark}
		)
	else
		tData:AddDescriptionLine(
			LANG.TryTranslation("ttt2_wammo_cantuse"),
			nil,
			{mat_tid_xmark}
		)
	end
	
	tData:AddIcon(BaseHUD.AmmoIcons[ammo_type] or mat_tid_large_ammo)
end)
