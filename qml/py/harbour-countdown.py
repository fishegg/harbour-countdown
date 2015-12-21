#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Created on 2015年11月5日

@author: 0312birdzhang
'''
import time
import os
import sqlite3
import hashlib
import datetime
import dbus

#/usr/share/lipstick/notificationcategories
bus = dbus.SessionBus()
noobject = bus.get_object('org.freedesktop.Notifications','/org/freedesktop/Notifications')
interface = dbus.Interface(noobject,'org.freedesktop.Notifications')
#print(interface.GetCapabilities())
XDG_DATA_HOME="/home/nemo/.local/share"

__appName="harbour-countdown"

DbPath=os.path.join(XDG_DATA_HOME, __appName,__appName, "QML","OfflineStorage","Databases")


def getDbname():
    h = hashlib.md5()
    h.update("days".encode(encoding='utf_8', errors='strict'))
    dbname=h.hexdigest()
    return DbPath+"/"+dbname+".sqlite"


def parseTime(year,month,day):
    return datetime.datetime(year,month,day)

"""
提醒
"""
def notify(title):
    interface.Notify("Countdown",
                 0,
                 "/usr/share/icons/hicolor/86x86/apps/harbour-countdown.png",
                 str(title),
                 "Countdown notification",
                 dbus.Array(),
                 dbus.Dictionary({"desktop-entry":"/usr/share/applications/harbour-countdown.desktop",
				 "x-nemo-preview-body": "Countdown notification",
                                  "x-nemo-preview-summary":str(title) },
                                  signature='sv'),
                 60)

def diffDays(date):
    now = datetime.datetime.now()
    diff = date - now
    days = diff.days
    if days >= 0 and days < 1:
        return True
    else:
        return False

def getDatas():
    try:
        conn = sqlite3.connect(getDbname())
        cur = conn.cursor()
        cur.execute('SELECT * FROM day')
        for i in cur.fetchall():
            date = parseTime(int(i[3]),int(i[4]),int(i[5]))
            if diffDays(date):
                notify(i[1])
    except Exception as e:
        return
    conn.close()


if __name__ == "__main__":
    getDatas()
