import QtQuick 2.0
Text{
    id:r
    property var us: app&&app.us?app.us:unikSettings
    font.family: r.us.fontFamily
    font.pixelSize: app.fs
    color: app.c2
}
