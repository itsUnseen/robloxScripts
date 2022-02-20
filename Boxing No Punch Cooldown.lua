local c = 0

for i,v in pairs (getgc(true)) do
    if (type(v) == 'function' and getfenv(v).script == game:GetService("Workspace").itsUnseen.CombatSetupClient) then
       c = c + 1
       for a,b in pairs (debug.getupvalues(v)) do
           if (tostring(b) == 'PUNCHING_COOLDOWN') then
               local val = Instance.new("IntValue")
               val.Value = 0
               debug.setupvalue(v, a, val)
           end
        end
    end
end
