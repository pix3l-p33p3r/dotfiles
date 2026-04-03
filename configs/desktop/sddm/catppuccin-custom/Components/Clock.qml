import QtQuick 2.15

Column {
  id: clockContainer
  spacing: 5
  anchors {
    margins: 10
    top: parent.top
    left: parent.left
  }

  Text {
    id: timeLabel
    color: "#CDD6F4"
    font {
      family: config.Font
      pointSize: 48
      bold: true
    }

    function updateTime() {
      var now = new Date()
      var hours = now.getHours().toString().padStart(2, '0')
      var minutes = now.getMinutes().toString().padStart(2, '0')
      var seconds = now.getSeconds().toString().padStart(2, '0')
      text = hours + ":" + minutes + ":" + seconds
    }

    Component.onCompleted: updateTime()

    Timer {
      interval: 1000
      repeat: true
      running: true
      onTriggered: timeLabel.updateTime()
    }
  }

  Text {
    id: dateLabel
    color: "#CDD6F4"
    font {
      family: config.Font
      pointSize: 16
      bold: false
    }
    opacity: 0.8

    function updateDate() {
      var now = new Date()
      var options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }
      text = now.toLocaleDateString('en-US', options)
    }

    Component.onCompleted: updateDate()

    Timer {
      interval: 60000
      repeat: true
      running: true
      onTriggered: dateLabel.updateDate()
    }
  }
}
