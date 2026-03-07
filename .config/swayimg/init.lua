-- default mode
swayimg.set_mode("viewer")
swayimg.enable_decoration(false)
swayimg.imagelist.set_order("alpha")
swayimg.text.set_foreground(0xffff0000)
swayimg.text.set_overall_timer(1000)

-- Viewer mode settings
swayimg.viewer.set_default_scale("optimal")
swayimg.viewer.set_window_background("auto")
swayimg.viewer.set_image_background(0x1c1c1c88)
swayimg.viewer.set_text_tl({
  "File: {name}",
  "Type: {format}",
  "Size: {sizehr}",
})
swayimg.viewer.set_text_tr({
   "{list.index}/{list.total}"
})

swayimg.viewer.on_key("Escape", function()
   swayimg.exit()
end)
swayimg.viewer.on_key("q", function()
   swayimg.exit()
end)
swayimg.viewer.on_key("Ctrl-c", function()
   local file = swayimg.viewer.current_image().path
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
   os.execute("gio trash " .. swayimg.viewer.current_image().path)
end)
swayimg.viewer.on_key("Shift+Delete", function()
   os.execute("rm -f " .. swayimg.viewer.current_image().path)
end)

-- Gallery mode
swayimg.gallery.set_thumb_size(200)
swayimg.gallery.set_cache_size(100)
swayimg.gallery.set_background_color(0x202020ff)
swayimg.gallery.set_selected_color(0x484848ff)
swayimg.gallery.on_key("Delete", function()
   os.execute("gio trash " .. swayimg.gallery.current_image().path)
end)
swayimg.gallery.on_key("Shift+Delete", function()
   os.execute("rm -f " .. swayimg.gallery.current_image().path)
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

-- vim: set et sts=3 sw=3:
