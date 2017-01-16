using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

var m_or_ft = [
    1.0,        // meters to meters
    3.28084     // meters to feet
];

const km_or_mi = [
    0.001,      // meters to kilometers
    0.000621371 // meters to miles
];

function format_number(value, deviceSettings)
{
    if (value != null) {
        return value.format("%2d");
    }
    else {
        return "--";
    }
}

(:high_memory_device) function format_ascent_or_descent(meters, deviceSettings)
{
    if (meters == null) {
        return "--";
    }
    else {
        // TODO: remove workaround for ConnectIQ bug
        deviceSettings.elevationUnits = deviceSettings.elevationUnits ? 1 : 0;

        var distance = m_or_ft[deviceSettings.elevationUnits] * meters;

        var fmt;
        if (distance < 10) {
            fmt = "%.2f";
        }
        else if (distance < 100) {
            fmt = "%.1f";
        }
        else {
            fmt = "%d";
        }

        return distance.format(fmt);
    }
}

class Number
{
    hidden var _M_name;

    function initialize() {
        _M_name = Ui.loadResource(Rez.Strings.LapAbbr);
    }

    function format(info, deviceSettings) {
        return format_number(info.lapNumber, deviceSettings);
    }

    function description() {
        return _M_name;
    }

    function dimensions(dc, font) {
        return dc.getTextWidthInPixels("99", font);
    }
}

class Distance
{
    hidden var _M_name;

    function initialize() {
        _M_name = Ui.loadResource(Rez.Strings.DistanceAbbr);
    }

    function format(info, deviceSettings) {

        if (info.elapsedDistance == null) {
            return "--";
        }
        else {
            // TODO: remove workaround for ConnectIQ bug
            deviceSettings.distanceUnits = deviceSettings.distanceUnits ? 1 : 0;

            var distance = km_or_mi[deviceSettings.distanceUnits] * info.elapsedDistance;

            var fmt;
            if (distance < 10) {
                fmt = "%.2f";
            }
            else if (distance < 100) {
                fmt = "%.1f";
            }
            else {
                fmt = "%d";
            }

            return distance.format(fmt);
        }
    }

    function description() {
        return _M_name;
    }

    function dimensions(dc, font) {
        return dc.getTextWidthInPixels("9.99", font);
    }
}

class Time
{
    hidden var _M_name;

    function initialize() {
        _M_name = Ui.loadResource(Rez.Strings.TimeAbbr);
    }

    function format(info, deviceSettings) {
        if (info.elapsedTime == null) {
            return "-:--";
        }

        var seconds = info.elapsedTime / 1000;

        var hh = seconds / 3600;
        var mm = seconds / 60 % 60;
        var ss = seconds % 60;

        if (hh != 0) {
            return Lang.format("$1$:$2$:$3$", [
                                   hh,
                                   mm.format("%02d"),
                                   ss.format("%02d")
                               ]);
        }
        else {
            return Lang.format("$1$:$2$", [
                                   mm,
                                   ss.format("%02d")
                               ]);
        }
    }

    function description() {
        return _M_name;
    }

    function dimensions(dc, font) {
        return dc.getTextWidthInPixels("9:99:99", font);
    }
}

class Speed
{
    hidden var _M_name;

    function initialize() {
        _M_name = Ui.loadResource(Rez.Strings.SpeedAbbr);
    }

    function format(info, deviceSettings) {

        if (info.elapsedDistance == null ||
            info.elapsedTime == null ||
            info.elapsedTime < 1000) {
            return "-.--";
        }

        var seconds = info.elapsedTime / 1000.0;

        // TODO: remove workaround for ConnectIQ bug
        deviceSettings.paceUnits = deviceSettings.paceUnits ? 1 : 0;

        var distance = km_or_mi[deviceSettings.paceUnits] * info.elapsedDistance;

        var speed = distance / (seconds / 3600.0);

        var fmt;
        if (speed < 10) {
            fmt = "%.2f";
        }
        else if (speed < 100) {
            fmt = "%.1f";
        }
        else {
            fmt = "%d";
        }

        return speed.format(fmt);
    }

    function description() {
        return _M_name;
    }

    function dimensions(dc, font) {
        return dc.getTextWidthInPixels("99.9", font);
    }
}

class Pace
{
    hidden var _M_name;

    function initialize() {
        _M_name = Ui.loadResource(Rez.Strings.PaceAbbr);
    }

    function format(info, deviceSettings) {

        if (info.elapsedDistance == null ||
            info.elapsedTime == null ||
            info.elapsedDistance < 3) {
            return "-:--";
        }

        var seconds = info.elapsedTime / 1000.0;

        // TODO: remove workaround for ConnectIQ bug
        deviceSettings.paceUnits = deviceSettings.paceUnits ? 1 : 0;

        var distance = km_or_mi[deviceSettings.paceUnits] * info.elapsedDistance;

        // seconds is now seconds per distance
        seconds = (seconds / distance).toNumber();

        var mm = seconds / 60;
        var ss = seconds % 60;

        return Lang.format("$1$:$2$", [
                               mm,
                               ss.format("%02d")
                           ]);
    }

    function description() {
        return _M_name;
    }

    function dimensions(dc, font) {
        return dc.getTextWidthInPixels("99:99", font);
    }
}

(:high_memory_device) class Ascent
{
    hidden var _M_name;

    function initialize() {
        _M_name = Ui.loadResource(Rez.Strings.AscentAbbr);
    }

    function format(info, deviceSettings) {
        return format_ascent_or_descent(info.totalAscent, deviceSettings);
    }

    function description() {
        return _M_name;
    }

    function dimensions(dc, font) {
        return dc.getTextWidthInPixels("999", font);
    }
}

(:high_memory_device) class Descent
{
    hidden var _M_name;

    function initialize() {
        _M_name = Ui.loadResource(Rez.Strings.DescentAbbr);
    }

    function format(info, deviceSettings) {
        return format_ascent_or_descent(info.totalDescent, deviceSettings);
    }

    function description() {
        return _M_name;
    }

    function dimensions(dc, font) {
        return dc.getTextWidthInPixels("999", font);
    }
}

(:high_memory_device) class Calories
{
    hidden var _M_name;

    function initialize() {
        _M_name = Ui.loadResource(Rez.Strings.CaloriesAbbr);
    }

    function format(info, deviceSettings) {
        return format_number(info.calories, deviceSettings);
    }

    function description() {
        return _M_name;
    }

    function dimensions(dc, font) {
        return dc.getTextWidthInPixels("999", font);
    }
}

var _M_formats;

class Model
{
    class Lap
    {
        var lapNumber;
        var elapsedTime;
        var elapsedDistance;
        (:high_memory_device) var totalAscent;
        (:high_memory_device) var totalDescent;
        (:high_memory_device) var calories;

        function initialize() {
            // values are initially null already
        }

        function toString() {
            return Lang.format("Lap time=$1$", [ elapsedTime ]);
        }

        function reset() {
            lapNumber = null;
            elapsedTime = null;
            elapsedDistance = null;

            aux_reset();
        }

        (:high_memory_device) hidden function aux_reset() {
            totalAscent = null;
            totalDescent = null;
            calories = null;
        }

        (:low_memory_device) hidden function aux_reset() {
            // do nothing
        }

        function zero() {
            lapNumber = 1;
            elapsedTime = 0;
            elapsedDistance = 0;

            aux_zero();
        }

        (:high_memory_device) hidden function aux_zero() {
            calories = 0;
            totalAscent = 0;
            totalDescent = 0;
        }

        (:low_memory_device) hidden function aux_zero() {
            // do nothing
        }

        function assign(info) {
            elapsedTime = info.elapsedTime;
            elapsedDistance = info.elapsedDistance;

            aux_assign(info);
        }

        (:high_memory_device) hidden function aux_assign(info) {
            calories = info.calories;
            totalAscent = info.totalAscent;
            totalDescent = info.totalDescent;
        }

        (:low_memory_device) hidden function aux_assign(info) {
        }

        function minus_assign_field(field, rhs) {
            var lval = self[field];
            var rval = rhs [field];

            var result = null;
            if (lval != null) {

                if (rval != null) {
                    result = lval - rval;
                }
                else {
                    result = lval;
                }
            }

            self[field] = result;
        }

        function plus_assign_field(field, rhs) {
            var lval = self[field];
            var rval = rhs [field];

            var result = null;
            if (lval != null) {

                if (rval != null) {
                    result = lval + rval;
                }
                else {
                    result = lval;
                }

            }
            else if (rval != null) {
                result = rval;
            }

            self[field] = result;
        }

        function minus_assign(rhs) {
            minus_assign_field(:elapsedTime, rhs);
            minus_assign_field(:elapsedDistance, rhs);

            aux_minus_assign(rhs);
        }

        (:high_memory_device) hidden function aux_minus_assign(rhs) {
            minus_assign_field(:calories, rhs);
            minus_assign_field(:totalAscent, rhs);
            minus_assign_field(:totalDescent, rhs);
        }

        (:low_memory_device) hidden function aux_minus_assign(rhs) {
        }

        function plus_assign(rhs) {
            plus_assign_field(:elapsedTime, rhs);
            plus_assign_field(:elapsedDistance, rhs);

            aux_plus_assign(rhs);
        }

        (:high_memory_device) hidden function aux_plus_assign(rhs) {
            plus_assign_field(:calories, rhs);
            plus_assign_field(:totalAscent, rhs);
            plus_assign_field(:totalDescent, rhs);
        }

        (:low_memory_device) hidden function aux_plus_assign(rhs) {
        }
    }

    hidden var _M_paused;

    // accumulated lap data at the most recent pause
    hidden var _M_a_lap;

    // lap data at the most recent resume
    hidden var _M_p_lap;

    // the lap data presented to the user
    hidden var _M_laps;

    // index of the current lap in _M_laps
    hidden var _M_off;

    function initialize() {
    }

    function onStart() {
        _M_off = 0;

        _M_laps = device_allocateLaps();
        for (var i = 0; i < _M_laps.size(); ++i) {
            _M_laps[i] = new Lap();
        }

        _M_a_lap = new Lap();
        _M_a_lap.zero();

        _M_p_lap = new Lap();

        _M_laps[_M_off].zero();

        //self.reset();
    }

    function onStop() {
        _M_laps = null;
        _M_a_lap = null;
        _M_p_lap = null;
    }

    function onTimerLap(info) {
        if (_M_paused) {

            // just store the accumulated value prior to pausing
            _M_laps[_M_off].assign(_M_a_lap);

        }
        else {

            _M_laps[_M_off].assign(info);

            // cacluate elapsed values since most recent pause
            _M_laps[_M_off].minus_assign(_M_p_lap);

            // accumulate the previous sums
            _M_laps[_M_off].plus_assign(_M_a_lap);

            // cache the last known values
            _M_p_lap.assign(info);
        }

        _M_a_lap.zero();

        var number = _M_laps[_M_off].lapNumber;
        _M_off = (_M_off + 1) % _M_laps.size();

        _M_laps[_M_off].zero();
        _M_laps[_M_off].lapNumber = number + 1;
    }

    function onTimerPause(info) {
        self.suspend(info);
    }

    function onTimerResume(info) {
        self.resume(info);
    }

    function onTimerReset(info) {
        _M_off = 0;

        for (var i = 1; i < _M_laps.size(); ++i) {
            _M_laps[i].reset();
        }

        _M_lap[_M_off].zero();

        _M_a_lap.reset();
        _M_p_lap.reset();
    }

    function onTimerStart(info) {
        self.resume(info);
    }

    function onTimerStop(info) {
        self.suspend(info);
    }

    function compute(info) {

        if (_M_paused == null) {
            _M_paused = (info.timerState != Activity.TIMER_STATE_ON);
        }

        if (_M_paused) {

            // just store the accumulated value prior to pausing
            _M_laps[_M_off].assign(_M_a_lap);

        }
        else {

            _M_laps[_M_off].assign(info);

            // cacluate elapsed values since most recent pause
            _M_laps[_M_off].minus_assign(_M_p_lap);

            // accumulate the previous sums
            _M_laps[_M_off].plus_assign(_M_a_lap);
        }
    }

    hidden function suspend(info) {
        _M_paused = true;

        //
        // add the values since the last snapshot to the
        // accumulator, and then update our snapshot
        //

        var delta = new Lap();
        delta.assign(info);

        delta.minus_assign(_M_p_lap);

        _M_a_lap.plus_assign(delta);
        _M_p_lap.reset();
    }

    hidden function resume(info) {
        _M_paused = false;
        _M_p_lap.assign(info);
    }

    hidden function reset(info) {
        _M_a_lap.zero();
        _M_p_lap.reset();
    }

    function getLapCount() {
        return _M_laps.size();
    }

    function getLap(index) {
        var count = _M_laps.size();
        return _M_laps[ (_M_off + count - index) % count ];
    }

    (:round_218x218) hidden function device_allocateLaps() {
        return new [ 6 ];
    }

    (:round_240x240) hidden function device_allocateLaps() {
        return new [ 5 ];
    }

    (:semiround_215x180) hidden function device_allocateLaps() {
        return new [ 5 ];
    }

    (:rectangle_205x148) hidden function device_allocateLaps() {
        return new [ 8 ];
    }

    (:rectangle_240x400) hidden function device_allocateLaps() {
        return new [ 17 ];
    }

    (:rectangle_200x265) hidden function device_allocateLaps() {
        return new [ 11 ];
    }


}

class MyView extends Ui.DataField
{
    hidden var _M_rows; // number of rows
    hidden var _M_cols; // array of type ids

    function initialize() {
        DataField.initialize();
    }

    hidden var _M_model;

    function setModel(model) {
        _M_model = model;
    }

    function onTimerStart() {
        var info = Activity.getActivityInfo();
        _M_model.onTimerStart(info);
    }

    function onTimerStop() {
        var info = Activity.getActivityInfo();
        _M_model.onTimerStop(info);
    }

    function onTimerPause() {
        var info = Activity.getActivityInfo();
        _M_model.onTimerPause(info);
    }

    function onTimerResume() {
        var info = Activity.getActivityInfo();
        _M_model.onTimerResume(info);
    }

    function onTimerReset() {
        var info = Activity.getActivityInfo();
        _M_model.onTimerReset(info);
    }

    function onTimerLap() {
        var info = Activity.getActivityInfo();
        _M_model.onTimerLap(info);
    }

    function compute(info) {
        _M_model.compute(info);
    }

    var _M_font;
    var _M_offs;

    var locX;
    var locY;
    var width;

    function onLayout(dc) {
        //Sys.println("onLayout");

        //_M_cols = App.getApp().getProperty("cols");
        //if (_M_cols == null) {
        _M_cols = 4;
        //}

        _M_offs = new [ _M_cols ];
        _M_cols = new [ _M_cols ];

        // figure out the data format for each column

        for (var i = 0; i < _M_cols.size(); ++i) {
            var type = App.getApp().getProperty(Lang.format("col$1$", [ i ]));
            if (type == null) {
                type = i;
            }

            _M_cols[i] = new _M_formats[type]();
        }

        // device-specific stuff. this would normally come from a layout, but
        // layouts eat up tons of memory.
        _M_rows = _M_model.getLapCount();

        var details = device_details(dc);
        _M_font = details[0];
        locX = details[1];
        locY = details[2];
        width = dc.getWidth() - (locX * 2);

        var twidth = 0;
        for (var i = 0; i < _M_cols.size(); ++i) {
            // maximum width of field in a normal scenario
            var fwidth = _M_cols[i].dimensions(dc, _M_font);

            // width of the column text label
            var header = _M_cols[i].description();
            var hwidth = dc.getTextWidthInPixels(header, _M_font);

            // pick the bigger of the two
            if (fwidth < hwidth) {
                fwidth = hwidth;
            }

            _M_offs[i] = twidth + (fwidth / 2);
            twidth += fwidth;
        }

        for (var i = 0; i < _M_cols.size(); ++i) {
            _M_offs[i] = locX + (width * _M_offs[i] / twidth);
        }

        return true;
    }

    (:round_218x218) hidden function device_details(dc) {
        return [ Gfx.FONT_SYSTEM_TINY, 15, 45 ];
    }

    (:round_240x240) hidden function device_details(dc) {
        return [ Gfx.FONT_SYSTEM_TINY, 20, 45 ];
    }

    (:semiround_215x180) hidden function device_details(dc) {
        return [ Gfx.FONT_SYSTEM_MEDIUM, 15, 30 ];
    }

    (:rectangle_205x148) hidden function device_details(dc) {
        return [ Gfx.FONT_SYSTEM_MEDIUM, 0, 0 ];
    }

    (:rectangle_240x400) hidden function device_details(dc) {
        if (dc.getWidth() == 400) {
            return [ Gfx.FONT_SYSTEM_LARGE, 0, 0 ];
        }
        else {
            return [ Gfx.FONT_SYSTEM_MEDIUM, 0, 0 ];
        }
    }

    (:rectangle_200x265) hidden function device_details(dc) {
        if (dc.getWidth() == 265) {
            return [ Gfx.FONT_SYSTEM_LARGE, 0, 0 ];
        }
        else {
            return [ Gfx.FONT_SYSTEM_MEDIUM, 0, 0 ];
        }
    }

    function onUpdate(dc) {
        //Sys.println("onUpdate");

        if (_M_offs == null) {
            onLayout(dc);
        }

        var bgcolor = getBackgroundColor();

        dc.setColor(~bgcolor & 0x0FFF, bgcolor);
        dc.clear();

        var deviceSettings = Sys.getDeviceSettings();

        var dy = dc.getFontHeight(_M_font);

        var ty = locY;
        var by = dc.getHeight() - locY - dy;

        for (var i = 0; i < _M_cols.size(); ++i) {
            var s = _M_cols[i].description();
            dc.drawText(_M_offs[i], ty, _M_font, s, Gfx.TEXT_JUSTIFY_CENTER);
        }

        ty += dy;

        for (var i = 0; i < _M_rows; ++i) {
            var info = _M_model.getLap(i);

            for (var j = 0; j < _M_cols.size(); ++j) {
                var s = _M_cols[j].format(info, deviceSettings);
                dc.drawText(_M_offs[j], ty, _M_font, s, Gfx.TEXT_JUSTIFY_CENTER);
            }

            ty += dy;

            // if we would draw below the bottom
            if (by < ty) {
                break;
            }
        }

        //Sys.println("done.");
    }

    function onSettingsChanged() {
        _M_offs = null; // force onLayout to get called
    }
}

class LapsApp extends App.AppBase
{
    function initialize() {
        AppBase.initialize();
    }

    hidden function register_formats() {
        _M_formats = [
            $.Number,
            $.Time,
            $.Distance,
            $.Pace,
            $.Speed
        ];

        aux_register_formats();
    }

    hidden function deregister_formats() {
        _M_formats = null;
    }

    (:high_memory_device) hidden function aux_register_formats() {
        _M_formats.addAll([
            $.Ascent,
            $.Descent,
            $.Calories
        ]);
    }

    (:low_memory_device) hidden function aux_register_formats() {
    }

    hidden var _M_model;

    function onStart(params) {
        register_formats();

        _M_model = new Model();
        _M_model.onStart();
    }

    function onStop(params) {
        _M_model.onStop();
        _M_model = null;

        deregister_formats();
    }

    hidden var _M_view;

    function onSettingsChanged() {
        _M_view.onSettingsChanged();
    }

    function getInitialView() {
        _M_view = new MyView();
        _M_view.setModel(_M_model);

        return [ _M_view ];
    }
}
