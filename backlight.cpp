#include "backlight.h"

#include <stdio.h>
#include <stdlib.h>

Backlight::Backlight(QObject *parent) 
	: QObject(parent)
	, m_enabled(false)
{
}

void Backlight::setEnabled(bool e)
{
	if (e == m_enabled)
		return;

	FILE *f = fopen("/sys/class/gpio/gpio18/value", "w");
    if (f) {
        if (e)
            fprintf(f, "1\n");
        else
            fprintf(f, "0\n");
        fclose(f);
    }
    else
    {
        qDebug("Failed to set backlight to %d", e);
    }

	m_enabled = e;
	emit enabledChanged();
}
