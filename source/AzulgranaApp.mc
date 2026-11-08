import Toybox.Application;
import Toybox.WatchUi;
class AzulgranaApp extends Application.AppBase {
    function initialize() { AppBase.initialize(); }
    function getInitialView() { return [new AzulgranaView()]; }
}
