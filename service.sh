#!/system/bin/sh
#MODDIR=${0%/*}
MODDIR="$(dirname $(readlink -f "$0"))"
MAGISKBB='/data/adb/magisk/busybox'

# 等待启动完成
until [ "$(getprop sys.boot_completed)" -eq 1 ]; do
  sleep 1
done

# 检测 cron 模块
if [ -x ${MODDIR}/files/bin/busybox/busybox_${F_ARCH} ]; then
  ${MODDIR}/files/bin/busybox/busybox_${F_ARCH} --install -s ${MODDIR}/files/bin/busybox
elif [ -x ${MAGISKBB} ]; then
  ${MAGISKBB} --install -s ${MODDIR}/files/bin/busybox
elif [ -n "$(command -v busybox)" ]; then
  findbb=$(command -v busybox)
  ${findbb} --install -s ${MODDIR}/files/bin/busybox
fi

export PATH=${MODDIR}/files/bin/busybox:$PATH

# 要监听的应用包名
APP_PACKAGE_NAME="com.example.yourapp"

# 你要检测的WiFi SSID
TARGET_WIFI_SSID="360"

# 检查WiFi状态的函数
check_wifi_status() {
  # 获取WiFi状态信息
  wifi_status=$(cmd wifi status)

  # 检查是否有 "Wi-Fi is connected to"
  if echo "$wifi_status" | grep -q "Wi-Fi is connected to"; then
    # 获取连接的SSID
    connected_ssid=$(echo "$wifi_status" | grep "Wi-Fi is connected to" | awk -F "to " '{print $2}')

    if [ "$connected_ssid" = "$TARGET_WIFI_SSID" ]; then
      # 已连接到指定WiFi，关闭应用
      am force-stop $APP_PACKAGE_NAME
    else
      # 连接的不是目标WiFi，启动应用
      am start -n $APP_PACKAGE_NAME/.MainActivity
    fi
  else
    # WiFi未连接或WiFi关闭，启动应用
    am start -n $APP_PACKAGE_NAME/.MainActivity
  fi
}

# 无限循环监控WiFi状态
while true; do
  check_wifi_status
  sleep 5  # 每5秒检查一次
done
