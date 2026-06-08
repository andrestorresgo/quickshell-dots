#!/bin/bash

# Check network
net_type="none"
net_state="disconnected"
net_signal=0
net_ssid=""
net_text="OFFLINE"
net_icon="wifi_off"

device_info=$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device | grep -E ":(connected|connecting)" 2>/dev/null)

if [ -n "$device_info" ]; then
    dev_name=$(echo "$device_info" | head -n1 | cut -d: -f1)
    dev_type=$(echo "$device_info" | head -n1 | cut -d: -f2)
    dev_state=$(echo "$device_info" | head -n1 | cut -d: -f3)
    dev_conn=$(echo "$device_info" | head -n1 | cut -d: -f4)
    
    if [ "$dev_type" = "wifi" ]; then
        net_type="wifi"
        net_state="$dev_state"
        wifi_info=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep "^yes:" | head -n1 2>/dev/null)
        if [ -n "$wifi_info" ]; then
            net_ssid=$(echo "$wifi_info" | cut -d: -f2)
            net_signal=$(echo "$wifi_info" | cut -d: -f3)
        fi
        net_text="${net_signal}%"
        
        if [ -z "$net_signal" ] || [ "$net_signal" -eq 0 ]; then
            net_icon="wifi_off"
        elif [ "$net_signal" -lt 25 ]; then
            net_icon="wifi_1_bar"
        elif [ "$net_signal" -lt 50 ]; then
            net_icon="wifi_2_bar"
        elif [ "$net_signal" -lt 75 ]; then
            net_icon="wifi"
        else
            net_icon="wifi"
        fi
    elif [ "$dev_type" = "ethernet" ]; then
        net_type="ethernet"
        net_state="$dev_state"
        net_text="ONLINE"
        net_icon="lan"
    fi
fi

bt_enabled=false
bt_connected=false
bt_devices_count=0
bt_device_name=""
bt_icon="bluetooth_disabled"
bt_text="OFF"

if systemctl is-active --quiet bluetooth 2>/dev/null; then
    if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
        bt_enabled=true
        bt_icon="bluetooth"
        bt_text="ON"
        
        connected_devices=$(bluetoothctl devices Connected 2>/dev/null)
        if [ -n "$connected_devices" ]; then
            bt_connected=true
            bt_devices_count=$(echo "$connected_devices" | wc -l)
            bt_device_name=$(echo "$connected_devices" | head -n1 | cut -d' ' -f3-)
            bt_icon="bluetooth_connected"
            bt_text="CONNECTED"
        fi
    fi
fi

if ! [[ "$net_signal" =~ ^[0-9]+$ ]]; then
    net_signal=0
fi

if ! [[ "$bt_devices_count" =~ ^[0-9]+$ ]]; then
    bt_devices_count=0
fi

net_ssid=$(echo -n "$net_ssid" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
bt_device_name=$(echo -n "$bt_device_name" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')

cat <<EOF
{
  "network": {
    "type": "$net_type",
    "state": "$net_state",
    "signal": $net_signal,
    "ssid": "$net_ssid",
    "icon": "$net_icon",
    "text": "$net_text"
  },
  "bluetooth": {
    "enabled": $bt_enabled,
    "connected": $bt_connected,
    "devices_count": $bt_devices_count,
    "device_name": "$bt_device_name",
    "icon": "$bt_icon",
    "text": "$bt_text"
  }
}
EOF

