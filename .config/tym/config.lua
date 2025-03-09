local tym = require('tym')

tym.set_config({
   font = "Dina NFM 12",
   scrollback_length = 2000,
   -- vim retrobox colorscheme (modified)
   color_background = '#1c1c1c',
   color_foreground = '#ebdbb2',
   color_0  = '#1c1c1c',
   color_1  = '#cc241d',
   color_2  = '#98971a',
   color_3  = '#d79921',
   color_4  = '#458588',
   color_5  = '#b16286',
   color_6  = '#689d6a',
   color_7  = '#cfc3a6',
   color_8  = '#3c3c3c',
   color_9  = '#fb4934',
   color_10 = '#b8bb26',
   color_11 = '#fabd2f',
   color_12 = '#83a598',
   color_13 = '#d3869b',
   color_14 = '#8ec07c',
   color_15 = '#ebdbb2',
})

tym.set_hook('signal', function(command)
   if command == 'reload' then
      tym.reload()
      return
   end
end)

tym.set_keymaps({
   ['<Ctrl>0'] = function()
      for id in pairs(tym.get_ids()) do
         tym.signal(id, 'hook', {'reload'})
      end
      tym.notify("Successfully reloaded all tym instances.")
   end,
   ['<Ctrl>equal'] = function()
      tym.set('scale', 100)
      tym.notify('set scale: 100%')
   end,
   ['<Ctrl>minus'] = function()
      local s = tym.get('scale') - 10
      tym.set('scale', s)
      tym.notify('set scale: ' .. s .. '%')
   end,
   ['<Ctrl><Shift>plus'] = function()
      local s = tym.get('scale') + 10
      tym.set('scale', s)
      tym.notify('set scale: ' .. s .. '%')
   end,
})
