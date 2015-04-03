import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import "global.js" as Global
import "control.js" as Control

Rectangle {
    id: settingPanel

    property int yPos:200
/*
    property alias onlyOne: countingRegime.checked
    property alias enableSeconds: enableSecs.checked
    property alias loadSavedWatches: loadSavedWatches.checked
    property alias defaultName: defaultNameField.text
    property alias theme: themeChoice.currentText   */

    color: Global.currentTheme.settingsPanelColor
    width:400
    state: "SETTINGS_CLOSE"
    height: 150


    function setSettingToPanel() {
       countingRegime.checked = Global.settings.onlyOneRun;
       enableSecs.checked = Global.settings.enableSeconds;
       loadSavedWatches.checked = Global.settings.loadOnStart;
       defaultNameField.text = Global.settings.defName;
       themeChoice.currentIndex = Global.settings.themeNr;
    }


    MouseArea{
        anchors.fill:settingPanel
        onClicked: settingPanel.state = "SETTINGS_CLOSE"
    }

    GridLayout{
        id: grid
        //columns: 2
        //anchors.centerIn:  settingPanel
        rowSpacing: 12
        columnSpacing: 30
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 30

        ColumnLayout{
            anchors.margins: 50

            CheckBox{
                id: countingRegime
                text: "Only one watch can go"
                checked: false;

            }

            CheckBox{
                id: enableSecs
                text: "Enable seconds"
                checked: false;

            }
            CheckBox{
                id: loadSavedWatches
                text: "Load saved watches on start"
                checked: false;

            }
        }

        Column {
            ComboBox {
                id: themeChoice
                model: [Control.whiteThemeName,Control.darkThemeName]

            }

            TextField {
                id: defaultNameField
                text:"Project name"

            }
        }

        MenuButton{
            id: saveButton
            buttonText: "Save"
            Layout.row : 1
            onButtonClick: {
                Control.saveSettings(enableSecs.checked,countingRegime.checked,loadSavedWatches.checked,
                                    themeChoice.currentText,themeChoice.currentIndex,defaultNameField.text);
                Control.writeSettingsToFile();
            }
        }
    }


    states: [
        State {
            name: "SETTINGS_OPEN"
            PropertyChanges {
                target: settingPanel
                y: settingPanel.yPos
            }
        },
        State {
            name: "SETTINGS_CLOSE"
            PropertyChanges {
                target: settingPanel
                y:settingPanel.yPos - settingPanel.height
            }
        }
    ]
    transitions: [
        Transition {
            to: "*"
            NumberAnimation{
                target: settingPanel
                properties: "y"
                duration: 300
                easing.type: Easing.OutExpo
            }

        }
    ]
}

