#ifndef BACKLIGHT_H
#define BACKLIGHT_H

#include <QObject>

class Backlight : public QObject
{
	Q_OBJECT

	Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)

public:
	Backlight(QObject *parent = nullptr);

	bool isEnabled() const { return m_enabled; }

public slots:
	void setEnabled(bool);

signals:
	void enabledChanged();

private:
	bool m_enabled;
};

#endif // BACKLIGHT_H
