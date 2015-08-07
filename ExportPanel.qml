import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.LocalStorage 2.0
import QtQuick.Controls.Styles 1.2
import "global.js" as Global
import "control.js" as Control


Rectangle {
    id: exportPanel

    property int yPos:40
    property var locale: Qt.locale("en_EN")
    property var fromDay: new Date();
    property var toDay: new Date();

    color: Global.currentTheme.mainPanelColor
    width: 400
    state: "ExportPanel_CLOSE"
    height: 50


    function repaint() {
       exportPanel.color = Global.currentTheme.mainPanelColor
    }



    function getDataFromDB(newdate) {
       var db = LocalStorage.openDatabaseSync("ClocksData", "1.0", "The data of clock working", 10001);
       var curDate = "'" + newdate.toLocaleDateString(Qt.locale(),"yyyy-MM-dd")+"'" ;//" '2015-05-25' " ;

       function TimeTaskStruct(name,time) {
            this.name = name
            this.time = time
        }

       var dailyTasks = []

       db.transaction(
           function(tx) {

               var query = "SELECT serialNr,name
                            FROM Data WHERE date= " +curDate +
                           " GROUP BY serialNr,name";

               var rs = tx.executeSql(query);
               var rs2;
               var from,to,timeDiff,totalTime;
               var timeStr;
               for(var i = 0; i < rs.rows.length; i++) {
                   //dailyTasks.length = 0;
                   query = "SELECT startTime,endTime
                            FROM Data WHERE date= " +curDate +
                                   "AND name= '" +rs.rows.item(i).name +"' "+
                                   "AND serialNr = '" + rs.rows.item(i).serialNr + "'";
                   rs2 = tx.executeSql(query);
                   totalTime = 0;
                   for (var j = 0; j<rs2.rows.length; j++) {
                       totalTime += Control.timeDifference(rs2.rows.item(j).startTime,rs2.rows.item(j).endTime);
                   }
                   timeStr = Control.secondsToTime(totalTime);
                   dailyTasks[i] = new TimeTaskStruct(rs.rows.item(i).name, timeStr);

               }

           }
       )

        return dailyTasks;
    }





    MouseArea{
        anchors.fill:exportPanel
        onClicked: exportPanel.state = "SETTINGS_CLOSE"
            //console.log(exportPanel.yPos + "     " + exportPanel.height)}
    }

    Row{
        anchors.left: parent.left
        anchors.leftMargin: 50
        anchors.verticalCenter:  parent.verticalCenter
        spacing: 20

        Text{
            text: "Select period "
            font.pointSize: 11
            color: Global.currentTheme.buttonLabelColor
            function repaint() {
                color = Global.currentTheme.buttonLabelColor
            }

        }

        TextField {
            id: fromDate;
            text: fromDay.toLocaleDateString(locale,"yyyy-MMM-dd")
            font.pixelSize: 15
            horizontalAlignment: TextInput.AlignHCenter
            onActiveFocusChanged: {
                underCalendar.enabled = true;
                calendar.field = fromDate
                calendar.visible = true;
                calendar.focus = true;
              }

        }

        Text{
            text: ":"
            font.pointSize: 11
            color: Global.currentTheme.buttonLabelColor
            function repaint() {
                color = Global.currentTheme.buttonLabelColor
            }


        }

        TextField {
            id: toDate;
            text: toDay.toLocaleDateString(locale,"yyyy-MMM-dd")
            font.pixelSize: 15
            horizontalAlignment: TextInput.AlignHCenter
            onActiveFocusChanged: {
                underCalendar.enabled = true;
                calendar.field = toDate
                calendar.visible = true;
                calendar.focus = true;
              }

        }


    }




    MenuButton {
        id: exportExcelButton
        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.verticalCenter:  parent.verticalCenter
        buttonWidth: 150
        buttonHeigth: 25
        buttonText: "Export to Excel"
        onButtonClick: {
            exportPanel.state = "ExportPanel_CLOSE"
            var nextDay = new Date();
            var partName = "(exported " + nextDay.toLocaleDateString(locale,"yyyy-MMM-dd") + ")";
            nextDay.setDate(fromDay.getDate());

            var dailyTasks = []
            DBExport.createFile();

            do {
                dailyTasks = getDataFromDB(nextDay);
                DBExport.printDate(nextDay.toLocaleDateString(locale,"yyyy-MMM-dd"));
                DBExport.printHeader("Activity","Total time");
                console.log(nextDay);

                for(var i=0;i<dailyTasks.length;++i){
                    console.log(dailyTasks[i].name + "  :  " + dailyTasks[i].time)
                    DBExport.exportTask(dailyTasks[i].name,dailyTasks[i].time)
                }
                DBExport.addLine()
                nextDay.setDate(nextDay.getDate()+1);

            }while(nextDay < toDay)

            DBExport.saveFile("TimeKeeper data" + partName + ".xlsx");

        }
    }



    Calendar {
        id: calendar

        property TextField field : fromDate

        z:5
        x: field.x
        y: field.y+field.height

        selectedDate: new Date()
        visible: false
        frameVisible: true
        focus: true
        style: calendarstyle
        __locale: locale

        onClicked: {
            var previousDate = field.text;
            var currentDate;

            switch (field) {
                case fromDate:    fromDay.setDate(calendar.selectedDate.getDate());
                                  fromDay.setMonth(calendar.selectedDate.getMonth());
                                  fromDay.setYear(calendar.selectedDate.getFullYear());
                                  field.text =   fromDay.toLocaleDateString(locale,"yyyy-MMM-dd");
                                    break;
                case toDate:      toDay.setDate(calendar.selectedDate.getDate());
                                  toDay.setMonth(calendar.selectedDate.getMonth());
                                  toDay.setYear(calendar.selectedDate.getFullYear());
                                  field.text =   toDay.toLocaleDateString(locale,"yyyy-MMM-dd");
                                    break;
            }
            underCalendar.enabled = false;
            calendar.visible = false;

        }
        function repaint(){
            style = nullstyle;
            style = calendarstyle
        }

    }
    property Component calendarstyle: VarCalendarStyle{}
    property Component nullstyle: CalendarStyle{}

    MouseArea{
        //mouse area lies under calendar.It need to catch mouse's click out of calendar
        id:underCalendar
        z:2
        anchors.fill: parent
        enabled: false
        onClicked: {
            enabled = false;
            calendar.visible = false;
        }
    }


    states: [
        State {
            name: "ExportPanel_OPEN"
            PropertyChanges {
                target: exportPanel
                y: exportPanel.yPos
            }
        },
        State {
            name: "ExportPanel_CLOSE"
            PropertyChanges {
                target: exportPanel
                y:exportPanel.yPos - exportPanel.height
            }
        }
    ]
    transitions: [
        Transition {
            to: "*"
            NumberAnimation{
                target: exportPanel
                properties: "y"
                duration: 300
                easing.type: Easing.OutExpo
            }

        }
    ]
}


