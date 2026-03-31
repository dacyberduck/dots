swayimg.set_window_size(854, 480)
swayimg.enable_decoration(false)
swayimg.imagelist.set_order("alpha")
swayimg.text.set_foreground(0xffffff00)
swayimg.text.set_timeout(1000)
swayimg.text.set_size(16)

-- Viewer mode settings
swayimg.viewer.set_default_scale("optimal")
swayimg.viewer.set_window_background(0x441c1c1c)
swayimg.viewer.set_image_background(0x441c1c1c)
swayimg.viewer.set_text("topleft", { "File: {name}" })
swayimg.viewer.set_text("topright", { "{list.index}/{list.total}" })
swayimg.viewer.set_text("bottomleft", { "Type: {format} [{sizehr}]" })
swayimg.viewer.set_text("bottomright", { "Scale: {scale}" })
swayimg.viewer.on_key("Escape", function()
   swayimg.exit()
end)
swayimg.viewer.on_key("q", function()
   swayimg.exit()
end)
swayimg.viewer.on_key("Ctrl-y", function()
   local path = swayimg.viewer.get_image().path
   os.execute("dms clipboard copy " .. path)
   os.execute("dms notify swayimg 'image path copied to clipboard' --timeout 3 --icon " .. path)
end)
swayimg.viewer.on_key("Ctrl-c", function()
   local file = swayimg.viewer.get_image().path
   if file == "stdin://" then
      file = "/tmp/swayimg-export.png"
      swayimg.viewer.export(file)
   end
   os.execute("dms clipboard copy --type `xdg-mime query filetype " .. file .. "` < " .. file)
   os.execute("dms notify swayimg 'image copied to clipboard' --timeout 3 --icon " .. file)
end)
swayimg.viewer.on_key("Ctrl-s", function()
   local path = os.getenv("HOME") .. "/Pictures/Swayimg/export-" .. os.date("%Y%m%d%H%M%S") .. ".png"
   os.execute("[[ ! -d ~/Pictures/Swayimg ]] && mkdir -p ~/Pictures/Swayimg")
   swayimg.viewer.export(path)
   os.execute("dms notify swayimg 'image saved as " .. path:match('([^/]+)$') .. "' --timeout 3 --icon " .. path .. " --file " .. path)
end)
swayimg.viewer.on_key("Ctrl+Left", function()
   swayimg.viewer.open("prev")
end)
swayimg.viewer.on_key("Ctrl+Right", function()
   swayimg.viewer.open("next")
end)
swayimg.viewer.on_key("Space", function()
   swayimg.viewer.open("next")
end)
swayimg.viewer.on_key("Delete", function()
   os.execute("gio trash " .. swayimg.viewer.get_image().path)
end)
swayimg.viewer.on_key("Shift+Delete", function()
   os.execute("rm -f " .. swayimg.viewer.get_image().path)
end)

-- Gallery mode
swayimg.gallery.set_thumb_size(200)
swayimg.gallery.limit_cache(100)
swayimg.gallery.set_window_color(0x202020ff)
swayimg.gallery.set_selected_color(0x484848ff)
swayimg.gallery.on_key("Delete", function()
   os.execute("gio trash " .. swayimg.gallery.get_image().path)
end)
swayimg.gallery.on_key("Shift+Delete", function()
   os.execute("rm -f " .. swayimg.gallery.get_image().path)
end)
swayimg.gallery.on_key("Escape", function()
   swayimg.exit()
end)
swayimg.gallery.on_key("q", function()
   swayimg.exit()
end)

-- Slideshow mode
swayimg.slideshow.on_key("Escape", function()
   swayimg.exit()
end)
swayimg.slideshow.on_key("q", function()
   swayimg.exit()
end)

--  mode
swayimg.on_initialized(function()
   if swayimg.imagelist.size() > 1 then
      swayimg.set_mode("gallery")
   else
      swayimg.set_mode("viewer") -- default mode
   end
end)

-- vim: set et sts=3 sw=3:
