-- MovementState (ModuleScript in StarterPlayer > StarterPlayerScripts)
-- What the local player's body is doing right now. The Movement and CameraFeel scripts write it;
-- the stamina bar and other effects only read it.
return {
	stamina = 1,          -- 0 = empty, 1 = full
	sprinting = false,    -- running right now
	exhausted = false,    -- ran out; can't sprint again until stamina is back to Config.STAMINA_RESPRINT_AT
	crouching = false,    -- crouched right now (Movement writes it; CameraFeel lowers the view)
	footsteps = 0,        -- counts up once per footstep (CameraFeel); footstep sounds will listen to this
	reduceMotion = false, -- player setting: no head bob, tilt, shake or sprint FOV change
}
