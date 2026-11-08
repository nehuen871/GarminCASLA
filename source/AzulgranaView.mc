import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class AzulgranaView extends WatchUi.WatchFace {
    private var crest;
    private var clockFont;
    private var dataFont;
    private var dateFont;
    private var labelFont;
    private var sleeping = false;

    function initialize() { WatchFace.initialize(); }
    function onLayout(dc) {
        crest = WatchUi.loadResource(Rez.Drawables.Crest);
        clockFont = WatchUi.loadResource(Rez.Fonts.Clock);
        dataFont = WatchUi.loadResource(Rez.Fonts.Data);
        dateFont = WatchUi.loadResource(Rez.Fonts.Date);
        labelFont = WatchUi.loadResource(Rez.Fonts.Label);
    }
    function onEnterSleep() { sleeping = true; WatchUi.requestUpdate(); }
    function onExitSleep() { sleeping = false; WatchUi.requestUpdate(); }

    // The same blue-to-grana gradient applies independently to each value.
    private function gradientText(dc, x, y, font, text) {
        var width = dc.getTextWidthInPixels(text, font);
        var height = dc.getFontHeight(font);
        var left = (x - width / 2).toNumber();
        for (var i = 0; i < 24; i += 1) {
            var t = i.toFloat() / 23;
            var r = (65 + 167 * t).toNumber();
            var g = (145 - 89 * t).toNumber();
            var b = (255 - 162 * t).toNumber();
            var start = (width * i / 24).toNumber();
            var end = (width * (i + 1) / 24).toNumber();
            dc.setClip(left + start, y, end - start, height);
            dc.setColor((r << 16) | (g << 8) | b, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
        }
        dc.clearClip();
    }
    private function rail(dc, x, y, direction, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x, y, x + direction * 28, y);
        dc.drawLine(x + direction * 28, y, x + direction * 38, y + 10);
    }
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var cx = dc.getWidth() / 2;
        var clock = System.getClockTime();
        var hour = clock.hour;
        if (!System.getDeviceSettings().is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }
        var timeLabel = hour.format("%02d") + ":" + clock.min.format("%02d");
        if (sleeping) {
            // No second timer or full-color crest in AMOLED low-power mode.
            var shift = (clock.min % 2 == 0) ? -8 : 8;
            gradientText(dc, cx + shift, 164 + shift, dataFont, timeLabel);
            return;
        }
        gradientText(dc, cx, 28, labelFont, "C A S L A");
        gradientText(dc, cx, 51, clockFont, timeLabel);
        // Garmin calls onUpdate once a second while the watch face is awake.
        gradientText(dc, cx, 125, dataFont, clock.sec.format("%02d"));
        rail(dc, 75, 142, 1, 0x26558D);
        rail(dc, 315, 142, -1, 0x822841);
        dc.drawBitmap(cx - crest.getWidth() / 2, 157, crest);
        rail(dc, 88, 279, 1, 0x26558D);
        rail(dc, 302, 279, -1, 0x822841);
        var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var days = ["DOM", "LUN", "MAR", "MIE", "JUE", "VIE", "SAB"];
        var dateLabel = days[date.day_of_week - 1] + " " +
            date.day.format("%02d") + "/" + date.month.format("%02d");
        gradientText(dc, cx, 302, dateFont, dateLabel);
        gradientText(dc, 135, 330, labelFont, "PASOS");
        gradientText(dc, 255, 330, labelFont, "BATERIA");
        var steps = ActivityMonitor.getInfo().steps;
        var stepLabel = (steps == null) ? "--" : steps.format("%d");
        gradientText(dc, 135, 347, dataFont, stepLabel);
        var battery = System.getSystemStats().battery.toNumber();
        gradientText(dc, 255, 347, dataFont, battery.format("%d") + "%");
        dc.setColor(0x25324A, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(cx, 332, cx, 372);
    }
}
