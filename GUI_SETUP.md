### <p align="center"> **Using desktop** </p>

# VNC Me GUI Chalane Ke Liye
1. PlayStore se Koi Bhi VNC VIEWER App Dounload Kare 
2. Termux Open Kare 
3. Termux Me Ubuntu Start Kare 'ubuntu' Tupe Kar Ke Enter Press Kare (Ab Aap Ubuntu Ke andar Hai)
4. Ubuntu Me 'vncstart' Type Kar Ke Enter Dabaye (VNC Server Start Ho Chuka Hai)
5. Vnc Viewer App Ko Open Kare
6. '+' Plus icone Pe Click Kare
7. Address Me 'localhost:5901' Type Kare, Name App Koi bhi Rakh Sakte Hai
8. Password Dale Jo Aap Ne Ubuntu Install Karte Wakt Dala Tha 

# Termux:X11 Me GUI Chalane Ke Liye
1. Yaha Se [github](https://github.com/termux/termux-x11/releases/latest) Termux-x11 Apk install kare
2. Termux me Termux-X11 Ke Package Install Kare:

```bash
pkg update && pkg install x11-repo -y
```
```bash
pkg install termux-x11 -y
```

3. termux.properties me Allow external apps ko true Kar De Niche Ke Command Termux Me Run Kar Ke
```bash
sed -i s/'# allow-external-apps = true'/'allow-external-apps = true'/g ~/.termux/termux.properties
```

***Ab Termux Ko Restart Kare***

4. Ab Termux Me Niche Diye Gaye Commands Run Kar Ke Termux-X11 Start Kare
```bash
termux-x11 :1 &
```
```bash
ubuntu --shared-tmp
```

5. Ab Display Start Kare
```bash
export DISPLAY=:1
```
```bash
export PULSE_SERVER=127.0.0.1
```

- **Agar Aap Ne XFCE Install Kiya HAi To XFCE Desktop Start Kare** 
```bash
startxfce4
```

- **Agar Aap Ne CINNAMON Install Kiya HAi To CINNAMON Desktop Start Kare**
```bash
service dbus start
```
```bash
dbus-launch cinnamon-session
```
- **Termux-X11 App Khole Aap Ka Desktop Start Ho Chuka Hai**
 
