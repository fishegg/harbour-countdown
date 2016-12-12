#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QQuickItem>
#include <QSettings>
#include <QString>


class Settings : public QObject
{
    Q_OBJECT
    Q_ENUMS(date_format)
    Q_ENUMS(seperator_type)
    //Q_PROPERTY(date_format format READ get_date_format)
    QSettings* settings;

public:
    explicit Settings(QObject *parent = 0);

    enum date_format {
        System_locale_short,
        System_locale,
        YYYYMMDD,
        DDMMYYYY,
        MMDDYYYY
    };

    enum seperator_type {
        Period,
        Slash,
        Hhyphen
    };

    date_format int_to_date_format(int i);
    seperator_type int_to_seperator_type(int i);

    Q_INVOKABLE void set_date_format(date_format f);
    Q_INVOKABLE void set_seperator_type(seperator_type s);

    Q_INVOKABLE int get_date_format();
    Q_INVOKABLE int get_seperator_type();
signals:

public slots:
};

#endif // SETTINGS_H
