local wezterm = require 'wezterm';
return {
    font = wezterm.font("IBM Plex Mono Text"),
    font_size = 15.0,
    color_scheme = "Dracula+",
    keys = {
        -- This will create a new split and run your default program inside it
        {key="s", mods="CTRL|SHIFT",
        action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},
        -- This will create a new split and run your default program inside it
        {key="v", mods="CTRL|SHIFT",
        action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
        {key="{", mods="CTRL|SHIFT", action=wezterm.action{ActivateTabRelative=-1}},
        {key="}", mods="CTRL|SHIFT", action=wezterm.action{ActivateTabRelative=1}},
        { key = "h", mods="CTRL|SHIFT",
        action=wezterm.action{ActivatePaneDirection="Left"}},
        { key = "l", mods="CTRL|SHIFT",
        action=wezterm.action{ActivatePaneDirection="Right"}},
        { key = "k", mods="CTRL|SHIFT",
        action=wezterm.action{ActivatePaneDirection="Up"}},
        { key = "j", mods="CTRL|SHIFT",
        action=wezterm.action{ActivatePaneDirection="Down"}},
    }
}
