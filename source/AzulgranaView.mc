import Toybox.Graphics;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class AzulgranaView extends WatchUi.WatchFace {
    private var background;
    private var sleeping = false;
    function initialize() { WatchFace.initialize(); }
    function onLayout(dc) {
        background = WatchUi.loadResource(Rez.Drawables.Background);
    }
    function onEnterSleep() { sleeping = true; WatchUi.requestUpdate(); }
    function onExitSleep() { sleeping = false; WatchUi.requestUpdate(); }
    // Horizontal blue-to-grana gradient, clipped to each text stripe.
    private function gradientText(dc, x, y, font, text) {
        var width = dc.getTextWidthInPixels(text, font);
        var height = dc.getFontHeight(font);
        var left = (x - width / 2).toNumber();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + 1, y + 2, font, text, Graphics.TEXT_JUSTIFY_CENTER);
        var bands = 24;
        for (var i = 0; i < bands; i += 1) {
            var t = i.toFloat() / (bands - 1);
            // Bright endpoints preserve legibility on the dark navy panels.
            var r = (65 + (232 - 65) * t).toNumber();
            var g = (145 + (56 - 145) * t).toNumber();
            var b = (255 + (93 - 255) * t).toNumber();
            var start = (width * i / bands).toNumber();
            var end = (width * (i + 1) / bands).toNumber();
            dc.setClip(left + start, y, end - start, height);
            dc.setColor((r << 16) | (g << 8) | b, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
        }
        dc.clearClip();
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
        var label = hour.format("%02d") + ":" + clock.min.format("%02d");
        if (sleeping) {
            // Black AMOLED background; alternate position each minute.
            var shift = (clock.min % 2 == 0) ? -8 : 8;
            gradientText(dc, cx + shift, 158 + shift, Graphics.FONT_LARGE, label);
            return;
        }
        dc.setColor(0x071426, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, 390, 390);
        // Original aspect ratio: 390 x 244. Crest remains fully visible.
        dc.drawBitmap(0, 94, background);
        dc.setColor(0x071426, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, 0, 390, 94);
        dc.fillRectangle(0, 314, 390, 76);
        dc.setColor(0xD71939, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(110, 89, 170, 3);
        gradientText(dc, cx, 31, Graphics.FONT_NUMBER_HOT, label);
        var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var days = ["DOM", "LUN", "MAR", "MIE", "JUE", "VIE", "SAB"];
        var dateLabel = days[date.day_of_week - 1] + " " +
            date.day.format("%02d") + "/" + date.month.format("%02d");
        gradientText(dc, cx, 316, Graphics.FONT_SMALL, dateLabel);
        var battery = System.getSystemStats().battery.toNumber();
        gradientText(dc, cx, 356, Graphics.FONT_XTINY,
            "BAT " + battery.format("%d") + "%");
    }
}
