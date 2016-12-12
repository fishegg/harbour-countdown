#include "settings.h"
#include <qdebug.h>

    Settings::Settings(QObject *parent) {
        settings = new QSettings("harbour-countdown","harbour-countdown");
    }

    void Settings::set_date_format(date_format f) {
        settings->setValue(QString("Date_format"),QVariant(f));
    }

    void Settings::set_seperator_type(seperator_type s) {
        settings->setValue(QString("Date_seperator"),QVariant(s));
    }

    int Settings::get_date_format() {
        return settings->value(QString("Date_format"),QVariant(0)).toInt();
    }

    int Settings::get_seperator_type() {
        return settings->value(QString("Date_seperator"),QVariant(0)).toInt();
    }

