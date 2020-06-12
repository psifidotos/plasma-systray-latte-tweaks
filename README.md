# Plasma SysTray Tweaks for Latte

Plasma systray is too important to be forked and maintained and this is why I am not taking up this task. On the other hand there is no real reason to not present some Latte specific optimisations. All the changes and improvements introduced are only in qml side and as such it might be easier to maintain when plasma system tray evolves between different plasma versions. The reasons that these tweaks were needed are the following:

* Plasma systray is not using the Latte AutoColoring introduced with v0.9 and as such all applets in the systray are painted with no exceptions. With these tweaks the user can now choose which applets/tasks will be auto-colored in the systray or not; by default all applets are auto-colored
* As a gift, an icons spacing option is included that can be accessed from systray setttings -> Appearance tab

<p align="center">
<img src="https://i.imgur.com/NBjthiP.gif" width="530"><br/>
<i>systray auto-coloring demonstration</i>
</p>

<p align="center">
<img src="https://i.imgur.com/rVKoCM8.png" width="580"><br/>
<i>Auto-Color option</i>
</p>

<p align="center">
<img src="https://i.imgur.com/F6F8wBJ.png" width="580"><br/>
<i>icons margin in Apperance tab</i>
</p>


# Install

1. Copy folders `org.kde.plasma.systemtray` and `org.kde.plasma.private.systemtray` at your user folder: `~/.local/share/plasma/plasmoids`
2. Restart Latte


# Update

1. Replace folders the two folders installed at `~/.local/share/plasma/plasmoids` with their newer counter parts
2. Restart Latte


# Remove

1. Remove the two installed folders from your `~/.local/share/plasma/plasmoids` folder
2. Restart Latte


# Maintenance

* The current code is using Plasma v5.18 and I will try to update it when new plasma versions are released with changes in their QML code. That means of course that any improvements in plasma qml code will not be available if you dont remove the **tweaks** or update with newer versions of tweaked files. So use these with care and in the case that your systray breaks just remove the **tweaks**. 
* If someone wants to check out what the tweaks are changing for safety reasons etc, the [tweaks](https://github.com/psifidotos/plasma-systray-latte-tweaks/commits/tweaks) branch holds all the relevant commits.
